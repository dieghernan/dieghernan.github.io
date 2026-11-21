library(giscoR)
library(tidyverse)
library(sf)


sa <- gisco_get_countries(resolution = 3)
bra <- sa |>
  filter(ISO3_CODE == "BRA")

bra_map <- ggplot(sa) +
  geom_sf(fill = "#DFDFDF", color = "#656565") +
  scale_y_continuous(breaks = seq(-30, 0, 10)) +
  annotate(
    "text",
    x = -28,
    y = -15,
    label = "Atlantic Sea",
    family = "serif",
    fontface = 3,
    color = "#1278AB",
    size = 6
  ) +
  geom_sf(data = bra, fill = "#C12838", color = "#656565") +
  coord_sf(ylim = c(-33, 7), xlim = c(-73, -19)) +
  theme(
    panel.background = element_rect(fill = "#C7E7FB"),
    plot.background = element_rect(fill = "#FEFDFD")
  )


frame <- st_linestring(rbind(
  c(-175, 85),
  c(175, 85),
  c(175, -85),
  c(-175, -85),
  c(-175, 85)
)) |>
  st_segmentize(5) |>
  st_cast("POLYGON") |>
  st_sfc(crs = 4326) |>
  st_transform("+proj=robin")

w <- gisco_get_countries(resolution = 3, epsg = 3857) |>
  select(ISO3_CODE) |>
  st_transform("+proj=robin") |>
  st_intersection(frame)

bra_w <- w |>
  filter(ISO3_CODE == "BRA")

ins <- ggplot(w) +
  geom_sf(data = frame, fill = "white", color = NA) +
  geom_sf(fill = "#DFDFDF", color = "#656565", linewidth = 0.1) +
  geom_sf(data = bra_w, fill = "#C12838", color = "#656565", linewidth = 0.1) +
  geom_sf(data = frame, fill = NA, color = "black", linewidth = 0.3) +
  coord_sf(crs = "+proj=robin") +
  theme_void()


library(cowplot)
# Use the same font metrics when arranging plots off screen.
cowplot::set_null_device(function(width, height) {
  cowplot::agg_null_device(width, height)
  grid::grid.newpage()
})

ggdraw() +
  draw_plot(bra_map) +
  draw_plot(ins, width = 0.35, x = 0.6, y = 0.35)

png_path <- "assets/img/blog/20220303_inset.png"
ggsave(png_path, dpi = 300)
knitr::plot_crop(png_path)

converted <- sub("\\.png$", ".webp", png_path, ignore.case = TRUE)
webp::write_webp(png::readPNG(png_path), converted)
# Read back the result before removing the intermediate image.
webp::read_webp(converted)
unlink(png_path)
