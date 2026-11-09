# Run from the repository root. Preview with bundle exec jekyll serve --drafts.
source("_Rmd/renderblog_v2.R")

draft <- diegpost_draft_v2("never-trust-a-map.Rmd")
markdown <- readLines(draft, warn = FALSE, encoding = "UTF-8")
markdown <- sub(
  'src="https://dieghernan.github.io/assets/img/drafts/',
  'src="/assets/img/drafts/',
  markdown,
  fixed = TRUE
)
writeLines(markdown, draft, useBytes = TRUE)
