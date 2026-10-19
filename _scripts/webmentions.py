#!/usr/bin/env python3
"""Send post Webmentions after deployment, using a durable per-target ledger."""
import argparse
import hashlib
from functools import partial
from http.client import HTTPConnection, HTTPSConnection
from html.parser import HTMLParser
import ipaddress
import json
from pathlib import Path
import re
import socket
from urllib.parse import urlencode, urldefrag, urljoin, urlsplit
from urllib.request import (build_opener, getproxies, HTTPHandler, HTTPSHandler,
                            HTTPRedirectHandler, ProxyHandler, Request)

ORIGIN = 'https://dieghernan.github.io'
LIMIT = 4 * 1024 * 1024
VOID = set('area base br col embed hr img input link meta param source track wbr'.split())


def allowed(url, external=True):
    try:
        p = urlsplit(url)
        host = (p.hostname or '').lower().rstrip('.')
        return (p.scheme in ('http', 'https') and bool(host)
                and not p.username and not p.password and p.port in (None, 80, 443)
                and host != 'fed.brid.gy' and not host.endswith('.fed.brid.gy')
                and (not external or host != urlsplit(ORIGIN).hostname))
    except ValueError:
        return False


def validate_request(url):
    if not allowed(url, external=False):
        raise ValueError('Excluded URL')
    p = urlsplit(url)
    addresses = socket.getaddrinfo(p.hostname, p.port or (443 if p.scheme == 'https' else 80), type=socket.SOCK_STREAM)
    if not addresses or any(not ipaddress.ip_address(a[4][0]).is_global for a in addresses):
        raise ValueError('Non-public destination')
    return addresses


def connect_addresses(addresses, address, timeout=15, source_address=None):
    """Connect to a validated sockaddr, without resolving the hostname again."""
    last_error = None
    for family, kind, protocol, _, sockaddr in addresses:
        sock = socket.socket(family, kind, protocol)
        try:
            sock.settimeout(timeout)
            if source_address:
                sock.bind(source_address)
            sock.connect(sockaddr)
            return sock
        except OSError as error:
            sock.close()
            last_error = error
    raise last_error or OSError('No validated addresses')


class PinnedConnection:
    def __init__(self, *args, addresses, **kwargs):
        super().__init__(*args, **kwargs)
        self._create_connection = partial(connect_addresses, addresses)


class PinnedHTTPConnection(PinnedConnection, HTTPConnection):
    pass


class PinnedHTTPSConnection(PinnedConnection, HTTPSConnection):
    # HTTPSConnection keeps the original hostname for TLS SNI/certificate checks.
    pass


class PublicHTTPHandler(HTTPHandler):
    def http_open(self, req):
        connection = partial(PinnedHTTPConnection, addresses=validate_request(req.full_url))
        return self.do_open(connection, req)


class PublicHTTPSHandler(HTTPSHandler):
    def https_open(self, req):
        connection = partial(PinnedHTTPSConnection, addresses=validate_request(req.full_url))
        return self.do_open(connection, req, context=self._context)


class SafeRedirects(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        # Never replay a form submission to a redirected endpoint.
        if req.get_method() != 'GET':
            raise ValueError('Endpoint redirected the submission')
        external = urlsplit(req.full_url).hostname != urlsplit(ORIGIN).hostname
        if not allowed(newurl, external=external):
            raise ValueError('Excluded redirect destination')
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def fetch(url, data=None):
    # A forward proxy resolves destinations itself, so address pinning cannot be
    # guaranteed. Fail closed rather than bypass a configured environment proxy.
    if any(getproxies().get(key) for key in ('http', 'https', 'all')):
        raise ValueError('DNS pinning requires direct egress; configured proxies are unsupported')
    headers = {'User-Agent': 'dieghernan-Webmentions/1.0 (+https://dieghernan.github.io/)'}
    if data is not None:
        headers['Content-Type'] = 'application/x-www-form-urlencoded'
    with build_opener(ProxyHandler({}), PublicHTTPHandler(), PublicHTTPSHandler(), SafeRedirects()).open(Request(url, data=data, headers=headers), timeout=15) as r:
        body = r.read(LIMIT + 1)
        if len(body) > LIMIT:
            raise ValueError('Response too large')
        return r.geturl(), r.headers, body.decode(r.headers.get_content_charset() or 'utf-8', errors='replace')


class Page(HTMLParser):
    def __init__(self, html):
        super().__init__(convert_charrefs=True)
        self.canonical = None
        self.post = False
        self.targets = set()
        self.endpoints = []
        self.stack = []
        self.content = []
        self.depth = None
        self.schema = None
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == 'link' and 'canonical' in a.get('rel', '').lower().split():
            self.canonical = a.get('href')
        if tag in ('link', 'a') and 'webmention' in a.get('rel', '').lower().split() and a.get('href'):
            self.endpoints.append(a['href'])
        if tag == 'script' and a.get('type') == 'application/ld+json':
            self.schema = []
        if self.depth is None and 'e-content' in a.get('class', '').split():
            self.depth = len(self.stack)
        if self.depth is not None:
            self.content.append(self.get_starttag_text())
            if tag == 'a' and a.get('href'):
                self.targets.add(a['href'])
        if tag not in VOID:
            self.stack.append(tag)

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if tag not in VOID:
            self.handle_endtag(tag)

    def handle_endtag(self, tag):
        if self.depth is not None:
            self.content.append('</' + tag + '>')
        if tag in self.stack:
            pos = len(self.stack) - 1 - self.stack[::-1].index(tag)
            del self.stack[pos:]
        if self.depth is not None and len(self.stack) <= self.depth:
            self.depth = None
        if tag == 'script' and self.schema is not None:
            try:
                data = json.loads(''.join(self.schema))
                self.post |= has_post(data)
            except ValueError:
                pass
            self.schema = None

    def handle_data(self, data):
        if self.depth is not None:
            self.content.append(data)
        if self.schema is not None:
            self.schema.append(data)

    @property
    def digest(self):
        return hashlib.sha256(''.join(self.content).encode()).hexdigest()


def has_post(data):
    if isinstance(data, list):
        return any(has_post(x) for x in data)
    if isinstance(data, dict):
        types = data.get('@type', [])
        if types == 'BlogPosting' or isinstance(types, list) and 'BlogPosting' in types:
            return True
        return has_post(data.get('@graph', []))
    return False


def posts_in(site):
    posts = {}
    for path in sorted(Path(site).rglob('*.html')):
        page = Page(path.read_text())
        if not page.post or not page.canonical or not page.content:
            continue
        if not page.canonical.startswith(ORIGIN + '/'):
            raise ValueError('Unexpected canonical URL')
        targets = sorted({urldefrag(urljoin(page.canonical, t))[0] for t in page.targets
                          if allowed(urljoin(page.canonical, t))})
        posts[page.canonical] = {'digest': page.digest, 'targets': targets}
    if not posts:
        raise ValueError('No published posts found; refusing to initialize an empty ledger')
    return posts


def discover(target, request=fetch):
    final, headers, html = request(target)
    # RFC 8288 Link headers take precedence over HTML discovery.
    for header in headers.get_all('Link', []):
        for match in re.finditer(r'<([^>]+)>\s*((?:;[^,]*)*)', header):
            rel = re.search(r';\s*rel\s*=\s*(?:"([^"]*)"|([^;\s,]+))', match[2], re.I)
            if rel and 'webmention' in (rel[1] or rel[2]).lower().split():
                endpoint = urljoin(final, match[1])
                if allowed(endpoint):
                    return endpoint
    for value in Page(html).endpoints:
        endpoint = urljoin(final, value)
        if allowed(endpoint):
            return endpoint
    return None


def process(posts, state, request=fetch, checkpoint=lambda: None):
    if state is None:
        state = {'version': 1, 'posts': {
            source: {target: post['digest'] for target in post['targets']}
            for source, post in posts.items()}}
        print(f'Baseline: {len(posts)} existing posts recorded; no mentions sent.')
        return state
    if state.get('version') != 1 or not isinstance(state.get('posts'), dict):
        raise ValueError('Unknown ledger format')
    for source, post in posts.items():
        seen = state['posts'].setdefault(source, {})
        pending = [t for t in post['targets'] if seen.get(t) != post['digest']]
        if not pending:
            continue
        try:
            final, _, html = request(source)
            live = Page(html)
            if final != source or live.canonical != source or live.digest != post['digest']:
                raise ValueError('Published article does not match the deployed artifact yet')
        except Exception as error:
            print(f'Retry source {source}: {type(error).__name__}: {error}')
            continue
        for target in pending:
            try:
                endpoint = discover(target, request)
                if endpoint:
                    request(endpoint, urlencode({'source': source, 'target': target}).encode())
                    print(f'Accepted: {source} -> {target}')
                else:
                    print(f'No endpoint: {target}')
                seen[target] = post['digest']
                checkpoint()
            except Exception as error:
                print(f'Retry target {target}: {type(error).__name__}: {error}')
    return state


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--site', required=True)
    parser.add_argument('--state', required=True)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    posts = posts_in(args.site)
    path = Path(args.state)
    state = json.loads(path.read_text()) if path.exists() else None
    if args.dry_run:
        print(f'Dry run: {len(posts)} posts, {sum(len(p["targets"]) for p in posts.values())} eligible links; no requests or writes.')
        return
    def save():
        path.write_text(json.dumps(state, indent=2, sort_keys=True) + '\n')
    state = process(posts, state, checkpoint=save)
    save()


if __name__ == '__main__':
    main()
