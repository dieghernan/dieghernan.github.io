#0. Prepare R----
rm(list = ls())
library(pacman)

p_load(sf,
       rnaturalearth,
       dplyr)



#1. Functions----
st_orthoproj <- function(sf, xinit, yinit) {
  #S1 - Prepare
  #System - deactivate warnings
  oldw <- getOption("warn")
  options(warn = -1)
  
  #Unproject map
  sfinit = sf %>%
    st_buffer(0) %>%
    st_transform(crs = 4326)
  
  #Center
  clon = xinit
  #This minimize an error when cropping
  if (yinit == 0) {
    clat = 0.001
  } else {
    clat = yinit
  }
  crs.out = paste("+proj=ortho +lon_0=",
                  clon,
                  " +lat_0=",
                  clat,
                  sep = "")
  
  #S2 - Border Projected map
  #Earth radius in m as per the internal math or sf
  R = 6378137 
  
  #Equations from wikipedia: https://en.wikipedia.org/wiki/Orthographic_projection_in_cartography#Mathematics
  #Note that operates in radians, hence 360deg is 2pi
  x = R * sin(seq(0, 2 * pi, length.out = 1000))
  y = R * cos(seq(0, 2 * pi, length.out = 1000))
  border = cbind(x, y) %>%
    st_multipoint() %>%
    st_sfc(crs = crs.out)
  
  #S3 - Prepare cut by unprojecting Border
  border_un = st_transform(border, 4326) %>%
    st_geometry()
  
  #Arrange coordinates
  coord = st_coordinates(border_un) %>%
    as.data.frame() %>%
    arrange(X, Y) %>% select(X, Y)
  
  #Complete polygon by using bbox
  bbox = st_bbox(border_un)
  #This is to draw the closure either to the North or South Pole, depending of the hemisphere where proj is centered
  if (clat > 0) {
    a1 = bbox["ymax"]
    a2 = 90
    
  } else {
    a1 = bbox["ymin"]
    a2 = -90
  }
  #Complete coordinates and close
  X = c(bbox["xmax"], bbox["xmax"], bbox["xmin"], bbox["xmin"])
  Y = c(a1, a2, a2, a1)
  pol = rbind(coord,
              cbind(X, Y)) %>%
    as.matrix() %>%
    st_linestring() %>%
    st_cast("POLYGON") %>%
    st_sfc(crs = 4326)
  
  #S4 - Get smoothed map and project
  sfcrop = st_intersection(sfinit, pol) %>%
    st_transform(crs = crs.out)
  
  #Fix validity by buffering
  ptr = st_buffer(sfcrop[!is.na(st_is_valid(sfcrop)), ], 0.0)
  
  options(warn = oldw)
  #S5 - Output
  return(ptr)
}
st_orthoborder <- function(xinit, yinit) {
  clon = xinit
  #This minimize an error when cropping
  if (yinit == 0) {
    clat = 0.001
  } else {
    clat = yinit
  }
  crs.out = paste("+proj=ortho +lon_0=",
                  clon,
                  " +lat_0=",
                  clat,
                  sep = "")
  orthoborder = cbind(6378137 * sin(seq(0, 2 * pi, length.out = 1000)),
                      6378137 * cos(seq(0, 2 * pi, length.out = 1000))) %>%
    st_linestring() %>%
    st_sfc(crs = crs.out) %>%
    st_cast("POLYGON")
  return(orthoborder)
}

st_orthogrid <- function(cuts, xinit, yinit) {
  clon = xinit
  #This minimize an error when cropping
  if (yinit == 0) {
    clat = 0.001
  } else {
    clat = yinit
  }
  crs.out = paste("+proj=ortho +lon_0=",
                  clon, 
                  " +lat_0=", 
                  clat, 
                  sep = "")
  
  grid = st_graticule(
    lon = seq(-180, 180, cuts),
    lat = seq(-90, 90, cuts),
    ndiscr = 100,
    margin = 10e-9
  ) %>%
    st_transform(crs = crs.out)
  #After projecting some lines are null or converted to points
  grid = grid[lengths(grid$geometry) > 2,]
  for (i in 1:nrow(grid)) {
    #Segmentize
    seg = grid[i, ]
    segp = st_cast(seg, "POINT")
    #Create segments n-1
    segp_c = st_coordinates(segp)
    for (f in 1:(nrow(segp) - 1)) {
      line = segp_c[f:(f + 1), ] %>%
        as.matrix() %>%
        st_linestring()
      linedf = st_sf(f, geom = st_geometry(line))
      names(linedf) = c("ii", "geom")
      if (f == 1) {
        linfin = linedf
      } else{
        linfin = rbind(linfin, linedf)
      }
    }
    linfin$l = as.integer(st_length(linfin)) / 1000
    linfin = linfin %>% filter(l < 3000) %>% st_combine()
    linfin = st_sf(i, geom = linfin)
    names(linfin) = c("ind", "geom")
    if (i == 1) {
      segs = linfin
    } else {
      segs = rbind(segs, linfin)
    }
  }
  st_crs(segs) = crs.out
  segs = st_geometry(segs)
  return(segs)
}

#2. Test zone----
x = 0
y = 0
#_Load shp
cntry = ne_countries(50, "countries", returnclass = "sf")

#Orthoborder
ort_border = st_orthoborder(x, y)

#Orthomap
ort_map = st_orthoproj(cntry, x, y)

#Orthogrid
ort_grid = st_orthogrid(30, x, y)


#3. Plots----
plot(ort_border)
plot(ort_grid, add = T)
plot(st_geometry(ort_map), add = T)

#4 Wikistyle----
library(jsonlite)
download.file("https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodesfull.json",
              "Countrycodesfull.json")
ISOfull = fromJSON("Countrycodesfull.json") %>% as.data.frame()
ISO_orgnames = function(df) {
  orgs_index = unlist(df[1, "org_id"]) %>% as.data.frame(stringsAsFactors =
                                                         F)
  names(orgs_index) = "orgs"
  return(orgs_index)
}
db=ISO_orgnames(ISOfull)


#Extract 
ISO_memcol <- function(df,
                       orgtosearch) {
  ind <- match(orgtosearch, unlist(df[1, "org_id"]))
  or <- lapply(1:nrow(df), function(x)
    unlist(df[x, "org_member"])[ind])
  or <- data.frame(matrix(unlist(or)), stringsAsFactors = F)
  names(or) <- orgtosearch
  df2 <- as.data.frame(cbind(df, or, stringsAsFactors = F))
  return(df2)
}
replace = ISO_memcol(ISOfull, "AU")

#Replace sf from origin
#SHP from Eurostat: crs 3857 - Pseudomercator

#For reproductibiliy purposes
# download.file(
#   "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/countries/shp/CNTR_RG_03M_2016_3857.shp.zip",
#   paste(tempdir(),
#         "test.zip",
#         sep="/")
# )
# 
# unzip(paste(tempdir(),
#             "test.zip",
#             sep="/"),
#       exdir=tempdir())
# 
# map=st_read(paste(tempdir(),
#                   "CNTR_RG_03M_2016_3857.shp",
#                   sep = "/")
#             )
map=st_read("~/R/mapslib/EUROSTAT/CNTR_RG_03M_2016_3857.shp")

replace_sf = map %>% select(ISO_3166_3 = ISO3_CODE) %>% full_join(replace)
plot(st_geometry(replace_sf))

#Get center 
cen = replace_sf %>%
  st_transform(crs = 4326) %>%
  st_buffer(0) %>%
  filter(AU == "member") %>%
  st_union() %>%
  st_centroid(of_largest_polygon = T) %>%
  st_coordinates()

mapproj = st_orthoproj(replace_sf, cen[1], cen[2])
borderproj = st_orthoborder(cen[1], cen[2])
gridproj = st_orthogrid(30, cen[1], cen[2])

svg("test_AU.svg",width = 550/90,height = 550/90)
#Plotting
par(mar = c(0, 0, 0, 0))
#Wiki https://en.wikipedia.org/wiki/Wikipedia:WikiProject_Maps/Conventions/Orthographic_maps
#BG
library(rsvg)
 download.file("https://upload.wikimedia.org/wikipedia/commons/8/8d/Orthographic_gradient.svg",
               "Orthographic_gradient.svg"
               )
grad=as.raster(rsvg("Orthographic_gradient.svg"))
plot(borderproj, col = NA, border = NA)
posgrad=st_bbox(borderproj)
rasterImage(grad,
            posgrad[1],
            posgrad[2],
            posgrad[3],
            posgrad[4])


#All countries
plot(
  st_geometry(mapproj),
  col = "#B9B9B9",
  border = "#FFFFFF",
  lwd = 0.32,
  add = T
)
#Members
m = mapproj %>% filter(AU == "member")
plot(
  st_geometry(m),
  col = "#346733",
  border = "#FFFFFF",
  lwd = 0.32,
  add = T
)
#Related
ot = mapproj %>% filter(!is.na(AU) & AU != "member")
plot(
  st_geometry(ot),
  col = "#C6DEBD",
  border = "#FFFFFF",
  lwd = 0.32,
  add = T
)
#Grids
plot(gridproj,
     col = "gray77",
     lwd = 0.32,
     add = T)
#Border
plot(
  borderproj,
  border =  "#AAAAAA",
  col = NA,
  lwd = 1.6,
  add = T
)
dev.off()
