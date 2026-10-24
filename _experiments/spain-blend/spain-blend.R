# Run from the repository root:
# Rscript _experiments/spain-blend/spain-blend.R
# Experiment based on _Rmd/2022-10-17-tidyterra-hillshade.Rmd and
# https://barney.fly.dev/2026/01/27/ggplot2-blending-adventure/
library(terra)
library(tidyterra)
library(ggplot2)

output_dir <- file.path("_experiments", "spain-blend")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
data_dir <- path.expand("~/R/mapslib/misc")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

# Match the source post: SRTM 30 arcseconds, light altitude 30, azimuth 270.
elevation <- geodata::elevation_30s("ESP", path = data_dir)
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
legend_breaks <- seq(0, 3500, 250)

# Extract exact scale-mapped colors, with no raster resampling. The two
# independent fill scales are resolved before the layers enter ggblend.
palette_stops <- subset(
  tidyterra::hypsometric_tints_db,
  pal == "spain"
)
# Fit the complete Spain tint ramp to the local elevation range.
palette_values <- scales::rescale(palette_stops$limit, to = r_limits)
elevation_scale <- scale_fill_hypso_tint_c(
  limits = r_limits,
  values = palette_values,
  palette = "spain",
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

# Resolve the binned colors before blending, retaining the scale underneath
# to generate the interval legend just as in the continuous version.
binned_scale <- scale_fill_hypso_tint_b(
  limits = r_limits,
  values = palette_values,
  palette = "spain",
  na.value = NA,
  breaks = legend_breaks,
  labels = scales::label_comma()
)
binned_base <- ggplot() +
  geom_spatraster(data = elevation, maxcell = Inf) +
  binned_scale
binned_fill <- ggplot_build(binned_base)$data[[1]]$fill
stopifnot(length(binned_fill) == ncell(elevation))
binned_plot <- binned_base +
  (list(
    geom_spatraster(data = elevation, fill = binned_fill, maxcell = Inf),
    geom_spatraster(data = hill, fill = hill_fill, alpha = 0.85, maxcell = Inf)
  ) |>
    ggblend::blend("multiply"))

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
          legend.key.width = unit(0.54, "in"),
          legend.key.height = unit(0.5, "lines"),
          legend.text.position = "bottom",
          legend.title.position = "right"
        ),
        override.aes = list(alpha = 1)
      )
    ) +
    labs(
      title = "Elevation of Spain",
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
      legend.title = element_text(size = 12),
      legend.text = element_text(size = 10),
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
binned_plot <- style_plot(
  binned_plot,
  "Hillshade and hypsometric tint | Binned multiply blend"
) +
  guides(
    fill = guide_coloursteps(
      title = "m.",
      direction = "horizontal",
      barwidth = unit(8.5, "in"),
      barheight = unit(0.2, "in"),
      show.limits = TRUE,
      even.steps = TRUE
    )
  )

# ragg supports the compositing groups used by ggblend.
plots <- list(
  alpha = alpha_plot,
  multiply = multiply_plot,
  binned = binned_plot
)
for (variant in names(plots)) {
  plot <- plots[[variant]]
  ggsave(
    file.path(output_dir, paste0("spain-", variant, ".png")),
    plot = plot,
    device = ragg::agg_png,
    width = 12,
    height = 10,
    units = "in",
    dpi = 240,
    bg = "grey97"
  )
}
magick::image_read(file.path(
  output_dir,
  paste0("spain-", names(plots), ".png")
)) |>
  magick::image_scale("1400x") |>
  magick::image_append() |>
  magick::image_write(file.path(output_dir, "spain-comparison.png"))
writeLines(
  trimws(capture.output(sessionInfo()), which = "right"),
  file.path(output_dir, "session-info.txt")
)
message("Maps saved to ", normalizePath(output_dir, winslash = "/"))
