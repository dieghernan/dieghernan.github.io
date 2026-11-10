---
title: "Never trust a map"
subtitle: "All of them are dirty liars."
description: >-
  Put the same circles on twelve world maps and see what each projection
  does to them.
header_img: "https://dhhdevblog.netlify.app/assets/img/drafts/never-trust-a-map-og-perspective-1.webp"
og_image: "https://dhhdevblog.netlify.app/assets/img/drafts/never-trust-a-map-og-perspective-1.webp"
og_image_width: 1200
og_image_height: 630
og_image_type: image/webp
og_image_alt: >-
  A vertical perspective of Earth above North Africa, with red indicatrices
  that flatten toward the horizon.
tags:
  - rstats
  - rspatial
  - maps
  - ggplot2
  - sf
  - giscoR
output:
  html_document: default
  md_document:
    variant: gfm
    preserve_yaml: true
---

<!-- TODO: Add the r_bloggers tag when this post is published. -->





All maps lie. Some lie more than others, and some are deliberately designed to
mislead us. Mark Monmonier wrote a whole book about it. [*How to Lie with
Maps*](https://press.uchicago.edu/ucp/books/book/chicago/H/bo27400568.html)

Take election maps. [Land doesn't vote. People do.](https://storymaps.arcgis.com/stories/0e636a652d44484b9457f953994b212b)
Yet a vast, sparsely populated
region can dominate a map, while a densely populated city barely gets noticed.
[See the same election mapped several
ways](https://www.esri.com/about/newsroom/arcwatch/explore-a-map-of-election-results)

Change the color scale or the class breaks on a choropleth and the same data can
tell a very different story.
[See what changing the class breaks does](https://www.esri.com/about/newsroom/arcuser/better-breaks-define-your-maps-purpose).
For a worked example with municipal income data from Spain, see
[Cómo (no) mentir con la visualización](https://cdr-book.github.io/datos-espaciales.html#no-mentir) (in Spanish).

But even the most honest maps lie.

The Earth is (approximately) spherical, and there’s no way to represent its
curved surface on a flat map without distorting something. A projection can
preserve some properties, such as area or local angles, at the expense of
others.

Fortunately, we have a lie detector.

## Meet Tissot’s indicatrices

Imagine covering the globe with identical small circles. When you flatten
the Earth, those circles can change size, shape or both. The area of each
resulting ellipse shows how much the projection enlarges or shrinks the area
at that location. Its shape reveals whether the projection stretches more in
one direction than another.

### A quick technical note

The `geom_tissot()` function in **crstools** approximates Tissot's infinitesimal
circles by projecting geographic buffers of a fixed radius. For point-by-point
measurements, the **tissot** package calculates local distortion factors with
PROJ.

Let's put some maps to the test.

## Same circles, different maps

We start with the same grid for all twelve projections. That's 99 points in
nine rows and eleven columns, with a circle of 350 km radius at each point.
The red shapes show what happens to those circles when we change the projection.





## Three ways to handle distortion

Each approach makes a different trade-off.

- **Conformal.** These projections preserve local angles and shapes, so tiny
  circles stay round even when their size changes. Mercator is useful for
  navigation because a constant compass bearing follows a straight line.
- **Equal-area.** These projections keep areas in proportion, even when shapes
  stretch. Equal Earth works well for thematic world maps, where readers may
  want to compare how much land different regions or categories cover.
- **Compromise.** These projections balance different kinds of distortion. Both
  area and shape can change. Robinson and Winkel Tripel are useful for
  general-purpose world maps and atlases, where the overall view matters.

## Web Mercator

If the circles are still circles, where's the lie?

<img src="/assets/img/drafts/never-trust-a-map-web-mercator-1.webp" alt="Web Mercator world map with red circles that grow from the equator toward the top and bottom of the map." width="100%" />

Web Mercator comes close to the classic **conformal** pattern. Compare the
middle row with the rows above and below. The circles stay roughly round, but
they grow much larger toward high latitudes. That's how Greenland ends up
looking so big.

## Equal Earth

Equal Earth is an **equal-area** projection. What happens to the circles when
we preserve area?

<img src="/assets/img/drafts/never-trust-a-map-equal-earth-1.webp" alt="Equal Earth world map with red ellipses of roughly equal area that become flatter toward high latitudes." width="100%" />

The shapes give the game away. The circles flatten toward the top and bottom,
but their areas stay roughly the same.

## Winkel Tripel

Winkel Tripel is a **compromise** projection. What happens when we let both
shape and area change?

<img src="/assets/img/drafts/never-trust-a-map-winkel-tripel-1.webp" alt="Winkel Tripel world map with red indicatrices that vary in size and become more elongated away from the center." width="100%" />

Follow the second row from the top, east across Russia, and watch the
ellipses stretch and tilt. Then compare them with the equatorial row to see
how their areas change as well.

## Twelve ways to flatten the world

Pick a red circle near Greenland and follow it from map to map. The last two
views share a center over North Africa. The vertical perspective shows less of
the globe because its viewpoint is only 10,000 km above the surface. Both views
include a bonus circle at the North Pole.

<i class="fa-solid fa-exclamation"></i> Each map is scaled independently to
fit its panel. Compare circle sizes **within** each map. You can compare
shapes across panels.
{: .alert .alert-warning .p-3 .mx-2 .mb-3}

<img src="/assets/img/drafts/never-trust-a-map-projection-gallery-1.webp" alt="Twelve world maps in a four-row, three-column grid. Red indicatrices vary in area and shape across projections. The final two panels compare a vertical perspective and an orthographic view centered over North Africa, both with an extra indicatrix at the North Pole." width="100%" />

The outlines can fool you, too. Equal Earth and the heart-shaped Bonne look
quite different, yet both preserve area. Here's one way to group the twelve
projections shown in the poster.

- **Conformal pattern.** Web Mercator.
- **Equal-area.** Equal Earth, Mollweide, Sinusoidal, Hammer, Bonne and Goode
  homolosine.
- **Compromise.** Winkel Tripel and Robinson.
- **Equidistant along meridians.** Plate carrée.
- **Perspective views.** Vertical perspective and Orthographic.

So which map should you trust? It depends on what you're asking it to show.
Choose an equal-area map to compare areas, a conformal one when local angles
matter or a compromise for an overall view. The question is whether the lie
helps you see what you're looking for.

## How we drew it

<details class="my-4" markdown="1">

<summary>Show the R code</summary>

In **R**, we get country boundaries from **giscoR**, build the grid with **sf**
and draw the maps with **ggplot2** and **crstools**. The setup also loads Inter
Tight for the map titles. The drawing function handles Goode's cuts and the
horizons of the two perspective views.


``` r
map_family <- "inter-tight"
sysfonts::font_add_google("Inter Tight", family = map_family)
showtext::showtext_opts(dpi = knitr::opts_chunk$get("dpi"))
showtext::showtext_auto()
library(crstools)
library(ggplot2)
library(sf)

meridians <- seq(-150, 150, 30)
parallels <- seq(-75, 75, length.out = 9)
earth_radius <- 6371007.181
buffer_km <- 350
map_background <- "grey90"
perspective_height <- 10000000
view_center <- "+lat_0=30 +lon_0=10"

projections <- c(
  setNames("EPSG:4326", "Plate carr\u00e9e"),
  "Web Mercator" = "EPSG:3857",
  "Robinson" = "+proj=robin",
  "Winkel Tripel" = "+proj=wintri",
  "Mollweide" = "ESRI:54009",
  "Sinusoidal" = "ESRI:54008",
  "Equal Earth" = "+proj=eqearth +datum=WGS84",
  "Hammer" = "+proj=hammer +R=6371007.181",
  "Bonne" = "ESRI:54024",
  "Goode homolosine" = "+proj=igh +R=6371007.181",
  "Vertical perspective" = sprintf(
    "+proj=nsper %s +R=%.3f +h=%.0f", view_center, earth_radius, perspective_height
  ),
  "Orthographic" = sprintf("+proj=ortho %s +R=%.3f", view_center, earth_radius)
)

frame <- st_linestring(rbind(
  c(-175, 85),
  c(175, 85),
  c(175, -85),
  c(-175, -85),
  c(-175, 85)
)) |>
  st_segmentize(5) |>
  st_cast("POLYGON") |>
  st_sfc(crs = 4326)

world <- giscoR::gisco_get_countries(epsg = 4326, resolution = 3)
graticule <- st_graticule(frame, lon = meridians, lat = parallels)

goode_lat <- c(90:-90, rep(c(-90:0, 0:-90), 3), -90:90, 90:0, 0:90, 90)
goode_lon <- c(
  rep(180, 181),
  rep(c(80.01, 79.99, -19.99, -20.01, -99.99, -100.01), each = 91),
  rep(-180, 181),
  rep(c(-40.01, -39.99), each = 91),
  180
)
goode_frame <- st_sfc(st_polygon(list(cbind(goode_lon, goode_lat))), crs = 4326)

goode_lobes <- rbind(
  c(-180, -40, 0, 90),
  c(-40, 180, 0, 90),
  c(-180, -100, -90, 0),
  c(-100, -20, -90, 0),
  c(-20, 80, -90, 0),
  c(80, 180, -90, 0)
)

goode_lines <- lapply(seq_len(nrow(goode_lobes)), function(index) {
  bounds <- goode_lobes[index, ]
  longitude <- seq(bounds[1] + 0.01, bounds[2] - 0.01, length.out = 361)
  latitude <- seq(bounds[3] + 0.01, bounds[4] - 0.01, length.out = 181)
  lng <- meridians[meridians > bounds[1] & meridians < bounds[2]]
  lat <- parallels[parallels > bounds[3] & parallels < bounds[4]]
  c(
    lapply(lng, function(x) st_linestring(cbind(x, latitude))),
    lapply(lat, function(y) st_linestring(cbind(longitude, y)))
  )
})
goode_grid <- st_sfc(
  c(
    list(st_linestring(cbind(seq(-179.99, 179.99, length.out = 721), 0))),
    do.call(c, goode_lines)
  ),
  crs = 4326
)
```


``` r
indicatrices <- function(lng, lat) {
  geom_tissot(
    data = world,
    radius = units::as_units(buffer_km, "km"),
    fill = "#E63946",
    color = "#A4161A",
    alpha = 0.65,
    centres = list(lng = lng, lat = lat)
  )
}

draw_map <- function(title) {
  projection <- projections[[title]]
  grid <- graticule
  circles <- indicatrices(meridians, parallels)
  land <- st_geometry(world)
  radians <- pi / 180
  buffer_limit <- sin(buffer_km * 1000 / earth_radius)

  if (title == "Goode homolosine") {
    outline <- st_transform(goode_frame, projection)
    grid <- st_transform(goode_grid, projection)
    circles <- lapply(parallels, function(lat) {
      cuts <- if (lat > 0) -40 else c(-100, -20, 80)
      longitude_gap <- abs((outer(meridians, cuts, "-") + 180) %% 360 - 180)
      distance <- sin(pmin(longitude_gap, 90) * radians) * cos(lat * radians)
      visible <- meridians[apply(distance, 1, min) > buffer_limit]
      indicatrices(visible, lat)
    })
  } else if (title %in% c("Vertical perspective", "Orthographic")) {
    height <- if (title == "Vertical perspective") perspective_height else Inf
    horizon <- acos(earth_radius / (earth_radius + height))
    disk_radius <- earth_radius / sqrt(1 + 2 * earth_radius / height)
    outline <- st_sfc(st_point(c(0, 0)), crs = projection) |>
      st_buffer(disk_radius, nQuadSegs = 180)

    # Clip land just inside the horizon in a distance-preserving projection.
    distance_crs <- sprintf("+proj=aeqd %s +R=%.3f", view_center, earth_radius)
    visible_cap <- st_sfc(st_point(c(0, 0)), crs = distance_crs) |>
      st_buffer(horizon * earth_radius - 1, nQuadSegs = 180)
    land <- st_transform(land, distance_crs, partial = TRUE) |>
      st_make_valid() |>
      st_intersection(visible_cap)

    if (title == "Vertical perspective") {
      grid <- st_geometry(grid) |>
        st_transform(distance_crs) |>
        st_intersection(visible_cap) |>
        st_transform(projection, partial = FALSE)
    }

    # Keep circles whose entire buffer fits inside the horizon.
    buffer_cutoff <- cos(horizon - buffer_km * 1000 / earth_radius)
    circles <- lapply(parallels, function(lat) {
      cosine <- sin(lat * radians) * sin(30 * radians) +
        cos(lat * radians) * cos(30 * radians) *
          cos((meridians - 10) * radians)
      visible <- meridians[cosine > buffer_cutoff]
      if (length(visible)) indicatrices(visible, lat)
    })
    # All meridians meet at the pole, so draw one circle there.
    circles <- c(circles, list(indicatrices(10, 90)))
  } else {
    outline <- st_transform(frame, projection, partial = TRUE)
  }

  limits <- st_bbox(outline)
  land <- st_transform(land, projection, partial = TRUE)
  if (st_is_longlat(land)) {
    # Clip the longitude-latitude panel in its display coordinates.
    land <- st_set_crs(land, NA) |>
      st_make_valid() |>
      st_intersection(st_set_crs(outline, NA)) |>
      st_set_crs(projection)
  } else {
    land <- st_intersection(st_make_valid(land), st_make_valid(outline))
  }

  ggplot() +
    geom_sf(data = outline, fill = "white", color = NA) +
    geom_sf(data = land, fill = "grey70", color = "grey70", linewidth = 0.15) +
    geom_sf(
      data = grid,
      color = "grey40",
      alpha = 0.45,
      linewidth = 0.3
    ) +
    geom_sf(data = outline, fill = NA, color = "grey30", linewidth = 0.75) +
    circles +
    coord_sf(
      crs = projection,
      xlim = limits[c("xmin", "xmax")],
      ylim = limits[c("ymin", "ymax")],
      datum = NA
    ) +
    labs(title = title) +
    theme_void(base_family = map_family) +
    theme(
      plot.title = element_text(face = "bold"),
      plot.margin = margin(10, 10, 10, 10),
      plot.background = element_rect(fill = map_background, color = NA),
      panel.background = element_rect(fill = map_background, color = NA)
    )
}
```


``` r
draw_map("Web Mercator")
draw_map("Equal Earth")
draw_map("Winkel Tripel")
```

</details>

<details class="my-4" markdown="1">

<summary>Show the gallery code</summary>


``` r
featured <- c("Web Mercator", "Equal Earth", "Winkel Tripel")
gallery_order <- c(featured, setdiff(names(projections), featured))

grid::grid.newpage()
grid::grid.rect(gp = grid::gpar(fill = map_background, col = NA))
grid::pushViewport(grid::viewport(
  width = 0.92,
  height = 0.92,
  layout = grid::grid.layout(
    7, 3,
    heights = grid::unit(c(2, 1.5, 1, 10, 10, 10, 10), "null")
  )
))
grid::grid.text(
  "One Earth, twelve projections",
  gp = grid::gpar(
    fontfamily = map_family, fontsize = 25, fontface = "bold", col = "grey15"
  ),
  vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1:3)
)
grid::grid.text(
  "Each red shape starts as a circle with a radius of 350 km",
  gp = grid::gpar(fontfamily = map_family, fontsize = 14, col = "grey25"),
  vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 1:3)
)

for (index in seq_along(gallery_order)) {
  title <- gallery_order[[index]]
  grid::pushViewport(grid::viewport(
    layout.pos.row = (index - 1) %/% 3 + 4,
    layout.pos.col = (index - 1) %% 3 + 1,
    layout = grid::grid.layout(2, 1, heights = grid::unit(c(1, 9), "null"))
  ))
  grid::grid.text(
    title,
    gp = grid::gpar(
      fontfamily = map_family, fontsize = 14, fontface = "bold", col = "grey15"
    ),
    vp = grid::viewport(layout.pos.row = 1)
  )
  grid::pushViewport(grid::viewport(layout.pos.row = 2))
  map <- draw_map(title) + theme(plot.title = element_blank())
  print(map, vp = grid::viewport(width = 0.94, height = 0.94))
  grid::popViewport(2)
}
grid::popViewport()
```

</details>



## References

- Fernández-Avilés, G. (2024). Trabajando con datos espaciales. In G.
  Fernández-Avilés & J.-M. Montero (Eds.), *Fundamentos de ciencia de datos
  con R* (Chapter 40). McGraw Hill. <https://cdr-book.github.io/datos-espaciales.html>.
- Monmonier, M. (2018). *How to lie with maps* (3rd ed.). University of Chicago
  Press.
- Snyder, J. P. (1987). *Map projections--A working manual*. U.S. Geological
  Survey. <https://doi.org/10.3133/pp1395>
- Tissot, N. A. (1881). *Mémoire sur la représentation des surfaces et les
  projections des cartes géographiques*. Gauthier-Villars.
