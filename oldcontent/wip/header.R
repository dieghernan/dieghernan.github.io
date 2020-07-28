#Back
rm(list = ls())
library(sf)
library(rnaturalearth)
library(dplyr)
library(grDevices)
mapworld=st_read("~/R/mapslib/EUROSTAT/CNTR_RG_20M_2016_3857.shp") %>%
  st_transform(crs="+proj=robin")

s=st_bbox(mapworld)
rel=(s["xmax"]-s["xmin"])/(s["ymax"]-s["ymin"])
rm(s)
getwd()
png("./assets/img/headerblog.png", width = 700,height = 700/rel,
    units = "px",res=90)
par(mar=c(0,0,0,0))
plot(st_geometry(mapworld),
     col=c("#008080", "#469594",
           "#6EA9A8", "#93BEBD", "#B7D4D3"),
     border="#132C2C",
     bg="#F3F8F8",
     lwd=0.3)


dev.off()

