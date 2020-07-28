library(sf)
library(rnaturalearth)
library(dplyr)
#library(raster)
rm(list = ls())
#Dir mapslib
#mapslib="~/R/mapslib/rnaturalearthdata"

#Download raster
#ne_download(50,type="GRAY_50M_SR_OB",category = 'raster',destdir = mapslib)
# ne_download(50,type="NE2_50M_SR_W",category = 'raster',destdir = mapslib)
# ne_download(50,type="NE1_50M_SR_W",category = 'raster',destdir = mapslib)
# ne_download(50,type="HYP_50M_SR_W",category = 'raster',destdir = mapslib)
# 
# rst = ne_load(50,
#               type = "NE1_50M_SR",
#               category = 'raster',
#               destdir = mapslib) %>% 
#   brick()
# 
# 
# plotRGB(rst)

for (i in seq(-150,150,30)){
  x=i
  y=seq(-60,60,30)
  f=data.frame(x,y)
  f$xlabel=paste(abs(f$x),ifelse(f$x<0,"W","E"),sep="")
  f$ylabel=paste(abs(f$y),ifelse(f$y<0,"S","N"),sep="") 
  
  if(i==-150){
    coords=f
  } else {
    coords=rbind(coords,f)
  }
  rm(f)
}
#Note that operates in radians, hence 360deg is 2pi
circle=lapply(1:nrow(coords), function(x){
  cbind(pmin(150,pmax(-150,coords[x,1]+5 * sin(seq(0, 2 * pi, length.out = 1000)))),
        pmin(90,pmax(-90,coords[x,2]+5 * cos(seq(0, 2 * pi, length.out = 1000)))))  %>% 
    as.matrix() %>%
    st_linestring() }
  ) %>% st_sfc(crs=4326)
a=st_transform(circle,3857)
plot(a)
st_bbox(a)
plot(circle[10:30],axes=T)
st_bbox(circle[10])
tissot_nopoles=st_sf(coords[,-c(1,2)],geometry=circle)
map=ne_countries(returnclass = "sf")

merc_map=st_transform(map,3857)
merc_tis=st_transform(tissot_nopoles,3857)

plot(st_geometry(merc_map))
plot(st_geometry(merc_tis),add=T,col="red")

rm(circle,coords,i,x,y)
testcenter= tissot_nopoles %>% filter(xlabel=="0E" & ylabel=="0N")
plot(testcenter,axes=T)
st_bbox(testcenter)
merc=st_transform(testcenter,"+proj=merc")
st_crs(merc)
plot(merc,axes=T)
min(abs(st_bbox(merc)))
map=ne_countries(returnclass = "sf")
plot(st_geometry(map))
npole=st_point(c(0,0)) %>% 
  st_sfc(crs="+proj=laea +lon_0=0 +lat_0=90") %>% 
  st_buffer(min(abs(st_bbox(merc)))) %>%
  st_transform(4326)
dra
spole=st_point(c(0,0)) %>% 
  st_sfc(crs="+proj=ortho +lon_0=0 +lat_0=-90") %>% 
  st_buffer(min(abs(st_bbox(merc)))) 
plot(st_geometry(st_transform(map,"+proj=ortho +lon_0=0 +lat_0=60")))
plot(st_geometry(st_transform(tissot_nopoles,"+proj=ortho +lon_0=0 +lat_0=60")),col="red",add=T)
plot(spole,axes=T,col="green",add=T)

f=draw.
plot(pole,axes=T)
plot(tissot_nopoles)
#Add poles=
np=data.frame(x=0,y=90,xlabel="0 E", ylabel="90 N")
sp=data.frame(x=0,y=-90,xlabel="0 E", ylabel="90 S")
coords=rbind(rbind(coords,np),sp)
geom=st_multipoint(as.matrix(coords[,1:2])) %>%st_sfc() %>% st_cast("POINT")
plot(geom)
tissot_cent=st_sf(coords,geometry=geom,crs=4326)
plot(st_geometry(tissot_nopoles))
plot(st_geometry(tissot_nopoles[53,]),axes=T)
st_bbox(tissot_nopoles[53,])
map=ne_countries(50,returnclass = "sf")
plot(st_geometry(map))
plot(st_geometry(tissot_cent),add=T,col="red",cex=1)
#Create circle around
#radius 15degrees
R=15
#Note that operates in radians, hence 360deg is 2pi
nogeom=st_drop_geometry(tissot_cent)
circle=lapply(1:nrow(nogeom), function(x){
  cbind(pmin(180,pmax(-180,nogeom[x,1]+5 * sin(seq(0, 2 * pi, length.out = 1000)))),
        pmin(90,pmax(-90,nogeom[x,2]+5 * cos(seq(0, 2 * pi, length.out = 1000)))))  %>% 
    as.matrix() %>%
    st_linestring() 
  
}) %>% st_sfc(crs=4326)

plot(st_geometry(map))
plot(circle,add=T)

map2=st_crop()
par(mar=c(2,2,2,2))
webmerc=st_transform(map,"+proj=robin +lon_0=40")
webmerc_tiss=st_transform(circle,"+proj=robin +lon_0=40")

plot(st_geometry(webmerc),axes=T)
plot(st_geometry(webmerc_tiss),add=T)
x=1
cbind(tissot_cent[x,1]+15 * sin(seq(0, 2 * pi, length.out = 1000)),
      tissot_cent[x,2]+15 * cos(seq(0, 2 * pi, length.out = 1000)))

%>% 
  as.matrix() %>%
  st_linestring()

xa = 90+R * sin(seq(0, 2 * pi, length.out = 1000))
ya = 60+R * cos(seq(0, 2 * pi, length.out = 1000))
n=cbind(xa,ya) %>% st_linestring() 
plot(n,axes=T)

trans=st_transform(tissot_cent,"+proj=ortho")


plot(st_geometry(trans),col="red",cex=5)

paste(coords[1,],"W")

x=seq(-180,180,30)
y=lapply(points, function(x) seq(-60,60,30))
coord=cbind(x,y)
