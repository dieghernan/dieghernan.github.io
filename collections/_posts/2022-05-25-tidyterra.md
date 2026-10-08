---
title: "Introducing <strong>tidyterra</strong>"
subtitle: Easily work with and plot SpatRasters
excerpt: tidyterra provides tidyverse methods for terra objects and geom
  functions for plotting with ggplot2.
tags:
  - r_bloggers
  - rstats
  - rspatial
  - maps
  - ggplot2
  - tidyterra
  - terra
  - maptiles
  - r_package
output:
  html_document:
    df_print: paged
  md_document:
    variant: gfm
    preserve_yaml: yes
header_img: ./assets/img/blog/20220525_easteregg-2.webp
description: "Use tidyterra to manipulate terra spatial objects with tidyverse methods and plot SpatRasters with ggplot2."
schema_image:
  - /assets/img/blog/20220525_easteregg-2.webp
  - /assets/img/blog/20220525_easteregg-3.webp
og_image_width: 2100
og_image_height: 2100
og_image_type: "image/webp"
og_image_alt: "Street map of Maungawhau with an elevation overlay restricted to terrain above 130 meters. Lower ground remains visible on the base map."
---

If you have been playing around with **R** for a while, you are probably
familiar with the `volcano` dataset:

```r

data("volcano")
image(volcano, col = terrain.colors(256, rev = TRUE))
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_volcano-1.webp" title="plot of chunk 20220525_volcano" alt="Elevation heatmap of Maungawhau in Auckland from the volcano dataset. Colors indicate altitude and reveal the crater surrounded by higher ground." width="100%" />

This represents the topographic information about one of the volcanoes of Auckland
(New Zealand), specifically [Maungawhau / Mount
Eden](https://en.wikipedia.org/wiki/Maungawhau_/_Mount_Eden). But **do you know
that this map is flipped?**

In this post I introduce the [**tidyterra**
package](https://github.com/dieghernan/tidyterra), recently added to
[CRAN](https://CRAN.R-project.org/package=tidyterra), and I show you how to
geotag the `volcano` dataset. We will also produce **ggplot2** maps using the
functions of **tidyterra**.

```r
# Libraries
library(terra)
library(ggplot2)
library(tidyterra)
library(maptiles)
library(sf)
```

## Wait, `volcano` is flipped?

Let's check it out. Thanks to the package **maptiles** we can have a glimpse of
the location of Maungawhau using map tiles, as in Google Maps. We will use
**tidyterra** for displaying the map tile:

```r

# location of Maungawhau

box <- c(
  174.7611552780,
  -36.8799200525,
  174.7682380109,
  -36.8719519780
)
class(box) <- "bbox"
box <- st_as_sfc(box)
st_crs(box) <- 4326

box <- box %>%
  # To crs for NZGD49
  st_transform(27200)

tile <- get_tiles(box, crop = TRUE, zoom = 16)


ggtile <- ggplot() +
  geom_spatraster_rgb(data = tile)

ggtile
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_tile-1.webp" title="plot of chunk 20220525_tile" alt="Street map of Maungawhau in Auckland, showing the crater, surrounding paths and nearby streets." width="100%" />

Here we have a crisp RGB tile of Maungawhau. Now, the next
question is how to match the `volcano` dataset (a matrix) with this tile (a
geotagged map tile)? Let's check it out.

## Working with SpatRasters

Thanks to the **terra** package we can start converting `volcano` into a
SpatRaster:

```r

volcano_rast <- rast(volcano)

terra::plot(volcano_rast)
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_volcano_raster-1.webp" title="plot of chunk 20220525_volcano_raster" alt="Elevation raster of Maungawhau before orientation correction. The crater appears near the top of the map." width="100%" />

```r

# Wait, it is flipped!
volcano_rast_ok <- rast(volcano[
  seq(nrow(volcano), 1, -1),
  seq(ncol(volcano), 1, -1)
])

# Much better!
terra::plot(volcano_rast_ok)
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_volcano_raster-2.webp" title="plot of chunk 20220525_volcano_raster" alt="Elevation raster of Maungawhau after reversing rows and columns. The crater now appears near the bottom of the map." width="100%" />

```r

volcano_rast_ok
#> class       : SpatRaster
#> dimensions  : 87, 61, 1  (nrow, ncol, nlyr)
#> resolution  : 1, 1  (x, y)
#> extent      : 0, 61, 0, 87  (xmin, xmax, ymin, ymax)
#> coord. ref. :
#> source      : memory
#> name        : lyr.1
#> min value   :    94
#> max value   :   195
```

Nice! Now we have a raster of `volcano`, but still without geotagged
information. Thanks to this article by Tomislav Hengl
([@tom_hengl](https://twitter.com/tom_hengl)) we can check the basic geographic
parameters of `volcano` (see [Volcano
Maungawhau](https://www.geomorphometry.org/2009/08/20/volcano-maungawhau/)), which are:

- **CRS**: EPSG:27200
- **xllcorner**: 2667400
- **yllcorner**: 6478700
- **cellsize**: 10 m
- **ncols**: 61
- **nrows**: 87

And we can translate that easily to an empty SpatRaster:

```r

# Extra length for proper handling extent
xrange <- range(seq(from = 2667400, length.out = 62, by = 10))
yrange <- range(seq(from = 6478700, length.out = 88, by = 10))

template <- rast(
  crs = "EPSG:27200",
  xmin = xrange[1],
  xmax = xrange[2],
  ymin = yrange[1],
  ymax = yrange[2],
  resolution = 10
)
template
#> class       : SpatRaster
#> dimensions  : 87, 61, 1  (nrow, ncol, nlyr)
#> resolution  : 10, 10  (x, y)
#> extent      : 2667400, 2668010, 6478700, 6479570  (xmin, xmax, ymin, ymax)
#> coord. ref. : NZGD49 / New Zealand Map Grid (EPSG:27200)
```

So now we only need to transfer the values from `volcano_rast_ok` to our
template:

```r

# Use tidyterra to pull the values of one raster
# and create a new layer

volcano2 <- template %>%
  mutate(elevation = pull(volcano_rast_ok, lyr.1)) %>%
  select(elevation)

volcano2
#> class       : SpatRaster
#> dimensions  : 87, 61, 1  (nrow, ncol, nlyr)
#> resolution  : 10, 10  (x, y)
#> extent      : 2667400, 2668010, 6478700, 6479570  (xmin, xmax, ymin, ymax)
#> coord. ref. : NZGD49 / New Zealand Map Grid (EPSG:27200)
#> source      : memory
#> name        : elevation
#> min value   :        94
#> max value   :       195

terra::plot(volcano2)
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_create_volcano2-1.webp" title="plot of chunk 20220525_create_volcano2" alt="Georeferenced elevation map of Maungawhau. Projected coordinates locate the terrain and colors represent altitude from 94 to 195 meters." width="100%" />

```r

# And plot it
ggtile +
  geom_spatraster(data = volcano2) +
  scale_fill_terrain_c(alpha = 0.75)
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_create_volcano2-2.webp" title="plot of chunk 20220525_create_volcano2" alt="Street map of Maungawhau overlaid with a translucent elevation raster, aligning the terrain with the crater and surrounding streets." width="100%" />

## An Easter egg

The `volcano` dataset may not be completely up to date. As a complement,
**tidyterra** includes a `.tif` file with the same dimensions as our `volcano2`
raster, but with the topographic values extracted from [Auckland LiDAR 1m DEM
(2013)](https://data.linz.govt.nz/layer/53405-auckland-lidar-1m-dem-2013/) and
resampled to a resolution of 5x5 meters, for package size optimization. See here
how to load it and check the plotting possibilities of **tidyterra**:

```r

# Load out Easter Egg

volcano2_easter <- rast(system.file("extdata/volcano2.tif",
  package = "tidyterra"
))

volcano2_easter
#> class       : SpatRaster
#> dimensions  : 174, 122, 1  (nrow, ncol, nlyr)
#> resolution  : 5, 5  (x, y)
#> extent      : 1756969, 1757579, 5917003, 5917873  (xmin, xmax, ymin, ymax)
#> coord. ref. : NZGD2000 / New Zealand Transverse Mercator 2000 (EPSG:2193)
#> source      : volcano2.tif
#> name        : elevation
#> min value   :  76.26222
#> max value   :  195.5542
terra::plot(volcano2_easter)
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_easteregg-1.webp" title="plot of chunk 20220525_easteregg" alt="Elevation map of Maungawhau derived from LiDAR data, showing the crater and surrounding terrain at 5-meter resolution." width="100%" />

```r


# Only altitudes of more than 130m

volcano_filter <- volcano2_easter %>%
  filter(elevation > 130)


ggtile +
  geom_spatraster(data = volcano_filter) +
  scale_fill_viridis_c(na.value = NA, alpha = 0.7) +
  labs(fill = "Elevation (m)")
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_easteregg-2.webp" title="plot of chunk 20220525_easteregg" alt="Street map of Maungawhau with an elevation overlay restricted to terrain above 130 meters. Lower ground remains visible on the base map." width="100%" />

```r


# Contour lines

ggtile +
  geom_spatraster_contour(data = volcano2_easter, binwidth = 10)
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_easteregg-3.webp" title="plot of chunk 20220525_easteregg" alt="Street map of Maungawhau overlaid with elevation contours at 10-meter intervals. Nested contours outline the crater and its rim." width="100%" />

```r


# Contour lines + contour polygons

ggtile +
  geom_spatraster_contour_filled(
    data = volcano2_easter,
    breaks = seq(70, 210, 20),
    alpha = 0.7
  ) +
  geom_spatraster_contour(
    data = volcano2_easter, binwidth = 2.5,
    alpha = 0.7, size = .2, color = "grey10"
  ) +
  coord_sf(expand = FALSE)
```

<img src="https://dieghernan.github.io/assets/img/blog/20220525_easteregg-4.webp" title="plot of chunk 20220525_easteregg" alt="Street map of Maungawhau overlaid with colored elevation bands at 20-meter intervals and contour lines at 2.5-meter intervals." width="100%" />
