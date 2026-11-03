# Render Madrid postal areas without a banner or labels.
# Run: Rscript _scripts/postal-codes-spain.R [path/to/cp-28.geojson]
# Requires sf, ggplot2, ragg and magick.
# Source: https://dieghernan.github.io/codigospostales/ (CC BY 4.0).
# Administrative boundaries: Goerlich and Pérez Vázquez (2025),
# https://doi.org/10.5281/zenodo.15345101.

render_postal_areas <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  script <- commandArgs() |>
    grep(pattern = "^--file=", value = TRUE) |>
    sub(pattern = "^--file=", replacement = "") |>
    normalizePath()
  root <- dirname(dirname(script))
  source <- if (length(args)) {
    args[[1]]
  } else {
    "https://dieghernan.github.io/codigospostales/assets/data/cp-28.geojson"
  }

  postal_areas <- sf::read_sf(source) |>
    sf::st_transform(25830)
  postal_areas$highlight <- as.integer(postal_areas$COD_POSTAL) %% 7 == 0
  map <- ggplot2::ggplot(postal_areas) +
    ggplot2::geom_sf(
      ggplot2::aes(fill = highlight),
      color = "#777575",
      linewidth = 0.14
    ) +
    ggplot2::scale_fill_manual(values = c("#dedddd", "#ff9285")) +
    ggplot2::coord_sf(expand = TRUE) +
    ggplot2::theme_void() +
    ggplot2::theme(
      legend.position = "none",
      plot.background = ggplot2::element_rect(fill = "#f2f1f1", color = NA),
      plot.margin = ggplot2::margin(12, 12, 12, 12)
    )

  temporary_png <- tempfile(fileext = ".png")
  on.exit(unlink(temporary_png), add = TRUE)
  ggplot2::ggsave(
    temporary_png,
    map,
    device = ragg::agg_png,
    width = 12,
    height = 8,
    units = "in",
    dpi = 200,
    bg = "#f2f1f1"
  )
  image <- magick::image_read(temporary_png) |>
    magick::image_resize("1200x800!") |>
    magick::image_strip()
  output <- file.path(root, "assets/img/misc/postal-codes-spain")
  magick::image_write(
    image,
    paste0(output, ".jpg"),
    format = "jpeg",
    quality = 92
  )
  magick::image_write(
    image,
    paste0(output, ".webp"),
    format = "webp",
    quality = 85,
    defines = c("webp:lossless" = "false", "webp:method" = "6")
  )
  print(magick::image_info(image))
}

render_postal_areas()
