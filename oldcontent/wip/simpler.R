#1. Set up----
rm(list = ls(all = TRUE))

library(sf)
library(rnaturalearth)
library(dplyr)
library(RColorBrewer)

RColorBrewer::brewer.pal.info


europe  <- ne_download(50,type="map_subunits", returnclass = "sf", destdir = tempdir()) %>%
  subset(CONTINENT=="Europe")

# Gridding
europe=st_transform(europe,3857)

## Important, the grid widht is established in the same unit that the projection, in this case is meters (m)
st_make_grid()


grid = st_make_grid(europe,
                    500,
                    crs = st_crs(europe),
                    what = "polygons",
                    square = TRUE
                    )

plot(grid)


plot(st_geometry(Hexbin),col=brewer.pal(7,"Blues"), main="Honeycomb")


RColorBrewer::display.brewer.all()

library(pacman)
p_load(
  sf,
  raster,
  dplyr,
  cartography,
  rnaturalearth,
  openxlsx,
  rmapshaper,sp)

testmap=getData("GADM",country="ESP",level=1)
testmap_sf=st_as_sf(testmap)
testmap_sf=testmap_sf[1:3,]
plot(st_geometry(testmap_sf))


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

hexno=hexsquaremap(testmap_sf,"hex",1,F)
hexsi=hexsquaremap(testmap_sf,"hex",1,T)
squno=hexsquaremap(testmap_sf,"square",1,F)
squsi=hexsquaremap(testmap_sf,"square",1,T)
dots=dotsmap(testmap_sf,1)
dev.off()
par(mfrow = c(3, 2), mar = c(1, 1, 1, 1))
plot(st_geometry(hexno),col=colors()[60:90])
plot(st_geometry(hexsi),col=colors()[60:90])
plot(st_geometry(squno),col=colors()[60:90])
plot(st_geometry(squsi),col=colors()[60:90])
plot(st_geometry(dots),col=colors()[60:90])
simply=ms_simplify(testmap_sf,keep=0.001) %>% st_as_sf()
plot(st_geometry(simply),col=colors()[60:90])
file.remove("gadm36_ESP_1_sp.rds")

