library(terra)
library(tidyterra)
library(ggplot2)

output_dir <- file.path("_experiments", "switzerland-hillshade")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
data_dir <- path.expand("~/R/mapslib/misc")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
elevation <- geodata::elevation_30s("CHE", path = data_dir)
elevation <- clamp(elevation, lower = 0, values = TRUE)
names(elevation) <- "elevation"
slope <- terrain(elevation, "slope", unit = "radians")
aspect <- terrain(elevation, "aspect", unit = "radians")

# Hillshade with gray colors.
hill <- shade(slope, aspect, 0, 60)

hill_plot <- ggplot() +
  geom_spatraster(data = hill, show.legend = FALSE, maxcell = Inf) +
  # Use a grayscale palette.
  scale_fill_gradient(
    high = "white",
    low = "gray20",
    na.value = "transparent"
  )

# Extract the hillshade colors.
hill_cols <- layer_data(hill_plot) |>
  pull(fill)
range(elevation)

p1 <- ggplot() +
  geom_spatraster(data = hill, fill = hill_cols) +
  # geom_spatraster(
  #   data = elevation,
  #   inherit.aes = FALSE,
  #   aes(alpha = after_stat(value))
  # ) +
  # scale_fill_cross_blended_c(breaks = seq(0, 5000, 1000)) +
  # scale_alpha(range = c(1, 0.25)) +
  coord_sf(expand = FALSE) +
  labs(
    title = "Elevation of Switzerland",
    subtitle = "terra",
    x = NULL,
    y = NULL
  ) +
  guides(
    alpha = "none",
    fill = guide_colourbar(
      direction = "horizontal",
      barwidth = grid::unit(4, "in"),
      barheight = grid::unit(0.15, "in")
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    plot.background = element_rect(fill = "grey97", colour = NA),
    plot.margin = margin(12, 12, 12, 12)
  )


p1
ggsave(
  file.path(output_dir, paste0("switzerland-", "terra", ".png")),
  p1,
  device = ragg::agg_png,
  width = 8,
  height = 6.5,
  dpi = 180
)

# metR
library(dplyr)
deriv <- function(z, x) {
  c(NA_real_, diff(z) / diff(x))
}
sun.angle <- 60
metr <- elevation |>
  select(z = elevation) |>
  as_tibble(xy = TRUE) |>
  group_by(y) |>
  mutate(dx = deriv(z, x)) |>
  ungroup() |>
  group_by(x) |>
  mutate(dy = deriv(z, y)) |>
  ungroup() |>
  filter(!is.na(dx), !is.na(dy)) |>
  mutate(
    shade = (cos(atan2(-dy, -dx) - (sun.angle + 90) * pi / 180) + 1) / 2,
    shade = coalesce(shade, 0)
  ) |>
  select(x, y, shade) |>
  as_spatraster()

crs(metr) <- pull_crs(elevation)

p2 <- ggplot() +
  geom_spatraster(data = metr) +
  scale_fill_gradient(
    high = "white",
    low = "gray20",
    na.value = "transparent"
  ) +
  # geom_relief(aes(z = elevation)) +
  #   geom_spatraster(
  #     data = elevation,
  #     inherit.aes = FALSE,
  #     aes(alpha = after_stat(value))
  #   ) +
  # scale_fill_cross_blended_c(breaks = seq(0, 5000, 1000)) +
  #   scale_alpha(range = c(1, 0.25)) +
  coord_sf(expand = FALSE, crs = pull_crs(elevation)) +
  labs(
    title = "Elevation of Switzerland",
    subtitle = "metR",
    x = NULL,
    y = NULL
  ) +
  guides(
    alpha = "none",
    fill = "none"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    plot.background = element_rect(fill = "grey97", colour = NA),
    plot.margin = margin(12, 12, 12, 12)
  )

p2
ggsave(
  file.path(output_dir, paste0("switzerland-", "metR", ".png")),
  p2,
  device = ragg::agg_png,
  width = 8,
  height = 6.5,
  dpi = 180
)

# Con overlay
library(maptiles)
library(terra)

pol <- elevation |> as.polygons() |> as_sf()

rgb_tile <- maptiles::get_tiles(
  pol,
  crop = TRUE,
  provider = "Esri.WorldShadedRelief",
  zoom = 7,
  project = TRUE
)

m <- mask(rgb_tile, pol)


p3 <- ggplot() +
  geom_spatraster_rgb(data = m) +
  coord_sf(expand = FALSE) +
  labs(
    title = "Elevation of Switzerland",
    subtitle = "tile",
    x = NULL,
    y = NULL
  ) +
  guides(
    alpha = "none",
    fill = guide_colourbar(
      direction = "horizontal",
      barwidth = grid::unit(4, "in"),
      barheight = grid::unit(0.15, "in")
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    plot.background = element_rect(fill = "grey97", colour = NA),
    plot.margin = margin(12, 12, 12, 12)
  )

p3
ggsave(
  file.path(output_dir, paste0("switzerland-", "tile", ".png")),
  p3,
  device = ragg::agg_png,
  width = 8,
  height = 6.5,
  dpi = 180
)

magick::image_read(file.path(
  output_dir,
  paste0("switzerland-", c("terra", "tile", "metR"), ".png")
)) |>
  magick::image_append() |>
  magick::image_write(file.path(output_dir, "switzerland-comparison.png"))


writeLines(
  trimws(capture.output(sessionInfo()), which = "right"),
  file.path(output_dir, "session-info.txt")
)

# No borrar
# deriv <- function(z, x) {
#   c(NA_real_, diff(z) / diff(x))
# }
#
# r |>
#   select(z = elevation) |>
#   as_tibble(xy = TRUE) |>
#   group_by(y) |>
#   mutate(dx = deriv(z, x)) |>
#   ungroup() |>
#   group_by(x) |>
#   mutate(dy = deriv(z, y)) |>
#   ungroup() |>
#   filter(!is.na(dx), !is.na(dy)) |>
#   mutate(
#     shade = (cos(atan2(-dy, -dx) - (sun.angle + 90) * pi / 180) + 1) / 2,
#     shade = coalesce(shade, 0)
#   ) |>
#   select(x,y,shade) |>
#   as_spatraster() |>
#   autoplot()
#
#
# deriv <- function(z, x) {
#   c(NA_real_, diff(z) / diff(x))
# }
#
#
# sun.angle = 60
# coords <- r |>
#   select(z = elevation) |>
#   as_tibble(xy = TRUE)
#
# coords$dx <- unsplit(
#   lapply(split(coords, coords$y), \(d) deriv(d$z, d$x)),
#   coords$y
# )
#
# coords$dy <- unsplit(
#   lapply(split(coords, coords$x), \(d) deriv(d$z, d$y)),
#   coords$x
# )
#
# coords <- coords[!is.na(coords$dx) & !is.na(coords$dy), ]
#
# angle <- (sun.angle + 90) * pi / 180
#
# coords$shade <- (cos(atan2(-coords$dy, -coords$dx) - angle) + 1) / 2
# coords$shade[is.na(coords$shade)] <- 0
#
# aaa <- coords |>
#   select(x,y,shade) |>
#   as_spatraster()
#
# ggplot() +
#   geom_spatraster(data = aaa) +
#   scale_fill_gradient(
#     high =  "white",
#     low = "gray20",
#     na.value = "transparent"
#   )
