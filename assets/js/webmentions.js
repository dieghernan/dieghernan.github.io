/* Public webmention.io data is rendered as plain text, never as HTML. */
(() => {
  const section = document.querySelector('[data-webmentions]');
  if (!section) return;
  const button = section.querySelector('[data-webmentions-load]');
  const status = section.querySelector('[data-webmentions-status]');
  const results = section.querySelector('[data-webmentions-results]');
  const reactionResults = section.querySelector('[data-webmentions-reactions]');
  const reactions = new Map();
  const seen = new Set();
  let page = 0;

  function safeURL(value) {
    try {
      const url = new URL(value);
      return ['https:', 'http:'].includes(url.protocol) ? url.href : null;
    } catch {
      return null;
    }
  }

  function render(mention) {
    if (mention['wm-private'] || mention['wm-deleted']) return;
    const url = safeURL(mention.url) || safeURL(mention['wm-source']);
    if (!url) return;
    const key = mention['wm-id'] || url;
    if (seen.has(key)) return;
    seen.add(key);
    const type = mention['wm-property'];
    const labels = { 'like-of': 'Likes', 'repost-of': 'Reposts', 'bookmark-of': 'Bookmarks' };
    if (labels[type]) {
      if (!reactions.has(type)) {
        const group = document.createElement('div');
        group.className = 'webmentions-reaction';
        const summary = document.createElement('h3');
        summary.className = 'h6';
        const list = document.createElement('ul');
        group.append(summary, list);
        reactionResults.append(group);
        reactionResults.hidden = false;
        reactions.set(type, { summary, list, count: 0 });
      }
      const group = reactions.get(type);
      const item = document.createElement('li');
      const name = mention.author?.name || new URL(url).hostname;
      const reactionLink = link('', url);
      reactionLink.title = name;
      reactionLink.setAttribute('aria-label', name);
      reactionLink.append(makeAvatar(name, mention.author?.photo));
      item.append(reactionLink);
      group.list.append(item);
      group.summary.textContent = `${labels[type]} (${++group.count})`;
      return;
    }
    const article = document.createElement('li');
    article.className = 'webmention-mention';
    const authorName = mention.author?.name || new URL(url).hostname;
    article.append(link(url, url));
    if (mention.author?.name) {
      article.append(document.createTextNode(' by '));
      article.append(link(authorName, safeURL(mention.author?.url) || url));
    }
    results.append(article);
    results.hidden = false;
  }

  function makeAvatar(authorName, photoURL) {
    const avatar = document.createElement('span');
    avatar.className = 'webmention-avatar';
    avatar.setAttribute('aria-hidden', 'true');
    avatar.textContent = authorName.trim().slice(0, 1).toUpperCase();
    const photo = safeURL(photoURL);
    if (photo && photo.startsWith('https:')) {
      const image = document.createElement('img');
      image.src = photo;
      image.alt = '';
      image.loading = 'lazy';
      image.referrerPolicy = 'no-referrer';
      image.addEventListener('error', () => image.remove());
      avatar.append(image);
    }
    return avatar;
  }

  function link(text, url) {
    const anchor = document.createElement('a');
    anchor.href = url;
    anchor.rel = 'nofollow ugc noopener';
    anchor.textContent = text;
    return anchor;
  }

  async function loadMentions() {
    button.disabled = true;
    status.textContent = 'Loading mentions…';
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 15000);
    try {
      const endpoint = new URL('https://webmention.io/api/mentions.jf2');
      endpoint.search = new URLSearchParams({
        target: section.dataset.target, 'per-page': '100', page: String(page),
        'sort-dir': 'up'
      });
      const response = await fetch(endpoint, { signal: controller.signal, credentials: 'omit', referrerPolicy: 'no-referrer' });
      if (!response.ok) throw new Error('Could not load mentions');
      const feed = await response.json();
      if (!Array.isArray(feed.children)) throw new Error('Invalid feed');
      feed.children.forEach(render);
      page += 1;
      const more = feed.paging?.['total-pages']
        ? page < feed.paging['total-pages'] : feed.children.length === 100;
      button.hidden = !more;
      button.textContent = 'Load more mentions';
      status.textContent = seen.size ? `${seen.size} ${seen.size === 1 ? 'mention' : 'mentions'}` : 'No mentions yet. Linked to this post? Share your page below.';
      status.classList.toggle('webmentions-empty', seen.size === 0);
    } catch {
      status.textContent = 'Mentions could not be loaded. Please try again.';
      button.hidden = false;
      button.textContent = 'Try again';
    } finally {
      clearTimeout(timeout);
      button.disabled = false;
    }
  }

  button.addEventListener('click', loadMentions);
  loadMentions();
})();
