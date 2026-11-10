library(terra)
library(mapSpain)
library(elevatr)
library(metR)
library(ggplot2)
library(tidyterra)
library(ggblend)

map_family <- "inter-tight"
sysfonts::font_add_google("Inter Tight", family = map_family)
showtext::showtext_auto()

map_background <- "#faf8f2"
theme_set(
  theme_minimal(base_family = map_family) +
    theme(
      plot.background = element_rect(fill = map_background, colour = NA),
      panel.background = element_rect(fill = map_background, colour = NA),
      plot.margin = margin(20, 20, 20, 20),
      panel.grid = element_blank(),
      plot.title = element_text(face = "bold", colour = "#203b47"),
      axis.text = element_text(colour = "#203b47"),
      legend.position = "bottom",
      legend.key = element_rect(fill = map_background, colour = NA),
      legend.spacing.x = unit(0, "pt")
    )
)

# The data
andalusia <- esp_get_ccaa("Andalucia", epsg = 3857)
dem <- get_elev_raster(
  andalusia,
  # z = 7, TODO: Use this in the final plot
  z = 5,
  clip = "bbox",
  tmp_dir = tools::R_user_dir("elvatr", "cache")
) |>
  rast()

dem <- project(dem, pull_crs(andalusia))
names(dem) <- "elevation"

# Alpha trick ----
slope_1 <- terrain(dem, "slope", unit = "radians")
aspect_1 <- terrain(dem, "aspect", unit = "radians")

# Single shadow
hill_1 <- shade(slope_1, aspect_1, 40, direction = 270)

pal_greys <- hcl.colors(1000, "Grays")

gghill_1 <- ggplot() +
  geom_spatraster(data = hill_1, maxcell = Inf, show.legend = FALSE) +
  scale_fill_gradientn(colors = pal_greys, na.value = NA) +
  coord_sf(expand = FALSE) +
  labs(title = "Single-direction hillshade", x = NULL, y = NULL)

# Show

print(gghill_1)

# Get colors

pal_1 <- layer_data(gghill_1) |> dplyr::pull(fill)

plot_brks <- sort(c(0, seq(-2500, 3500, 1000))) |> unique()


map_alpha <- ggplot() +
  geom_spatraster(data = hill_1, fill = pal_1, maxcell = Inf) +
  geom_spatraster(data = dem, maxcell = Inf) +
  scale_fill_hypso_tint_c(
    "etopo1",
    alpha = 0.4,
    breaks = plot_brks,
    labels = scales::label_comma()
  ) +
  guides(
    alpha = "none",
    fill = guide_legend(
      title = "   m.",
      direction = "horizontal",
      nrow = 1,
      keywidth = 1.75,
      keyheight = 0.5,
      label.position = "bottom",
      title.position = "right",
      override.aes = list(alpha = 1)
    )
  ) +
  coord_sf(expand = FALSE) +
  labs(title = "Transparent color overlay", x = NULL, y = NULL)

print(map_alpha)

# Introducing metR ----

hill_metr <- ggplot(dem, aes(x, y)) +
  geom_relief(aes(z = elevation)) +
  coord_sf(crs = terra::crs(dem), expand = FALSE) +
  labs(title = "Hillshade with metR", x = NULL, y = NULL)

print(hill_metr)

map_metr <- ggplot(dem, aes(x, y)) +
  geom_relief(aes(z = elevation)) +
  geom_spatraster(
    data = dem,
    inherit.aes = FALSE,
    aes(alpha = after_stat(value)),
    maxcell = Inf
  ) +
  scale_alpha(range = c(1, 0.25)) +
  scale_fill_hypso_tint_c(
    "etopo1",
    alpha = 0.4,
    breaks = plot_brks,
    labels = scales::label_comma()
  ) +
  guides(
    alpha = "none",
    fill = guide_legend(
      title = "   m.",
      direction = "horizontal",
      nrow = 1,
      keywidth = 1.75,
      keyheight = 0.5,
      label.position = "bottom",
      title.position = "right",
      override.aes = list(alpha = 1)
    )
  ) +
  coord_sf(expand = FALSE) +
  labs(title = "Elevation-dependent transparency", x = NULL, y = NULL)

print(map_metr)

# Introducing ggblend (no alpha trick) ----
map_multiply <- ggplot() +
  list(
    geom_spatraster(data = hill_1, fill = pal_1, maxcell = Inf),
    geom_spatraster(data = dem, maxcell = Inf),
    scale_fill_hypso_tint_c(
      "etopo1",
      breaks = plot_brks,
      labels = scales::label_comma()
    )
  ) |>
  blend("multiply") +
  guides(
    alpha = "none",
    fill = guide_legend(
      title = "   m.",
      direction = "horizontal",
      nrow = 1,
      keywidth = 1.75,
      keyheight = 0.5,
      label.position = "bottom",
      title.position = "right",
      override.aes = list(alpha = 1)
    )
  ) +
  coord_sf(expand = FALSE) +
  labs(title = "Multiply blend", x = NULL, y = NULL)

print(map_multiply)

# Multishadows -----

hill_2 <- shade(slope_1, aspect_1, 40, direction = c(225, 270, 315, 360)) |>
  mean()

gghill_2 <- ggplot() +
  geom_spatraster(data = hill_2, maxcell = Inf, show.legend = FALSE) +
  scale_fill_gradientn(colors = pal_greys, na.value = NA) +
  coord_sf(expand = FALSE) +
  labs(title = "Multidirectional hillshade", x = NULL, y = NULL)

# Show
print(gghill_2)

# Get colors
pal_2 <- layer_data(gghill_2) |> dplyr::pull(fill)


map_multi <- ggplot() +
  list(
    geom_spatraster(data = hill_2, fill = pal_2, maxcell = Inf),
    geom_spatraster(data = dem, maxcell = Inf),
    scale_fill_hypso_tint_c(
      "etopo1",
      breaks = plot_brks,
      labels = scales::label_comma()
    )
  ) |>
  blend("multiply") +
  guides(
    alpha = "none",
    fill = guide_legend(
      title = "   m.",
      direction = "horizontal",
      nrow = 1,
      keywidth = 1.75,
      keyheight = 0.5,
      label.position = "bottom",
      title.position = "right",
      override.aes = list(alpha = 1)
    )
  ) +
  coord_sf(expand = FALSE) +
  labs(title = "Multidirectional multiply blend", x = NULL, y = NULL)

print(map_multi)

# Jackpot: strechting + modified palette like the one used by metR

# Stretching
q <- as.numeric(quantile(values(hill_2), c(0.05, 0.95), na.rm = TRUE))

hill_3 <- clamp((hill_2 - q[1]) / diff(q), 0, 1)

gghill_3 <- ggplot() +
  geom_spatraster(data = hill_3, maxcell = Inf, show.legend = FALSE) +
  # scale_fill_gradientn(colors = pal_greys, na.value = NA)
  scale_fill_gradient2(
    high = "white",
    mid = "gray80",
    low = "gray20",
    na.value = "transparent"
  ) +
  coord_sf(expand = FALSE) +
  labs(title = "Stretched multidirectional hillshade", x = NULL, y = NULL)

# Show
print(gghill_3)

# Get colors
pal_3 <- layer_data(gghill_3) |> dplyr::pull(fill)


map_final <- ggplot() +
  list(
    geom_spatraster(data = hill_3, fill = pal_3, maxcell = Inf),
    geom_spatraster(data = dem, maxcell = Inf),
    scale_fill_hypso_tint_c(
      "etopo1",
      breaks = plot_brks,
      labels = scales::label_comma()
    )
  ) |>
  blend("multiply") +
  guides(
    alpha = "none",
    fill = guide_legend(
      title = "   m.",
      direction = "horizontal",
      nrow = 1,
      keywidth = 1.75,
      keyheight = 0.5,
      label.position = "bottom",
      title.position = "right",
      override.aes = list(alpha = 1)
    )
  ) +
  coord_sf(expand = FALSE) +
  labs(title = "Stretched hillshade with multiply", x = NULL, y = NULL)

print(map_final)

# Comparison poster ----

grid::grid.newpage()
grid::pushViewport(grid::viewport(
  layout = grid::grid.layout(
    6,
    2,
    heights = grid::unit(c(0.55, rep(1, 5)), "null")
  )
))

grid::grid.rect(gp = grid::gpar(fill = map_background, col = NA))
grid::grid.text(
  "Five ways to shade Andalusia",
  y = 0.68,
  vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1:2),
  gp = grid::gpar(fontfamily = map_family, fontface = "bold", fontsize = 24)
)
grid::grid.text(
  "Hillshade on the left, elevation colors on the right",
  y = 0.28,
  vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1:2),
  gp = grid::gpar(fontfamily = map_family, fontsize = 12, col = "#203b47")
)

print(gghill_1, vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 1))
print(map_alpha, vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 2))
print(hill_metr, vp = grid::viewport(layout.pos.row = 3, layout.pos.col = 1))
print(map_metr, vp = grid::viewport(layout.pos.row = 3, layout.pos.col = 2))
print(gghill_1, vp = grid::viewport(layout.pos.row = 4, layout.pos.col = 1))
print(map_multiply, vp = grid::viewport(layout.pos.row = 4, layout.pos.col = 2))
print(gghill_2, vp = grid::viewport(layout.pos.row = 5, layout.pos.col = 1))
print(map_multi, vp = grid::viewport(layout.pos.row = 5, layout.pos.col = 2))
print(gghill_3, vp = grid::viewport(layout.pos.row = 6, layout.pos.col = 1))
print(map_final, vp = grid::viewport(layout.pos.row = 6, layout.pos.col = 2))

grid::popViewport()
