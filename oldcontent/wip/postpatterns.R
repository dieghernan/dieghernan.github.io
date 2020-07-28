# 1. Set up----

rm(list = ls())

library(sf)
library(dplyr)
library(rnaturalearth)

DE=ne_countries(50,country = "Germany", returnclass = "sf") %>% st_transform(3036)

par(mar=c(0,0,0,0))
patternLayer(DE,pattern="zigzag")



par(mfrow=c(1,1))

# 2. Load shp-----
DE = st_read("~/R/mapslib/EUROSTAT/CNTR_RG_10M_2016_3035.geojson",
                stringsAsFactors = FALSE) %>% filter(id=="DE")

# 3. Case study----


# Point

grid=st_make_grid(DE,    
                  what = "corners",
                  square = F)

# To avoid dots close to the edge
negbuff=st_buffer(DE,dist = -15*1000)
grid2=grid[st_contains(negbuff,grid,sparse = F)]

par(mar=c(0,0,0,0))
plot(st_geometry(DE))
plot(st_geometry(grid2),add=T, col="red", pch=18)

# Grid

grid=st_make_grid(DE,    
                  what = "polygons",
                  square = T) %>% st_cast("LINESTRING") %>% st_intersection(DE) 

# Clean and keep lines only
grid2=grid[st_geometry_type(grid) %in% c("LINESTRING","MULTILINESTRING")]

par(mar=c(0,0,0,0))
plot(st_geometry(DE))
plot(st_geometry(grid2), col="red", lty=2, add=T)

# Horizontal
grid=st_make_grid(DE,    
                  what = "polygons",
                  square = T)
par(mar=c(0,0,0,0))
plot(grid)
plot(grid[55],add=T, col="blue")
plot(st_point(st_coordinates(grid[55])[1, 1:2]),col="red", add=T,pch=16)
plot(st_point(st_coordinates(grid[55])[2, 1:2]),col="orange", add=T, pch=16)
plot(st_point(st_coordinates(grid[55])[3, 1:2]),col="pink", add=T, pch=16)
plot(st_point(st_coordinates(grid[55])[4, 1:2]),col="black", add=T, pch=16)

# Select horizontal only
grid_int=lapply(1:length(grid), function(j)
  st_linestring(st_coordinates(grid[j])[c(1,4), 1:2])
  )%>%
  st_sfc(crs = st_crs(DE)) %>% st_intersection(DE)

# Clean and keep lines only
grid2=grid_int[st_geometry_type(grid_int) %in% c("LINESTRING","MULTILINESTRING")]
par(mar=c(0,0,0,0))
plot(st_geometry(DE))
plot(st_geometry(grid2), col="red", lty=2, add=T)

# The function----


source("patternfun.R")

par(mfrow=c(2,5), mar=c(1,1,1,1), cex=0.5)
patternLayer(DE,"dot")
title("dot")
patternLayer(DE,"text",txt="Y")
title("text")
patternLayer(DE,"diamond",density = 0.5)
title("diamond")
patternLayer(DE,"grid", lwd=1.5)
title("grid")
patternLayer(DE,"hexagon",col="blue")
title("hexagon")
patternLayer(DE,"horizontal",lty=5)
title("horizontal")
patternLayer(DE,"vertical")
title("vertical")
patternLayer(DE,"left2right")
title("left2right")
patternLayer(DE,"right2left")
title("right2left")
patternLayer(DE,"zigzag")
title("zigzag")
par(mar=c(0,0,0,0), mfrow=c(1,1))
patternLayer(DE,cellsize=20*1000,pattern = "zigzag")
# Playing options
par(mar=c(1,1,1,1), mfrow=c(2,3))
patternLayer(DE,"dot", pch=10, density = 0.5, cex=2, col="darkblue")

patternLayer(DE,"dot", pch=21, col="red", bg="green", cex=1.25)

plot(st_geometry(DE),col="grey")
patternLayer(DE,"text",txt="DE",density = 1.1, col="white", add=T)

patternLayer(DE,"horizontal", lty=3)
patternLayer(DE,"zigzag", lwd=2, col="red")
patternLayer(DE,"left2right", density = 2, col="orange")

# Showing----
#1. Shapefiles-----
NUTS1 = st_read("~/R/mapslib/EUROSTAT/NUTS_RG_10M_2016_3035_LEVL_1.geojson",
                stringsAsFactors = FALSE)
outerNUTS=c("ES7","FRY","PT2","PT3")
FRGNUTS=c("DE4","DE8","DEE","DED","DEG")

EU_NUTS=NUTS1 %>% filter(!NUTS_ID %in% c(outerNUTS,
                                         FRGNUTS)) %>% group_by(CNTR_CODE) %>% summarise(do_union=T)

FRG=NUTS1 %>% filter(NUTS_ID %in% FRGNUTS) %>% group_by(CNTR_CODE) %>% summarise(do_union=T)

WORLD = st_read("~/R/mapslib/EUROSTAT/CNTR_RG_10M_2016_3035.geojson",
                stringsAsFactors = FALSE) 

USSRISO3=c("ARM","AZE",
           "BLR","EST",
           "GEO","KAZ",
           "KIR","LVA",
           "LTU","MDA",
           "RUS","TJK",
           "TKM","UKR",
           "UZB"
)
WarsawPact=c(USSRISO3,
             "POL","BGR",
             "CZE","SVK",
             "HUN", "ROU",
             "UKR", "LVA", 
             "EST","LTU", 
             "BLR", "MOL","ARM")



#EU membership
orgsdb <- read.csv("https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/CountrycodesOrgs.csv")  %>% filter(org_id == "EU")


CCodes = read.csv(
  "https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodes.csv",
  na.strings = "",
  encoding = "UTF-8",
  stringsAsFactors = F
) 

EU_NUTS=left_join(EU_NUTS,CCodes, by=c("CNTR_CODE"="NUTS")) %>% left_join(orgsdb %>% select(
  ISO_3166_3,org_name ,org_member))

x <- data.frame("CNTR_CODE"=c("BE",	"FR",	"DE",	"IT",	"LU",	"NL",	"DK",	"IE",	"UK",	"EL",	"PT",	"ES",	"AT",	"FI",	"SE",	"CY",	"CZ",	"EE",	"HU",	"LV",	"LT",	"MT",	"PL",	"SK",	"SI",	"BG",	"RO",	"HR"
), year=c(1957,	1957,	1957,	1957,	1957,	1957,	1973,	1973,	1973,	1981,	1986,	1986,	1995,	1995,	1995,	2004,	2004,	2004,	2004,	2004,	2004,	2004,	2004,	2004,	2004,	2007,	2007,	2013))

EU_NUTS=left_join(EU_NUTS,x)

EU_NUTS$yearcat=ifelse(is.na(EU_NUTS$year),NA,
                       paste(as.integer(EU_NUTS$year/10),"0s",sep=""))

EU_NUTS$yearcat=ifelse(EU_NUTS$org_member== "candidate country","candidate",
                       EU_NUTS$yearcat)

EU_NUTS=EU_NUTS %>% arrange((yearcat))

#ADD FRG
FRG2=st_sf(EU_NUTS %>% filter(CNTR_CODE=="DE"),
          geometry=st_geometry(FRG))
FRG2$yearcat="1990s"
EU_NUTS=rbind(EU_NUTS,FRG2) %>% unique()

labs=unique(EU_NUTS$yearcat)
labs=labs[!is.na(labs)]


#Combine typo and pattern----

svg("check.svg",
  
  width = 950 / 90,
      height = 830 / 90,)



par(mar=c(0,0,0,0), mfrow=c(1,1))
plot(st_geometry(EU_NUTS),col=NA,border=NA)
plot(st_geometry(WORLD),add=T)
IRCUT=WORLD %>% filter(ISO3_CODE %in% WarsawPact) %>% select(ISO3_CODE)
IRCUT=rbind(IRCUT,FRG %>% select(
  ISO3_CODE=CNTR_CODE))
patternLayer(IRCUT,"vertical",col="red",add=T, density = 2)
legendPattern(
  pos="right",
  frame = T,
  pattern.categ = c("a","b","c","e","f"),
  pattern.type = c("dot","text","left2right","diamond","zigzag"),
  pattern.col = "blue",
  pattern.bg = "red",
  pattern.txt = "s",
  title.txt = "",
  values.cex = 1,
  title.cex = 0.1
)

dev.off()


#end----

EU_NUTS=left_join(EU_NUTS)



# 2. Input data-----
CCodes = read.csv(
  "https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodes.csv",
  na.strings = "",
  encoding = "UTF-8",
  stringsAsFactors = F
)
orgsdb <- read.csv("https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/CountrycodesOrgs.csv") 


outerNUTS=c("ES7","FRY","PT2","PT3")
NUTS1 = st_read("~/R/mapslib/EUROSTAT/NUTS_RG_10M_2016_3035_LEVL_1.geojson",
                stringsAsFactors = FALSE)

WORLD = st_read("~/R/mapslib/EUROSTAT/CNTR_RG_10M_2016_3035.geojson",
                stringsAsFactors = FALSE)
par(mar=c(0,0,0,0))
EU_NUTS1 = NUTS1 %>% filter(!NUTS_ID %in% outerNUTS) %>% group_by(CNTR_CODE) %>% summarise(do_union = T)


FRG=c("DE4","DE8","DEE","DED","DEG")

FRG.sf=NUTS1 %>% filter(NUTS_ID %in% FRG)
plot(st_geometry(FRG.sf))

a=NUTS1 %>% filter(CNTR_CODE=="DE")
plot(st_geometry(EU_NUTS1))
st_bbox(EU_NUTS1)

par(mar=c(0,0,0,0))
plot(st_geometry(WORLD),
     xlim=c(2636838,7315863),
     ylim=c(1385758,5412200))
EU_NUTS3=left_join(EU_NUTS3, CCodes, by=c("CNTR_CODE"="NUTS"))

par(mar=c(0,0,0,0))
plot(st_geometry(EU_NUTS3))
USSR=c("ARM","AZE",
       "BLR","EST",
       "GEO","KAZ",
       "KIR","LVA",
       "LTU","MDA",
       "RUS","TJK",
       "TKM","UKR",
       "UZB"
       )


Warsaw=WORLD %>% filter(ISO3_CODE %in%
                             c(USSR,
                               "POL","BGR",
                               "CZE","SVK",
                               "HUN", "ROU",
                               "UKR", "LVA", 
                               "EST","LTU", 
                               "BLR", "MOL","ARM"))


par(mar=c(0,0,0,0))
plot(st_geometry(EU_NUTS3))
plot(st_geometry(Warsaw),add=T,col="red", border=NA)

orgsdb <- read.csv("https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/CountrycodesOrgs.csv") %>%
  distinct(org_id, org_name)


# 3. Help functions-----
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

# Data cleansing----
library(jsonlite)
a=download.file()
df <- fromJSON("https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodesfull.json")

df_org <- ISO_memcol(orgsdb,"C")


EU_NUTS3=left_join(EU_NUTS3,CCodes, by=c("CNTR_CODE"="NUTS") )

par(mar=c(0,0,0,0))
plot(st_geometry(EU_NUTS3))


