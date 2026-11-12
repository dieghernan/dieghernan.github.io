input <- "./collections/_posts/2019-10-16-WikiMap1.md" |>
  path.expand()

file.exists(input)
output <- "post-devto.md"

rmarkdown::pandoc_convert(
  input = input,
  from = "gfm",
  to = "gfm",
  output = "post-devto.md",
  options = "--wrap=none",
  verbose = TRUE
)

system2(
  rmarkdown::pandoc_exec(),
  args = c(
    "-f",
    "gfm",
    "-t",
    "gfm",
    "--wrap=none",
    "-o",
    "post-devto.md",
    input
  ),
  stdout = TRUE,
  stderr = TRUE
)
