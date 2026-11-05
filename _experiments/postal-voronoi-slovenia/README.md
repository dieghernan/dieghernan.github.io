# Postal codes with Voronoi: Slovenia

First post draft, in English. Open **postal-voronoi.html** for the rendered article;
edit **postal-voronoi.Rmd** for the source. This experiment is not published as a blog post.

A second version, **postal-voronoi-v2.Rmd** / **postal-voronoi-v2.html**,
uses a more conversational voice under the title *Postal codes and tessellations*.
Its headings and all 17 R chunks (including options and plot labels) are
identical to the first version. Only the title and prose differ; references
are unchanged. Render it from the repository root with
`source("_experiments/postal-voronoi-slovenia/render-v2.R")`.
A third version, **postal-voronoi-v3.Rmd** / **postal-voronoi-v3.html**,
keeps the conversational title with a tone between the first two drafts:
direct explanations and friendly transitions, with fewer playful asides.
It has the same headings, references and all 17 unchanged R chunks.
Render it with `source("_experiments/postal-voronoi-slovenia/render-v3.R")`.
All versions share the data cache and write the same GeoPackage layers.

From the repository root, render with:

```r
source("_experiments/postal-voronoi-slovenia/render.R")
```

Requires giscoR (with `gisco_get_postalcodes()`), sf, dplyr, ggplot2,
rmarkdown, knitr and ragg, plus Pandoc (provided by Quarto or RStudio).
The first render downloads the 2024 European GISCO LAU and postal datasets
(roughly 270 MB combined); subsequent renders reuse `data/`.

Outputs: a self-contained HTML article, `postal-areas.gpkg` with assigned
and unassigned layers, and `session-info.txt`. The cached source data and
intermediate plot directory are ignored by Git. Duplicate point coordinates
are resolved by retaining the first code in sorted order, with counts in the article.

The article covers Ljubljana first, then individual municipal components
across Slovenia, using inward margins of 200 and 50 m. Those margins and
municipal clipping are modelling choices, not validated Slovenian postal rules.
The HTML includes geometric coverage and overlap checks; it does not validate
postal accuracy. Further iterations can compare margins and refine map design.
