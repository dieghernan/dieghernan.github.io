# Run from the repository root:
# Rscript _experiments/romania-blend/romania-blend.R
# Experiment based on _Rmd/2022-10-17-tidyterra-hillshade.Rmd and
# https://barney.fly.dev/2026/01/27/ggplot2-blending-adventure/
library(terra)
library(tidyterra)
library(ggplot2)

output_dir <- file.path("_experiments", "romania-blend")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
data_dir <- path.expand("~/R/mapslib/misc")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

# Match the source post: SRTM 30 arcseconds, light altitude 30, azimuth 270.
elevation <- geodata::elevation_30s("ROU", path = data_dir)
stopifnot(inherits(elevation, "SpatRaster"))
elevation <- terra::clamp(elevation, lower = 0, values = TRUE)
names(elevation) <- "alt"
slope <- terra::terrain(elevation, "slope", unit = "radians")
aspect <- terra::terrain(elevation, "aspect", unit = "radians")
hill <- terra::shade(slope, aspect, angle = 30, direction = 270)
names(hill) <- "shades"
stopifnot(terra::compareGeom(elevation, hill))

r_limits <- as.vector(terra::minmax(elevation))
r_limits <- pmax(
  c(floor(r_limits[1] / 500), ceiling(r_limits[2] / 500)) * 500,
  0
)
legend_breaks <- c(seq(0, 500, 100), seq(750, 1500, 250), 2000)

# Extract exact scale-mapped colors, with no raster resampling. The two
# independent fill scales are resolved before the layers enter ggblend.
palette_stops <- subset(tidyterra::hypsometric_tints_db, pal == "dem_poster")
# Match the original post: fit the complete tint ramp to the local elevation
# range. Current tidyterra otherwise keeps the palette's absolute heights,
# placing white at 4,000 m, above Romania's highest raster cells.
palette_values <- scales::rescale(palette_stops$limit, to = r_limits)
elevation_scale <- scale_fill_hypso_tint_c(
  limits = r_limits,
  values = palette_values,
  palette = "dem_poster",
  na.value = NA,
  breaks = legend_breaks,
  labels = scales::label_comma()
)
elevation_plot <- ggplot() +
  geom_spatraster(data = elevation, maxcell = Inf) +
  elevation_scale
elevation_fill <- ggplot_build(elevation_plot)$data[[1]]$fill
hill_plot <- ggplot() +
  geom_spatraster(data = hill, maxcell = Inf) +
  scale_fill_gradientn(colors = hcl.colors(1000, "Grays"), na.value = NA)
hill_fill <- ggplot_build(hill_plot)$data[[1]]$fill
stopifnot(
  length(elevation_fill) == ncell(elevation),
  length(hill_fill) == ncell(hill)
)

blended_layers <- list(
  geom_spatraster(data = elevation, fill = elevation_fill, maxcell = Inf),
  geom_spatraster(data = hill, fill = hill_fill, alpha = 0.85, maxcell = Inf)
) |>
  ggblend::blend("multiply")

# The first elevation layer trains the scale and creates the real raster
# legend. The opaque elevation layer inside the blend covers it completely.
multiply_plot <- elevation_plot + blended_layers
alpha_plot <- ggplot() +
  geom_spatraster(data = hill, fill = hill_fill, maxcell = Inf) +
  geom_spatraster(data = elevation, maxcell = Inf, alpha = 0.4) +
  elevation_scale

# Prefer the source post's font when its local files are available.
font_dir <- path.expand("~/R/googlefonts")
font_files <- file.path(
  font_dir,
  paste0("NotoSerif-", c("Regular", "Bold", "Italic", "BoldItalic"), ".ttf")
)
font_family <- "serif"
if (all(file.exists(font_files))) {
  systemfonts::register_font(
    "notoserif",
    plain = font_files[1],
    bold = font_files[2],
    italic = font_files[3],
    bolditalic = font_files[4]
  )
  font_family <- "notoserif"
}

style_plot <- function(plot, subtitle) {
  plot +
    guides(
      fill = guide_legend(
        title = "   m.",
        direction = "horizontal",
        nrow = 1,
        theme = theme(
          legend.key.width = unit(0.65, "in"),
          legend.key.height = unit(0.5, "lines"),
          legend.text.position = "bottom",
          legend.title.position = "right"
        ),
        override.aes = list(alpha = 1)
      )
    ) +
    labs(
      title = "Elevation of Romania",
      x = NULL,
      y = NULL,
      subtitle = subtitle,
      caption = paste0(
        "@dhernangomez | tidyterra, ggplot2, geodata, ggblend\n",
        "Data: Shuttle Radar Topography Mission (SRTM)"
      )
    ) +
    theme_minimal(base_family = font_family) +
    theme(
      plot.background = element_rect(fill = "grey97", colour = NA),
      plot.margin = margin(20, 20, 20, 20),
      plot.caption = element_text(size = 12),
      plot.title = element_text(face = "bold", size = 34),
      plot.subtitle = element_text(size = 23, margin = margin(b = 10)),
      axis.text = element_text(size = 15),
      legend.position = "bottom",
      legend.title = element_text(size = 16),
      legend.text = element_text(size = 14),
      legend.key = element_rect(fill = "grey50", colour = NA),
      legend.key.spacing.x = unit(0, "pt")
    )
}

multiply_plot <- style_plot(
  multiply_plot,
  "Hillshade and hypsometric tint | Multiply blend"
)
alpha_plot <- style_plot(
  alpha_plot,
  "Hillshade and hypsometric tint | Original alpha 0.4"
)

# ragg supports the compositing groups used by ggblend.
for (variant in c("multiply", "alpha")) {
  plot <- if (variant == "multiply") multiply_plot else alpha_plot
  ggsave(
    file.path(output_dir, paste0("romania-", variant, ".png")),
    plot = plot,
    device = ragg::agg_png,
    width = 10,
    height = 9.25,
    units = "in",
    dpi = 240,
    bg = "grey97"
  )
}
magick::image_read(file.path(
  output_dir,
  c("romania-alpha.png", "romania-multiply.png")
)) |>
  magick::image_scale("1400x") |>
  magick::image_append() |>
  magick::image_write(file.path(output_dir, "romania-comparison.png"))
writeLines(
  trimws(capture.output(sessionInfo()), which = "right"),
  file.path(output_dir, "session-info.txt")
)
message("Maps saved to ", normalizePath(output_dir, winslash = "/"))
