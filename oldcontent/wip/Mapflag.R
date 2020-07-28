# 0. Init----
rm(list = ls())
library(png)
library(raster)
library(sf)
library(dplyr)
library(rnaturalearth)

# 1. Get Map----
SPAIN = getData(
  "GADM",
  download = TRUE,
  country = "Spain",
  level = 1,
  path = tempdir()
) %>%
  st_as_sf()

# Move Canary Islands
CAN = SPAIN %>% subset(GID_1 == "ESP.14_1")
CANNEW = st_sf(st_drop_geometry(CAN),
               geometry = st_geometry(CAN) + c(2, 8))
st_crs(CANNEW) <- st_crs(SPAIN)
SPAINV2 = rbind(SPAIN %>% subset(GID_1 != "ESP.14_1"),
                CANNEW) %>% st_transform(4258) # ETRS89 - Spanish Official
rm(CAN, CANNEW, SPAIN)



#Just for completing the map

NEIGH = ne_countries(50,returnclass = "sf") %>% select(1) %>% st_transform(st_crs(SPAINV2))

# Plot

plot(
  st_geometry(SPAINV2),
  col = NA,
  border = NA,
  bg = "#C6ECFF"
)
plot(st_geometry(NEIGH), col = "#E0E0E0",bg = "#C6ECFF", add = T)
plot(st_geometry(SPAINV2), col = "#FEFEE9", add = T,lwd=2)


# 2. Flags----
flags_wiki <- function(url, name) {
  require(curl)
  require(png)
  dest = paste("assets/flags/Flag_", name, ".svg.png", sep = "")
  curl_download(url, dest)
  #Adjust channels and extent 
  test = brick(readPNG(dest) * 255)
  extent(test) = extent(brick(dest))
  plotRGB(test)
}
dev.off()
par(mfrow = c(3, 6), mar = c(0, 0, 0, 0))
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Flag_of_Andaluc%C3%ADa.svg/800px-Flag_of_Andaluc%C3%ADa.svg.png",
  "ES.AN"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Flag_of_Aragon.svg/800px-Flag_of_Aragon.svg.png",
  "ES.AR"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Flag_of_Cantabria.svg/800px-Flag_of_Cantabria.svg.png",
  "ES.CB"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Flag_of_Castile-La_Mancha.svg/800px-Flag_of_Castile-La_Mancha.svg.png",
  "ES.CM"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Flag_of_Castile_and_Le%C3%B3n.svg/800px-Flag_of_Castile_and_Le%C3%B3n.svg.png",
  "ES.CL"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Flag_of_Catalonia.svg/800px-Flag_of_Catalonia.svg.png",
  "ES.CT"
)
# Select only Ceuta since the shape is combined. Could be splitted but I just did this for clarity
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Flag_Ceuta.svg/800px-Flag_Ceuta.svg.png",
  "ES.ML"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Flag_of_the_Community_of_Madrid.svg/800px-Flag_of_the_Community_of_Madrid.svg.png",
  "ES.MD"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Bandera_de_Navarra.svg/800px-Bandera_de_Navarra.svg.png",
  "ES.NA"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Flag_of_the_Land_of_Valencia_%28official%29.svg/800px-Flag_of_the_Land_of_Valencia_%28official%29.svg.png",
  "ES.VC"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Flag_of_Extremadura_%28with_coat_of_arms%29.svg/800px-Flag_of_Extremadura_%28with_coat_of_arms%29.svg.png",
  "ES.EX"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Flag_of_Galicia.svg/800px-Flag_of_Galicia.svg.png",
  "ES.GA"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Flag_of_the_Balearic_Islands.svg/800px-Flag_of_the_Balearic_Islands.svg.png",
  "ES.PM"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Flag_of_La_Rioja_%28with_coat_of_arms%29.svg/800px-Flag_of_La_Rioja_%28with_coat_of_arms%29.svg.png",
  "ES.LO"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Flag_of_the_Basque_Country.svg/800px-Flag_of_the_Basque_Country.svg.png",
  "ES.PV"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Flag_of_Asturias.svg/800px-Flag_of_Asturias.svg.png",
  "ES.AS"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Flag_of_the_Region_of_Murcia.svg/800px-Flag_of_the_Region_of_Murcia.svg.png",
  "ES.MU"
)
flags_wiki(
  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Flag_of_the_Canary_Islands.svg/800px-Flag_of_the_Canary_Islands.svg.png",
  "ES.CN"
)



#3. raster and plot----
dev.off()
par(mar = c(0, 0, 0, 0))
# Fix plot
plot(
  st_geometry(SPAINV2),
  col = NA,
  border = NA,
  bg = "#C6ECFF"
)
plot(st_geometry(NEIGH), col = "#E0E0E0", add = T)
plot(st_geometry(SPAINV2), col = "green", add = T)


# iter---
for (i in 1:nrow(SPAINV2)) {
  
  shp = SPAINV2[i, ]
  CCAA = shp$HASC_1
  print(paste("Iter ",i,CCAA,sep=" "))
  flagpath = paste("assets/flags/Flag_", CCAA, ".svg.png", sep = "")
  
  #Load as raster
  flag = brick(readPNG(flagpath) * 255)
  extent(flag) = extent(brick(flagpath))
  
  # Geotagging
  projection(flag) <- CRS(st_crs(shp)[["proj4string"]])
  # Adjust the new extent in way that the shape is centered and completely covered
  # Keeping the flag aspect ratio
  ratioflag = extent(flag)@xmax / extent(flag)@ymax
  
  #MIddle point
  extshp=extent(shp)
  w=(extshp@xmax-extshp@xmin)/2
  h=(extshp@ymax-extshp@ymin)/2
  w_mp=extshp@xmin+w
  h_mp=extshp@ymin+h
  
  if(w>h*ratioflag){
    new_ext=c(extshp@xmin,extshp@xmax,h_mp-w/ratioflag,h_mp+w/ratioflag)
  } else {
    new_ext=c(w_mp-h*ratioflag,w_mp+h*ratioflag,extshp@ymin,extshp@ymax)
  }
  
  extent(flag) <- new_ext
  #Done - masking
  fig = mask(flag, shp)
  
  
  plotRGB(fig, bgalpha = 0, add = T)
}



plot(st_geometry(SPAINV2),border="black",lwd=2,axes=T,add=T)

# For blog----
rm(list = ls())
library(jsonlite)

df = fromJSON("https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodesfull.json")
ISO_memcol = function(df,
                      orgtosearch 
) {
  ind = match(orgtosearch, unlist(df[1, "org_id"]))
  or = lapply(1:nrow(df), function(x)
    unlist(df[x, "org_member"])[ind])
  or = data.frame(matrix(unlist(or)), stringsAsFactors = F)
  names(or) = orgtosearch
  df2 = as.data.frame(cbind(df, or, stringsAsFactors = F))
  return(df2)
}
df_org = ISO_memcol(df, "EU") %>% select(
  ISO_3166_3,
  EU) %>% subset(EU=="member")

all=ne_download(50,type="map_subunits",returnclass = "sf")%>%
  select(ADM0_A3, CONTINENT) %>% 
  left_join(df_org,by=c("ADM0_A3"="ISO_3166_3")) %>%
  st_transform(25830)

eu=all %>% subset(!is.na(EU)) %>%
  subset(CONTINENT =="Europe" | ADM0_A3=="CYP") %>%
  mutate(EU="EU") %>% group_by(EU) %>% summarise(drop=n()) %>%
  select(EU)

# Flag
require(curl)
require(png)
url="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Flag_of_Europe.svg/800px-Flag_of_Europe.svg.png"
dest = "assets/flags/Flag_EU.svg.png"
curl_download(url, dest)
#Load as raster
flag = brick(readPNG(dest) * 255)
extent(flag) = extent(brick(dest))
shp=eu
# Geotagging
projection(flag) <- CRS(st_crs(shp)[["proj4string"]])
# Adjust the new extent in way that the shape is centered and completely covered
# Keeping the flag aspect ratio
ratioflag = extent(flag)@xmax / extent(flag)@ymax

#MIddle point
extshp=extent(shp)
w=(extshp@xmax-extshp@xmin)/2
h=(extshp@ymax-extshp@ymin)/2
w_mp=extshp@xmin+w
h_mp=extshp@ymin+h

if(w>h*ratioflag){
  new_ext=c(extshp@xmin,extshp@xmax,h_mp-w/ratioflag,h_mp+w/ratioflag)
} else {
  new_ext=c(w_mp-h*ratioflag,w_mp+h*ratioflag,extshp@ymin,extshp@ymax)
}

extent(flag) <- new_ext
#Done - masking
fig = mask(flag, shp)
par(mar=c(0,0,0,0))
plot(st_geometry(eu),col=NA,border=NA,bg = "#C6ECFF")
plot( ne_countries(50,returnclass = "sf") %>%
        st_transform(st_crs(eu)) %>%
        st_geometry(),
      col = "#E0E0E0",
      border="white",
      lwd=1.5,
     add=T
     
     
     )
plotRGB(fig,add=T,bg=0)

#WIP----
#WIP
stdh_pngbackground<-function(sho)

