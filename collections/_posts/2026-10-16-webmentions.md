---
title: "Conversations across the web with Webmentions"
subtitle: "Bringing mentions, likes and reposts back to the blog"
excerpt: "A small addition to my Jekyll blog, inspired by Matt Hobbs: Webmentions with a Chulapa look."
tags:
  - jekyll
  - html
  - chulapa
  - indieweb
header_img: /assets/img/blog/202610-webmentions-header-photo.webp
schema_image: /assets/img/blog/202610-webmentions-header-photo.webp
og_image_width: 1727
og_image_height: 911
og_image_type: "image/webp"
og_image_alt: "Laptop displaying a blog on a wooden desk beside a window, with an open notebook, a pen and potted plants."
---

Conversations about a blog post often happen somewhere else. Someone shares a
link, replies on their own site or reacts to a post on social media. I wanted
to bring some of that activity back here.

This implementation was directly inspired by **Matt Hobbs's article,
"Implementing Webmentions on this blog," published on Nooshu**:

<https://nooshu.com/blog/2019/11/18/implementing-webmentions/>

I liked its simple presentation: links to mentions and replies,
followed by small groups of avatars for likes and reposts. So I added a
similar section to this blog, using the typography, colors and buttons from
[<span class="chulapa">Chulapa</span>](https://dieghernan.github.io/chulapa).

## How it works

A Webmention is a notification that one page links to another. If you write
about one of my posts on your own site, you can send its URL so the link can
appear below the original article.

This blog already advertised a **webmention.io** endpoint. The missing piece
was displaying the mentions it had collected. A small JavaScript file now
requests the public mentions for each post's canonical URL and builds the
section automatically when the page opens.

Mentions and replies appear as a numbered list of links and authors. Likes
and reposts have their own counts and rows of overlapping avatars. The
content stays on its original site; each link takes you to the conversation.
The existing GitHub comments are still available, too.

## A small addition to a static blog

The implementation uses a Jekyll include, a stylesheet and plain JavaScript.
There is no extra Jekyll plugin or change to the deployment workflow.
**Webmention.io** handles receiving and verifying links, while the browser
loads the results through its public API.

I tried it with the [geobounds post]({% post_url 2026-02-12-geobounds %}),
which already had mentions, and with a recent post that had none. Both cases
matter: an empty section should still explain how to join in.

Social reactions need a bridge that sends them as Webmentions; they do not
appear automatically just because a link was shared on a social network.

## Send a link

Written something that links to this post? Open **Shared your thoughts on this
post? Drop your link here!** below and submit your page's URL. The form works
without JavaScript, although displaying existing mentions requires it.

Thanks to **Matt Hobbs** for the inspiration and for sharing his
[implementation](https://gist.github.com/Nooshu/121e5bf7f3d5c6528413c57db257894f).
It is a nice way to let a static blog take part in a wider conversation.

<div class="alert alert-info p-3 mx-2 mb-3" role="note">
<p><strong>AI assistance:</strong> I wrote this post with help from
<strong>Codex</strong>, including drafting and editing the text. Codex also
helped implement and test the Webmentions section. The header image was
generated with AI and depicts a fictional workspace.</p>
</div>
