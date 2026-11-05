Sys.setlocale("LC_CTYPE", "English_United States.utf8")
rmarkdown::render(
  "_experiments/postal-voronoi-slovenia/postal-voronoi.Rmd",
  quiet = FALSE,
  envir = new.env()
)
