# Run from the repository root. Pass Rmd filenames to select drafts.
source("_Rmd/renderblog_v2.R")

drafts <- commandArgs(trailingOnly = TRUE)
if (!length(drafts)) {
  drafts <- c(
    "headtails.Rmd"
    # "never-trust-a-map.Rmd",
    # "better-hillshading-R.Rmd"
  )
}

draft_image_path <- "assets/img/drafts/"
draft_image_url <- paste0("https://dieghernan.github.io/", draft_image_path)
cover_prefix <- paste0(
  "^https://(dieghernan[.]github[.]io|dhhdevblog[.]netlify[.]app)/",
  draft_image_path
)

for (draft in drafts) {
  input <- file.path("_Rmd", basename(draft))
  styler::style_file(input)
  output <- diegpost_draft_v2(draft)

  metadata <- rmarkdown::yaml_front_matter(output)
  cover_url <- c(metadata$og_image, metadata$header_img)[1]
  image_size <- NULL
  if (
    length(cover_url) &&
      !is.na(cover_url) &&
      grepl(cover_prefix, cover_url)
  ) {
    image_path <- paste0(draft_image_path, sub(cover_prefix, "", cover_url))
    image_size <- dim(webp::read_webp(image_path))
  }

  for (path in c(input, output)) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    if (identical(path, output)) {
      lines <- gsub(
        paste0('src="', draft_image_url),
        'src="/assets/img/drafts/',
        lines,
        fixed = TRUE
      )
    }
    if (!is.null(image_size)) {
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
    }
    writeLines(lines, path, useBytes = TRUE)
  }
  gc()
}
