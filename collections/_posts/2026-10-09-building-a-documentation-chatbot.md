---
title: 'Building a documentation chatbot for <span class="chulapa">Chulapa</span>'
subtitle: "A development diary: context, small screens and useful answers"
excerpt: "How I built an AI assistant for my theme's documentation, and what happened when I started asking it real questions."
tags:
  - jekyll
  - html
  - chulapa
header_img: /assets/img/blog/202610-chatbot-header.webp
schema_image: /assets/img/blog/202610-chatbot-header.webp
og_image_width: 1730
og_image_height: 909
og_image_type: "image/webp"
og_image_alt: "Paper collage of an open notebook with code-like marks, floating conversation shapes and golden sparkles beside a window overlooking Madrid."
---

This website uses my **Jekyll** theme,
[<span class="chulapa">Chulapa</span>](https://dieghernan.github.io/chulapa). Some time ago, I
started wondering whether I could add a chatbot to its documentation. The docs
already explain the settings, layouts and snippets, but you sometimes need to
know what a feature is called before finding it. Could I make that a little
easier?

The idea was simple: ask a question, get a useful example and follow a link to
the original docs. With [**Codex**](https://learn.chatgpt.com/learn/codex),
OpenAI's coding agent, I had an initial version working on the page in
**less than an hour**: I could open the widget, send a question and read its
answer. That was the prototype, though. Checking its answers and making it
behave properly on a phone took quite a few more rounds.

## Start with a prototype, then decide where it belongs

I started with references rather than an empty editor. The [freeCodeCamp
tutorial on an embeddable
chatbot](https://www.freecodecamp.org/news/how-to-build-an-embeddable-ai-chatbot-widget-with-cloudflare-workers/)
provided a practical starting point for a browser widget backed by
**Cloudflare Workers**. I also liked the visual approach in [Malte Grosser's chatbot
post](https://www.malte-grosser.com/post/adding-a-free-ai-chatbot/).

I built the implementation with **Codex**. I described what I wanted, supplied
those references and asked it to inspect the existing theme and documentation.
There were three pieces to work on: the widget visitors use in the browser,
the Worker that processes requests on Cloudflare and the context, a summary of
the documentation supplied to the model. We worked through them together. I tested
the page, asked the chatbot questions and brought back screenshots when
something looked wrong. **Codex** helped turn that feedback into code changes.

Working this way let me spend more time trying the assistant as a visitor
would: does this answer help
me configure my site? Can I read it with the keyboard open? What happens after a
long conversation?

At first, I considered adding the chatbot as a theme feature. That quickly felt
like too much to ask of someone who just wants a **Jekyll** site. An AI account, a
separate backend and a maintained knowledge summary would become part of their
setup.

So I kept it as an extension of the theme's documentation site. The
[implementation and evaluation
files](https://github.com/dieghernan/chulapa/tree/main/docs/ai-chatbot) live
under `docs/ai-chatbot/` in the theme repository. Someone using the theme does
not need to set up a Worker or maintain an AI context. This also gives me room
to experiment without making every experiment part of the template.

## A static site with a separate AI backend

**Jekyll** builds the static documentation pages. I chose a separate service
to process the chatbot's questions. A script loads the chat
widget, and a **Cloudflare Worker** serves the widget and handles questions. The
Worker sends the question, instructions and a reviewed documentation summary to
**Workers AI**, Cloudflare's service for running AI models, then returns the
answer to the browser.

The model currently configured is **Gemma**, using the identifier
`@cf/google/gemma-4-26b-a4b-it`. The Worker accesses it through an `AI` binding:
a connection configured in Cloudflare that lets the Worker call **Workers AI**.
That connection stays on the server side, so visitors do not receive an API key.
**Codex** helped me build and test the implementation; **Gemma** is the model
that answers visitors' questions.

There is no automatic document retrieval in this implementation. The context is
a Markdown file maintained alongside the code. Adding a documentation URL or the
RSS feed URL gives the model a reference to share; it does not make the Worker
download that page or discover new posts.

That was an intentional starting point. I can inspect exactly which facts the
assistant receives, and updating it does not require a vector database or a
document indexing pipeline. The tradeoff is that I have to keep that summary
current.

Making the answers readable was another part of the interface work. They
arrive as Markdown, which **Marked** converts to HTML for lists, code blocks
and links. **DOMPurify** then removes potentially dangerous HTML before the
answer is displayed. Visitors can copy code and follow permitted documentation
links. Mentions of the theme use its `chulapa` class, while code and
configuration identifiers retain their original formatting.

## The first answers exposed the missing context

One of my first questions was: “Can I add video here?” The answer did not really
help. I knew the docs explained how to do it, so I asked **Codex** to check what the
assistant was receiving. The summary needed the video snippet and its options,
not just a general mention that videos were supported.

Another exchange made the problem particularly obvious. The theme has built-in
skins that change the site's visual appearance. I asked how to change a skin,
and the assistant explained `chulapa-skin.skin`. Then I asked which skins
were available. It replied that there were more than 40, but gave no names. That
was related to the question, yet it did not help me choose anything.

I added actual skin names and a link to the visual catalog to the context,
along with an instruction to give examples when someone asks what is available.
In the follow-up tests, the assistant returned skin names and a link to the
catalog instead of just repeating the number of choices. That was a useful
improvement I could check directly, even though other answers still needed work.
For
configuration questions, a small complete example is often more useful than
another paragraph. For example, this goes in the site's `_config.yml` to
select the `darkly` skin:

```yaml
chulapa-skin:
  skin: darkly
```

I expanded the summary selectively: installation, configuration, layouts,
videos, galleries, navigation, search, comments, SEO and the FAQ. Later passes
added Sass variables and Markdown guidance. I tried to include the details that
let someone act: exact option names, defaults, a short example and the right
source page.

Copying all the docs into the prompt would have been easier to automate. It
would also make each request larger and leave plenty of irrelevant information
competing with the answer. The goal was informative help with a manageable
context, rather than the longest possible context.

## Testing questions instead of counting successful requests

I asked **Codex** to work through the documentation in batches and send basic and
advanced questions to the live assistant. Installation and skin changes were
only the beginning. We also checked project-site URLs, favicons, local videos,
galleries, highlighting and combinations of settings. I reviewed the results and
used the weak answers to decide where the context needed more detail.

I also asked **Codex** to look for real user questions in the
[Issues](https://github.com/dieghernan/chulapa/issues) and
[Discussions](https://github.com/dieghernan/chulapa/discussions) of the
<span class="chulapa">Chulapa</span> repository. These helped us test the
assistant with the wording people actually use when they get stuck, rather
than only questions based on documentation headings. We used those questions
to prepare evaluation cases and checked the answers against the docs. Feature
requests needed particular care: someone asking for an option does not mean
the theme already supports it.

We added an evaluation script that sends questions to the live assistant in
batches and saves the full responses. That gives me a record to review for
the explanation, code and source links. A successful HTTP response only means that the request
worked. It says nothing about whether the YAML is correct, the answer covers
every part of the question or the link points to the right page.

Some failures were subtle: a plausible option in the wrong place, an incomplete
example or a source link with an invented anchor. Follow-up tests helped target
those weaknesses. I also included unsupported features and unrelated questions
to check whether the assistant would acknowledge missing information.

This process is sometimes called “training the chatbot,” but I did not train or
fine-tune the model. I improved the supplied context and instructions, then
tested the resulting answers. Those changes can help, but they do not guarantee
that every future response will be correct.

## A chat history that does not become model memory

The widget keeps recent messages in the tab's session storage, making it easier
to return to an answer while browsing. Each request to the model is independent,
however: earlier messages are not sent with the next question. This started as
a limitation of the prototype, rather than a deliberate choice to rule out
conversational memory, and remains a limitation of the version described here.
Keeping the history visible does not change what the backend sends to the model.

That distinction needed to be visible. A familiar chat interface naturally
invites questions such as “And what about that one?” Here, it is better to ask a
complete question. I added that guidance near the input and a clear-chat control
for the local history.

## The phone found problems the desktop missed

The interface took several rounds of testing on a real phone. Opening the
keyboard could zoom the page or leave the panel clipped. Rotating the phone made
the available space even smaller. A desktop browser resized to a narrow width
was useful, but it did not reproduce all of those behaviors.

The input now uses a mobile-friendly text size, and the panel follows the
space actually visible on screen when the keyboard opens. That available area
is called the visual viewport; using it helps the panel fit above the keyboard.
Opening the chat on mobile does not automatically focus the input and summon
the keyboard.

Long conversations revealed another bug: a second scrollbar appeared on the
outer panel, followed by a large empty area below the form. Constraining the
message log and clipping its paint overflow kept scrolling inside the history,
with the header and question form visible.

The button that opens the chatbot also had to coexist with the theme's floating
menu button and its separate table-of-contents control. After trying different
positions, I settled on stacking the chatbot button above the menu button on
smaller screens, matching its size and right margin, with a gap between them.
Small alignment differences were much more
noticeable than I expected.

I wanted the launcher to fit the site visually and still be easy to recognize.
We tried a robot icon first, then settled on a small sparkle SVG for opening
the assistant and a paper-plane icon for sending a question. The SVG uses
`currentColor`, so its color follows the button's CSS instead of being fixed
inside the image. That makes it easier to keep the icon consistent with the
rest of the control.

## Limits and maintenance are part of the implementation

I wanted to keep the experiment within the Free account's allowance, including
the requests we sent while testing. The Worker has input checks, a bounded
response length and a rate-limit binding
configured for five requests per IP per minute. Live testing eventually produced
a rejection, but it also showed that the cutoff was not exactly the sixth
request. Cloudflare describes this limiter as approximate and local to each
location, meaning a Cloudflare data center, in its [Rate Limiting API
documentation](https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/).
It is useful protection, not an exact global usage counter.

The per-IP limit controls how often a visitor can send questions; the account's
quota limits total AI usage. I kept the account on the Free plan without
configuring a paid alternative to continue answering when its allowance runs
out. The current allowances are listed in
[Cloudflare's **Workers AI** pricing](https://developers.cloudflare.com/workers-ai/platform/pricing/).

To maintain this implementation, I run these commands from the
<span class="chulapa">Chulapa</span> repository:

```sh
cd docs/ai-chatbot
npm ci
npm run build
npm test
npx wrangler deploy
```

These commands build, test and deploy the existing Worker; they are not a
complete installation guide for a new chatbot. A **GitHub Pages** deployment
publishes the documentation, while `wrangler deploy` updates the assistant.
Changes to the context reach the live model only after rebuilding and deploying
the Worker.

I also added an `AGENTS.md` file with repository instructions for **Codex** and
other coding agents: when documentation changes, review the assistant's context
and relevant evaluation cases. That makes this check part of the work on the
docs, instead of something I have to remember afterward.

## What I want this assistant to do well

I want someone to ask a practical question, receive an informative answer and
leave with a working example or a useful documentation link. There are still
limitations: independent questions require enough detail, combined questions can
lose a part of the answer, and source links need continued checking.

You can try it on the
[<span class="chulapa">Chulapa</span> documentation site](https://dieghernan.github.io/chulapa/docs). Open the sparkle button and
ask a complete question about your setup. I would love to hear which answers
helped and which ones sent you back to the docs!

The most useful part of the process was trying the assistant with questions I
already knew how to answer. It made the gaps easy to spot: an answer could sound
reasonable and still leave me without the setting or example I needed. That is
what I want to keep checking as the documentation grows.

<div class="alert alert-info p-3 mx-2 mb-3" role="note">
<p><strong>AI assistance:</strong> I wrote this post with help from
<strong>Codex</strong>, including drafting and editing the text. I reviewed it
against the implementation and my experience building the chatbot. The header
illustration was also generated with AI.</p>
</div>
