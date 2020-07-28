#5. Tissots-----

rm(list = ls(all = TRUE))
lonlat.crs = CRS("+init=epsg:4326")
mappath = "C:/Users/q31407/Documents/R/mapslib"
test.spdf = readOGR(dsn = paste(mappath, "CNTR_RG_20M_2016_3857", sep = "/") ,
                    layer = "CNTR_RG_20M_2016_3857")
#Matrix points
for (i in seq(from = -180, to = 180, by = 30)){
  y=seq(from = -90, to = 90, by = 30)
  x=rep(i,length(y))
  if(i==-180){
    mat_p=cbind(x,y)
  }
  else{
    mat_p=rbind(mat_p,cbind(x,y))
  }
  rm(x,y)
  if(i==180){
    mat_p=data.frame(mat_p)
    nopolar=subset(mat_p,abs(mat_p$y)<90)
    rm(mat_p)
  }
}

#SpatialPolygons
for (i in 1:nrow(nopolar)){
  s=nopolar[i,]
  rad=5*40075*1000/360
  cir=destPoint(s,b=1:361,rad)
  lon=ifelse(abs(cir[,1]-s[1,1])>100,s[1,1],cir[,1])
  lat=ifelse(abs(cir[,2]-s[1,2])>100,s[1,2],cir[,2])
  cir=cbind(lon,lat)
  cir=Polygon(cir)
  cir=SpatialPolygons(list(Polygons(list(cir), as.character(i))))
  proj4string(cir)=projection(lonlat.crs)
  if(i==1){
    tissot.sp=cir
  }
  else{
    tissot.sp=rbind(tissot.sp,cir)
  }
  rm(cir,s)
}
rm(nopolar,i,lat,lon)
#North Pole points
NP.CRS=CRS("+init=epsg:3035 +lat_0=90 +units=m")
NP.map=spTransform(test.spdf,NP.CRS)
NP.sp=gCentroid(as(extent(NP.map),"SpatialPolygons"))
proj4string(NP.sp)=NP.CRS
NP.sp=gBuffer(NP.sp,width=rad)
NP.sp=spTransform(NP.sp,lonlat.crs)
rm(NP.CRS,NP.map)
NP.sp <- spChFIDs(NP.sp, as.character(length(row.names(tissot.sp))+1))
tissot.sp=rbind(tissot.sp,NP.sp)

#South Pole points
coorNP=NP.sp@polygons[[1]]@Polygons[[1]]@coords
coorSP=coorNP*-1
SP.sp=Polygon(coorSP)
SP.sp=SpatialPolygons(list(Polygons(list(SP.sp), as.character(length(row.names(tissot.sp))+1))))
proj4string(SP.sp)=projection(NP.sp)
tissot.sp=rbind(tissot.sp,SP.sp)
rm(NP.sp,coorSP,coorNP,SP.sp,rad)

grlogic

if (!grlogic){
  grlogic=TRUE
}
if (missing(grlogic)){
  grlogic=TRUE
}

test_tissot<-function(projtext,map,tissot,grlogic=TRUE,NPlogic=TRUE,SPlogic=TRUE){
  proj=CRS(projtext)
  library(scales)
  #Project
  map_i=spTransform(map,proj)
  tis=tissot
  if (!SPlogic){
    tis=tis[-67,]
  }
  if(!NPlogic){
    tis=tis[1:65,]
  }
  
  tiss_i=spTransform(tis,proj)
  plot(map_i,col = "#FDFFE3", border = NA,bg="#C8EBFF")
  if (grlogic){
  grid_i = gridlines(  tissot.sp,  easts = seq(from = -180, to = 180, by = 30),  norths = seq(from = -90, to = 90, by = 30),ndiscr = 50)  
  grid_i=spTransform(grid_i,proj)
  plot(grid_i,col="grey45",lty=3,add=T)
  }
  
  #Plot
  plot(tiss_i,add=T,col=alpha("#ED8956", 0.4),border=NA)
  title(projtext)
}
test_tissot("+proj=aea +lat_1=29.5 +lat_2=42.5",test.spdf,tissot.sp,SPlogic = F)
test_tissot("+proj=aeqd",test.spdf,tissot.sp)
test_tissot("+proj=aitoff",test.spdf,tissot.sp)
test_tissot(("+proj=wintri"),test.spdf,tissot.sp)

test_tissot(("+proj=eqc"),test.spdf,tissot.sp)
test_tissot(("+init=epsg:3857"),test.spdf,tissot.sp)
test_tissot(("+proj=cea +lat_ts=45"),test.spdf,tissot.sp)
test_tissot("+init=epsg:3035",test.spdf,tissot.sp)
test_tissot("+proj=moll",test.spdf,tissot.sp)
test_tissot("+proj=robin",test.spdf,tissot.sp)
test_tissot(("+proj=wintri"),test.spdf,tissot.sp)
#-------------------------------


#3 Alternativas----
hexsquaremap <- function(sf,
                   tipo = "square",
                   ancho = 50,
                   grupo = F) {
  if (tipo == "square") {
    type = T
  }
  else{
    type = F
  }
  initial = sf
  initial$index_target = 1:nrow(initial)
  target = st_geometry(initial)
  grid = st_make_grid(
    target,
    ancho,
    crs = st_crs(initial),
    what = "polygons",
    square = type
  )
  grid = st_sf(index = 1:length(lengths(grid)), grid)
  cent_grid = st_centroid(grid)
  cent_merge = st_join(cent_grid, initial["index_target"], left = F)
  grid_new = inner_join(grid, st_drop_geometry(cent_merge))
  if (grupo == F) {
    noagrup = aggregate(
      grid_new,
      by = list(grid_new$index_target),
      FUN = min,
      do_union = FALSE
    )
    a = noagrup
  }
  else {
    agrup = aggregate(
      st_buffer(grid_new, dist = 0.5),
      by = list(grid_new$index_target),
      FUN = min
    )
    a = agrup
  }
  
  data = st_drop_geometry(initial)
  a = left_join(a, data)
  a = a[names(sf)]
  a = st_cast(a, "MULTIPOLYGON")
  return(a)
}

dotsmap <- function(sf,
                    ancho = 50) {
  initial = sf
  initial$index_target = 1:nrow(initial)
  target = st_geometry(initial)
  grid = st_make_grid(target,
                      ancho,
                      crs = st_crs(initial),
                      what = "centers")
  grid = st_sf(index = 1:length(lengths(grid)), grid)
  cent_merge = st_join(grid, initial["index_target"], left = F)
  grid_new = st_buffer(cent_merge, ancho / 2)
  
  a = aggregate(
    grid_new,
    by = list(grid_new$index_target),
    FUN = min,
    do_union = FALSE
  )
  data = st_drop_geometry(initial)
  a = left_join(a, data)
  a = a[names(sf)]
  a = st_cast(a, "MULTIPOLYGON")
  return(a)
}

