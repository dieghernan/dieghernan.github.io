---
title: 'Better hillshading with R: the display matters'
subtitle: >-
  Same terrain, different shadows
excerpt: >-
  Build a shaded relief map step by step, from a transparent color overlay
  to multidirectional lighting with stretched contrast.
description: >-
  Compare hillshading with terra and metR, then combine elevation colors
  with multidirectional hillshade and contrast stretching using ggblend.
header_img: "https://dhhdevblog.netlify.app/assets/img/drafts/better-hillshading-R-final-map-with-stretched-hillshade-1.webp"
og_image: "https://dhhdevblog.netlify.app/assets/img/drafts/better-hillshading-R-final-map-with-stretched-hillshade-1.webp"
og_image_width: 1400
og_image_height: 1272
og_image_type: image/webp
og_image_alt: >-
  Shaded relief of the Strait of Gibraltar in greens and ochres with blue 
  bathymetry.
tags:
  - music
  - rstats
  - rspatial
  - maps
  - hillshading
  - ggplot2
  - tidyterra
  - terra
output:
  html_document: default
  md_document:
    variant: gfm
    preserve_yaml: true
mathjax: true
---



Lately, I've been revisiting my
[earlier](https://dieghernan.github.io/202210_tidyterra-hillshade/)
[posts](https://dieghernan.github.io/202212_tidyterra-hillshade-2/) on
hillshading and the [tidyterra
FAQs](https://dieghernan.github.io/tidyterra/articles/faqs.html). I wanted to
understand why two maps made from the same digital elevation model (DEM) could
look so different. How much of that comes from the hillshade, and how much from
the way we combine it with the elevation colors?

I ended up testing six different approaches to hillshading and blending. Here's how they compare.

![Six versions of the Strait of Gibraltar pair grayscale hillshades with color
maps, including two ways to combine the same multidirectional hillshade with
elevation
colors.](/assets/img/drafts/better-hillshading-R-hillshade-comparison-poster-1.webp)

Looking at these results, three decisions turned out to matter most: **how we calculate the hillshade, how we transform its tonal range and how we blend it with the elevation colors**.

I started with the basic alpha approach I had used in earlier maps. While
working on the **tidyterra** FAQs, I discovered `metR::geom_relief()` and gave
it a try. To my surprise, I preferred the
[**metR**](https://eliocamp.github.io/metR/) result.

## Data and setup

<!-- TODO: Use elevation tile zoom 7 for the final render (zoom 4 is for iteration). -->

In this post, I'm using a DEM for the area around the Strait of Gibraltar in
southern Spain. I get the boundary from **mapSpain** and use its bounding box to
download the elevation tiles with **elevatr**. Then I reproject the DEM to match
the boundary. The Strait maps share that DEM, and every color map uses
**tidyterra**'s `etopo1` elevation palette.

The terrain tiles include elevations on land and depths below sea level, so the
map also shows the seabed around the Strait.


``` r
library(terra)
library(mapSpain)
library(elevatr)
library(metR)
library(ggplot2)
library(tidyterra)
library(ggblend)

map_family <- "inter-tight"
sysfonts::font_add_google("Inter Tight", family = map_family)
showtext::showtext_opts(dpi = knitr::opts_chunk$get("dpi"))
showtext::showtext_auto()

map_background <- "#faf8f2"
theme_set(
  theme_minimal(base_family = map_family) +
    theme(
      plot.background = element_rect(fill = map_background, colour = NA),
      panel.background = element_rect(fill = map_background, colour = NA),
      plot.margin = margin(20, 20, 20, 20),
      panel.grid = element_blank(),
      plot.title = element_text(face = "bold", colour = "#203b47"),
      axis.text = element_text(colour = "#203b47"),
      legend.position = "bottom",
      legend.key = element_rect(fill = map_background, colour = NA),
      legend.spacing.x = unit(0, "pt")
    )
)

# The data

# Use Andalusia and Melilla to get the bbox.
the_strait <- esp_get_ccaa(c("Andalucia", "Melilla"), epsg = 3857)

# Create the cache directory if needed.

if (!dir.exists(tools::R_user_dir("elevatr", "cache"))) {
  dir.create(tools::R_user_dir("elevatr", "cache"), recursive = TRUE, )
}

dem <- get_elev_raster(
  the_strait,
  z = 7,
  clip = "bbox",
  tmp_dir = tools::R_user_dir("elevatr", "cache")
) |>
  rast()

dem <- project(dem, pull_crs(the_strait))
names(dem) <- "elevation"
```

## Hillshade with alpha

For my first attempt, I followed the example in the **terra** documentation. It
calculates slope and aspect from the DEM, creates a hillshade with a single
light direction and draws a semi-transparent elevation layer on top. I do the
same in **ggplot2** and set the elevation colors to 40% opacity with
`alpha = 0.4`.

I set the sun 40° above the horizon, with light coming from the west-northwest
(300°). Then, I draw the hillshade in grayscale, extract the colors with
`layer_data()` and pass those colors directly to the hillshade layer.


``` r
slope_1 <- terrain(dem, "slope", unit = "radians")
aspect_1 <- terrain(dem, "aspect", unit = "radians")

# Single shadow
hill_1 <- shade(slope_1, aspect_1, 40, direction = 300)

pal_greys <- hcl.colors(1000, "Grays")

gghill_1 <- ggplot() +
  geom_spatraster(data = hill_1, maxcell = Inf, show.legend = FALSE) +
  scale_fill_gradientn(colors = pal_greys, na.value = NA) +
  coord_sf(expand = FALSE) +
  labs(title = "Single-direction hillshade", x = NULL, y = NULL)

# Show

print(gghill_1)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-single-direction-hillshade-1.webp" alt="Grayscale relief map of the Strait of Gibraltar. Slopes facing west-northwest catch the light, outlining ridges in the east while the Guadalquivir lowlands stay mostly smooth." width="100%" />

``` r

# Get colors

pal_1 <- layer_data(gghill_1) |> dplyr::pull(fill)

plot_brks <- seq(-2500, 3500, by = 500)
elevation_legend <- guide_legend(
  title = "Elevation (m)",
  direction = "horizontal",
  nrow = 1,
  keywidth = unit(0.38, "in"),
  keyheight = unit(0.14, "in"),
  theme = theme(
    legend.text.position = "bottom",
    legend.title.position = "top",
    legend.text = element_text(size = 8),
    legend.key.spacing.x = unit(2, "pt")
  ),
  override.aes = list(alpha = 1)
)
```


``` r
map_alpha <- ggplot() +
  geom_spatraster(data = hill_1, fill = pal_1, maxcell = Inf) +
  geom_spatraster(data = dem, maxcell = Inf) +
  scale_fill_hypso_tint_c(
    "etopo1",
    alpha = 0.4,
    breaks = plot_brks,
    labels = scales::label_comma()
  ) +
  guides(alpha = "none", fill = elevation_legend) +
  coord_sf(expand = FALSE) +
  labs(title = "Transparent color overlay", x = NULL, y = NULL)

print(map_alpha)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-transparent-color-overlay-1.webp" alt="Relief map with muted greens in the lowlands, ochres in the mountains and blue offshore. Ridges lit from the west-northwest show through the pale colors." width="100%" />

## Shaded relief with metR {#shaded-relief-with-metr}

Enter **metR**. This is the approach I tried in the **tidyterra** FAQs using
`metR::geom_relief()`. Here I plot the hillshade directly from the DEM with the
elevation colors on top. This time I map `alpha` to elevation, so more of the
hillshade shows through in the mountains. I kept the light coming from the same
direction. `sun.angle = 60` in **metR** corresponds to an azimuth of 300° in
**terra**.


``` r
hill_metr <- ggplot(dem, aes(x, y)) +
  geom_relief(aes(z = elevation)) +
  coord_sf(crs = terra::crs(dem), expand = FALSE) +
  labs(title = "Hillshade with metR", x = NULL, y = NULL)

print(hill_metr)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-metr-hillshade-1.webp" alt="High-contrast grayscale relief map. Alternating dark and light slopes define the eastern mountains and trace ridges on the seabed south of the coast." width="100%" />


``` r
map_metr <- ggplot(dem, aes(x, y)) +
  geom_relief(aes(z = elevation)) +
  geom_spatraster(
    data = dem,
    inherit.aes = FALSE,
    aes(alpha = after_stat(value)),
    maxcell = Inf
  ) +
  scale_alpha(range = c(1, 0.25)) +
  scale_fill_hypso_tint_c(
    "etopo1",
    breaks = plot_brks,
    labels = scales::label_comma()
  ) +
  guides(alpha = "none", fill = elevation_legend) +
  coord_sf(expand = FALSE) +
  labs(title = "Elevation-dependent transparency", x = NULL, y = NULL)

print(map_metr)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-metr-relief-map-1.webp" alt="Relief map with pale ochre mountains, green lowlands and blue water. High-contrast shading is most visible in the eastern ranges, where the elevation colors are more transparent." width="100%" />

Look at the mountains in the east. The ridges stood out more clearly and the
colors felt less washed out, but I'd changed two things at once: the hillshade
itself and how I combined it with the elevation colors.

**Could I get closer to the metR map just by changing how I blended the
hillshade with the elevation colors?**

<details markdown="1">

<summary><strong>A quick note on what metR is doing</strong></summary>

As I discovered later, `geom_relief()` shades slopes mainly by the direction
they face. In mountainous terrain, this can make ridges and valleys stand out
strongly. I'll come back to how that works in [the bonus
section](#bonus-recreating-metrs-relief-shading-from-scratch).

</details>

## Introducing ggblend

Before changing how I calculated the shadows, I wanted to test the other half of the problem: how the hillshade interacts with the elevation colors. Could a different blend get me closer to the **metR** result without changing the underlying shade?

[Barney Harris](https://barney.fly.dev/2026/01/27/ggplot2-blending-adventure/)
noticed that the colors in the first version of my Romania map looked a bit
washed out when I made the elevation colors transparent. He showed what happens
when you blend the two layers with `multiply` in **ggblend**.

I kept the same hillshade and elevation palette, then used
`ggblend::blend("multiply")` to blend the hillshade over the colors at 85%
opacity. Let's see how it looks.


``` r
map_multiply <- ggplot() +
  list(
    geom_spatraster(data = dem, maxcell = Inf),
    scale_fill_hypso_tint_c(
      "etopo1",
      breaks = plot_brks,
      labels = scales::label_comma()
    ),
    geom_spatraster(data = hill_1, fill = pal_1, maxcell = Inf, alpha = .85)
  ) |>
  blend("multiply") +
  guides(alpha = "none", fill = elevation_legend) +
  coord_sf(expand = FALSE) +
  labs(title = "Multiply blend", x = NULL, y = NULL)

print(map_multiply)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-multiply-single-direction-hillshade-1.webp" alt="Relief map with deeper greens and blues than the transparent overlay. Dark slopes add texture to the ochre mountains while the western lowlands remain mostly smooth." width="100%" />

The colors looked better without changing the hillshade itself. That answered part of my question about blending, but left another open: **what was I losing by using a single light direction?**

## Enhancing the hillshading

So far, my **terra** hillshade has used a single light source from the
west-northwest. [Dominic
Royé](https://dominicroye.github.io/blog/hillshade-effect/#multidirectional-shadows)
shows what happens when you light the terrain from four directions. He keeps the
sun at the same angle above the horizon.

So let's try lighting the terrain from four directions. I kept the multiply
blend and the light 40° above the horizon. I shifted Royé's four directions so
they're centered near the same 300° azimuth, then averaged the four hillshades.


``` r
hill_2 <- shade(slope_1, aspect_1, 40, direction = c(220, 320, 10, 280)) |>
  mean()

gghill_2 <- ggplot() +
  geom_spatraster(data = hill_2, maxcell = Inf, show.legend = FALSE) +
  scale_fill_gradientn(colors = pal_greys, na.value = NA) +
  coord_sf(expand = FALSE) +
  labs(title = "Multidirectional hillshade", x = NULL, y = NULL)

# Show
print(gghill_2)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-multidirectional-hillshade-1.webp" alt="Grayscale relief map. Highlights pick out ridges running in several directions across the eastern mountains, with softer shadows on adjacent slopes." width="100%" />

``` r

# Get colors
pal_2 <- layer_data(gghill_2) |> dplyr::pull(fill)
```


``` r
map_multi <- ggplot() +
  list(
    geom_spatraster(data = dem, maxcell = Inf),
    scale_fill_hypso_tint_c(
      "etopo1",
      breaks = plot_brks,
      labels = scales::label_comma()
    ),
    geom_spatraster(data = hill_2, fill = pal_2, maxcell = Inf, alpha = .85)
  ) |>
  blend("multiply") +
  guides(alpha = "none", fill = elevation_legend) +
  coord_sf(expand = FALSE) +
  labs(title = "Multidirectional multiply blend", x = NULL, y = NULL)

print(map_multi)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-multiply-multidirectional-hillshade-1.webp" alt="Relief map with textured ochre mountain ridges, deep green lowlands in the west and blue offshore areas where the seabed texture remains visible." width="100%" />

The extra light directions revealed more of the terrain, but I still preferred the **metR** map. Maybe the remaining difference wasn't the lighting alone, but how strongly the shadows affected the colors.

## One more trick: the alpha hack

Both **ggblend** maps looked darker than the **metR** map, so I tried [Timo
Grossenbacher's alpha
hack](https://timogrossenbacher.ch/bivariate-maps-with-ggplot2-and-sf/). I map
the hillshade values to `alpha`, leaving `fill` free for the elevation palette
and its legend. With `range = c(0.6, 0)`, the darkest parts of the hillshade get
the most opacity and the lightest become transparent. In the [**metR**
map](#shaded-relief-with-metr), I mapped elevation to `alpha` instead.

I draw the same multidirectional hillshade over the elevation colors. The
hillshade values stay the same.


``` r
map_multi_alpha <- ggplot() +
  geom_spatraster(data = dem, maxcell = Inf) +
  geom_spatraster(
    data = hill_2, fill = pal_2, maxcell = Inf,
    aes(alpha = after_stat(value))
  ) +
  scale_fill_hypso_tint_c(
    "etopo1",
    breaks = plot_brks,
    labels = scales::label_comma()
  ) +
  scale_alpha(range = c(0.6, 0)) +
  guides(alpha = "none", fill = elevation_legend) +
  coord_sf(expand = FALSE) +
  labs(title = "Multidirectional alpha hack", x = NULL, y = NULL)

plot(map_multi_alpha)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-multiply-multidirectional-alpha-1.webp" alt="Relief map with textured ochre mountain ridges, deep green lowlands in the west and blue offshore areas. Colors are lighter than when using ggblend" width="100%" />

Almost there. The colors were brighter, but the result still lacked the contrast
and definition I liked in the **metR** map. Changing the blend mode and opacity
had helped, yet something was still missing. Perhaps the tonal range of the
hillshade itself mattered too.

## Jackpot! Stretching the hillshade

An earlier experiment comparing **metR** and **terra** on Swiss elevation data
suggested a possible explanation. The calculation behind `geom_relief()`
produces shade values between 0 and 1, as I explain in [the bonus
section](#bonus-recreating-metrs-relief-shading-from-scratch). In that test,
the **terra** hillshade covered a noticeably narrower range.

<div class="alert alert-success p-3 mx-2 mb-3" markdown="1">

<i class="fa-solid fa-lightbulb"></i> **What if I stretch the hillshade before
blending it with the elevation colors?**

</div>

I map the 5th percentile of the multidirectional hillshade to 0 and the 95th
to 1. I rescale the values in between linearly and clip the rest to 0 or 1.

Stretching makes subtle terrain features easier to see by increasing contrast.
The underlying elevation data stay the same.

I also wanted a brighter result, closer to the **metR** map. Let's see what happens when I stretch the hillshade and use a lighter grayscale ramp.


``` r
# Stretching
q <- as.numeric(quantile(values(hill_2), c(0.05, 0.95), na.rm = TRUE))

hill_3 <- clamp((hill_2 - q[1]) / diff(q), 0, 1)

gghill_3 <- ggplot() +
  geom_spatraster(data = hill_3, maxcell = Inf, show.legend = FALSE) +
  scale_fill_gradient(
    high = "white",
    low = "gray80",
    na.value = "transparent"
  ) +
  coord_sf(expand = FALSE) +
  labs(title = "Stretched multidirectional hillshade", x = NULL, y = NULL)

# Show
print(gghill_3)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-stretch-multidirectional-hillshade-1.webp" alt="Grayscale relief map with a pale background and sharper gray shadows along the eastern mountain ridges and the slopes of the seabed." width="100%" />

``` r

# Get colors
pal_3 <- layer_data(gghill_3) |> dplyr::pull(fill)
```


``` r
map_final <- ggplot() +
  list(
    geom_spatraster(data = hill_3, fill = pal_3, maxcell = Inf),
    geom_spatraster(data = dem, maxcell = Inf),
    scale_fill_hypso_tint_c(
      "etopo1",
      breaks = plot_brks,
      labels = scales::label_comma()
    )
  ) |>
  blend("multiply") +
  guides(alpha = "none", fill = elevation_legend) +
  coord_sf(expand = FALSE) +
  labs(title = "Stretched hillshade with multiply", x = NULL, y = NULL)

print(map_final)
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-final-map-with-stretched-hillshade-1.webp" alt="Relief map of the Strait of Gibraltar with bright blue bathymetry, green lowlands and ochre mountains. Fine shadows define the eastern ridges and the seabed." width="100%" />

The full map looks promising, but I wanted to check whether the finer mountain ridges benefited too. The devil is in the details. For this closer look at Sierra Nevada, I downloaded
a separate DEM and used it for all four maps. Look at the same ridges in the two
bottom panels to see what the stretch and lighter gray ramp change.

<details markdown="1" class="my-4">

<summary>Show the Sierra Nevada code</summary>


``` r
sierra_area <- sf::st_bbox(
  c(xmin = -3.75, ymin = 36.83, xmax = -2.75, ymax = 37.34),
  crs = sf::st_crs(4326)
) |>
  sf::st_as_sfc() |>
  sf::st_transform(sf::st_crs(terra::crs(dem)))

sierra_nevada <- sf::st_bbox(sierra_area)

# Download beyond the frame so the edge cells have neighbors.
sierra_dem <- get_elev_raster(
  sf::st_as_sf(sf::st_buffer(sierra_area, dist = 1000)),
  z = 9,
  clip = "bbox",
  tmp_dir = tools::R_user_dir("elevatr", "cache")
) |>
  rast()
names(sierra_dem) <- "elevation"

sierra_slope <- terrain(sierra_dem, "slope", unit = "radians")
sierra_aspect <- terrain(sierra_dem, "aspect", unit = "radians")
sierra_single <- shade(sierra_slope, sierra_aspect, 40, direction = 300)
sierra_multi <- shade(
  sierra_slope, sierra_aspect, 40,
  direction = c(220, 320, 10, 280)
) |>
  mean()

sierra_q <- quantile(
  values(crop(sierra_multi, vect(sierra_area))),
  c(0.05, 0.95),
  na.rm = TRUE
)
sierra_stretched <- clamp((sierra_multi - sierra_q[1]) / diff(sierra_q), 0, 1)

sierra_metr <- ggplot(sierra_dem, aes(x, y)) +
  geom_relief(aes(z = elevation), sun.angle = 60) +
  geom_spatraster(
    data = sierra_dem,
    inherit.aes = FALSE,
    aes(alpha = after_stat(value)),
    maxcell = Inf
  ) +
  scale_alpha(range = c(1, 0.25)) +
  scale_fill_hypso_tint_c("etopo1")

sierra_blend <- function(hillshade, gray_ramp) {
  hillshade_plot <- ggplot() +
    geom_spatraster(data = hillshade, maxcell = Inf) +
    scale_fill_gradientn(colors = gray_ramp, na.value = NA)
  hillshade_colors <- layer_data(hillshade_plot)$fill

  ggplot() +
    list(
      geom_spatraster(data = hillshade, fill = hillshade_colors, maxcell = Inf),
      geom_spatraster(data = sierra_dem, maxcell = Inf),
      scale_fill_hypso_tint_c("etopo1")
    ) |>
    blend("multiply")
}

sierra_multi_alpha <- function(hillshade, gray_ramp) {
  hillshade_plot <- ggplot() +
    geom_spatraster(data = hillshade, maxcell = Inf) +
    scale_fill_gradientn(colors = gray_ramp, na.value = NA)
  hillshade_colors <- layer_data(hillshade_plot)$fill

  ggplot() +
    geom_spatraster(data = sierra_dem, maxcell = Inf) +
    geom_spatraster(
      data = hillshade, fill = hillshade_colors, maxcell = Inf,
      aes(alpha = after_stat(value))
    ) +
    scale_alpha(range = c(0.6, 0)) +
    scale_fill_hypso_tint_c("etopo1")
}

sierra_view <- coord_sf(
  xlim = unname(sierra_nevada[c("xmin", "xmax")]),
  ylim = unname(sierra_nevada[c("ymin", "ymax")]),
  expand = FALSE,
  crs = terra::crs(sierra_dem),
  datum = NA
)
detail_theme <- theme(
  legend.position = "none",
  axis.title = element_blank(),
  plot.margin = margin(4, 5, 4, 5)
)

grid::grid.newpage()
grid::grid.rect(gp = grid::gpar(fill = map_background, col = NA))
grid::pushViewport(grid::viewport(
  width = 0.97,
  height = 0.97,
  layout = grid::grid.layout(2, 2)
))
print(
  sierra_metr + sierra_view + detail_theme + labs(title = "metR"),
  vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1)
)
print(
  sierra_blend(sierra_single, pal_greys) + sierra_view + detail_theme + labs(title = "West-northwest light"),
  vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 2)
)
print(
  sierra_multi_alpha(sierra_multi, pal_greys) + sierra_view + detail_theme + labs(title = "Multidirectional + alpha hack"),
  vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 1)
)
print(
  sierra_blend(sierra_stretched, c("gray80", "white")) + sierra_view + detail_theme + labs(title = "Stretched hillshade"),
  vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 2)
)
grid::popViewport()
```

</details>

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-sierra-nevada-detail-1.webp" alt="Four close-ups of Sierra Nevada in a two-by-two grid. The top row shows metR and the multiply blend lit from the west-northwest. The bottom row shows the multidirectional with alpha-hack and stretched versions. The last panel is brighter, with fine ridges visible across the mountain range." width="100%" />

## Comparing the maps

The Sierra Nevada close-up helps show what happens to fine ridges. To return to the original question about the whole map, I put all six versions side by side. The first and third rows use the same
single-direction hillshade, with different ways of combining the layers. The
fourth and fifth rows use the same multidirectional hillshade, so you can
compare the multiply blend with the alpha hack.

<details markdown="1" class="my-4">

<summary>Show the poster code</summary>


``` r
elevation_guide <- ggplotGrob(map_final)
elevation_guide <- elevation_guide$grobs[[
  match("guide-box-bottom", elevation_guide$layout$name)
]]

poster_theme <- theme(
  plot.title = element_blank(),
  legend.position = "none",
  plot.margin = margin(5, 8, 5, 8)
)
heading_style <- grid::gpar(
  fontfamily = map_family,
  fontface = "bold",
  fontsize = 14,
  col = "#203b47"
)

grid::grid.newpage()
grid::grid.rect(gp = grid::gpar(fill = map_background, col = NA))
grid::pushViewport(grid::viewport(
  width = 0.97,
  height = 0.97,
  layout = grid::grid.layout(
    9,
    3,
    widths = grid::unit(c(0.16, 1, 1), "null"),
    heights = grid::unit(c(0.31, 0.18, rep(1, 6), 0.3), "null")
  )
))

grid::grid.text(
  "Six ways to shade the Strait of Gibraltar",
  vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1:3),
  gp = grid::gpar(
    fontfamily = map_family, fontface = "bold", fontsize = 24, col = "#203b47"
  )
)
grid::grid.text(
  "Hillshade",
  vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 2),
  gp = heading_style
)
grid::grid.text(
  "Elevation colors",
  vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 3),
  gp = heading_style
)

grid::grid.text(
  "Fixed alpha",
  rot = 90,
  vp = grid::viewport(layout.pos.row = 3, layout.pos.col = 1),
  gp = heading_style
)
print(gghill_1 + poster_theme, vp = grid::viewport(layout.pos.row = 3, layout.pos.col = 2))
print(map_alpha + poster_theme, vp = grid::viewport(layout.pos.row = 3, layout.pos.col = 3))

grid::grid.text(
  "metR",
  rot = 90,
  vp = grid::viewport(layout.pos.row = 4, layout.pos.col = 1),
  gp = heading_style
)
print(hill_metr + poster_theme, vp = grid::viewport(layout.pos.row = 4, layout.pos.col = 2))
print(map_metr + poster_theme, vp = grid::viewport(layout.pos.row = 4, layout.pos.col = 3))

grid::grid.text(
  "Multiply",
  rot = 90,
  vp = grid::viewport(layout.pos.row = 5, layout.pos.col = 1),
  gp = heading_style
)
print(gghill_1 + poster_theme, vp = grid::viewport(layout.pos.row = 5, layout.pos.col = 2))
print(map_multiply + poster_theme, vp = grid::viewport(layout.pos.row = 5, layout.pos.col = 3))

grid::grid.text(
  "Multi + multiply",
  rot = 90,
  vp = grid::viewport(layout.pos.row = 6, layout.pos.col = 1),
  gp = heading_style
)
print(gghill_2 + poster_theme, vp = grid::viewport(layout.pos.row = 6, layout.pos.col = 2))
print(map_multi + poster_theme, vp = grid::viewport(layout.pos.row = 6, layout.pos.col = 3))

grid::grid.text(
  "Multi + alpha hack",
  rot = 90,
  vp = grid::viewport(layout.pos.row = 7, layout.pos.col = 1),
  gp = heading_style
)
print(gghill_2 + poster_theme, vp = grid::viewport(layout.pos.row = 7, layout.pos.col = 2))
print(map_multi_alpha + poster_theme, vp = grid::viewport(layout.pos.row = 7, layout.pos.col = 3))

grid::grid.text(
  "Stretched",
  rot = 90,
  vp = grid::viewport(layout.pos.row = 8, layout.pos.col = 1),
  gp = heading_style
)
print(gghill_3 + poster_theme, vp = grid::viewport(layout.pos.row = 8, layout.pos.col = 2))
print(map_final + poster_theme, vp = grid::viewport(layout.pos.row = 8, layout.pos.col = 3))

grid::pushViewport(grid::viewport(layout.pos.row = 9, layout.pos.col = 2:3))
grid::grid.draw(elevation_guide)
grid::popViewport(2)
```

</details>


<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-hillshade-comparison-poster-1.webp" alt="Six rows pair grayscale hillshades with color maps of the Strait of Gibraltar. The fourth and fifth rows compare multiply blending and the alpha hack using the same multidirectional hillshade." width="100%" />

Look at the coast in the first and third rows. With multiply, the greens along
the coast and the blues offshore are stronger, even though both maps use the
same hillshade. In the last row, the stretch and lighter gray ramp give the
seabed a brighter look, and I can still pick out its ridges. That's the version
I'd use for this map.

## Bonus: Recreating metR's relief shading from scratch {#bonus-recreating-metrs-relief-shading-from-scratch}

The stretched hillshade got me closer to the look I liked in the **metR** map.
But I still wanted to know what `geom_relief()` was doing differently. So I took
a look under the hood.

Luckily, Elio Campitelli, the developer of **metR**, wrote a post back in 2018
[explaining how he built
`geom_relief()`](https://eliocamp.github.io/codigo-r/2018/02/how-to-make-shaded-relief-in-r/).
He stumbled on a simple way to shade terrain and later learned that
cartographers call it [*aspect-based
shading*](https://ikgrelief.ethz.ch/analytical/shading-methods/). He was happy
with the result, though he also said it wasn't the best method and wanted to try
others.

Let's take a closer look using the current implementation of
[`metR::geom_relief()`](https://github.com/eliocamp/metR/blob/main/R/geom_relief.R).
While conventional hillshading uses both slope and aspect, aspect-based
hillshading uses just the downhill direction. A gentle slope and a steep slope
facing the same way can get exactly the same shade.

$$
I = \frac{1 + \cos(\theta - \alpha)}{2}
$$

Here $$\theta$$ is the downhill angle, computed with `atan2(-dy, -dx)`, and
$$\alpha$$ is the light direction, converted to radians from `sun.angle + 90`.
At `sun.angle = 0`, slopes that descend toward the north get the brightest
shade. Positive angles turn the light counterclockwise. The cosine gives an
intensity from 0 to 1.

I can get the same calculation on a regular grid with base **R** and **terra**.
I use three-point differences, centered in the interior and one-sided at the
edges. Raster rows run north to south, so the vertical step is negative.

The function loads the raster into memory and needs at least three rows and
three columns. It keeps the original CRS. I prefer a projected grid so both axes
measure distance in the same units.


``` r
hill_aspect_based <- function(x, sun.angle = 60) {
  stopifnot(
    inherits(x, "SpatRaster"), terra::nlyr(x) == 1L,
    nrow(x) >= 3L, ncol(x) >= 3L
  )
  z <- terra::as.matrix(x, wide = TRUE)
  spacing <- terra::res(x)

  deriv <- function(z, h) {
    n <- length(z)
    c(
      (-3 * z[1] + 4 * z[2] - z[3]) / (2 * h),
      (z[3:n] - z[1:(n - 2)]) / (2 * h),
      (3 * z[n] - 4 * z[n - 1] + z[n - 2]) / (2 * h)
    )
  }

  dx <- t(apply(z, 1, deriv, h = spacing[1]))
  dy <- apply(z, 2, deriv, h = -spacing[2])
  angle <- (sun.angle + 90) * pi / 180
  shade <- (1 + cos(atan2(-dy, -dx) - angle)) / 2
  shade[is.na(z)] <- NA_real_

  out <- terra::rast(x)
  terra::values(out) <- as.vector(t(shade))
  names(out) <- "relief"
  out
}
```

Here are the two versions side by side, using the Sierra Nevada DEM from the
close-up above. Both use the same map extent, light direction (`sun.angle = 60`)
and gray20-to-white ramp for intensities from 0 to 1.


``` r
light_direction <- 60
dark <- "gray20"
light <- "white"
hill_recreated <- hill_aspect_based(sierra_dem, sun.angle = light_direction)

map_view <- coord_sf(
  crs = terra::crs(sierra_dem),
  xlim = c(xmin(sierra_dem), xmax(sierra_dem)),
  ylim = c(ymin(sierra_dem), ymax(sierra_dem)),
  expand = FALSE
)

relief_metr <- ggplot(sierra_dem, aes(x, y)) +
  geom_relief(
    aes(z = elevation),
    sun.angle = light_direction, dark = dark, light = light,
    interpolate = FALSE
  ) +
  map_view +
  labs(title = "metR", x = NULL, y = NULL)

relief_terra <- ggplot() +
  geom_spatraster(
    data = hill_recreated, maxcell = Inf, interpolate = FALSE,
    show.legend = FALSE
  ) +
  scale_fill_gradient(low = dark, high = light, limits = c(0, 1), na.value = NA) +
  map_view +
  labs(title = "Base R and terra", x = NULL, y = NULL)

grid::grid.newpage()
grid::grid.rect(gp = grid::gpar(fill = map_background, col = NA))
grid::pushViewport(grid::viewport(
  width = 0.97,
  height = 0.97,
  layout = grid::grid.layout(1, 2)
))
print(relief_metr, vp = grid::viewport(layout.pos.col = 1))
print(relief_terra, vp = grid::viewport(layout.pos.col = 2))
grid::popViewport()
```

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-recreated-metr-relief-1.webp" alt="Two grayscale maps of Sierra Nevada compare metR with a base R and terra recreation. Both show similar bands of light and dark on mountain ridges and across valleys." width="100%" />

The two versions matched on a complete test grid with equally scaled axes. I
calculate the shade in raster coordinates, while **metR** uses the coordinates
transformed by **ggplot2**, so scaling the axes differently can change the
result. Around gaps, my version can leave a few extra cells blank because
**metR** can calculate across missing observations.

I liked what **metR** did in Sierra Nevada, but it didn't work as well for me in
the mostly flat terrain of [Doñana National
Park](https://en.wikipedia.org/wiki/Do%C3%B1ana_National_Park). **metR** shades
by aspect alone, so even a gentle slope can change shade sharply when it faces a
different direction. In the left panel, that can make the lowlands look rougher
than I want. I prefer the quieter result on the right, where I use the stretched
hillshade with multiply blending.

<details markdown="1" class="my-4">

<summary>Show the Doñana code</summary>


``` r
donana_area <- sf::st_bbox(
  c(xmin = -7.14, ymin = 36.80, xmax = -5.96, ymax = 37.40),
  crs = sf::st_crs(4326)
) |>
  sf::st_as_sfc() |>
  sf::st_transform(sf::st_crs(terra::crs(dem)))

donana <- sf::st_bbox(donana_area)

# Download beyond the frame so the edge cells have neighbors.
donana_dem <- get_elev_raster(
  sf::st_as_sf(sf::st_buffer(donana_area, dist = 1000)),
  z = 9,
  clip = "bbox",
  tmp_dir = tools::R_user_dir("elevatr", "cache")
) |>
  rast()

names(donana_dem) <- "elevation"

donana_slope <- terrain(donana_dem, "slope", unit = "radians")
donana_aspect <- terrain(donana_dem, "aspect", unit = "radians")
donana_multi <- shade(
  donana_slope, donana_aspect, 40,
  direction = c(220, 320, 10, 280)
) |>
  mean()

donana_q <- quantile(
  values(crop(donana_multi, vect(donana_area))),
  c(0.05, 0.95),
  na.rm = TRUE
)
donana_stretched <- clamp((donana_multi - donana_q[1]) / diff(donana_q), 0, 1)

donana_metr <- ggplot(donana_dem, aes(x, y)) +
  geom_relief(aes(z = elevation), sun.angle = 60) +
  geom_spatraster(
    data = donana_dem,
    inherit.aes = FALSE,
    aes(alpha = after_stat(value)),
    maxcell = Inf
  ) +
  scale_alpha(range = c(1, 0.25)) +
  scale_fill_hypso_tint_c("etopo1")

donana_blend <- function(hillshade, gray_ramp) {
  hillshade_plot <- ggplot() +
    geom_spatraster(data = hillshade, maxcell = Inf) +
    scale_fill_gradientn(colors = gray_ramp, na.value = NA)
  hillshade_colors <- layer_data(hillshade_plot)$fill

  ggplot() +
    list(
      geom_spatraster(data = hillshade, fill = hillshade_colors, maxcell = Inf),
      geom_spatraster(data = donana_dem, maxcell = Inf),
      scale_fill_hypso_tint_c("etopo1")
    ) |>
    blend("multiply")
}

donana_view <- coord_sf(
  xlim = unname(donana[c("xmin", "xmax")]),
  ylim = unname(donana[c("ymin", "ymax")]),
  expand = FALSE,
  crs = terra::crs(donana_dem),
  datum = NA
)
donana_theme <- theme(
  legend.position = "none",
  axis.title = element_blank(),
  plot.margin = margin(4, 5, 4, 5)
)

grid::grid.newpage()
grid::grid.rect(gp = grid::gpar(fill = map_background, col = NA))
grid::pushViewport(grid::viewport(
  width = 0.97,
  height = 0.97,
  layout = grid::grid.layout(1, 2)
))
print(
  donana_metr + donana_view + donana_theme + labs(title = "metR"),
  vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1)
)
print(
  donana_blend(donana_stretched, c("gray80", "white")) +
    donana_view + donana_theme + labs(title = "Stretched hillshade"),
  vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 2)
)
grid::popViewport()
```

</details>

<img src="https://dieghernan.github.io/assets/img/drafts/better-hillshading-R-metr-donana-1.webp" alt="Two maps of Doñana compare metR with a stretched hillshade blended with elevation colors. The metR map shows stronger light and dark patterns across the lowlands." width="100%" />

## What I learned

After all these experiments, here are my main takeaways:

- **Blending matters.** I started by changing the hillshading method, but how I combined the shadows with the elevation colors turned out to be just as important.
- **More light directions aren't always better.** Multidirectional hillshading revealed more terrain features, but it wasn't the improvement I was looking for on its own.
- **Don't underestimate contrast.** Stretching the hillshade and using a lighter gray ramp made the biggest visual difference in my map. Sometimes the answer is simpler than a new algorithm.
- **Choose the shading to suit the terrain.** For mountainous areas, I'd consider aspect-based shading, whether with **metR** or my own implementation. For flatter landscapes, I prefer the more restrained look of conventional hillshading.

In the end, I didn't find a universally better hillshading method. I found a combination that works better for the map I wanted to make.

<iframe class="d-block w-100 border-0 rounded my-3" title="In the Shadows by The Rasmus on Spotify" src="https://open.spotify.com/embed/track/31RLtLXs4hZsxzLMpe7gl5?theme=0" height="152" loading="lazy" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" allowfullscreen>

</iframe>

## References

- Campitelli, E. (2018, February 4). How to make a shaded relief in R. *Código
  R*.
  <https://eliocamp.github.io/codigo-r/2018/02/how-to-make-shaded-relief-in-r/>
- Campitelli, E. (2026). *metR: Tools for easier analysis of meteorological
  fields* (Version 0.19.0) [Computer software]. Zenodo.
  <https://doi.org/10.5281/zenodo.23231796>
- Grossenbacher, T. (2019, April 19). Bivariate maps with ggplot2 and sf. *Timo
  Grossenbacher*.
  <https://timogrossenbacher.ch/bivariate-maps-with-ggplot2-and-sf/>
- Harris, B. (2026, January 27). My ggplot2 blending adventure. *Reproducible
  Ruins*. <https://barney.fly.dev/2026/01/27/ggplot2-blending-adventure/>
- Hernangómez, D. (2023). Using the tidyverse with terra objects: The tidyterra
  package. *Journal of Open Source Software, 8*(91), Article 5751.
  <https://doi.org/10.21105/joss.05751>
- Horn, B. K. P. (1981). Hill shading and the reflectance map. *Proceedings of
  the IEEE, 69*(1), 14–47. <https://doi.org/10.1109/PROC.1981.11918>
- Mapzen. (n.d.). *Terrain tiles* [Data set]. Registry of Open Data on AWS.
  <https://registry.opendata.aws/terrain-tiles/>
- Royé, D. (2022, July 20). Hillshade effects. *Dr Dominic Royé*.
  <https://dominicroye.github.io/blog/hillshade-effect/>
- *Shading methods*. (2015, January 21). Relief Shading.
  <https://ikgrelief.ethz.ch/analytical/shading-methods/>
