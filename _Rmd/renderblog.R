# Setup----
library(pacman)

p_load(ezknitr)
p_load(styler)

path.expand("./_Rmd")

file.path(getwd())

diegpost <- function(file) {
  getwd()
  ezknit(
    paste0(getwd(),"/_Rmd/",file,".Rmd"),
    out_dir = "./collections/_posts",
    fig_dir = "../assets/img/blog",
    keep_html = FALSE
  )

  # # Move images
  current_folder <- "./collections/assets/img/blog"
  new_folder <- "./assets/img/blog"
  list_of_files <- list.files(current_folder)
  file.copy(file.path(current_folder,list_of_files), new_folder, overwrite = TRUE, recursive = TRUE)
  unlink("./collections/assets",
         recursive = TRUE,
         force = TRUE)

  # Fix img links
  newfile <- paste0("./collections/_posts", "/", file, ".md")

  lines <- readLines(newfile)
  newlines <- gsub('<img src="../assets/img',
                   '<img src="https://dieghernan.github.io/assets/img', lines)
  newlines <- gsub('(../assets/img',
                   '(https://dieghernan.github.io/assets/img',
                   newlines, fixed = TRUE)

  # Fix double slashes
  newlines <- gsub("https://dieghernan.github.io/assets/img//",
                   "https://dieghernan.github.io/assets/img/", newlines, fixed = TRUE)

  newlines <- gsub("https://dieghernan.github.io/assets/img/blog//",
                   "https://dieghernan.github.io/assets/img/blog/", newlines, fixed = TRUE)

  writeLines(newlines, newfile)

}


diegpost_draft <- function(file) {
  getwd()
  ezknit(
    paste0(getwd(),"/_Rmd/",file,".Rmd"),
    out_dir = "./collections/_drafts",
    fig_dir = "../assets/img/drafts",
    keep_html = FALSE
  )

  # # Move images
  current_folder <- "./collections/assets/img/drafts"
  new_folder <- "./assets/img/drafts/"
  list_of_files <- list.files(current_folder)

  file.copy(file.path(current_folder,list_of_files), new_folder, overwrite = TRUE, recursive = TRUE)

  unlink("./collections/assets",
         recursive = TRUE,
         force = TRUE)

  # Fix img links
  newfile <- paste0("./collections/_drafts", "/", file, ".md")

  lines <- readLines(newfile)
  newlines <- gsub('<img src="../assets/img',
                   '<img src="https://dieghernan.github.io/assets/img', lines)
  newlines <- gsub('(../assets/img',
                   '(https://dieghernan.github.io/assets/img',
                   newlines, fixed = TRUE)

  # Fix double slashes
  newlines <- gsub("https://dieghernan.github.io/assets/img//",
                   "https://dieghernan.github.io/assets/img/", newlines, fixed = TRUE)

  newlines <- gsub("https://dieghernan.github.io/assets/img/drafts//",
                   "https://dieghernan.github.io/assets/img/drafts/", newlines, fixed = TRUE)

  writeLines(newlines, newfile)

}


file <- "bertin_dots"
diegpost_draft(file)



plots <- list.files("./assets/img/blog", pattern = "png$", full.names = TRUE)
file

lapply(plots, knitr::plot_crop)

knitr::plot_crop("./assets/img/drafts/xxx_celestial_map_cn-1.png")

rm(list = ls())



#Render 2019-04-27-Using-CountryCodes ----

#diegpost("2019-04-27-Using-CountryCodes")
# diegpost("2019-05-05-Cast to subsegments")
#
# #diegpost("2019-05-13-Where-in-the-world")
# #diegpost("2019-05-20-Leaflet_R_Jekyll")
# diegpost("2019-06-02-Beautiful1")
# diegpost("2019-06-18-Beautiful2")
# #diegpost("2019-10-16-WikiMap1")
# diegpost("2019-11-07-QuickR")
# diegpost("2019-12-12-Beautiful3")
# diegpost("2020-02-06-Brexit")
# diegpost("2020-02-17-cartography1")
# diegpost("2020-04-05-headtails")
# diegpost("2022-03-03-insetmaps")

# diegpost("2022-05-25-tidyterra")
diegpost("2019-05-13-Where-in-the-world")

knitr::plot_crop("./assets/img/blog/20221017-6-finalplot-1.png")

file="2022-03-03-insetmaps"

# Fix img url

allmds <- list.files("./collections/", recursive = TRUE, pattern = ".md$", full.names = TRUE)

for (newfile in allmds){
  message(newfile, "\n")

  lines <- readLines(newfile)
  newlines <- gsub('<img src="../assets/img',
                   '<img src="https://dieghernan.github.io/assets/img', lines)
  newlines <- gsub('(../assets/img',
                   '(https://dieghernan.github.io/assets/img',
                   newlines, fixed = TRUE)


  writeLines(newlines, newfile)
}








# ezknit(
#   "/cloud/project/_Rmd/2019-04-05-Cast to subsegments.Rmd",
#   wd="/cloud/project/assets",
#   out_dir = "../collections/_posts",
#   fig_dir = "../../assets/img/blog",
#   keep_html = FALSE,
#   chunk_opts = list(dev='svg'),
#   verbose = T
# )


draft <- "Unknown-pleasures-R"

# unlink(".collections", recursive = TRUE)

ezknit(
  paste0(getwd(),"/_Rmd/",draft,".Rmd"),
  out_dir = "./collections/_drafts",
  fig_dir = "./img/",
  keep_html = FALSE
)


# Try converting to webp

im <- list.files("assets/img/towebp", full.names = TRUE)

im <- plots

lapply(im, function(x){
  
  file.copy(x, "./assets/img/towebp")
  unlink(x)
  
})

x <- "bonne_proj.png"

a <- lapply(im, function(x){
  
f <- png::readPNG(x)  

out <- gsub(".png$", ".webp", x)

aa <- try(webp::write_webp(f, out), silent = TRUE)  

if (class(aa) == "try-error"){
  file.copy(x, "assets/img/blognoconv")
  
}
  
})

webp::write_webp(f, "a.webp")

x <- im[1]

x <- "assets/img/blog/20191212_imgpost-1.png"

img <- magick::image_read(x)
img2 <- magick::image_convert(img,  colorspace = "sRGB")

aa <- magick::image_data(img, "rgba")

arr <- as.raster(img2)

magick::colorspace_types()

install.packages("ggpattern")


posts <- list.files("collections/_posts", full.names = TRUE)

i = 19

file.edit(posts[i])
