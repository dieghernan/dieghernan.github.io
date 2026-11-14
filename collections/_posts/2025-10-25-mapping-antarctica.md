---
series:
  - id: map-projections
    order: 4
title: "Mapping Antarctica"
excerpt: "Fix a polygon artifact in the GISCO data and draw Antarctica from the South Pole in R."
subtitle: "Cool maps from the South Pole"
syndication:
  - https://www.r-bloggers.com/2025/10/mapping-antarctica/
  - https://dev.to/dieghernan/mapping-antarctica-4chp
  - https://oneworldwithr.substack.com/p/202510_mapping-antarctica
tags:
  - polar
  - maps
  - beautiful_maps
  - sf
  - ggplot2
  - giscoR
  - voronoi
  - rspatial
  - rstats
  - music
  - r_bloggers
output:
  html_document:
  md_document:
    variant: gfm
    preserve_yaml: true
header_img: "https://dieghernan.github.io/assets/img/blog/202510_good_pol-1.webp"
last_modified_at: 2026-11-14
og_image_width: 2100
og_image_height: 1846
og_image_type: "image/webp"
og_image_alt: >-
  South Pole-centered map of Antarctica after removing the polygon artifact.
  The landmass is continuous across the previously affected area.
---

Creating maps with **R** is usually straightforward, but representations that
cross the [International Date
Line](https://en.wikipedia.org/wiki/International_Date_Line) or that use polar
projections can be tricky.

Different spatial-data providers use different conventions: some break
geometries at certain longitudes (for example, cutting the Chukchi Peninsula),
while others omit portions of the data. These inconsistencies can produce
awkward artifacts near the poles.

In this post, I fix the [GISCO (European
Commission)](https://ec.europa.eu/eurostat/web/gisco) shapefile for Antarctica
and produce clean orthographic maps.


``` r
# Libraries
library(tidyverse)
library(sf)
library(giscoR)
library(ggrepel)
library(rmapshaper)

# Define a common theme for the maps.
background <- "#E2ECF2"

map_family <- "inter-tight"
sysfonts::font_add_google("Inter Tight", family = map_family)
showtext::showtext_opts(dpi = knitr::opts_chunk$get("dpi"))
showtext::showtext_auto()

theme_set(
  theme_grey(paper = background) +
    theme(
      text = element_text(family = map_family),
      plot.title = element_text(face = "bold"),
      plot.margin = margin(10, 10, 10, 10)
    )
)
```

## Fixing the geometry

First, we retrieve the Antarctic geometry from GISCO and transform it to an
orthographic projection centered on the South Pole.


``` r
antarct <- gisco_get_countries(year = 2024, resolution = 1, country = "ATA") %>%
  select(NAME = NAME_ENGL) |>
  # Orthographic projection centered on the South Pole
  st_transform(crs = "+proj=ortho +lat_0=-90 +lon_0=0")

ggplot(antarct) +
  geom_sf(fill = "lightblue")
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_init-1.webp" alt="South Pole-centered map of Antarctica with a gap extending from the coast toward the pole, caused by a polygon artifact." width="100%" />

<div role="note" aria-label="Note" class="callout-note" markdown="1">
**Updated November 14, 2026.** The original post showed how to repair the
geometry by editing vertices manually. This version uses a buffer.
</div>

In the orthographic projection, a narrow gap runs inland from the coast.
I close it by applying a 2-meter buffer:



``` r
# Regenerate initial shape
antarctica_fixed <- st_buffer(antarct, 2)

ggplot(antarctica_fixed) +
  geom_sf(fill = "lightblue")
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_good_pol-1.webp" alt="South Pole-centered map of Antarctica after removing the polygon artifact. The landmass is continuous across the previously affected area." width="100%" />

## Plotting examples

With the corrected geometry, we can draw the maps. Below are a few examples based on
proposed Antarctic flag designs.

### Graham Bartram's proposal (1996)

A simple rendition of Bartram's original concept:


``` r
bbox <- st_bbox(antarctica_fixed) # For limits on the panel

antarctica_fixed |>
  ggplot() +
  geom_sf(fill = "white", color = NA) +
  theme(
    panel.background = element_rect(fill = "#009fdc"),
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) +
  labs(title = "Graham Bartram's proposal") +
  coord_sf(
    xlim = c(bbox[c(1, 3)]) * 1.8,
    ylim = c(bbox[c(2, 4)]) * 1.4
  )
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_bartram-1.webp" alt="Antarctic flag design with a white silhouette of the continent on a blue background." width="100%" />

### Emblem of the Antarctic Treaty

This example uses graticules to create a concentric "bullseye" pattern around
Antarctica. Generating such graticules and merging meridians requires a few
extra steps to avoid small gaps near the pole.


``` r
# Need graticules
grats <- giscoR::gisco_get_countries() |>
  st_transform(st_crs(antarctica_fixed)) |>
  # Specify the cuts of the graticules
  st_graticule(
    lat = c(-80, -70, -60),
    lon = seq(-180, 180, 30),
    ndiscr = 10000,
    margin = 0.000001
  )


ggplot(grats) +
  geom_sf(color = "darkblue")
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_treaty1-1.webp" alt="Polar coordinate grid centered on the South Pole, with concentric latitude circles and radial longitude lines." width="100%" />

We merge meridians so the area around the South Pole is filled. `st_graticule()`
can leave a tiny hole at the pole, and we fix this by joining complementary
meridians.


``` r
# Merge meridians
merid <- lapply(seq(-180, 0, 30), function(x) {
  df <- grats |>
    filter(type == "E") |>
    filter(degree %in% c(x, x + 180))

  df2 <- df |>
    st_geometry() |>
    st_cast("MULTIPOINT") |>
    st_union() |>
    st_cast("LINESTRING")

  sf_x <- st_sf(
    degree = x,
    type = "E",
    geometry = df2
  )
}) |> bind_rows()


grats_end <- merid |>
  bind_rows(grats |>
    filter(type != "E"))
```

We then cut and color the resulting graticules so they form the emblem-like
pattern.


``` r
# Cut since some grats should be colored differently

antarctica_simp <- rmapshaper::ms_simplify(antarctica_fixed, keep = 0.005)
grats_yes <- st_intersection(grats_end, antarctica_simp)
grats_no <- st_difference(grats_end, antarctica_simp)

antarctica_simp |>
  ggplot() +
  geom_sf(fill = "white", color = NA) +
  theme(
    panel.background = element_rect(fill = "#072b5f"),
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) +
  geom_sf(data = grats_yes, color = "#072b5f", linewidth = 1) +
  geom_sf(data = grats_no, color = "white", linewidth = 1) +
  coord_sf(
    xlim = c(bbox[c(1, 3)]) * 1.8,
    ylim = c(bbox[c(2, 4)]) * 1.4
  ) +
  labs(title = "Emblem of the Antarctic Treaty")
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_treaty2-1.webp" alt="Antarctic Treaty emblem with a white Antarctic silhouette and polar coordinate grid on a dark blue background." width="100%" />

### Bartram's redesigned Antarctic flag

In 2024, Graham Bartram revealed a new version of his original flag as part of
a global campaign to raise awareness about the growing problem of microplastic
pollution. The new design keeps the familiar white outline of Antarctica but
swaps the plain blue background for one filled with countless tiny, colorful
dots. These dots represent the microscopic bits of plastic that have been
discovered even in the planet’s most untouched places, including the Antarctic
ice and its surrounding oceans.

![Antarctic flag variation with the white continental silhouette formed by scattered marks on a blue background.](https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Antarctica_Flag_Redesigned_by_Graham_Bartram.png/960px-Antarctica_Flag_Redesigned_by_Graham_Bartram.png)

Because the design relies on randomness, we approximate it using the following
procedure:

1.  Sample random points across the Antarctic polygon.
2.  Build Voronoi polygons from those points, then apply a small negative buffer
    to create gaps.
3.  Randomly sample the resulting polygons to increase visual noise.
4.  Color polygons so larger areas remain white while smaller polygons use
    shades of pink and magenta.


``` r
# Use the repaired Antarctic geometry

set.seed(2024)
# Sample, Voronoi and negative buffer
plastics <- st_sample(antarctica_fixed, 3000) |>
  st_union() |>
  st_voronoi(envelope = st_geometry(antarctica_fixed)) |>
  st_collection_extract() |>
  st_buffer(dist = -10000)


# Keep only those properly included in the outline

toinc <- st_contains_properly(antarctica_fixed, plastics, sparse = FALSE) |>
  as.vector()

# Select random chunks
plastic_end <- plastics[toinc, ] |>
  st_as_sf() |>
  slice_sample(prop = 0.75)

ggplot(plastic_end) +
  geom_sf(fill = "darkblue")
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_redesign-1.webp" alt="Map of Antarctica filled with randomly distributed blue points inside the continent boundary." width="100%" />

``` r


# Random coloring

plastic_end$area <- st_area(plastic_end) |> as.double()

plastic_end$fill <- sample(c("#ff00ec", "#9e00ec"), nrow(plastic_end), replace = TRUE)
plastic_end$fill <- ifelse(plastic_end$area > quantile(plastic_end$area, probs = 0.4),
  "white",
  plastic_end$fill
)

bbox2 <- st_bbox(plastic_end)
ggplot() +
  geom_sf(data = plastic_end, aes(fill = fill), color = NA, linewidth = 0) +
  scale_fill_identity() +
  theme(
    panel.background = element_rect(fill = "#009fdc"),
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) +
  labs(title = "New redesign") +
  coord_sf(
    xlim = c(bbox2[c(1, 3)] * 1.8),
    ylim = c(bbox2[c(2, 4)]) * 1.4
  )
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_redesign-2.webp" alt="Antarctic flag variation with the continental silhouette formed by scattered white points on a blue background." width="100%" />

<iframe
  class="d-block w-100 border-0 rounded my-3"
  title="Cold Heart (PNAU Remix) by Elton John and Dua Lipa on Spotify"
  src="https://open.spotify.com/embed/track/5PERfEjDBWImbO3W8m7f0w?theme=0"
  height="152"
  loading="lazy"
  allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture"
  allowfullscreen>
</iframe>
