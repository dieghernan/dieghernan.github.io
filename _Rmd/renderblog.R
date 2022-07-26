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

diegpost("2022-05-25-tidyterra")


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
