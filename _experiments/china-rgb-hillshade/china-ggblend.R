library(terra)
library(tidyterra)
library(ggplot2)

# Download and cache outside the repository.
cache <- path.expand("~/R/mapslib/misc")
dir.create(cache, recursive = TRUE, showWarnings = FALSE)
terraOptions(tempdir = cache)

elevation <- geodata::elevation_30s("CHN", path = cache)
elevation <- clamp(elevation, lower = 0, values = TRUE)
names(elevation) <- "elevation"

# Calculate hillshade before sampling for display.
slope <- terrain(elevation, "slope", unit = "radians")
aspect <- terrain(elevation, "aspect", unit = "radians")
hill <- shade(slope, aspect, angle = 30, direction = 270)
hill_rgb <- stretch(hill, minv = 0, maxv = 255, minq = 0, maxq = 1)

max_cells <- 2000000
limits <- c(0, ceiling(max(minmax(elevation)) / 1000) * 1000)
palette_stops <- subset(hypsometric_tints_db, pal == "dem_poster")
my_breaks <- c(0, 250, 500, 750, seq(1000, 8000, by = 1000))
base_text_size <- 16

# RGB shading uses no fill scale, so the elevation legend is retained.
map <- ggplot() +
  (list(
    geom_spatraster(data = elevation, maxcell = max_cells),
    geom_spatraster_rgb(
      data = hill_rgb,
      r = 1,
      g = 1,
      b = 1,
      alpha = 0.85,
      maxcell = max_cells
    )
  ) |>
    ggblend::blend("multiply")) +
  scale_fill_hypso_tint_c(
    palette = "dem_poster",
    limits = limits,
    values = scales::rescale(palette_stops$limit, to = limits),
    breaks = my_breaks,
    labels = scales::label_comma(),
    na.value = NA,
    name = "Elevation (m)"
  ) +
  coord_sf(expand = FALSE) +
  labs(
    title = "Elevation of China",
    subtitle = "Hillshade and hypsometric tint | Multiply blend",
    caption = paste0(
      "@dhernangomez using tidyterra, ggplot2, geodata and ggblend R packages.",
      " Data: Shuttle Radar Topography Mission (SRTM)"
    )
  ) +
  guides(
    fill = guide_legend(
      title = "m.",
      direction = "horizontal",
      nrow = 1,
      override.aes = list(alpha = 1)
    )
  ) +
  theme_minimal(base_family = "serif") +
  theme(
    plot.title = element_text(face = "bold", size = base_text_size * 1.4),
    plot.subtitle = element_text(
      size = base_text_size,
      margin = margin(b = 10)
    ),
    plot.caption = element_text(size = base_text_size * 0.5),
    axis.text = element_text(size = base_text_size * 0.7),
    axis.title = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(size = base_text_size * 0.8),
    legend.text = element_text(size = base_text_size * 0.7),
    legend.key = element_rect(fill = "grey50", colour = NA),
    legend.spacing.x = grid::unit(0, "pt"),
    legend.key.spacing.x = grid::unit(0, "pt"),
    legend.text.position = "bottom",
    legend.title.position = "top",
    legend.key.width = grid::unit(2.8, "line"),
    legend.key.height = grid::unit(0.5, "line"),
    plot.background = element_rect(fill = "grey97", colour = NA),
    plot.margin = margin(20, 20, 20, 20)
  )

ggsave(
  "china-ggblend.png",
  map,
  device = ragg::agg_png,
  width = 10,
  height = 8,
  dpi = 180
)
