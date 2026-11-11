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

An author's own figure in a post uses alt text without a visible caption:

```markdown
![Five generating sites and their Voronoi cells.](https://dieghernan.github.io/assets/img/blog/example.webp)
```

The URL illustrates the shape only. Use an actual existing/generated asset.
Figures produced by others may include an optional caption for credit or
context. Use the existing Kramdown `.caption` or HTML caption markup and keep
the alt text descriptive. Source attribution can also appear in the surrounding
prose or references. Project pages still require alt text and descriptive
captions, using their current markup.

## Reference style

Use APA 7 for each reference and alphabetize by the first author's surname
or by the group author. Keep Markdown bullets with continuation indentation
and preserve inline links in the article. Use the APA template for each
source type: journal articles, blog posts, reports, books, datasets or software.
Use sentence case where APA calls for it and preserve official names, accents,
citation anchors and the version actually used.

Match existing entries by DOI or canonical URL across posts, projects and
drafts. Reuse the same bibliographic text for the same work and version, and
keep corresponding Rmd and Markdown reference sections identical. Keep
documented exceptions, including the requested wording for Goerlich's
working paper. Consult `_maintenance/references-audit.md` for legacy decisions.

Confirm metadata with publishers and repositories. Cross-check DOI and
bibliographic fields through Crossref, DataCite and OpenAlex as appropriate.
Check DOI resolution directly when a registry has no record. Use verified
ISSNs and ISBNs to disambiguate publications and editions. APA entries omit
these identifiers unless the source type requires them.

Prefer a DOI to a duplicate landing-page URL. Use absolute DOI resolver
links and omit terminal punctuation after URLs. Use `[DOI](https://doi.org/...)`
for long CRAN DOIs that could overflow on mobile. Use a short descriptive
link for similarly long non-DOI URLs. Keep supplemental links when they
point to a distinct updated version or documentation.

See [APA 7 reference examples](https://apastyle.apa.org/style-grammar-guidelines/references/examples).

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
