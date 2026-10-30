"""Offline tests: no external notifications or HTTP requests."""
from email.message import Message
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch
from urllib.parse import parse_qs
from urllib.request import Request

import webmentions as wm

SOURCE = wm.ORIGIN + '/new-post/'
TARGET = 'https://other.example/post/'
ENDPOINT = 'https://receiver.example/webmention'
BRIDGY = 'https://fed.brid.gy/'


def article(body, source=SOURCE, extra=''):
    return (f'<html><head><link rel="canonical" href="{source}">'
            '<script type="application/ld+json">{"@type":"BlogPosting"}</script>'
            '</head><body><nav><a href="https://nav.example/">Nav</a></nav>'
            f'{extra}<article class="e-content">{body}</article>'
            '<footer><a href="https://footer.example/">Footer</a></footer></body></html>')


class WebmentionsTests(unittest.TestCase):
    def setUp(self):
        self.html = article(f'<p>Hello <a href="{TARGET}#section">world</a></p>')
        self.post = {'digest': wm.Page(self.html).digest, 'targets': [TARGET]}
        self.posts = {SOURCE: self.post}
        self.calls = []

    def request(self, url, data=None):
        self.calls.append((url, data))
        if url == SOURCE:
            return url, Message(), self.html
        if url == TARGET:
            return url, Message(), f'<link rel="webmention" href="{ENDPOINT}">'
        if url == ENDPOINT:
            self.assertEqual(parse_qs(data.decode()), {'source': [SOURCE], 'target': [TARGET]})
            return url, Message(), ''
        self.fail(url)

    def test_first_run_sends_existing_links_once(self):
        state = wm.process(self.posts, None, request=self.request)
        self.assertEqual(state['version'], 3)
        self.assertEqual(state['posts'][SOURCE][TARGET], self.post['digest'])
        self.assertEqual(len(self.calls), 3)
        wm.process(self.posts, state, request=self.request)
        self.assertEqual(len(self.calls), 3)

    def test_new_post_sends_once_and_edited_post_resends(self):
        state = {'version': 3, 'posts': {}}
        wm.process(self.posts, state, request=self.request)
        self.assertEqual(len(self.calls), 3)
        wm.process(self.posts, state, request=self.request)
        self.assertEqual(len(self.calls), 3)
        self.html = self.html.replace('Hello', 'Updated')
        self.post['digest'] = wm.Page(self.html).digest
        wm.process(self.posts, state, request=self.request)
        self.assertEqual(len(self.calls), 6)

    def test_failed_submission_remains_pending(self):
        def fail(url, data=None):
            if data:
                raise TimeoutError('receiver unavailable')
            return self.request(url, data)
        state = {'version': 3, 'posts': {}}
        wm.process(self.posts, state, request=fail)
        self.assertNotIn(TARGET, state['posts'][SOURCE])
        wm.process(self.posts, state, request=self.request)
        self.assertIn(TARGET, state['posts'][SOURCE])

    def test_stale_live_article_is_not_sent(self):
        state = {'version': 3, 'posts': {}}
        self.html = self.html.replace('Hello', 'Old')
        wm.process(self.posts, state, request=self.request)
        self.assertEqual(self.calls, [(SOURCE, None)])
        self.assertEqual(state['posts'][SOURCE], {})

    def test_link_headers_preserve_quoted_separators_and_escapes(self):
        cases = [
            f'<{ENDPOINT}>; title="Webmention, endpoint"; rel="webmention"',
            f'<https://ignored.example/>; title="Other, link"; rel="alternate", <{ENDPOINT}>; rel=webmention',
            f'<{ENDPOINT}>; title="A; B, C"; rel="alternate Webmention"',
            '<' + ENDPOINT + r'>; title="A \"quoted, endpoint\""; rel="webmention"',
            f'<{ENDPOINT}>; rel="webmention"; title="A, B", <https://ignored.example/>; rel=alternate',
        ]
        for header in cases:
            with self.subTest(header=header):
                headers = Message()
                headers['Link'] = header
                self.assertEqual(wm.discover(TARGET, lambda u: (TARGET, headers, '')), ENDPOINT)
        headers = Message()
        headers['Link'] = f'<{ENDPOINT}?options=a,b>; title="Comma in URI"; rel=webmention'
        self.assertEqual(wm.discover(TARGET, lambda u: (TARGET, headers, '')), ENDPOINT + '?options=a,b')

    def test_quoted_title_cannot_supply_a_false_relation(self):
        headers = Message()
        headers['Link'] = '<https://ignored.example/>; title="A; rel=webmention, B"; rel=alternate'
        self.assertIsNone(wm.discover(TARGET, lambda u: (TARGET, headers, '')))
        headers['Link'] = f'<{ENDPOINT}>; title="Webmention, endpoint"; rel="webmention"'
        self.assertEqual(wm.discover(TARGET, lambda u: (TARGET, headers, '')), ENDPOINT)

    def test_legacy_baseline_is_rebuilt_once_and_checkpointed_before_sending(self):
        for version in (1, 2):
            with self.subTest(version=version):
                self.calls = []
                state = {'version': version, 'posts': {SOURCE: {TARGET: self.post['digest']}}}
                checkpoints = []
                def save():
                    checkpoints.append((state['version'], bool(state['posts']), len(self.calls)))
                returned = wm.process(self.posts, state, request=self.request, checkpoint=save)
                self.assertIs(returned, state)
                self.assertEqual(checkpoints[0], (3, False, 0))
                self.assertEqual(len(self.calls), 3)
                wm.process(self.posts, state, request=self.request)
                self.assertEqual(len(self.calls), 3)

    def test_interrupted_rebuild_retains_progress_and_failed_targets(self):
        state = {'version': 2, 'posts': {SOURCE: {TARGET: self.post['digest']}}}
        def fail(url, data=None):
            if data:
                raise TimeoutError('unavailable')
            return self.request(url, data)
        wm.process(self.posts, state, request=fail)
        self.assertEqual(state['version'], 3)
        self.assertNotIn(TARGET, state['posts'][SOURCE])
        wm.process(self.posts, state, request=self.request)
        self.assertIn(TARGET, state['posts'][SOURCE])

    def test_no_endpoint_is_recorded(self):
        def unsupported(url, data=None):
            return url, Message(), self.html if url == SOURCE else '<p>No endpoint</p>'
        state = {'version': 3, 'posts': {}}
        wm.process(self.posts, state, request=unsupported)
        self.assertIn(TARGET, state['posts'][SOURCE])

    def test_header_discovery_precedes_relative_html_endpoint(self):
        headers = Message()
        headers['Link'] = '<https://ignored.example/>; rel="alternate", </wm>; rel="other webmention"'
        result = wm.discover(TARGET, lambda u: (TARGET, headers, f'<a rel="webmention" href="{ENDPOINT}">'))
        self.assertEqual(result, 'https://other.example/wm')
        result = wm.discover(TARGET, lambda u: (TARGET, Message(), '<a rel="webmention" href="../wm">'))
        self.assertEqual(result, 'https://other.example/wm')

    def test_bridgy_host_is_allowed_but_subdomains_are_excluded(self):
        self.assertTrue(wm.allowed(BRIDGY))
        self.assertTrue(wm.allowed('https://fed.brid.gy/webmention'))
        for host in ('sub.fed.brid.gy', 'SUB.FED.BRID.GY.'):
            html = f'<link rel="webmention" href="https://{host}/wm">'
            self.assertIsNone(wm.discover(TARGET, lambda u: (TARGET, Message(), html)))
        html = f'<link rel="webmention" href="{wm.ORIGIN}/wm">'
        self.assertIsNone(wm.discover(TARGET, lambda u: (TARGET, Message(), html)))
        self.assertFalse(wm.allowed('https://fed.brid.gy@fed.brid.gy/wm'))
        self.assertFalse(wm.allowed('javascript:alert(1)'))
        self.assertFalse(wm.allowed('https://?query'))

    def test_redirects_allow_bridgy_but_block_subdomains_and_post_replay(self):
        handler = wm.SafeRedirects()
        redirected = handler.redirect_request(Request(TARGET), None, 302, '', {}, 'https://fed.brid.gy/wm')
        self.assertEqual(redirected.full_url, 'https://fed.brid.gy/wm')
        with self.assertRaises(ValueError):
            handler.redirect_request(Request(TARGET), None, 302, '', {}, 'https://sub.fed.brid.gy/wm')
        with self.assertRaises(ValueError):
            handler.redirect_request(Request(ENDPOINT, data=b'x'), None, 307, '', {}, TARGET)
        with self.assertRaises(ValueError):
            handler.redirect_request(Request(TARGET), None, 302, '', {}, SOURCE)

    def test_chulapa_targets_and_redirects_are_allowed(self):
        for path in ('/chulapa', '/chulapa/', '/chulapa/docs/01-install'):
            self.assertTrue(wm.allowed(wm.ORIGIN + path))
        for path in ('/', '/chulapa-other/', '/202610_webmentions/'):
            self.assertFalse(wm.allowed(wm.ORIGIN + path))
        handler = wm.SafeRedirects()
        target = wm.ORIGIN + '/chulapa'
        redirected = handler.redirect_request(Request(target), None, 301, '', {}, target + '/')
        self.assertEqual(redirected.full_url, target + '/')
        html = f'<link rel="webmention" href="{wm.ORIGIN}/chulapa/receiver">'
        self.assertEqual(wm.discover(target, lambda u: (target, Message(), html)),
                         wm.ORIGIN + '/chulapa/receiver')
        for path in ('/', '/202610_webmentions/'):
            with self.assertRaises(ValueError):
                handler.redirect_request(Request(target), None, 302, '', {}, wm.ORIGIN + path)

    def test_valueless_html_attributes_do_not_break_discovery(self):
        html = ('<link rel><a rel href="https://example.org/">Link</a>'
                '<div class><script type></script></div>'
                f'<link rel="webmention" href="{ENDPOINT}">')
        self.assertEqual(wm.discover(TARGET, lambda u: (TARGET, Message(), html)), ENDPOINT)
        page = wm.Page(article('<p class>Hello</p>'))
        self.assertEqual(page.canonical, SOURCE)
        self.assertEqual(page.post, True)

    def test_private_address_rejected(self):
        private = [(2, 1, 6, '', ('127.0.0.1', 443))]
        with patch.object(wm.socket, 'getaddrinfo', return_value=private):
            with self.assertRaises(ValueError):
                wm.validate_request(TARGET)

    def test_relation_tokens_are_case_insensitive(self):
        for token in ('Webmention', 'WEBMENTION', 'webmention'):
            for tag in ('link', 'a'):
                html = f'<{tag} rel="alternate {token}" href="{ENDPOINT}">'
                self.assertEqual(wm.discover(TARGET, lambda u: (TARGET, Message(), html)), ENDPOINT)
            headers = Message()
            headers['Link'] = f'<{ENDPOINT}>; REL="alternate {token}"'
            self.assertEqual(wm.discover(TARGET, lambda u: (TARGET, headers, '')), ENDPOINT)

    def test_connections_pin_validated_address_and_preserve_tls_hostname(self):
        public = [(wm.socket.AF_INET, wm.socket.SOCK_STREAM, 6, '', ('93.184.216.34', 443))]
        private = [(wm.socket.AF_INET, wm.socket.SOCK_STREAM, 6, '', ('127.0.0.1', 443))]
        for handler, scheme in ((wm.PublicHTTPHandler(), 'http'), (wm.PublicHTTPSHandler(), 'https')):
            with self.subTest(scheme=scheme):
                sock = Mock()
                context = Mock()
                handler._context = context
                def open_connection(factory, req, **kwargs):
                    connection = factory('other.example', timeout=15, **kwargs)
                    connection.connect()
                    self.assertEqual(connection.host, 'other.example')
                with patch.object(wm.socket, 'getaddrinfo', side_effect=[public, private]) as dns, \
                     patch.object(wm.socket, 'socket', return_value=sock), \
                     patch.object(handler, 'do_open', side_effect=open_connection):
                    getattr(handler, scheme + '_open')(Request(scheme + '://other.example/post/'))
                self.assertEqual(dns.call_count, 1)
                sock.connect.assert_called_once_with(('93.184.216.34', 443))
                if scheme == 'https':
                    context.wrap_socket.assert_called_once_with(sock, server_hostname='other.example')

    def test_redirect_destination_is_validated_before_any_connection(self):
        handler = wm.SafeRedirects()
        redirected = handler.redirect_request(Request(TARGET), None, 302, '', {}, 'https://redirect.example/')
        private = [(wm.socket.AF_INET, wm.socket.SOCK_STREAM, 6, '', ('127.0.0.1', 443))]
        with patch.object(wm.socket, 'getaddrinfo', return_value=private), \
             patch.object(wm.socket, 'socket') as create_socket:
            with self.assertRaises(ValueError):
                wm.PublicHTTPSHandler().https_open(redirected)
        create_socket.assert_not_called()

    def test_proxy_is_rejected_without_bypassing_it(self):
        with patch.object(wm, 'getproxies', return_value={'https': 'http://proxy.example:8080'}), \
             patch.object(wm, 'build_opener') as opener:
            with self.assertRaisesRegex(ValueError, 'direct egress'):
                wm.fetch(TARGET)
        opener.assert_not_called()

    def test_generated_posts_only_and_article_links_only(self):
        body = (f'<p><a href="{TARGET}#a">A</a><a href="{TARGET}#b">B</a>'
                '<a href="/internal/">Own site</a><a href="https://fed.brid.gy/web/a">Fed</a>'
                '<a href="/chulapa/docs/01-install">Chulapa</a>'
                '<a href="/chulapa-other/">Internal</a>'
                '<a href="mailto:a@example.com">Mail</a><img src="https://image.example/a.png"></p>')
        with tempfile.TemporaryDirectory() as folder:
            Path(folder, 'post.html').write_text(article(body))
            Path(folder, 'page.html').write_text(article(body).replace('BlogPosting', 'WebPage'))
            project = article(body, source=wm.ORIGIN + '/projects/example/')
            Path(folder, 'project.html').write_text(project.replace('BlogPosting', 'WebPage'))
            posts = wm.posts_in(folder)
        expected = [wm.ORIGIN + '/chulapa/docs/01-install', TARGET, 'https://fed.brid.gy/web/a']
        self.assertEqual(posts[SOURCE]['targets'], expected)
        self.assertEqual(posts[wm.ORIGIN + '/projects/example/']['targets'], expected)

    def test_bridgy_trigger_outside_e_content_is_collected(self):
        extra = '<a class="u-bridgy-fed" href="https://fed.brid.gy/" hidden></a>'
        html = article('<p>No external links</p>', extra=extra)
        page = wm.Page(html)
        self.assertNotIn(BRIDGY, page.targets)
        self.assertIn(BRIDGY, page.bridgy_targets)
        with tempfile.TemporaryDirectory() as folder:
            Path(folder, 'post.html').write_text(html)
            posts = wm.posts_in(folder)
        self.assertEqual(posts[SOURCE]['targets'], [BRIDGY])

    def test_invalid_state_and_empty_site_fail_closed(self):
        with self.assertRaises(ValueError):
            wm.process(self.posts, {'version': 9, 'posts': {}})
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaises(ValueError):
                wm.posts_in(folder)


if __name__ == '__main__':
    unittest.main()
