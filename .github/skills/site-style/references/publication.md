# Publication conventions and examples

## Tags and metadata

Inspect comparable files before assigning tags. Current vocabulary includes
`rstats`, `rspatial`, `maps`, `beautiful_maps`, `r_bloggers`, `r_package`,
`dataset` and exact package names such as `sf`, `giscoR`, `ggplot2` and `terra`.
Projects use `project`, with technology/content tags and `discontinued` when
appropriate. Not every R post is a package announcement or a beautiful-map
post. The `r_bloggers` tag does not prove that an external copy exists.

Add actual external article URLs to `syndication`, in both Rmd and Markdown.
Use the existing “Also published on” mechanism rather than introducing a
second competing list. Never add the service homepage as a syndicated copy.
Project summaries and their structured data must agree with the original
project website, which is the source of truth. Do not copy its full catalog
into the blog or modify JSON-LD templates during a style-only task.

## Chulapa alerts and captions

Attach Kramdown attributes immediately below the message paragraph:

```markdown
<i class="fa fa-exclamation-triangle"></i> **Warning:** These are estimated
areas, not official postal boundaries.
{: .alert .alert-warning .p-3 .mx-2 .mb-3}
```

Use `alert-info` for information/tips, `alert-warning` for limitations and
`alert-danger` for serious warnings or discontinued projects. Existing project
notices sometimes add `.lead` and `.text-center`. Reuse the appropriate existing
convention without adding inline styles or a new alert component. Icons are
optional, and must use the Font Awesome version configured by the site.

Posts use images with alt text and no visible figure caption:

```markdown
![Five generating sites and their Voronoi cells.](https://dieghernan.github.io/assets/img/blog/example.webp)
```

The URL illustrates the shape only. Use an actual existing/generated asset.
Keep relevant explanation and source attribution in ordinary surrounding prose
or references. Do not add a `.caption` paragraph, HTML caption element or
nonempty `fig-cap` for a post. Existing project pages still require alt text
and descriptive captions, using their current markup.

## Reference style

The user's explicit model is the `References` section of
`collections/_posts/2022-10-17-tidyterra-hillshade.md`, mirrored in
`_Rmd/2022-10-17-tidyterra-hillshade.Rmd`. Read that section when matching
references. It supersedes the earlier template based on recent project pages.

Use Markdown bullets with a hanging continuation indent. Ordinary entries use
surname and initials, `&` before the final author and year in parentheses.
Article titles are plain text, not automatically italicized. Journal titles
and volume numbers use italics where shown in the model. Use visible absolute
DOI or web autolinks, `<https://...>`, rather than labels such as `[doi:...]`,
`[Article]` or `[Data portal]`. Preserve official title spelling and casing.

Examples copied from the model:

```markdown
- Patterson, T. & Jenny, B. (2011). The Development and Rationale of
  Cross-blended Hypsometric Tints. _Cartographic Perspectives_, (69), 31–46.
  <https://doi.org/10.14714/CP69.20>.
- Royé, Dominic. 2022. “Hillshade Effects.” July 20.
  <https://dominicroye.github.io/blog/hillshade-effect/>.
- Hernangómez, D. (2023). Using the tidyverse with terra objects: the tidyterra
  package. _Journal of Open Source Software_, _8_(91), 5751,
  <https://doi.org/10.21105/joss.05751>.
```

The model intentionally accommodates author-recommended citations, such as
Royé's own wording, instead of forcing all entries into one rigid template.
Web titles may be quoted, as in the Grossenbacher entry. Explain a relevant
redirect or updated version in the entry without silently replacing the
historical work. Keep bibliographic URLs absolute and prefer the DOI resolver
when available. For datasets, retain known versions, type and repository
without inventing missing fields. Do not rename original non-English titles.

Do not impose alphabetical ordering just because a review is requested.
Preserve citation anchors and keep reference sections matched in Rmd and
Markdown. Goerlich's working-paper wording has an explicit preservation
request. Consult `_maintenance/references-audit.md` before changing it. Link
failures alone do not invalidate a reference.

## YAML chunk headers with knitr

The function is `knitr::convert_chunk_header()`, not `chunk_headers()`.
It moves inline fence options into the chunk body. Specify `type = "yaml"`
explicitly: the Rmd default is `"multiline"`, which uses R-style assignments
rather than YAML. The installed **knitr** 1.52 implementation was inspected and
its YAML conversion tested on 2026-11-05 without running the example chunks.

Required format:

````markdown
```{r}
#| label: voronoi-toy-example
#| echo: true
#| fig-width: 9
#| fig-height: 5
#| fig-alt: >-
#|   Five generating sites and their cells, including a bounded central cell.
#| fig-cap: ""

# Executable R code follows the YAML options.
```
````

Safe conversion of an authorized target, producing a temporary preview first:

```r
input <- "_Rmd/selected-post.Rmd"
converted <- tempfile(fileext = ".Rmd")
knitr::convert_chunk_header(input, output = converted, type = "yaml")
```

`output = NULL` returns the converted text. `output = identity` overwrites the
input and should be used only when that file's conversion is in scope. The
function does not knit or execute analysis code. It does not by itself add
missing labels or alt text, and leaves existing in-body option blocks
alone when no inline header parameters exist. Inspect those separately.

The implementation converts dotted option names to dashes, uses YAML booleans
such as `false` and tags R expressions with `!expr`. Preserve those expressions
as expressions. Do not quote them into inert strings. Do not assume that the
`width` argument controls YAML wrapping, as it applies to the other modes.

Compare executable code before and after, using static extraction if useful:

```r
before <- knitr::purl(input, output = tempfile(), documentation = 0, quiet = TRUE)
after <- knitr::purl(converted, output = tempfile(), documentation = 0, quiet = TRUE)
stopifnot(identical(readLines(before), readLines(after)))
```

Also inspect labels, option values, multiline alt text, chunk references and
YAML boundaries. Static extraction alone does not prove option equivalence.
For new labels, use English descriptions rather than automatic `unnamed-chunk`
labels. Keep legacy labels where renaming could break figure URLs or references
unless the user authorizes that update.

Primary documentation:

- [knitr manual: convert_chunk_header](https://yihui.r-universe.dev/knitr/doc/manual.html).
- [knitr chunk options](https://yihui.org/knitr/options/).

## Render integration

Inspect `_Rmd/renderblog_v2.R` and the current post-specific wrapper before
changing a rendering workflow. Do not assume a helper's filename determines
whether it publishes drafts: read the actual function call. Sources are in
`_Rmd/`, article outputs in `collections/_posts/` or `collections/_drafts/`
and images in `assets/img/blog/` or `assets/img/drafts/` respectively.

Use the existing WebP conversion. Preserve the figure dimensions chosen by the
source and chunk. The current helper supports cropping outer margins before
WebP conversion with `fig.crop = TRUE`, and opt-out with `fig.crop = FALSE`.
Do not stretch images to enforce a universal aspect ratio or delete diagnostic
PNGs the user deliberately keeps. Measure metadata on the final converted
image. Avoid parallel image folders under `collections/` and unwanted output
files in the repository root.
