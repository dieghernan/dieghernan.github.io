---
title: "Mapping Antarctica"
subtitle: "Cool maps from the South Pole"
tags:
- r_bloggers
- beautiful_maps
- rstats
- rspatial
- maps
- ggplot2
- sf
- giscoR
output:
  html_document:
  md_document:
    variant: gfm
    preserve_yaml: true
header_img: https://dieghernan.github.io/assets/img/blog/202510_good_pol-1.webp
---



Creating maps with **R** is usually straightforward, but representations that
cross the [International Date
Line](https://en.wikipedia.org/wiki/International_Date_Line) or that use polar
projections can be tricky.

Different spatial-data providers use different conventions: some break
geometries at certain longitudes (for example, cutting the Chukchi Peninsula),
while others omit portions of the data. These inconsistencies can produce
awkward artifacts near the poles.

In this post I fix the [GISCO (European
Commission)](https://ec.europa.eu/eurostat/web/gisco) shapefile for Antarctica
and produce clean orthographic maps. I walk through the manual corrections and
then create a few example maps.


``` r
# Libraries
library(tidyverse)
library(sf)
library(giscoR)
library(ggrepel)
library(rmapshaper)
```

## Fixing the geometry

First, we obtain the GISCO Antarctica polygon and transform it to an
orthographic projection centered on the South Pole.


``` r
antarct <- gisco_get_countries(year = 2024, resolution = 1, country = "ATA") %>%
  select(NAME = NAME_ENGL) |>
  # Ortho proj centered in the South Pole
  st_transform(crs = "+proj=ortho +lat_0=-90 +lon_0=0")

ggplot(antarct) +
  geom_sf(fill = "lightblue")
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_init-1.webp" width="100%" />

The shapefile contains a visible "lollipop" cut that looks unnatural in an
orthographic projection. I correct it manually by:

1.  Identify the polygon that represents the main Antarctic landmass.
2.  Convert that polygon to a sequence of coordinates (points).
3.  Remove the small sequence of points that create the artifact.
4.  Rebuild the polygon from the cleaned coordinates and replace the broken
    geometry with the corrected one.

We convert polygons to point coordinates and inspect them to find the offending
sequence:


``` r
# Identify the max
ant_explode <- antarct |>
  st_cast("POLYGON")

nrow(ant_explode)
#> [1] 778

# Max polygon

ant_max <- ant_explode[which.max(st_area(ant_explode)), ]

coords <- st_coordinates(ant_max) |>
  as_tibble() |>
  # Add id for points
  mutate(np = row_number())


ggplot(coords, aes(X, Y)) +
  geom_point(size = 0.05, color = "darkblue") +
  geom_text(aes(label = np), check_overlap = TRUE) +
  coord_equal()
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_init_ant-1.webp" width="100%" />

From the plotted indices, we can see the problematic points fall roughly in the
range 8200–9200. We inspect that interval in detail to select the exact indices
to remove.


``` r
test <- coords |>
  filter(np %in% seq(8200, 9200))

test |>
  ggplot(aes(X, Y)) +
  geom_point(size = 0.05, color = "darkblue") +
  geom_text(aes(label = np), check_overlap = TRUE)
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_test_points-1.webp" width="100%" />

<div class="alert alert-warning p-3 mx-2 mb-3">

Note: This cleaning is tailored to this specific shapefile and may need to be
repeated for other shapefiles. The approach is straightforward but depends on
the particular geometry and projection.

</div>


``` r
# Final solution after some iterations...

test |>
  filter(np %in% seq(8289, 9130)) |>
  ggplot(aes(X, Y)) +
  geom_point(color = "darkblue") +
  labs(title = "To remove")


test |>
  filter(!np %in% seq(8289, 9130)) |>
  ggplot(aes(X, Y)) +
  geom_point(color = "darkblue") +
  labs(title = "To keep")
```

<div class="figure row no-gutters">
<img src="https://dieghernan.github.io/assets/img/blog/202510_final_sol-1.webp" width="50%" /><img src="https://dieghernan.github.io/assets/img/blog/202510_final_sol-2.webp" width="50%" />

After removing the offending points, we rebuild the polygon and reconstitute the
full Antarctica shape from the corrected piece plus the remaining polygons.
</div>

``` r
# From coordinates to polygon
newpol <- coords |>
  as.data.frame() |>
  filter(!np %in% seq(8289, 9130)) |> # Removing offending points
  select(X, Y) |>
  as.matrix() |>
  list() |>
  st_polygon() |>
  st_sfc() |>
  st_set_crs(st_crs(ant_max))

ant_max_fixed <- st_sf(st_drop_geometry(ant_max), geometry = newpol)

# Regenerate initial shape
antarctica_fixed <- bind_rows(
  ant_max_fixed,
  ant_explode[-which.max(st_area(ant_explode)), ]
) |>
  group_by(NAME) |>
  summarise(m = 1) |>
  select(-m) |>
  st_make_valid()

antarctica_fixed
#> Simple feature collection with 1 feature and 1 field
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -2583099 ymin: -2458296 xmax: 2690846 ymax: 2233395
#> Projected CRS: +proj=ortho +lat_0=-90 +lon_0=0
#> # A tibble: 1 × 2
#>   NAME                                                                     geometry
#> * <chr>                                                          <MULTIPOLYGON [m]>
#> 1 Antarctica (((-2456385 1179033, -2456141 1178965, -2456464 1178341, -2456563 117…

ggplot(antarctica_fixed) +
  geom_sf(fill = "lightblue")
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_good_pol-1.webp" width="100%" />

## Plotting examples

With the corrected shape we can produce maps. Below are a few examples based on
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

<img src="https://dieghernan.github.io/assets/img/blog/202510_bartram-1.webp" width="100%" />

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

<img src="https://dieghernan.github.io/assets/img/blog/202510_treaty1-1.webp" width="100%" />

We merge meridians so the area around the South Pole is filled. `st_graticule()`
can leave a tiny hole at the pole; we fix this by joining complementary
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

<img src="https://dieghernan.github.io/assets/img/blog/202510_treaty2-1.webp" width="100%" />

### Antarctica Flag Redesigned

In 2024, Graham Bartram revealed a new version of his original flag as part of 
a global campaign to raise awareness about the growing problem of microplastic 
pollution. The new design keeps the familiar white outline of Antarctica but 
swaps the plain blue background for one filled with countless tiny, colorful 
dots. These dots represent the microscopic bits of plastic that have been 
discovered even in the planet’s most untouched places - including the Antarctic 
ice and its surrounding oceans.

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Antarctica_Flag_Redesigned_by_Graham_Bartram.png/960px-Antarctica_Flag_Redesigned_by_Graham_Bartram.png" />

Because the design relies on randomness, we approximate it using the following
procedure:

1.  Sample random points across the Antarctic polygon.
2.  Build Voronoi polygons from those points, then apply a small negative buffer
    to create gaps.
3.  Randomly sample the resulting polygons to increase visual noise.
4.  Color polygons so larger areas remain white while smaller polygons use
    magenta/pink tones.


``` r
# Maximum chunk of Antarctica, the one that we fixed

ant_max_fixed
#> Simple feature collection with 1 feature and 1 field
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -2447764 ymin: -2125910 xmax: 2690846 ymax: 2233395
#> Projected CRS: +proj=ortho +lat_0=-90 +lon_0=0
#>         NAME                       geometry
#> 1 Antarctica POLYGON ((-2423737 1557908,...

set.seed(2024)
# Sample, Voronoi and negative buffer
plastics <- st_sample(ant_max_fixed, 3000) |>
  st_union() |>
  st_voronoi(envelope = st_geometry(ant_max_fixed)) |>
  st_collection_extract() |>
  st_buffer(dist = -10000)


# Keep only those properly included in the outline

toinc <- st_contains_properly(ant_max_fixed, plastics, sparse = FALSE) |>
  as.vector()

# Select random chunks
plastic_end <- plastics[toinc, ] |>
  st_as_sf() |>
  slice_sample(prop = 0.75)

ggplot(plastic_end) +
  geom_sf(fill = "darkblue")
```

<img src="https://dieghernan.github.io/assets/img/blog/202510_redesign-1.webp" width="100%" />

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
  geom_sf(data = plastic_end, aes(fill = fill), color = NA) +
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

<img src="https://dieghernan.github.io/assets/img/blog/202510_redesign-2.webp" width="100%" />
