#
# input <- "./collections/_posts/2019-10-16-WikiMap1.md" |>
#   path.expand()

all_files <- list.files("./collections/_posts", full.names = TRUE)
input <- all_files[6]

convert_to_devto <- function(input) {
  metadata <- rmarkdown::yaml_front_matter(input)
  file.exists(input)

  output <- file.path("_experiments", "devto", basename(input))

  res <- try(
    system2(
      rmarkdown::pandoc_exec(),
      args = c(
        "-f",
        "gfm",
        "-t",
        "gfm",
        "--wrap=none",
        "-o",
        output,
        input
      ),
      stdout = TRUE,
      stderr = TRUE
    )
  )

  if (!file.exists(output)) {
    cli::cli_alert_warning("Error en { output }")
    return(NULL)
  }

  new_meta <- list(
    "review" = "always",
    tags_choose_4 = paste(
      unique(
        c("rstats", sort(unique(metadata$tags)))
      ),
      collapse = ","
    ),
    "description" = metadata$subtitle,
    "cover_image" = metadata$header_img,
    "cover_image_bk" = metadata$og_image,
    "series" = "review",
    "ai_disclosure_level" = "no_ai"
  )

  pp <- capture.output(cat(yaml::as.yaml(new_meta)))
  body <- readLines(output, warn = FALSE, encoding = "UTF-8")

  al <- paste0("Has alerts? ", any(grepl(".alert|alert-", body)))
  spot <- paste0("Has Spotify? ", any(grepl("spotify", body)))
  ifram <- paste0("Has iframe? ", any(grepl("iframe", body)))
  det <- paste0("Has details_summary? ", any(grepl("<details>", body)))
  math <- paste0("Has math? ", any(grepl("math", body)))

  writeLines(
    c("---", pp, "---", "", al, spot, ifram, det, math, "", body),
    output,
    useBytes = TRUE
  )
  cli::cli_alert_success("OK { output }")
  return(NULL)
}


posts <- lapply(all_files, convert_to_devto)
all_colls <- list.files("./collections/_projects", full.names = TRUE)

cols <- lapply(all_colls, convert_to_devto)
