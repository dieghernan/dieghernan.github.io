# Run from the repository root. Pass Rmd filenames to select posts.
source("_Rmd/renderblog_v2.R")

posts <- c("2022-01-28-maps-flags.Rmd")

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
  if (file.exists(alt)) {
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
