# Render posts from any working directory after sourcing this file.
.renderblog_root <- local({
  script <- sys.frame(1)$ofile
  if (is.null(script)) {
    normalizePath(".", winslash = "/", mustWork = TRUE)
  } else {
    normalizePath(
      file.path(dirname(script), ".."),
      winslash = "/",
      mustWork = TRUE
    )
  }
})

render_blog <- function(file, draft = FALSE, root = .renderblog_root) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  name <- sub("\\.[Rr]md$", "", basename(file))
  input <- file.path(root, "_Rmd", paste0(name, ".Rmd"))
  if (!file.exists(input)) {
    stop("Rmd file not found: ", input, call. = FALSE)
  }
  folder <- if (draft) "drafts" else "blog"
  output_dir <- file.path(
    root,
    "collections",
    if (draft) "_drafts" else "_posts"
  )
  image_dir <- paste0("assets/img/", folder, "/")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(root, image_dir), recursive = TRUE, showWarnings = FALSE)

  old_knit <- knitr::opts_knit$get()
  old_chunk <- knitr::opts_chunk$get()
  old_hooks <- knitr::knit_hooks$get()
  old_option_hooks <- knitr::opts_hooks$get()
  on.exit(
    {
      knitr::opts_knit$restore(old_knit)
      knitr::opts_chunk$restore(old_chunk)
      knitr::knit_hooks$restore(old_hooks)
      knitr::opts_hooks$restore(old_option_hooks)
    },
    add = TRUE
  )

  knitr::opts_knit$set(root.dir = root, base.dir = root)
  knitr::opts_chunk$set(
    fig.path = paste0(image_dir, name, "-"),
    dev = "ragg_png",
    dpi = 200
  )
  knitr::render_markdown()
  knitr::opts_hooks$set(fig.path = function(options) {
    options$fig.path <- paste0(image_dir, basename(options$fig.path))
    options
  })
  plot_hook <- knitr::knit_hooks$get("plot")
  knitr::knit_hooks$set(plot = function(x, options) {
    urls <- vapply(
      x,
      function(path) {
        local_path <- if (grepl("^([A-Za-z]:|/)", path)) {
          path
        } else {
          file.path(root, path)
        }
        if (grepl("\\.png$", path, ignore.case = TRUE)) {
          converted <- sub("\\.png$", ".webp", local_path, ignore.case = TRUE)
          webp::write_webp(png::readPNG(local_path), converted)
          # Read back the result before removing the intermediate image.
          webp::read_webp(converted)
          unlink(local_path)
          local_path <- converted
        }
        absolute <- normalizePath(local_path, winslash = "/", mustWork = TRUE)
        prefix <- paste0(root, "/")
        if (!startsWith(absolute, prefix)) {
          stop(
            "Generated image is outside the blog directory: ",
            absolute,
            call. = FALSE
          )
        }
        paste0(
          "https://dieghernan.github.io/",
          substring(absolute, nchar(prefix) + 1)
        )
      },
      character(1)
    )
    plot_hook(urls, options)
  })

  temporary <- tempfile(fileext = ".md")
  on.exit(unlink(temporary), add = TRUE)
  knitr::knit(input, output = temporary, envir = new.env(parent = globalenv()))
  output <- file.path(output_dir, paste0(name, ".md"))
  if (!file.copy(temporary, output, overwrite = TRUE)) {
    stop("Could not save Markdown: ", output, call. = FALSE)
  }
  message("Post rendered: ", output)
  invisible(output)
}

diegpost <- function(file, root = .renderblog_root) {
  render_blog(file, root = root)
}

diegpost_draft <- function(file, root = .renderblog_root) {
  render_blog(file, draft = TRUE, root = root)
}
