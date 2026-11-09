# Run from the repository root. Preview with bundle exec jekyll serve --drafts.
source("_Rmd/renderblog_v2.R")

draft <- diegpost_draft_v2("never-trust-a-map.Rmd")


markdown <- readLines(draft, warn = FALSE, encoding = "UTF-8")
# Cropping changes the social image dimensions, so measure the final WebP.
metadata <- rmarkdown::yaml_front_matter(draft)
image_path <- sub("^https://dhhdevblog[.]netlify[.]app/", "", metadata$og_image)
image_path <- sub("^/", "", image_path)
image_size <- dim(webp::read_webp(image_path))
markdown <- sub(
  "^og_image_width:.*$",
  paste("og_image_width:", image_size[2]),
  markdown
)
markdown <- sub(
  "^og_image_height:.*$",
  paste("og_image_height:", image_size[1]),
  markdown
)
writeLines(markdown, draft, useBytes = TRUE)
