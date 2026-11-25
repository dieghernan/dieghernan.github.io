---
review: always
tags_choose_4: rstats,function,music,r_bloggers,rnaturalearth,rspatial,sf
description: User-defined function using the <strong>sf</strong> package
cover_image: https://dieghernan.github.io/assets/img/blog/20190505_benchmarkfunction-1.webp
cover_image_bk: ~
series: review
ai_disclosure_level: no_ai
---

Has alerts? TRUE
Has Spotify? TRUE
Has iframe? FALSE
Has details_summary? FALSE
Has math? FALSE
Has includes? TRUE

<div role="note" aria-label="Note" class="callout-note" markdown="1">

**Update (25 November 2026)**

The maps now use **ggplot2** and a shared palette to make the individual segments easier to follow.

</div>

This post introduces a user-defined function for casting **sf** objects of class `LINESTRING` or `POLYGON` into substrings.

## Required **R** packages

``` r
library(sf)
library(rnaturalearth)
library(dplyr)
library(ggplot2)

background <- "#FAF8F2"
foreground <- "#203B47"
map_title <- "inter-tight"
map_regular <- "inter"
segment_palette <- c("#D7191C", "#D89C00", "#0057B8")

sysfonts::font_add_google("Inter Tight", family = map_title)
sysfonts::font_add_google("Inter", family = map_regular)
showtext::showtext_opts(dpi = knitr::opts_chunk$get("dpi"))
showtext::showtext_auto()

theme_set(
  theme_grey(paper = background, base_family = map_regular, ink = foreground) +
    theme(
      plot.title = element_text(family = map_title, face = "bold"),
      legend.title = element_text(family = map_title, face = "bold"),
      panel.background = element_rect(fill = background),
      panel.grid = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      strip.background = element_rect(fill = background),
      strip.text = element_text(family = map_title, face = "bold", rel = 0.7, lineheight = 22),
      strip.clip = "off",
      plot.margin = margin(10, 10, 10, 10)
    )
)
```

## The problem

The **sf** package includes [st_cast()](https://r-spatial.github.io/sf/reference/st_cast.html), a powerful function that transforms geometries into other types of geometries (i.e. `LINESTRING` to `POLYGON`, etc.).

``` r
italy <- ne_countries(country = "italy", returnclass = "sf")
italy_pol <- st_cast(italy, "POLYGON")
italy_lin <- st_cast(italy_pol, "LINESTRING")
italy_pt <- st_cast(italy_lin, "POINT")


italy_stages <- bind_rows(
  list(
    MULTIPOLYGON = st_sf(
      part_colour = rep_len(segment_palette, nrow(italy)),
      geometry = st_geometry(italy)
    ),
    POLYGON = st_sf(
      part_colour = rep_len(segment_palette, nrow(italy_pol)),
      geometry = st_geometry(italy_pol)
    ),
    LINESTRING = st_sf(
      line_colour = rep_len(segment_palette, nrow(italy_lin)),
      geometry = st_geometry(italy_lin)
    ),
    POINT = st_sf(geometry = st_geometry(italy_pt))
  ),
  .id = "stage"
) %>%
  mutate(stage = factor(stage, levels = unique(stage)))

ggplot(italy_stages) +
  geom_sf(
    data = filter(italy_stages, !stage %in% c("LINESTRING", "POINT")),
    aes(fill = part_colour),
    colour = foreground, linewidth = 0.35
  ) +
  geom_sf(
    data = filter(italy_stages, stage == "LINESTRING"),
    aes(colour = line_colour), linewidth = 1
  ) +
  geom_sf(
    data = filter(italy_stages, stage == "POINT"),
    colour = segment_palette[1]
  ) +
  scale_fill_identity() +
  scale_colour_identity() +
  facet_wrap(vars(stage), ncol = 2) +
  labs(title = "Italy by geometry type")
```

<img src="https://dieghernan.github.io/assets/img/blog/20190505_italycast-1.webp" alt="Four maps of Italy show a single fill for the multipolygon, separate colors for its polygon parts, boundary lines and individual vertices." width="100%" />

What I missed when using `st_cast()` was the possibility of breaking `LINESTRING` objects into subsegments:

<img src="https://dieghernan.github.io/assets/img/blog/20190505_italycastsub-1.webp" alt="Outline of Italy split into short line segments, with alternating colors distinguishing adjacent segments." width="100%" />

{% include snippets/spotify.html id="4aVuWgvD0X63hcOCnZtNFA" title="Hold the Line by Toto on Spotify" %}

## An approach

One way to split a line is to create a `LINESTRING` for each pair of consecutive vertices. Here is the outline of mainland Spain before and after splitting.

``` r
test <- ne_countries(country = "spain", returnclass = "sf") %>%
  st_cast("POLYGON") %>%
  slice_max(order_by = st_area(geometry), n = 1, with_ties = FALSE) %>%
  st_cast("LINESTRING")

coordinates <- st_coordinates(test)[, c("X", "Y")]
geom <- lapply(
  seq_len(nrow(coordinates) - 1),
  \(i) coordinates[c(i, i + 1), , drop = FALSE]
) %>%
  st_multilinestring() %>%
  st_sfc(crs = st_crs(test)) %>%
  st_cast("LINESTRING")

spain_stages <- bind_rows(
  st_sf(
    stage = "Original line",
    segment_colour = foreground,
    geometry = st_geometry(test)
  ),
  st_sf(
    stage = "Individual segments",
    segment_colour = rep_len(segment_palette, length(geom)),
    geometry = geom
  )
) %>%
  mutate(stage = factor(stage, levels = unique(stage)))

ggplot(spain_stages) +
  geom_sf(aes(colour = segment_colour), linewidth = 1) +
  scale_colour_identity() +
  facet_wrap(vars(stage), nrow = 1) +
  labs(title = "One boundary, many segments")
```

<img src="https://dieghernan.github.io/assets/img/blog/20190505_testspain-1.webp" alt="Two outlines of mainland Spain. The left panel shows a continuous line and the right panel uses alternating colors to reveal individual segments." width="100%" />

## The function `stdh_cast_substring()`

Finally, I wrapped the solution into a function and extended it a little bit:

- When the input is not a `LINESTRING` or a `POLYGON`, it returns an error and stops.

- The function accepts **sf** objects with several rows or `sfc` objects with several geometries, and returns the same class as the input. In the case of **sf** objects, the input `data.frame` is added.

- By default, the output is a `MULTILINESTRING` geometry. This has the benefit that the output has the same number of geometries as the input. This can be modified by setting the `to` parameter to `LINESTRING`, which only casts the `MULTILINESTRING` object into `LINESTRING`.

``` r
stdh_cast_substring <- function(x, to = "MULTILINESTRING") {
  ggg <- st_geometry(x)

  if (!unique(st_geometry_type(ggg)) %in% c("POLYGON", "LINESTRING")) {
    stop("Input should be LINESTRING or POLYGON")
  }
  for (k in 1:length(st_geometry(ggg))) {
    sub <- ggg[k]
    geom <- lapply(
      1:(length(st_coordinates(sub)[, 1]) - 1),
      function(i) {
        rbind(
          as.numeric(st_coordinates(sub)[i, 1:2]),
          as.numeric(st_coordinates(sub)[i + 1, 1:2])
        )
      }
    ) %>%
      st_multilinestring() %>%
      st_sfc()

    if (k == 1) {
      endgeom <- geom
    } else {
      endgeom <- rbind(endgeom, geom)
    }
  }
  endgeom <- endgeom %>% st_sfc(crs = st_crs(x))
  if (class(x)[1] == "sf") {
    endgeom <- st_set_geometry(x, endgeom)
  }

  if (to == "LINESTRING") {
    endgeom <- endgeom %>% st_cast("LINESTRING")
  }
  return(endgeom)
}
```

The function could be improved in terms of performance. Given that it works at the coordinate level, high-resolution objects introduce some delay.

``` r
test100 <- ne_countries(
  continent = "south america",
  returnclass = "sf"
) %>%
  st_cast("POLYGON")

test50 <- ne_countries(50,
  continent = "south america",
  returnclass = "sf"
) %>%
  st_cast("POLYGON")


init <- Sys.time()
t1 <- stdh_cast_substring(test100, "LINESTRING")
end <- Sys.time()
knitr::kable(end - init, format = "markdown", col.names = "Computation time")
```

| Computation time |
|:-----------------|
| 0.1483591 secs   |

``` r


init <- Sys.time()
t2 <- stdh_cast_substring(test50, "LINESTRING")
end <- Sys.time()
knitr::kable(end - init, format = "markdown", col.names = "Computation time")
```

| Computation time |
|:-----------------|
| 4.732829 secs    |

``` r

t2$segment_colour <- rep_len(segment_palette, nrow(t2))

ggplot() +
  geom_sf(data = test50, fill = "#E6ECE7", colour = NA) +
  geom_sf(data = t2, aes(colour = segment_colour), linewidth = 1) +
  scale_colour_identity() +
  coord_sf(xlim = c(-94, -32), ylim = c(-58, 15), expand = FALSE) +
  labs(
    title = "South America in subsegments",
    subtitle = "Natural Earth boundaries at 1:50 million"
  )
```

<img src="https://dieghernan.github.io/assets/img/blog/20190505_benchmarkfunction-1.webp" alt="Map of South America with country boundaries split into short segments, illustrated with alternating colors." width="100%" />

There is a difference in performance: `test100` has 15 polygons decomposed into 914 substrings, while `test50` has 80 polygons decomposed into 8,414 substrings. The higher-resolution outlines take longer to split because they contain more vertices.
