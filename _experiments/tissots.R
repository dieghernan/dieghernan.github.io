projections <- c(
  "Plate Carreé" = "EPSG:4326",
  # Familiar
  "Web Mercator" = "EPSG:3857",
  "Robinson" = "+proj=robin",
  "Winkel Tripel" = "+proj=wintri",

  # Equal-area
  "Mollweide" = "ESRI:54009",
  "Sinusoidal" = "ESRI:54008",
  "Equal Earth" = "+proj=eqearth +datum=WGS84",
  "Hammer" = "+proj=hammer +R=6371007.181",

  # Unusual
  "Bonne" = "ESRI:54024",
  "Goode Homolosine" = "+proj=igh +R=6371007.181",
  "Van der Grinten" = "ESRI:54029",
  "Bertin 1953" = "+proj=bertin1953 +R=6371007.181",
  "Orthographic (Asia)" = "+proj=ortho +lat_0=3 +lon_0=3 +datum=WGS84"
)

map_colors <- c(
  ocean = "white",
  land = "grey70",
  tissot = "#E63946",
  tissot_border = "#A4161A",
  coastline = "grey70",
  graticule = "grey40",
  outline = "grey30",
  background = "grey90"
)

library(giscoR)
library(crstools)
library(sf)
library(ggplot2)
library(tissot)
library(tidyverse)

i <- 4

proj <- projections[i] |> unname()


bbox <- st_linestring(rbind(
  c(-175, 85),
  c(175, 85),
  c(175, -85),
  c(-175, -85),
  c(-175, 85)
)) |>
  st_segmentize(5) |>
  st_cast("POLYGON") |>
  st_sfc(crs = 4326)


sf_use_s2(FALSE)
grat <- st_graticule(bbox, lon = seq(-150, 150, 50), lat = seq(-75, 75, 25)) |>
  st_make_valid() |>
  st_transform(proj, partial = TRUE)


coast <- giscoR::gisco_get_countries(epsg = 4326) |>
  st_geometry() |>
  st_cast("POLYGON") |>
  st_make_valid() |>
  st_intersection(bbox) |>
  suppressWarnings() |>
  st_transform(proj, partial = TRUE) |>
  st_sf(x = 1) |>
  st_make_valid()


coast <- coast |>
  st_geometry() |>
  st_intersection(st_transform(bbox, proj, partial = TRUE)) |>
  st_make_valid() |>
  st_sf(x = 1)
sf_use_s2(TRUE)


limits <- bbox |>
  st_transform(proj) |>
  st_bbox() |>
  as.vector()

ggplot(coast) +
  geom_sf(data = bbox, fill = map_colors["ocean"], color = NA) +
  geom_sf(
    fill = map_colors["land"],
    color = map_colors["coastline"],
    linewidth = 0.15
  ) +
  geom_sf(
    data = grat,
    color = map_colors["graticule"],
    alpha = 0.45,
    linewidth = 0.3
  ) +
  geom_sf(
    data = bbox,
    fill = NA,
    color = map_colors["outline"],
    linewidth = 0.75
  ) +
  geom_tissot(
    radius = units::as_units(500, "km"),
    fill = map_colors["tissot"],
    color = map_colors["tissot_border"],
    alpha = 0.65,
    centres = list(
      lng = seq(-150, 150, 50),
      lat = seq(-75, 75, 25)
    )
  ) +
  coord_sf(datum = NA, ylim = limits[c(2, 4)], xlim = limits[c(1, 3)]) +
  labs(title = names(projections[i])) +
  theme(
    plot.background = element_rect(fill = map_colors["background"]),
    panel.background = element_rect(fill = map_colors["background"])
  )

# # Ortho
# library(sf)
# library(ggplot2)
# library(crstools)
#
# map_colors <- c(
#   ocean = "white",
#   land = "grey70",
#   tissot = "#E63946",
#   tissot_border = "#A4161A",
#   coastline = "grey70",
#   graticule = "grey40",
#   outline = "grey30",
#   background = "grey90"
# )
#
# crs_ortho <- paste(
#   "+proj=ortho",
#   "+lat_0=30",
#   "+lon_0=10",
#   "+R=6371007.181",
#   "+type=crs"
# )
# coast <- giscoR::gisco_get_countries(epsg = 4326) |>
#   st_geometry() |>
#   st_cast("POLYGON") |>
#   st_make_valid() |>
#   st_transform(crs_ortho, partial = TRUE) |>
#   st_sf(x = 1)
#
# coast <- coast[!st_is_empty(coast),]
#
#
# bbox <- st_point(x = c(0,0)) |>
#   st_buffer(dist = 6371000) |>
#   st_sfc(crs = crs_ortho)
#
# bbox_grat <- st_linestring(rbind(
#   c(-175, 85),
#   c(175, 85),
#   c(175, -85),
#   c(-175, -85),
#   c(-175, 85)
# )) |>
#   st_segmentize(5)  |>
#   st_cast("POLYGON") |>
#   st_sfc(crs = 4326)
#
# grat <- st_graticule(bbox_grat,
#                      lon = seq(-150, 150, 50),
#                      lat = seq(-75, 75, 25)
# ) |>
#   st_make_valid() |>
#   st_transform(crs_ortho, partial = TRUE)
#
# grat <- grat[!st_is_empty(grat),]
#
#
# ggplot(coast) +
#   geom_sf(data = bbox, fill = map_colors["ocean"], color = NA) +
#   geom_sf(
#     fill = map_colors["land"],
#     color = map_colors["coastline"],
#     linewidth = 0.15
#   ) +
#   geom_sf(
#     data = grat,
#     color = map_colors["graticule"],
#     alpha = 0.45,
#     linewidth = 0.3
#   ) +
#   geom_sf(
#     data = bbox,
#     fill = NA,
#     color = map_colors["outline"],
#     linewidth = 0.75
#   ) +
#   geom_tissot(
#     radius = units::as_units(500, "km"),
#     fill = map_colors["tissot"],
#     color = map_colors["tissot_border"],
#     alpha = 0.65,
#     centres = list(
#       lng = c(seq(-150, 150, 50), 0),
#       lat = c(seq(-75, 75, 25), 90)
#     )
#   ) +
#   coord_sf(datum = NA) +
#   labs(title = "Ortographic") +
#   theme(
#     plot.background = element_rect(fill = map_colors["background"]),
#     panel.background = element_rect(fill = map_colors["background"])
#   )
