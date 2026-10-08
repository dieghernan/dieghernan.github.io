---
title: "Happy Valentine's Day"
subtitle: "Do you know the Bonne projection?"
tags:
  - r_bloggers
  - beautiful_maps
  - rstats
  - rspatial
  - maps
  - ggplot2
  - sf
  - giscoR
redirect_from:
  - /202402_st_valentine/
output:
  md_document:
    variant: gfm
    preserve_yaml: yes
  html_document:
header_img: https://dieghernan.github.io/assets/img/blog/202402_bonne_proj.webp
og_image_width: 3000
og_image_height: 3000
og_image_type: "image/webp"
og_image_alt: "World map in a heart-shaped Bonne projection, with a Valentine greeting above it."
---

Do you know the [Bonne
Projection](https://en.wikipedia.org/wiki/Bonne_projection)? This is a very
special one, as it produces this result when used to map the whole world. Happy
Valentine’s Day!

```r
library(sf)
library(dplyr)
library(giscoR)
library(ggplot2)
library(showtext)


world <- gisco_get_countries()

# Shaped ocean

h_earth <- world %>%
  # Fine grid
  st_make_grid(n = c(50, 50)) %>%
  # Bonne projection
  st_transform("ESRI:54024") %>%
  # To sf object (data-frame like)
  st_sf(couple = 2, someval = 1, .)


# And finally

font_add_google(name = "Emilys Candy", family = "emilys")

showtext_auto()

ggplot() +
  geom_sf(data = h_earth, fill = "#f9b7bb", color = "#f9b7bb") +
  geom_sf(data = world, fill = "#d24658", color = "#d24658") +
  theme_void() +
  labs(
    title = "Happy Valentine's Day",
    caption = "Bonne Projection (ESRI:54024)"
  ) +
  theme(
    plot.background = element_rect(
      fill = "#faddcf",
      color = "transparent"
    ),
    text = element_text(family = "emilys", colour = "#d24658"),
    plot.title = element_text(hjust = 0.5, size = rel(3)),
    plot.caption = element_text(hjust = 0.5, size = rel(2))
  )
```

<img src="https://dieghernan.github.io/assets/img/blog/202402_bonne_proj.webp" alt="World map in a heart-shaped Bonne projection, with a Valentine greeting above it." width="100%" />
