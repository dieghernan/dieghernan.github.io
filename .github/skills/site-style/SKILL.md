---
name: site-style
description: Apply One World's house style to Jekyll posts, project pages and their Rmd sources, including absolute links, Chulapa alerts, tags, accessible figures, references and YAML chunk options. Complements generic proofreading rather than replacing it.
---

# One World house style

## Scope and precedence

Use with `.github/agents/site-editor.agent.md`. This skill owns site-specific
editorial and publication consistency. Generic spelling and grammar reviews
remain the job of the installed `review-docs` agent and `proofread-docs` skill.
Do not install a local namesake or copy their general review procedures here.

The user's current instructions override these defaults. Apply changes only to
the requested documents and their relevant source/output pairs, not to the whole
archive. Preserve unrelated working edits, deletions and historical content.
Existing posts contain exceptions and legacy inconsistencies, so a pattern found
once is not automatically a house rule.

Before editing, read the target, its source/output counterpart, relevant front
matter and the current render helper. For new writing, compare a recent post
with a similar purpose. See [publication details and
examples](references/publication.md) for Chulapa markup, reference templates and
chunk conversion. Read [preference provenance](references/provenance.md) when
resolving an apparent conflict or checking whether a rule was explicitly
requested.

## Language and voice

- Write posts and project descriptions in US English. Preserve official names,
  original publication titles and accurate quoted material in their language.
- Use sentence case for titles, subtitles, section headings and reader-facing
  metadata, including SEO and social titles, excerpts and descriptions. Keep
  the established capitalization of proper names, official titles, acronyms,
  package names and code identifiers. Use lowercase after a dash or colon
  when the phrase continues the same thought, as in `Gallery: size of a map`.
- Omit the Oxford comma and avoid semicolons in prose. Preserve semicolons
  needed in executable code or exact quotations.
- Keep explanations concise, approachable and practical. Explain what each
  important step does and why. Preserve natural questions, occasional cultural
  references and light humor when they fit the user's draft. Avoid adding a joke
  or an elaborate metaphor to every transition.
- Prefer short paragraphs and wrap prose near 80 columns. Preserve URLs, code,
  tables, YAML structure and significant Markdown spacing. Remove accidental
  double spaces, identical consecutive prose/comment lines and excess blank
  lines without damaging lists or chunk/front-matter boundaries.
- In prose, bold software and R package names: **R**, **Python**, **QGIS**,
  **Jekyll**, **Chulapa**, **sf**, **giscoR**, **ggplot2**. A linked name is
  `[**giscoR**](https://ropengov.github.io/giscoR/)`. Preserve exact casing. Use
  `<strong>` in titles requiring HTML. Keep descriptions, tags, alt text and
  plot labels plain where Markdown would appear literally. Bold names in visible
  captions too when their markup supports it.
- Put function names, arguments, object names and paths in backticks, such as
  `st_voronoi()`, `country` and `postal_points`. Do not bold package names
  inside executable code or change official titles in bibliographic records.

## Absolute links

All authored web links and image URLs in posts/projects must be fully qualified,
including those in Rmd sources and front matter. Internal site URLs start with
`https://dieghernan.github.io/`. Include `header_img`, `og_image`,
`schema_image`, image `src`/`srcset`, HTML links and reference definitions.

Resolve links against the actual page permalink, preserving case, fragments,
queries and canonical slash conventions. A same-page fragment can use the full
page URL plus `#section`. Keep genuine external project, DOI, documentation and
asset hosts unchanged. Do not prepend the blog domain to external sites.

Distinguish browser URLs from filesystem paths used by R. A cache directory,
`source()` path or `st_write()` destination stays a local path. Do not rewrite
code examples, `mailto:` or `tel:` as HTTP links. Preserve Jekyll routing fields
such as `permalink` and navbar configuration. Check resolved metadata URLs
without blindly expanding Liquid expressions or altering templates. A temporary
local-preview URL override must not leak into committed content.

## Accessible figures

Every image requires meaningful alt text, including Markdown/HTML images, linked
images, screenshots and header/featured images. Keep `fig-alt`, generated
`<img alt>` and social-preview `og_image_alt` consistent with the actual image.
Alt text conveys the important visual relationships or result.

In posts, leave figures produced by the author without visible captions. Use
`fig-cap: ""` where needed to override an inherited caption. When a post includes
a figure produced by someone else, a visible caption is optional and can give
the source, credit or context. Keep meaningful alt text in either case and
preserve necessary attribution in the caption, surrounding prose or references.
Do not redraw plots or remove credits embedded in the image during a style-only
task.

The caption rule above applies to posts. Project pages retain the earlier
requirement for a descriptive visible caption alongside alt text until the user
changes that requirement too. Keep caption text distinct from alt text, using
the existing theme support rather than adding new theme code.

When points, labels, categories or legends change, update all affected prose,
counts, alt texts, project captions and metadata. Reserve any stated
missing-data color for missing data. Do not change a palette during a prose-only
review, but flag ambiguities. Prefer WebP for generated raster maps using the
existing helper. Preserve aspect ratios, explicit chunk dimensions, titles and
legends. If image processing is authorized, crop outer blank margins before
conversion without stretching the plot, and measure social-image dimensions on
the final file.

## Front matter, alerts and references

- Require relevant tags on every post and project, matching the existing
  vocabulary and exact spelling. Select by content, not a fixed universal list.
  Keep the Rmd and Markdown tag lists aligned.
- Require explicit, nonempty `excerpt` and `description` fields in the front
  matter of every post, draft and project page. Write `excerpt` as a reader-facing
  teaser for Chulapa's listing cards and `description` as a concise summary for
  search and social metadata. The wording can differ to suit each purpose.
  Keep each field synchronized between the Rmd source and its generated
  Markdown counterpart.
- Check title, subtitle, image paths and alt metadata.
  Measure dimensions if authorized, otherwise flag stale values. Do not invent
  syndication URLs, project dates, dataset versions or publication status.
- Use Chulapa/Kramdown alert markup, not Quarto callouts, GitHub admonitions or
  custom CSS. Match severity to the message. See the publication reference.
- Use APA 7 for bibliographic entries and alphabetize by author in a
  `## References` section. Keep Markdown bullets and inline links in the
  article. Keep matching references identical in Rmd and Markdown and reuse
  the same entry across posts, projects and drafts for the same work and version.
  See the publication reference for identifier checks and mobile-friendly links.
- A 403, timeout or crawler failure is not proof of a dead link. Do not remove
  an attribution or silently replace a historical source with a newer edition.
  See the existing `_maintenance/` audits before reopening settled decisions.

## Rmd source and generated Markdown

R-based posts have an editable, reproducible source in `_Rmd/` and a matching
Markdown article in `collections/_posts/` or `collections/_drafts/`. Project
pages live in `collections/_projects/` and need no artificial Rmd counterpart.
Keep titles, prose, tags, links, references and accessibility text consistent
across existing source/output pairs. When no render is allowed, synchronize safe
editorial changes directly where feasible and identify stale results. Never
hand-edit computed outputs to suggest unexecuted code has run.

When reconciling editorial differences in an existing published post, use the
published Markdown as the source of truth. Apply approved wording and
capitalization to the matching Rmd while preserving its executable chunks.
When asked to propagate those edits to DEV, update the corresponding copy
and preserve its publication status and DEV-specific formatting.

Keep all project R scripts formatted with **air** and the R code in Rmd sources
formatted with **styler**, using `styler::style_file()` or
`styler::style_dir()`. Apply the formatters to source files, including
experiment scripts, within the user's authorized scope. Exclude generated,
vendored and deleted files. Preserve behavior, prose, chunk labels, YAML options
and figure dimensions. Formatting does not authorize running chunks, rendering
or rebuilding Markdown outputs.

Rmd chunk fences must contain only the engine, followed by YAML option comments.
Use **knitr**'s `convert_chunk_header(..., type = "yaml")` for old in-header
options. The exact conversion and safeguards are in the publication reference.
Require English, descriptive, unique chunk labels and English variable/function
names in new code. Existing identifier renaming or code refactoring needs
implementation scope, not just an editorial request.

Honor `#|` YAML syntax, including multiline alt text and project captions.
Preserve executable code, option values, expressions and explicit figure
dimensions. Do not migrate an Rmd to Quarto to obtain this syntax. Existing
shared `knitr::opts_chunk$set()` calls can remain R code.

## Verification and delivery

Perform static checks appropriate to the edit: front-matter syntax, absolute
URLs, tag consistency, image alt text, caption policy, references and
source/Markdown agreement and preservation of executable chunks. Resolve obvious
editorial issues and mark genuinely ambiguous statements with an HTML `FIXME`
comment.

Run only permitted operations. An instruction not to render/build applies to
both R execution and Jekyll as stated in the session. Converting chunk headers
and extracting code with `knitr::purl()` do not execute analysis, but still keep
such work within the requested files. Publication includes placing Markdown in
`_posts/` and may trigger deployment when pushed. Do not promote a draft,
commit, push or send Webmentions without current authorization. If pushing is
authorized, finish checks first and commit/push at the end.

Report changes briefly, with any pending synchronization, missing metadata or
unverified claims. Do not claim compilation or visual verification unless run.
