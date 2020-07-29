# Setup----
library(pacman)

p_load(ezknitr)
p_load(styler)

diegpost <- function(file) {
  getwd()
  ezknit(
    paste("~/R/dieghernan.github.io/_codes/",file,".Rmd",sep = ""),
    wd="./assets",
    out_dir = "../_posts",
    fig_dir = "../assets/figs",
    keep_html = FALSE
  )
}
#Render 2019-04-27-Using-CountryCodes ----

#diegpost("2019-04-27-Using-CountryCodes")
#diegpost("2019-05-05-Cast to subsegments")
#diegpost("2019-05-13-Where-in-the-world")
#diegpost("2019-05-20-Leaflet_R_Jekyll")
#diegpost("2019-06-02-Beautiful1")
#diegpost("2019-06-18-Beautiful2")
#diegpost("2019-11-07-QuickR")

ezknit(
  "/cloud/project/_Rmd/2019-04-27-Using-CountryCodes.Rmd",
  wd="/cloud/project/assets",
  out_dir = "../collections/_posts",
  fig_dir = "../../assets/img/blog",
  keep_html = FALSE,
  chunk_opts = list(dev='svg'),
  verbose = T
)

