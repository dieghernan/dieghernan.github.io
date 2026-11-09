# Based on the map gallery in _Rmd/never-trust-a-map.Rmd and Michael Sumner's
# experiment: https://gist.github.com/mdsumner/045b19365f605492baed2fe85b15afd5
library(ggplot2)
library(sf)

projections <- c(
  "Web Mercator" = "EPSG:3857",
  "Miller" = "+proj=mill +R=6378137 +type=crs",
  "Gall-Peters" = "+proj=cea +lat_ts=45 +datum=WGS84 +type=crs",
  "Robinson" = "+proj=robin +type=crs",
  "Equal Earth" = "+proj=eqearth +datum=WGS84 +type=crs"
)

world <- giscoR::gisco_get_countries(epsg = 4326, resolution = 10)
world <- world[world$CNTR_ID != "AQ", ]
# Use a common latitude cutoff inside Web Mercator's usable range.
land <- st_geometry(world) |>
  st_set_crs(NA) |>
  st_make_valid() |>
  st_crop(xmin = -180, xmax = 180, ymin = -85, ymax = 85) |>
  st_collection_extract("POLYGON") |>
  st_cast("POLYGON") |>
  st_set_crs(4326)

anchors <- st_coordinates(st_centroid(st_set_crs(land, NA)))
anchors <- st_as_sf(
  as.data.frame(anchors),
  coords = c("X", "Y"),
  crs = 4326
) |>
  st_geometry()

equal_earth <- st_transform(land, projections[["Equal Earth"]])
areas <- as.numeric(st_area(equal_earth))
large <- which(areas > 5e8)

local_shapes <- lapply(large, function(i) {
  xy <- st_coordinates(anchors[i])
  local_crs <- sprintf(
    "+proj=laea +lon_0=%.10f +lat_0=%.10f +datum=WGS84 +type=crs",
    xy[1, "X"],
    xy[1, "Y"]
  )
  st_transform(land[i], local_crs)[[1]]
}) |>
  st_sfc()

frame <- st_bbox(c(xmin = -180, xmax = 180, ymin = -85, ymax = 85), crs = 4326)
grid <- st_graticule(
  frame,
  lon = seq(-150, 150, 50),
  lat = seq(-75, 75, 25)
) |>
  st_geometry()

# Select the largest polygon in each geographic window.
island_windows <- rbind(
  "Greenland" = c(-75, -10, 59, 85),
  "Madagascar" = c(42, 52, -27, -11),
  "South Island" = c(165, 175, -48, -40)
)
island_ids <- apply(island_windows, 1, function(bounds) {
  xy <- st_coordinates(anchors)
  candidates <- which(
    xy[, "X"] > bounds[1] &
      xy[, "X"] < bounds[2] &
      xy[, "Y"] > bounds[3] &
      xy[, "Y"] < bounds[4]
  )
  candidates[which.max(areas[candidates])]
})
stopifnot(
  length(island_ids) == nrow(island_windows),
  all(island_ids %in% large)
)
island_names <- factor(names(island_ids), levels = rownames(island_windows))

projection_layers <- lapply(names(projections), function(name) {
  crs <- projections[[name]]
  label <- factor(name, levels = names(projections))
  projected <- if (name == "Equal Earth") {
    equal_earth
  } else {
    st_transform(land, crs)
  }
  # Both layers will be drawn as Cartesian coordinates.
  projected <- st_set_crs(projected, NA)
  positions <- st_coordinates(st_transform(anchors, crs))
  placed <- lapply(seq_along(large), function(i) {
    local_shapes[[i]] + positions[large[i], c("X", "Y")]
  }) |>
    st_sfc()
  centered <- lapply(island_ids, function(i) {
    projected[[i]] - positions[i, c("X", "Y")]
  }) |>
    st_sfc()

  list(
    land = st_sf(projection = label, geometry = projected),
    grid = st_sf(
      projection = label,
      geometry = st_set_crs(st_transform(grid, crs), NA)
    ),
    reference = st_sf(projection = label, geometry = placed),
    island_land = st_sf(
      projection = label,
      island = island_names,
      geometry = centered
    ),
    island_reference = st_sf(
      projection = label,
      island = island_names,
      geometry = local_shapes[match(island_ids, large)]
    )
  )
})

collect_layer <- function(name) {
  do.call(rbind, lapply(projection_layers, `[[`, name))
}

map_theme <- theme_void() +
  theme(
    plot.background = element_rect(fill = "grey90", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.spacing = grid::unit(6, "pt"),
    strip.text = element_text(face = "bold", margin = margin(5, 5, 5, 5)),
    plot.title = element_text(face = "bold"),
    plot.margin = margin(10, 10, 10, 10)
  )

world_comparison <- ggplot() +
  geom_sf(data = collect_layer("land"), fill = "grey70", color = NA) +
  geom_sf(
    data = collect_layer("grid"),
    color = "grey40",
    alpha = 0.35,
    linewidth = 0.2
  ) +
  geom_sf(
    data = collect_layer("reference"),
    fill = NA,
    color = "#A4161A",
    linewidth = 0.25
  ) +
  facet_wrap(vars(projection), ncol = 3) +
  coord_sf(datum = NA) +
  labs(
    title = "Same land, different projections",
    subtitle = "Gray shows the global projection. Red shows each piece in local LAEA."
  ) +
  map_theme

island_comparison <- ggplot() +
  geom_sf(data = collect_layer("island_land"), fill = "grey70", color = NA) +
  geom_sf(
    data = collect_layer("island_reference"),
    fill = NA,
    color = "#A4161A",
    linewidth = 0.4
  ) +
  facet_grid(island ~ projection) +
  coord_sf(datum = NA) +
  labs(
    title = "Three islands at the same scale",
    subtitle = "Each pair shares the same geographic anchor. Red shows local LAEA."
  ) +
  map_theme

output_dir <- "_experiments/local-laea"
ggsave(
  file.path(output_dir, "world.png"),
  world_comparison,
  width = 12,
  height = 9,
  dpi = 200
)
ggsave(
  file.path(output_dir, "islands.png"),
  island_comparison,
  width = 13,
  height = 9,
  dpi = 200
)
