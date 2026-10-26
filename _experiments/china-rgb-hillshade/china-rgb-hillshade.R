# Run from the repository root:
# Rscript _experiments/china-rgb-hillshade/china-rgb-hillshade.R
# https://github.com/dieghernan/dieghernan.github.io/discussions/36
library(terra)
library(tidyterra)
library(ggplot2)

output_dir <- file.path("_experiments", "china-rgb-hillshade")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
data_dir <- path.expand("~/R/mapslib/misc")
cache_dir <- file.path(data_dir, "derived", "china-rgb-hillshade")
dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
repository <- normalizePath(".", winslash = "/")
cache_dir <- normalizePath(cache_dir, winslash = "/")
stopifnot(!startsWith(tolower(cache_dir), paste0(tolower(repository), "/")))
max_cells <- 2000000

# Keep downloads and full-resolution derived rasters outside the repository.
elevation <- geodata::elevation_30s("CHN", path = data_dir)
names(elevation) <- "elevation"
elevation <- clamp(
  elevation,
  lower = 0,
  values = TRUE,
  filename = file.path(cache_dir, "elevation.tif"),
  overwrite = TRUE,
  wopt = list(datatype = "FLT4S", gdal = "COMPRESS=DEFLATE")
)

make_hillshade <- function(elevation, cache_dir) {
  slope_file <- tempfile("slope-", tmpdir = cache_dir, fileext = ".tif")
  aspect_file <- tempfile("aspect-", tmpdir = cache_dir, fileext = ".tif")
  on.exit(unlink(c(slope_file, aspect_file)), add = TRUE)
  slope <- terrain(
    elevation,
    "slope",
    unit = "radians",
    filename = slope_file,
    wopt = list(datatype = "FLT4S", gdal = "COMPRESS=DEFLATE")
  )
  aspect <- terrain(
    elevation,
    "aspect",
    unit = "radians",
    filename = aspect_file,
    wopt = list(datatype = "FLT4S", gdal = "COMPRESS=DEFLATE")
  )
  shade(
    slope,
    aspect,
    angle = 30,
    direction = 270,
    filename = file.path(cache_dir, "hillshade.tif"),
    overwrite = TRUE,
    wopt = list(datatype = "FLT4S", gdal = "COMPRESS=DEFLATE")
  )
}
hill <- make_hillshade(elevation, cache_dir)
stopifnot(compareGeom(elevation, hill))

# Explicit endpoints avoid changing the contrast through quantile clipping.
# The reference uses the same linear RGB grays, not a different HCL palette.
hill_rgb <- stretch(
  hill,
  minv = 0,
  maxv = 255,
  minq = 0,
  maxq = 1,
  filename = file.path(cache_dir, "hillshade-stretched.tif"),
  overwrite = TRUE,
  wopt = list(datatype = "FLT4S", gdal = "COMPRESS=DEFLATE")
)
stopifnot(compareGeom(elevation, hill_rgb))
limits <- c(0, ceiling(max(minmax(elevation)) / 1000) * 1000)
palette_stops <- subset(hypsometric_tints_db, pal == "dem_poster")
elevation_scale <- scale_fill_hypso_tint_c(
  palette = "dem_poster",
  limits = limits,
  values = scales::rescale(palette_stops$limit, to = limits),
  breaks = seq(0, limits[2], 1000),
  na.value = NA,
  name = "Elevation (m)"
)

# This is the proposed method: one RGB hillshade band repeated as R, G and B.
# Only elevation maps to fill, so its normal scale also supplies the legend.
rgb_plot <- ggplot() +
  (list(
    geom_spatraster(
      data = elevation,
      maxcell = max_cells,
      interpolate = FALSE
    ),
    geom_spatraster_rgb(
      data = hill_rgb,
      r = 1,
      g = 1,
      b = 1,
      alpha = 0.85,
      maxcell = max_cells,
      interpolate = FALSE
    )
  ) |>
    ggblend::blend("multiply")) +
  elevation_scale

# Keep the old fixed-color reference manageable by sampling BEFORE extracting
# colors. Both full-resolution inputs share a grid and use regular sampling.
sampled_elevation <- spatSample(
  elevation,
  max_cells,
  method = "regular",
  as.raster = TRUE
)
sampled_hill <- spatSample(
  hill_rgb,
  max_cells,
  method = "regular",
  as.raster = TRUE
)
stopifnot(compareGeom(sampled_elevation, sampled_hill))
reference_base <- ggplot() +
  geom_spatraster(
    data = sampled_elevation,
    maxcell = Inf,
    interpolate = FALSE
  ) +
  elevation_scale
built_reference <- ggplot_build(reference_base)$data[[1]]
cells <- cellFromXY(sampled_elevation, as.matrix(built_reference[c("x", "y")]))
stopifnot(length(cells) == ncell(sampled_elevation), !anyDuplicated(cells))
elevation_fill <- rep(NA_character_, ncell(sampled_elevation))
elevation_fill[cells] <- built_reference$fill
gray_values <- as.vector(values(sampled_hill))
hill_fill <- rep(NA_character_, length(gray_values))
valid <- !is.na(gray_values)
hill_fill[valid] <- grDevices::rgb(
  gray_values[valid],
  gray_values[valid],
  gray_values[valid],
  maxColorValue = 255
)
reference_plot <- reference_base +
  (list(
    geom_spatraster(
      data = sampled_elevation,
      fill = elevation_fill,
      maxcell = Inf,
      interpolate = FALSE
    ),
    geom_spatraster(
      data = sampled_hill,
      fill = hill_fill,
      alpha = 0.85,
      maxcell = Inf,
      interpolate = FALSE
    )
  ) |>
    ggblend::blend("multiply"))

# Check that the direct RGB version has one trained thematic fill scale,
# retains the full color range and draws the same sampled grid.
built_rgb <- ggplot_build(rgb_plot)
fill_scales <- Filter(
  function(scale) "fill" %in% scale$aesthetics,
  built_rgb$plot$scales$scales
)
stopifnot(
  length(fill_scales) == 1,
  identical(fill_scales[[1]]$get_limits(), limits)
)
rgb_layers <- Filter(function(data) "hexcol" %in% names(data), built_rgb$data)
stopifnot(length(rgb_layers) == 1)
stopifnot(nrow(rgb_layers[[1]]) == ncell(sampled_hill))
rgb_cells <- cellFromXY(
  sampled_elevation,
  as.matrix(rgb_layers[[1]][c("x", "y")])
)
stopifnot(all(sort(rgb_cells) == seq_len(ncell(sampled_elevation))))

style_plot <- function(plot, subtitle) {
  plot +
    coord_sf(expand = FALSE) +
    labs(
      title = "Elevation of China",
      subtitle = subtitle,
      caption = "SRTM 30 arcseconds | Multiply | Hillshade opacity: 85%",
      x = NULL,
      y = NULL
    ) +
    guides(
      fill = guide_colourbar(
        direction = "horizontal",
        barwidth = unit(5, "in"),
        barheight = unit(0.15, "in")
      )
    ) +
    theme_minimal(base_size = 11) +
    theme(
      legend.position = "bottom",
      legend.title = element_text(size = 9),
      legend.text = element_text(size = 9),
      plot.background = element_rect(fill = "grey97", colour = NA),
      plot.margin = margin(12, 12, 12, 12)
    )
}
plots <- list(
  reference = style_plot(
    reference_plot,
    "Fixed colors + extra layer for the legend"
  ),
  rgb = style_plot(rgb_plot, "Single-band RGB hillshade + normal fill legend")
)
for (variant in names(plots)) {
  ggsave(
    file.path(output_dir, paste0("china-", variant, ".png")),
    plots[[variant]],
    device = ragg::agg_png,
    width = 10,
    height = 8,
    dpi = 180
  )
}
magick::image_read(file.path(
  output_dir,
  paste0("china-", names(plots), ".png")
)) |>
  magick::image_append() |>
  magick::image_write(file.path(output_dir, "china-comparison.png"))
writeLines(
  c(
    paste("Downloaded data cache:", normalizePath(data_dir, winslash = "/")),
    paste("Derived full-resolution rasters:", cache_dir),
    paste("Source grid:", nrow(elevation), "x", ncol(elevation)),
    paste("Source cells:", ncell(elevation)),
    paste("Requested plotting cap:", max_cells),
    paste("Actual plotting cells:", ncell(sampled_elevation)),
    "Full and sampled grids: matched",
    "RGB method: one thematic fill scale, normal legend, no fixed color vectors",
    "Matched contrast: linear grayscale, minq = 0, maxq = 1",
    "Raster interpolation: disabled in both methods",
    "No downloaded or derived raster files written to the repository"
  ),
  file.path(output_dir, "validation.txt")
)
writeLines(
  trimws(capture.output(sessionInfo()), which = "right"),
  file.path(output_dir, "session-info.txt")
)
message("Experiment saved to ", normalizePath(output_dir, winslash = "/"))
