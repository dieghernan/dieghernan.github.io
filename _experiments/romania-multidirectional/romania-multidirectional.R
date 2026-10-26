# Run from the repository root:
# Rscript _experiments/romania-multidirectional/romania-multidirectional.R
# Inspired by https://dominicroye.github.io/blog/hillshade-effect/
library(terra)
library(tidyterra)
library(ggplot2)

output_dir <- file.path("_experiments", "romania-multidirectional")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
data_dir <- path.expand("~/R/mapslib/misc")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
elevation <- geodata::elevation_30s("ROU", path = data_dir)
elevation <- clamp(elevation, lower = 0, values = TRUE)
names(elevation) <- "elevation"
slope <- terrain(elevation, "slope", unit = "radians")
aspect <- terrain(elevation, "aspect", unit = "radians")

directions <- c(270, 15, 60, 330)
directional <- lapply(directions, function(direction) {
  shade(slope, aspect, angle = 45, direction = direction, normalize = TRUE)
})
# Averaging preserves the 0-255 range without stretching each map separately.
hillshades <- list(
  baseline = shade(
    slope,
    aspect,
    angle = 30,
    direction = 270,
    normalize = TRUE
  ),
  single = shade(slope, aspect, angle = 45, direction = 300, normalize = TRUE),
  multi = mean(rast(directional))
)
subtitles <- c(
  baseline = "Single direction: 270\u00b0 | Light altitude: 30\u00b0",
  single = "Single direction: 300\u00b0 | Light altitude: 45\u00b0",
  multi = "Four directions: 270\u00b0, 15\u00b0, 60\u00b0, 330\u00b0 | Light altitude: 45\u00b0"
)
limits <- c(0, ceiling(max(minmax(elevation)) / 500) * 500)
palette_stops <- subset(hypsometric_tints_db, pal == "dem_poster")
plots <- lapply(names(hillshades), function(variant) {
  hill <- hillshades[[variant]]
  stopifnot(compareGeom(elevation, hill))
  ggplot() +
    (list(
      geom_spatraster(data = elevation, maxcell = Inf, interpolate = FALSE),
      geom_spatraster_rgb(
        data = hill,
        r = 1,
        g = 1,
        b = 1,
        max_col_value = 255,
        alpha = 0.85,
        maxcell = Inf,
        interpolate = FALSE
      )
    ) |>
      ggblend::blend("multiply")) +
    scale_fill_hypso_tint_c(
      palette = "dem_poster",
      limits = limits,
      values = scales::rescale(palette_stops$limit, to = limits),
      breaks = seq(0, limits[2], 500),
      na.value = NA,
      name = "Elevation (m)"
    ) +
    coord_sf(expand = FALSE) +
    labs(
      title = "Elevation of Romania",
      subtitle = subtitles[[variant]],
      caption = paste(
        "SRTM 30 arcseconds | Multiply | Hillshade opacity: 85%",
        "Multidirectional lighting inspired by Dominic Roy\u00e9",
        sep = "\n"
      ),
      x = NULL,
      y = NULL
    ) +
    guides(
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
})
names(plots) <- names(hillshades)

# Validate the numerical average independently of the plotting layers.
expected <- Reduce(`+`, lapply(directional, values)) / length(directions)
stopifnot(isTRUE(all.equal(
  as.vector(values(hillshades$multi)),
  as.vector(expected)
)))
for (variant in names(plots)) {
  built <- ggplot_build(plots[[variant]])
  fill_scales <- Filter(
    function(scale) "fill" %in% scale$aesthetics,
    built$plot$scales$scales
  )
  raster_layers <- Filter(
    function(data) "spatraster" %in% names(data),
    built$data
  )
  stopifnot(
    length(fill_scales) == 1,
    identical(fill_scales[[1]]$get_limits(), limits),
    length(raster_layers) == 2,
    all(vapply(raster_layers, nrow, integer(1)) == ncell(elevation))
  )
  ggsave(
    file.path(output_dir, paste0("romania-", variant, ".png")),
    plots[[variant]],
    device = ragg::agg_png,
    width = 8,
    height = 6.5,
    dpi = 180
  )
}
magick::image_read(file.path(
  output_dir,
  paste0("romania-", names(plots), ".png")
)) |>
  magick::image_append() |>
  magick::image_write(file.path(output_dir, "romania-comparison.png"))
writeLines(
  c(
    paste("Source grid:", nrow(elevation), "x", ncol(elevation)),
    "Multidirectional mean: verified against cell-wise arithmetic",
    "All raster grids and plotting cell counts: matched",
    "All maps: one elevation fill scale with identical limits",
    "RGB: fixed 0-255 range, no individual contrast stretching",
    "Raster interpolation: disabled"
  ),
  file.path(output_dir, "validation.txt")
)
writeLines(
  trimws(capture.output(sessionInfo()), which = "right"),
  file.path(output_dir, "session-info.txt")
)
