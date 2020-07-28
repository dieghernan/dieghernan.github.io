# https://stackoverflow.com/questions/59185908/background-images-with-sf-maps-and-alternative-crs

rm(list = ls())
setwd("/cloud/project/myprojects/stackoverflow")


# Libraries----
library(sf)
library(raster)
library(rnaturalearth) #To get cities and coast to reprex

# Load shapefiles----
#popm.sf
popn.sf = ne_download(50, type = "populated_places", returnclass = "sf")
popn.sf_4326 = st_transform(popn.sf, 4326)
popn.sf_3035 = st_transform(popn.sf_4326, 3035)

#coasts
coast.sf = ne_download(10,
                       category = "physical",
                       type = "coastline",
                       returnclass = "sf")
coast.sf_4326 = st_transform(coast.sf, 4326)
coast.sf_3035 = st_transform(coast.sf, 3035)


# Background----
# Download NASA night lights image
download.file(
  "https://www.nasa.gov/specials/blackmarble/2016/globalmaps/BlackMarble_2016_01deg.jpg",
  destfile = "BlackMarble_2016_01deg.jpg",
  mode = "wb"
)

#To brick
earth <- brick("BlackMarble_2016_01deg.jpg")
raster_4326 <- earth
projection(raster_4326) <-
  CRS(st_crs(popn.sf_4326)[["proj4string"]])
extent(raster_4326) <-
  c(-180, 180,-89.99, 89.99) # Sligth offset to 180,180,-90,90 to avoid errors

#Project raster
proj3035 <- st_crs(popn.sf_3035)[["proj4string"]]
raster_3035 = projectRaster(raster_4326, crs = proj3035) # Some warnings, but still working

#Extra: to plots----
png(
  "/cloud/project/assets/figs/proj4326.png",
  bg = "#05050f",
  height = dim(raster_4326)[1],
  width = dim(raster_4326)[2]
)
par(mar = c(0, 0, 0, 0))
plotRGB(raster_4326, bgalpha = 0)
plot(coast.sf_4326$geometry, col = "blue", add = T)
plot(
  popn.sf_4326$geometry,
  col = adjustcolor("white", alpha.f = .4),
  pch = 20,
  cex = 3,
  add = T
)
dev.off()

png(
  "/cloud/project/assets/figs/proj3035.png",
  bg = "#05050f",
  height = dim(raster_3035)[1],
  width = dim(raster_3035)[2]
)
par(mar = c(0, 0, 0, 0))
plotRGB(raster_3035, bgalpha = 0)
plot(coast.sf_3035$geometry, col = "blue", add = T)
plot(
  popn.sf_3035$geometry,
  col = adjustcolor("white", alpha.f = .4),
  pch = 20,
  cex = 3,
  add = T
)
dev.off()

