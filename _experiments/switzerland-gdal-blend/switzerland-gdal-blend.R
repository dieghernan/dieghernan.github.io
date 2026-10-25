# Run from the repository root:
# Rscript _experiments/switzerland-gdal-blend/switzerland-gdal-blend.R
# https://gdal.org/programs/gdal_raster_blend.html
library(terra)
library(tidyterra)
library(ggplot2)

output_dir <- file.path("_experiments", "switzerland-gdal-blend")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
data_dir <- path.expand("~/R/mapslib/misc")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

# Keep the example small: roughly 1 km cells, without reprojection.
elevation <- geodata::elevation_30s("CHE", path = data_dir)
elevation <- clamp(elevation, lower = 0, values = TRUE)
names(elevation) <- "elevation"
slope <- terrain(elevation, "slope", unit = "radians")
aspect <- terrain(elevation, "aspect", unit = "radians")
hill <- shade(slope, aspect, angle = 30, direction = 270)
stopifnot(compareGeom(elevation, hill))

limits <- c(0, ceiling(max(minmax(elevation)) / 500) * 500)
palette_stops <- subset(hypsometric_tints_db, pal == "dem_poster")
elevation_scale <- scale_fill_hypso_tint_c(
  palette = "dem_poster",
  limits = limits,
  values = scales::rescale(palette_stops$limit, to = limits),
  breaks = seq(0, limits[2], 1000),
  na.value = NA,
  name = "Elevation (m)"
)
elevation_plot <- ggplot() +
  geom_spatraster(data = elevation, maxcell = Inf) +
  elevation_scale
hill_plot <- ggplot() +
  geom_spatraster(data = hill, maxcell = Inf) +
  scale_fill_gradientn(colours = hcl.colors(1000, "Grays"), na.value = NA)

# Index colors by spatial cell, rather than assuming ggplot's row order.
cell_colors <- function(plot, template) {
  built <- ggplot_build(plot)$data[[1]]
  cells <- cellFromXY(template, as.matrix(built[c("x", "y")]))
  stopifnot(length(cells) == ncell(template), !anyDuplicated(cells))
  colors <- rep(NA_character_, ncell(template))
  colors[cells] <- built$fill
  colors
}
elevation_colors <- cell_colors(elevation_plot, elevation)
hill_colors <- cell_colors(hill_plot, hill)

rgba_raster <- function(template, colors) {
  result <- rast(template, nlyrs = 4)
  values(result) <- t(grDevices::col2rgb(colors, alpha = TRUE))
  names(result) <- c("red", "green", "blue", "alpha")
  RGB(result) <- 1:3
  result
}
elevation_rgba <- rgba_raster(elevation, elevation_colors)
hill_rgba <- rgba_raster(hill, hill_colors)
color_file <- file.path(output_dir, "switzerland-colors.tif")
hill_file <- file.path(output_dir, "switzerland-hillshade.tif")
blend_file <- file.path(output_dir, "switzerland-multiply.tif")
for (item in list(
  list(data = elevation_rgba, file = color_file),
  list(data = hill_rgba, file = hill_file)
)) {
  writeRaster(
    item$data,
    item$file,
    datatype = "INT1U",
    NAflag = NA,
    overwrite = TRUE,
    gdal = c("COMPRESS=DEFLATE", "PHOTOMETRIC=RGB", "ALPHA=YES")
  )
}

# Some Windows gdalraster binaries report GDAL >= 3.12 but lack CLI algorithms.
# Prefer the R API when available; otherwise use an external GDAL executable.
commands <- gdalraster::gdal_commands(cout = FALSE)
api_has_multiply <- "raster blend" %in%
  commands$command &&
  any(grepl("multiply", capture.output(gdalraster::gdal_usage("raster blend"))))
if (api_has_multiply) {
  gdalraster::gdal_run(
    "raster blend",
    list(
      input = color_file,
      overlay = hill_file,
      output = blend_file,
      operator = "multiply",
      opacity = 85,
      overwrite = TRUE
    ),
    close = TRUE
  )
  backend <- paste("gdalraster", gdalraster::gdal_version()[1])
} else {
  gdal_exe <- Sys.getenv("GDAL_BLEND_EXE", Sys.which("gdal"))
  if (!nzchar(gdal_exe)) {
    gdal_exe <- file.path(
      Sys.getenv("USERPROFILE"),
      ".cache",
      "codex-gdal-blend-cli",
      "Library",
      "bin",
      "gdal.exe"
    )
  }
  stopifnot(file.exists(gdal_exe))
  backend <- system2(gdal_exe, "--version", stdout = TRUE)
  usage <- system2(gdal_exe, c("raster", "blend", "--help"), stdout = TRUE)
  if (!any(grepl("multiply", usage))) {
    stop(
      "This GDAL build lacks multiply. Set GDAL_BLEND_EXE to a GDAL 3.13+ executable."
    )
  }
  status <- system2(
    gdal_exe,
    c(
      "raster",
      "blend",
      "--operator=multiply",
      "--opacity=85",
      "--overwrite",
      shQuote(normalizePath(color_file, winslash = "/")),
      shQuote(normalizePath(hill_file, winslash = "/")),
      shQuote(normalizePath(blend_file, winslash = "/", mustWork = FALSE))
    )
  )
  stopifnot(status == 0)
}
blended <- rast(blend_file)
stopifnot(compareGeom(elevation_rgba, blended), nlyr(blended) == 4)

# Verify the GDAL output against the pixel-wise multiply formula.
color_values <- values(elevation_rgba)
hill_values <- values(hill_rgba)
valid <- color_values[, 4] == 255 & hill_values[, 4] == 255
expected <- color_values[valid, 1:3] *
  (0.15 + 0.85 * hill_values[valid, 1:3] / 255)
actual <- values(blended)[valid, 1:3]
pixel_error <- abs(actual - expected)
stopifnot(max(pixel_error) <= 3)
outside <- color_values[, 4] == 0 & hill_values[, 4] == 0
stopifnot(all(values(blended)[outside, 4] == 0))

ggblend_plot <- elevation_plot +
  (list(
    geom_spatraster(data = elevation, fill = elevation_colors, maxcell = Inf),
    geom_spatraster(
      data = hill,
      fill = hill_colors,
      alpha = 0.85,
      maxcell = Inf
    )
  ) |>
    ggblend::blend("multiply"))

# The thematic layer generates the legend; the opaque RGB covers it.
# Mask the RGB by the explicit output alpha band before plotting.
blended_rgb <- mask(blended[[1:3]], blended[[4]], maskvalues = 0)
gdal_plot <- elevation_plot +
  geom_spatraster_rgb(data = blended_rgb, maxcell = Inf)

style_plot <- function(plot, subtitle) {
  plot +
    coord_sf(expand = FALSE) +
    labs(
      title = "Elevation of Switzerland",
      subtitle = subtitle,
      caption = "SRTM 30 arcseconds via geodata | Multiply | Hillshade opacity: 85%",
      x = NULL,
      y = NULL
    ) +
    guides(
      fill = guide_colourbar(
        direction = "horizontal",
        barwidth = unit(4, "in"),
        barheight = unit(0.15, "in")
      )
    ) +
    theme_minimal(base_size = 11) +
    theme(
      legend.position = "bottom",
      legend.title = element_text(size = 9),
      legend.text = element_text(size = 9),
      panel.grid = element_line(colour = "grey85", linewidth = 0.2),
      plot.background = element_rect(fill = "grey97", colour = NA),
      plot.margin = margin(12, 12, 12, 12)
    )
}
plots <- list(
  ggblend = style_plot(ggblend_plot, "ggblend: blend the plotted layers"),
  gdal = style_plot(gdal_plot, "GDAL: blend the raster pixels first")
)
for (variant in names(plots)) {
  ggsave(
    file.path(output_dir, paste0("switzerland-", variant, ".png")),
    plots[[variant]],
    device = ragg::agg_png,
    width = 8,
    height = 6.5,
    dpi = 180
  )
}
magick::image_read(file.path(
  output_dir,
  paste0("switzerland-", names(plots), ".png")
)) |>
  magick::image_append() |>
  magick::image_write(file.path(output_dir, "switzerland-comparison.png"))

writeLines(
  c(
    paste("Backend:", backend),
    paste("gdalraster version:", packageVersion("gdalraster")),
    paste(
      "gdalraster algorithm registry:",
      paste(commands$command, collapse = ", ")
    ),
    paste("Raster dimensions:", nrow(elevation), "x", ncol(elevation)),
    paste("Opaque cells checked:", sum(valid)),
    paste("Mean absolute channel error (0-255):", mean(pixel_error)),
    paste("Maximum absolute channel error (0-255):", max(pixel_error)),
    "Transparent exterior: verified",
    "Matching raster grids: verified"
  ),
  file.path(output_dir, "validation.txt")
)
writeLines(
  capture.output(sessionInfo()),
  file.path(output_dir, "session-info.txt")
)
message("Experiment saved to ", normalizePath(output_dir, winslash = "/"))
