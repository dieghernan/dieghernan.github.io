# Libraries----

rm(list = ls())
library(sf)
library(geosphere)
library(rnaturalearth)

#Matrix points
for (i in seq(from = -180, to = 180, by = 30)) {
  y = seq(from = -90, to = 90, by = 30)
  x = rep(i, length(y))
  if (i == -180) {
    mat_p = cbind(x, y)
  }
  else{
    mat_p = rbind(mat_p, cbind(x, y))
  }
  rm(x, y)
  if (i == 180) {
    mat_p = data.frame(mat_p)
    nopolar = subset(mat_p, abs(mat_p$y) < 90)
    rm(mat_p)
  }
}
nopolar$xlabel=paste(abs(nopolar$x),ifelse(nopolar$x<0,"W","E"),sep="")
nopolar$ylabel=paste(abs(nopolar$y),ifelse(nopolar$y<0,"S","N"),sep="") 
for (i in 1:nrow(nopolar)) {
  s = nopolar[i,]
  rad = 5 * 40075 * 1000 / 360
  cir = destPoint(s[, 1:2], b = 1:361, rad)
  lon = ifelse(abs(cir[, 1] - s[1, 1]) > 100, s[1, 1], cir[, 1])
  lat = ifelse(abs(cir[, 2] - s[1, 2]) > 100, s[1, 2], cir[, 2])
  cir = cbind(lon, lat)
  cir = st_polygon(list(cir)) %>% st_sfc(crs = 4326)
  cir = st_sf(s, geom = cir)
  if (i == 1) {
    tissot = cir
  } else {
    tissot = rbind(tissot, cir)
  }
  rm(cir, s, lat, lon)
}
rm(i)

#North pole

np=st_point(c(0,0)) %>% st_sfc(crs="+proj=ortho +lat_0=90 +units=m")
np=st_buffer(np,rad)

sp=st_point(c(0,0)) %>% st_sfc(crs="+proj=ortho +lat_0=-90 +units=m")
a=st_read("https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/countries/geojson/CNTR_RG_10M_2016_3035.geojson")

