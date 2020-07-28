#a----
setwd("~/R/dieghernan.github.io/myprojects/wikimaps")


rm(list = ls())
library(sf)
library(readxl)
library(dplyr)
library(cartography)
WORLD = st_read("~/R/mapslib/EUROSTAT/CNTR_RG_03M_2016_3857.geojson",
                stringsAsFactors = FALSE)

WORLD = st_transform(WORLD, 3035)
NUTS3 = st_read("~/R/mapslib/EUROSTAT/NUTS_RG_03M_2016_3857_LEVL_3.geojson",
                stringsAsFactors = FALSE)
NUTS3 = st_transform(NUTS3, 3035)
df = st_drop_geometry(NUTS3) %>% select(CNTR_ID = CNTR_CODE) %>% unique()
EU = inner_join(WORLD, df)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(EU))

# NUTS3.cent = st_centroid(NUTS3)
#3857CONTBBOX=c(-2800000,4100000,6500000,12000000)
#3035
CONTBBOX = c(2200000, 1380000, 7150000, 5500000)
class(CONTBBOX) <- "bbox"
st_bbox(CONTBBOX)
CONTBBOX = st_as_sfc(CONTBBOX, crs = st_crs(NUTS3))
CONTBBOX = st_sf(CONT = "1", CONTBBOX, crs = st_crs(NUTS3))


outerNUTS=c("ES703","ES704","ES705","ES706","ES707",
            "ES708","ES709","FRY10","FRY20","FRY30",
            "FRY40","FRY50","PT200","PT300")


# r2 = st_join(NUTS3.cent, CONTBBOX) %>% st_drop_geometry() %>% select(NUTS_ID, CONT)
# NUTS3.flag = left_join(NUTS3, r2)

NUTS3.outer=NUTS3[NUTS3$NUTS_ID %in% outerNUTS,]
NUTS3.outer = st_transform(NUTS3.outer, 3857)
NUTS3.inner=NUTS3[NUTS3$NUTS_ID %in% outerNUTS==FALSE,]

par(mar = c(0, 0, 0, 0))
plot(st_geometry(CONTBBOX))
plot(st_geometry(NUTS3.inner), add = T)

position <- function(x) {
  is.odd <- function(f)
    f %% 2 != 0
  if (is.odd(x)) {
    x1 = c(0.73, 0.85)
    y1 = c(0.85, 0.97) + (x - 1) / 2 * c(-0.12, -0.12)
  } else{
    x1 = c(0.85, 0.97)
    y1 = c(0.85, 0.97) + (x - 2) / 2 * c(-0.12, -0.12)
  }
  posfig = c(x1, y1)
  return(posfig)
}


#Mercator

#TRY----
dev.off()
marseq=c(0.05,0.05,0.15,0.05)
svg(
  "NUTS3.svg",
  pointsize = 90,
  width = 950 / 90,
  height = 830 / 90,
  bg = "#C6ECFF"
)
par(mar = c(0, 0, 0, 0), cex.main = 0.12)
plot(st_geometry(CONTBBOX), border = NA, col = "#C6ECFF")

plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  lwd = 0.1,
  bg = "#C6ECFF",
  add = T
)

plot(
  st_geometry(NUTS3.inner),
  lwd = 0.2,
  add = T,
  col = "#FEFEE9"
)
plot(st_geometry(EU), lwd = 0.25, add = T)

#Canarias
par(fig = position(1), mar = marseq, new = TRUE)
INSET=NUTS3.outer %>% filter(CNTR_CODE == "ES")
plot(st_geometry(INSET),col = "#FEFEE9",
     main="Canarias (ES)")
box(which = "figure", lwd=1.5)
box()

#Guadeloupe
par(fig = position(2), mar = marseq, new = TRUE)
INSET=NUTS3.outer %>% 
  filter(NUTS_ID == "FRY10")
plot(st_geometry(INSET),col = "#FEFEE9",
     main="Guadeloupe (FR)")
box(which = "figure", lwd=1.5)
box()



#Martinique
par(fig = position(3), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY20")),
     main = "Martinique (FR)",
     col = "#FEFEE9")
box(which = "figure", lwd=1.5)
box()
#Guyane
par(fig = position(4), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY30")),
     main = "Guyane (FR)",
     col = "#FEFEE9")
plot(
  st_geometry(WORLD %>% st_transform(st_crs(NUTS3.outer))),
  col = "#E0E0E0",
  lwd = 0.1,
  add = T
)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY30")),
     col = "#FEFEE9",
     add = T)
box(which = "figure", lwd=1.5)
box()
#LaRéunion
par(fig = position(5), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY40")),
     main = "Réunion (FR)",
     col = "#FEFEE9")
box(which = "figure", lwd=1.5)
box()
#Mayotte
par(fig = position(6), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY50")),
     main = "Mayotte (FR)",
     col = "#FEFEE9")
box(which = "figure", lwd=1.5)
box()
#Azores
par(fig = position(7), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "PT200")),
     main = "Açores (PT)",
     col = "#FEFEE9")
box(which = "figure", lwd=1.5)
box()
#Madeira
par(fig = position(8), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "PT300")),
     main = "Madeira (PT)",
     col = "#FEFEE9")
box(which = "figure", lwd=1.5)
box()
#Malta
par(fig = position(9), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.inner %>% filter(CNTR_CODE == "MT")),
     main = "Malta",
     col = "#FEFEE9")
box(which = "figure", lwd=1.5)
box()

#Liechtenstein
par(fig = position(10), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.inner %>% filter(CNTR_CODE == "LI")),
     main = "Liechtenstein",
     col = "#FEFEE9")
plot(
  st_geometry(NUTS3.inner),
  col = "#E0E0E0",
  lwd = 0.1,
  add = T
)
plot(st_geometry(NUTS3.inner %>% filter(CNTR_CODE == "LI")),
     col = "#FEFEE9",
     add=T)
box(which = "figure", lwd=1.5)
box()
dev.off()


#DENS----
Dens = read_xls("demo_r_d3dens.xls", sheet = "Hoja1") %>%
  select(NUTS_ID = GEO,
         DENS = LATEST)
NUTS3.inner = left_join(NUTS3.inner, Dens)
NUTS3.outer = left_join(NUTS3.outer, Dens)
summary(NUTS3.inner$DENS)
df = st_drop_geometry(NUTS3.inner)
br = c(0, 25, 50, 100, 200, 500, 1000, 2500, 5000, 10000, 30000)
#c(0,10,25,50,100,200,500,1000,30000)
library(viridis)
library(cartography)
par(mar = c(0, 0, 0, 0))
choroLayer(
  NUTS3.inner,
  var = "DENS",
  border = NA,
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
dev.off()

#Plotdens----
dev.off()
svg(
  "NUTS3Dens.svg",
  pointsize = 90,
  width = 950 / 90,
  height = 830 / 90,
  bg = "#C6ECFF"
)
par(mar = c(0, 0, 0, 0), cex.main = 0.12)
plot(st_geometry(CONTBBOX), border = NA, col = "#C6ECFF")
plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  lwd = 0.1,
  bg = "#C6ECFF",
  add = T
)
br = c(0, 25, 50, 100, 200, 500, 1000, 2500, 5000, 10000, 30000)
choroLayer(
  NUTS3.inner,
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
plot(st_geometry(EU), lwd = 0.25, add = T)
legendChoro(
  pos = "left",
  title.txt = "",
  title.cex = 0.5,
  values.cex = 0.15,
  breaks = c("", format(br, big.mark = ",")[-c(1, length(br))], ""),
  col = rev(inferno(length(br) - 1, 0.5)),
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)
#Canarias
par(fig = position(1), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(CNTR_CODE == "ES")),
     main = "Canarias (ES)",
     col = "#FEFEE9")
choroLayer(
  NUTS3.outer %>% filter(CNTR_CODE == "ES"),
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
box(which = "figure", lwd=1.5)
box()
#Guadeloupe
par(fig = position(2), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY10")),
     main = "Guadeloupe (FR)",
     col = "#FEFEE9")
choroLayer(
  NUTS3.outer %>% filter(NUTS_ID == "FRY10"),
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
box(which = "figure", lwd=1.5)
box()
#Martinique
par(fig = position(3), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY20")),
     main = "Martinique (FR)",
     col = "#FEFEE9")
choroLayer(
  NUTS3.outer %>% filter(NUTS_ID == "FRY20"),
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
box(which = "figure", lwd=1.5)
box()
#Guyane
par(fig = position(4), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY30")),
     main = "Guyane (FR)",
     col = "#FEFEE9")
plot(
  st_geometry(WORLD %>% st_transform(st_crs(NUTS3.outer))),
  col = "#E0E0E0",
  lwd = 0.05,
  add = T
)
choroLayer(
  NUTS3.outer %>% filter(NUTS_ID == "FRY30"),
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.1,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY30")), add = T)
box(which = "figure", lwd=1.5)
box()
#LaRéunion
par(fig = position(5), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY40")),
     main = "Réunion (FR)",
     col = "#FEFEE9")
choroLayer(
  NUTS3.outer %>% filter(NUTS_ID == "FRY40"),
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
box(which = "figure", lwd=1.5)
box()
#Mayotte
par(fig = position(6), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "FRY50")),
     main = "Mayotte (FR)",
     col = "#FEFEE9")
choroLayer(
  NUTS3.outer %>% filter(NUTS_ID == "FRY50"),
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
box(which = "figure", lwd=1.5)
box()
#Azores
par(fig = position(7), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "PT200")),
     main = "Açores (PT)",
     col = "#FEFEE9")
choroLayer(
  NUTS3.outer %>% filter(NUTS_ID == "PT200"),
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
box(which = "figure", lwd=1.5)
box()
#Madeira
par(fig = position(8), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.outer %>% filter(NUTS_ID == "PT300")),
     main = "Madeira (PT)",
     col = "#FEFEE9")
choroLayer(
  NUTS3.outer %>% filter(NUTS_ID == "PT300"),
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
box(which = "figure", lwd=1.5)
box()
#Malta
par(fig = position(9), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.inner %>% filter(CNTR_CODE == "MT")),
     main = "Malta",
     col = "#FEFEE9")
choroLayer(
  NUTS3.inner %>% filter(CNTR_CODE == "MT"),
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
box(which = "figure", lwd=1.5)
box()
#Malta
par(fig = position(10), mar = marseq, new = TRUE)
plot(st_geometry(NUTS3.inner %>% filter(CNTR_CODE == "LI")),
     main = "Liechtenstein",
     col = "#FEFEE9")
choroLayer(
  NUTS3.inner,
  var = "DENS",
  add = T,
  border = "#646464",
  #border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)
box(which = "figure", lwd=1.5)
box()
dev.off()

rsvg::rsvg_png("NUTS3.svg",
               "NUTS3.png")
rsvg::rsvg_png("NUTS3Dens.svg",
               "NUTS3Dens.png")
