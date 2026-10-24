# Run from the repository root:
# Rscript _experiments/bolivia-overlay/bolivia-overlay.R
# Adapted from https://dieghernan.github.io/tidyterra/dev/articles/faqs.html#overlay
library(terra)
library(tidyterra)
library(ggplot2)

output_dir <- file.path("_experiments", "bolivia-overlay")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
data_dir <- path.expand("~/R/mapslib/misc")
tile_dir <- file.path(data_dir, "maptiles")
dir.create(tile_dir, recursive = TRUE, showWarnings = FALSE)
mosaic_dir <- file.path(tile_dir, "mosaics")
dir.create(mosaic_dir, recursive = TRUE, showWarnings = FALSE)

# Use the elevation raster extent, with no vector boundary or vector mask.
message("Loading SRTM elevation...")
elevation <- geodata::elevation_30s("BOL", path = data_dir)
stopifnot(inherits(elevation, "SpatRaster"))
tile_extent <- sf::st_bbox(
  c(
    xmin = terra::xmin(elevation),
    ymin = terra::ymin(elevation),
    xmax = terra::xmax(elevation),
    ymax = terra::ymax(elevation)
  ),
  crs = sf::st_crs(terra::crs(elevation))
)

message("Loading the Esri shaded relief tiles...")
rgb_file <- file.path(mosaic_dir, "bolivia-relief-raster-extent.tif")
if (!file.exists(rgb_file)) {
  rgb_tile <- maptiles::get_tiles(
    sf::st_as_sfc(tile_extent),
    crop = TRUE,
    provider = "Esri.WorldShadedRelief",
    zoom = 7,
    project = FALSE,
    cachedir = tile_dir
  )
  terra::writeRaster(rgb_tile, rgb_file)
} else {
  rgb_tile <- terra::rast(rgb_file)
}

# Overlay SRTM elevation, aligned to the RGB tile grid.
clim <- terra::clamp(elevation, lower = 0, values = TRUE) |>
  terra::project(rgb_tile)
names(clim) <- "elevation"
stopifnot(terra::compareGeom(clim, rgb_tile, lyrs = FALSE))
legend_breaks <- seq(0, 6500, 500)
palette_stops <- subset(
  tidyterra::hypsometric_tints_db,
  pal == "etopo1_hypso"
)
palette_values <- scales::rescale(palette_stops$limit, to = c(0, 6500))

caption <- paste0(
  "Tiles \\u00a9 Esri - Source: Esri\n",
  "Elevation: Shuttle Radar Topography Mission (SRTM), via geodata"
)
# Use a literal Unicode escape in R so the script also works under Windows
# locales that do not use UTF-8.
caption <- gsub("\\\\u00a9", intToUtf8(169), caption)

continuous_plot <- ggplot() +
  (list(
    geom_spatraster_rgb(data = rgb_tile, maxcell = Inf),
    geom_spatraster(data = clim, maxcell = Inf)
  ) |>
    ggblend::blend("multiply")) +
  scale_fill_hypso_tint_c(
    palette = "etopo1_hypso",
    limits = c(0, 6500),
    values = palette_values,
    breaks = legend_breaks,
    guide = guide_colourbar(barheight = unit(5, "in")),
    labels = scales::label_number()
  )

binned_plot <- ggplot() +
  (list(
    geom_spatraster_rgb(data = rgb_tile, maxcell = Inf),
    geom_spatraster(data = clim, maxcell = Inf)
  ) |>
    ggblend::blend("multiply")) +
  scale_fill_hypso_tint_b(
    palette = "etopo1_hypso",
    limits = c(0, 6500),
    values = palette_values,
    breaks = legend_breaks,
    guide = guide_coloursteps(barheight = unit(5, "in")),
    labels = scales::label_number()
  )

contour_plot <- ggplot() +
  (list(
    geom_spatraster_rgb(data = rgb_tile, maxcell = Inf),
    geom_spatraster_contour_filled(
      data = clim,
      breaks = legend_breaks,
      maxcell = Inf
    )
  ) |>
    ggblend::blend("multiply")) +
  scale_fill_hypso_tint_d(
    palette = "etopo1_hypso",
    guide = guide_legend(reverse = TRUE, keyheight = unit(0.3, "in"))
  )

style_plot <- function(plot, subtitle) {
  plot +
    coord_sf(expand = FALSE) +
    labs(
      title = "Elevation of Bolivia",
      subtitle = subtitle,
      fill = "Elevation (m)",
      x = NULL,
      y = NULL,
      caption = caption
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.background = element_rect(fill = "grey97", colour = NA),
      plot.margin = margin(15, 15, 15, 15),
      plot.title = element_text(size = 25, face = "bold"),
      plot.subtitle = element_text(size = 16, margin = margin(b = 10)),
      plot.caption = element_text(size = 9),
      legend.text = element_text(size = 10),
      legend.title = element_text(size = 11),
      panel.grid = element_line(colour = "grey85", linewidth = 0.2)
    )
}

plots <- list(
  continuous = style_plot(
    continuous_plot,
    "RGB shaded relief + continuous overlay | Multiply"
  ),
  binned = style_plot(
    binned_plot,
    "RGB shaded relief + binned overlay | Multiply"
  ),
  contours = style_plot(
    contour_plot,
    "RGB shaded relief + filled contours | Multiply"
  )
)
for (variant in names(plots)) {
  message("Rendering ", variant, "...")
  ggsave(
    file.path(output_dir, paste0("bolivia-overlay-", variant, ".png")),
    plot = plots[[variant]],
    device = ragg::agg_png,
    width = 12,
    height = 9,
    units = "in",
    dpi = 220,
    bg = "grey97"
  )
}
magick::image_read(file.path(
  output_dir,
  paste0("bolivia-overlay-", names(plots), ".png")
)) |>
  magick::image_scale("1200x") |>
  magick::image_append() |>
  magick::image_write(file.path(output_dir, "bolivia-overlay-comparison.png"))
writeLines(
  trimws(capture.output(sessionInfo()), which = "right"),
  file.path(output_dir, "session-info.txt")
)
message("Maps saved to ", normalizePath(output_dir, winslash = "/"))
