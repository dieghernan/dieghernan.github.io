---
title: "Insets with ggplot2 and tmap - and mapsf!"
subtitle: "A map on a map"
last_modified_at: 2022-03-03
tags: [r_bloggers,rstats,rspatial, maps,sf,ggplot2, tmap, mapSpain, mapsf, inset]
header_img: ./assets/img/blog/20220303_inset.png
excerpt: A common challenge when creating maps is how to include an inset map on 
  your visualization. An inset map is a smaller map usually included on a corner 
  that may provide additional context to the overall map, or may include map 
  units than won't be usually represented properly.
output: 
  md_document:
    variant: gfm
    preserve_yaml: true
---

*This post is dedicated to [Dominic Royé](https://dominicroye.github.io/en/), AKA [\@dr_xeo](https://twitter.com/dr_xeo)*

A common challenge when creating maps is how to include an inset map on your visualization. An inset map is nothing more than a smaller map usually included on a corner that may provide additional context to the overall map. It is also useful for representing spatial units that may form part of a country but its geographical location would imply an imperfect visualization, or even to include small units that otherwise won't be shown on the map.

I have already covered this [using the base `plot()` function](https://dieghernan.github.io//201911_QuickR/), but this time I would show how to produce these insets using the `ggplot2` and the `tmap` packages. In short: **use `cowplot` package**.

## Test case: Canary Island as an inset

On this example, I would create a map of Spain using `mapSpain` and creating an inset for the Canary Islands.

The "true" map of Spain is:

``` r
library(mapSpain)
library(sf)
library(ggplot2)
library(dplyr)

regions <- esp_get_ccaa(moveCAN = FALSE)

ggplot(regions) +
  geom_sf()
```

<img src="https://dieghernan.github.io/assets/img/blog//20220303_truemap-1.png" title="plot of chunk 20220303_truemap" alt="plot of chunk 20220303_truemap" width="100%"/>

I would use a different CRS for each part of Spain. In the case of mainland Spain I would use ETRS89 / UTM 30N ([EPSG:25830](https://epsg.io/25830)) and for the Canary Islands I would use REGCAN95 / UTM 28N ([EPSG:4083](https://epsg.io/4083))

``` r
main <- regions %>%
  filter(ccaa.shortname.es != "Canarias") %>%
  st_transform(25830)

ggplot(main) +
  geom_sf()
```

<img src="https://dieghernan.github.io/assets/img/blog//20220303_mainsub-1.png" title="plot of chunk 20220303_mainsub" alt="plot of chunk 20220303_mainsub" width="100%"/>

``` r
island <- regions %>%
  filter(ccaa.shortname.es == "Canarias") %>%
  st_transform(4083)

ggplot(island) +
  geom_sf()
```

<img src="https://dieghernan.github.io/assets/img/blog//20220303_mainsub-2.png" title="plot of chunk 20220303_mainsub" alt="plot of chunk 20220303_mainsub" width="100%"/>

So that was easy! Just a couple of maps using `ggplot2`. Let's start mixing and matching!

## On `ggplot2`

We have already created two quick maps on `ggplot2`. Now, to produce our map with insets we would:

1.  Produce two plots: The main plot and the sub plot providing a minimal style. We would store them as `ggplot2` objects.

2.  We would combine both objects with `cowplot`.

``` r
# Main plot
main_gg <- ggplot(main) +
  geom_sf() +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "grey85", colour = NA),
    # Add a bit of margin on the bottom left
    # We would place the inset there
    plot.margin = margin(l = 80, b = 80)
  )

# Sub plot
sub_gg <- ggplot(island) +
  geom_sf() +
  theme_void() +
  # Add a border to the inset
  theme(
    panel.border = element_rect(fill = NA, colour = "black"),
    plot.background = element_rect(fill = "grey95")
  )
```

We have our objects in place, and now is when the magic happens! With `cowplot` we can combine both maps on a single one. You may need to play a bit with the parameters `x`, `y` `hjust` and `vjust` of the sub plot to improve the placement:

``` r
library(cowplot)

ggdraw() +
  draw_plot(main_gg) +
  draw_plot(sub_gg,
    height = 0.2,
    x = -0.25,
    y = 0.08
  )
```

<img src="https://dieghernan.github.io/assets/img/blog//20220303_insetggplot-1.png" title="plot of chunk 20220303_insetggplot" alt="plot of chunk 20220303_insetggplot" width="100%"/>

Note also that this approach is valid not only for maps, but for all type of plot produced by `ggplot2`, since this package is not specific for map objects:

``` r
# Combining non-spatial plots
library(palmerpenguins)

mass_flipper <- ggplot(
  data = penguins,
  aes(
    x = flipper_length_mm,
    y = body_mass_g
  )
) +
  geom_point(aes(
    color = species,
    shape = species
  ),
  size = 3,
  alpha = 0.8
  ) +
  theme_minimal() +
  scale_color_manual(values = c("darkorange", "purple", "cyan4"))

flipper_hist <- ggplot(data = penguins, aes(x = flipper_length_mm)) +
  geom_histogram(aes(fill = species),
    alpha = 0.5,
    position = "identity",
    show.legend = FALSE
  ) +
  scale_fill_manual(values = c("darkorange", "purple", "cyan4")) +
  theme_void() +
  theme(plot.background = element_rect(fill = "white"))


# Non-sense plot!
ggdraw() +
  draw_plot(mass_flipper) +
  draw_plot(flipper_hist,
    scale = 0.25,
    y = 0.3,
    x = -0.2
  )
```

<img src="https://dieghernan.github.io/assets/img/blog//20220303_insetggplot_nonsense-1.png" title="plot of chunk 20220303_insetggplot_nonsense" alt="plot of chunk 20220303_insetggplot_nonsense" width="100%"/>

## On `tmap`

We can follow a similar approach on `tmap`. On versions v3.x.x (there is a new [revamped version on development](https://github.com/r-tmap/tmap/issues/599)) we can use [`tmap_grob()`](https://github.com/r-tmap/tmap/issues/541) to convert the `tmap` objects to the objects that `cowplot` can handle.

``` r
library(tmap)

main_tmap <- tm_shape(main) +
  tm_polygons() +
  tm_layout(
    inner.margins = c(.3, .3, 0, 0),
    frame = FALSE
  )


main_tmap <- tmap_grob(main_tmap)

sub_tmap <- tm_shape(island) +
  tm_polygons()

sub_tmap <- tmap_grob(sub_tmap)
```

Once that we have these new "grobs", we can use the same approach than we applied to `ggplot2` objects.

``` r
ggdraw() +
  draw_plot(main_tmap) +
  draw_plot(sub_tmap,
    height = 0.3,
    x = -0.2
  )
```

<img src="https://dieghernan.github.io/assets/img/blog//20220303_insettmap-1.png" title="plot of chunk 20220303_insettmap" alt="plot of chunk 20220303_insettmap" width="100%"/>

## Update: On `mapsf`

[Timotheé Giraud](https://rgeomatic.hypotheses.org/) (AKA [\@rgeomatic](https://twitter.com/rgeomatic)), the developer of `mapsf`, shared also how to create inset maps using that package:

``` r
library(mapsf)

mf_map(main)
mf_inset_on(island, pos = "bottomright", cex = .3)
mf_map(island)
box(lwd = .5)
mf_inset_off()
```

<img src="https://dieghernan.github.io/assets/img/blog//20220303_insetmapsf-1.png" title="plot of chunk 20220303_insetmapsf" alt="plot of chunk 20220303_insetmapsf" width="100%"/>
