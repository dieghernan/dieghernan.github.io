# Run from the repository root. Pass Rmd filenames to select posts.
source("_Rmd/renderblog_v2.R")

# list.files("_Rmd", pattern = "Rmd$") |> clipr::write_clip()

posts <- c(
  # "2026-11-06-postal-codes.Rmd",
  # "2026-10-24-orange-peel.Rmd",
  # "2026-02-12-geobounds.Rmd",
  # "2025-10-25-mapping-antarctica.Rmd",
  # "2025-02-17-st_valentine.Rmd",
  # "2023-12-16-bertin_dots.Rmd",
  # "2023-01-25-star-map-R.Rmd",
  # "2022-12-12-tidyterra-hillshade-2.Rmd",
  "2022-10-17-tidyterra-hillshade.Rmd"
  # "2022-05-25-tidyterra.Rmd",
  # "2022-05-01-Unknown-pleasures-R.Rmd",
  # "2022-03-03-insetmaps.Rmd",
  # "2022-01-28-maps-flags.Rmd",
  # "2020-04-05-headtails.Rmd",
  # "2019-06-02-Beautiful1.Rmd",
  # "2019-05-05-Cast-to-subsegments.Rmd"
)

for (post in posts) {
  input <- file.path("_Rmd", post)
  styler::style_file(input)
  output <- diegpost_v2(post)

  # Cropping changes the social image dimensions, so measure the final WebP.
  metadata <- rmarkdown::yaml_front_matter(output)
  image_url <- c(metadata$og_image, metadata$header_img)[1]
  if (
    !length(image_url) ||
      is.na(image_url) ||
      !startsWith(image_url, "https://dieghernan.github.io/assets/")
  ) {
    next
  }
  image_path <- sub("^https://dieghernan[.]github[.]io/", "", image_url)

  # Check and update old copies
  alt <- sub("-1.webp", ".webp", image_path)
  if (file.exists(alt) & alt != image_path) {
    tt <- file.copy(image_path, alt, overwrite = TRUE)
  }

  image_size <- dim(webp::read_webp(image_path))

  for (path in c(input, output)) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    lines <- sub(
      "^og_image_width:.*$",
      paste("og_image_width:", image_size[2]),
      lines
    )
    lines <- sub(
      "^og_image_height:.*$",
      paste("og_image_height:", image_size[1]),
      lines
    )
    writeLines(lines, path, useBytes = TRUE)
  }
}

# Special case
res <- list.files(
  "assets/img/blog",
  pattern = "explorepals(.*).png",
  full.names = TRUE
) |>
  lapply(function(local_path) {
    knitr::plot_crop(local_path)
    converted <- sub("\\.png$", ".webp", local_path, ignore.case = TRUE)
    unlink(converted, force = TRUE)
    webp::write_webp(png::readPNG(local_path), converted)
    # Read back the result before removing the intermediate image.
    webp::read_webp(converted)
    unlink(local_path)
  })

# Update featured images
feat_img <- list.files("assets/img/feat")
all_imgs <- list.files("assets/img/blog", full.names = TRUE)

vapply(
  feat_img,
  function(img) {
    if (any(grepl(img, basename(all_imgs)))) {
      file.copy(
        all_imgs[basename(all_imgs) == img],
        file.path(".", "assets", "img", "feat") |> path.expand(),
        overwrite = TRUE
      )
    } else {
      FALSE
    }
  },
  FUN.VALUE = logical(1)
)
