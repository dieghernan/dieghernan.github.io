# init----
rm(list = ls())
library(sf)
library(jsonlite)
library(dplyr)

origsharing <- function(data){
  geom = lapply(1:length(data[["areas"]][["coordinates"]]), function(x) {
    st_linestring(data[["areas"]][["coordinates"]][[x]][, 1:2]) %>% st_cast("POLYGON")
  }) %>% st_sfc()
  return(geom)
}

cleansharing <- function(data) {
  geom = lapply(1:length(data[["areas"]][["coordinates"]]), function(x) {
    st_linestring(data[["areas"]][["coordinates"]][[x]][, 1:2]) %>% st_cast("POLYGON")
  }) %>% st_sfc()
  
  df = st_sf(area = st_area(geom) / 1000, geom)
  df = df %>% arrange(desc(area))
  df$a = 1
  df = df[, 3]
  for (i in 1:nrow(df)) {
    if (i == 1) {
      keep = df[i, ]
    } else {
      if (st_contains(keep, df[i, ], sparse = FALSE)) {
        keep = st_difference(keep, df[i, ])
        keep = keep[, 1]
      } else {
        geom = st_combine(rbind(keep, df[i, ]))
        keep = st_sf(st_drop_geometry(keep), geom)
        keep = st_buffer(keep, 0)
        rm(geom)
      }
    }
  }
  return(keep)
}


#Coup----
download.file("https://storage.googleapis.com/providers/a/coup-madrid.json",
              destfile = "assets/shp/sharing/coup_madrid.json")

data=fromJSON("assets/shp/sharing/coup_madrid.json")
init="Coup"
data_init=origsharing(data)
data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")
df=data.frame(service="motosharing",provider="coup", city="madrid", stringsAsFactors = F)
coup=st_sf(df,geom=st_geometry(data_clean))

#Muving----
download.file("https://storage.googleapis.com/providers/a/muving-madrid.json",
              destfile = "assets/shp/sharing/muving_madrid.json")


data=fromJSON("assets/shp/sharing/muving_madrid.json")
init="Muving"
data_init=origsharing(data)
data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")

df=data.frame(service="motosharing",provider="muving", city="madrid", stringsAsFactors = F)
muving=st_sf(df,geom=st_geometry(data_clean))

#ecooltra----
download.file("https://storage.googleapis.com/providers/a/cooltra-madrid.json",
              destfile = "assets/shp/sharing/ecooltra_madrid.json")


data=fromJSON("assets/shp/sharing/ecooltra_madrid.json")
init="eCooltra"
data_init=origsharing(data)
plot(data_init,col=NA,border="black")
plot(data_init[[1]],add=T,col="green")
plot(data_init[[2]],add=T,col="green")
#plot(data_init[[3]],add=T,col="green")
plot(data_init[[4]],add=T,col="green")
p=st_coordinates(data_init[[4]]) %>% as.data.frame()
p[1:3,]


data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")

df=data.frame(service="motosharing",provider="ecooltra", city="madrid", stringsAsFactors = F)
ecooltra=st_sf(df,geom=st_geometry(data_clean))


#Movo----
download.file("https://storage.googleapis.com/providers/a/movo-madrid.json",
              destfile = "assets/shp/sharing/movo_madrid.json")
data=fromJSON("assets/shp/sharing/movo_madrid.json")
init="Movo"
data_init=origsharing(data)
data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")


df=data.frame(service="motosharing",provider="movo", city="madrid", stringsAsFactors = F)
movo=st_sf(df,geom=st_geometry(data_clean))

#acciona----
download.file("https://storage.googleapis.com/providers/a/acciona-madrid.json",
              destfile = "assets/shp/sharing/acciona_madrid.json")
data=fromJSON("assets/shp/sharing/acciona_madrid.json")
init="Acciona"
data_init=origsharing(data)
data_clean=cleansharing(data)
par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")

df=data.frame(service="motosharing",provider="acciona", city="madrid", stringsAsFactors = F)
acciona=st_sf(df,geom=st_geometry(data_clean))

#ioscoot----
download.file("https://storage.googleapis.com/providers/a/ioscoot-madrid.json",
              destfile = "assets/shp/sharing/ioscoot_madrid.json")
data=fromJSON("assets/shp/sharing/ioscoot_madrid.json")
init="ioscoot"
data_init=origsharing(data)
data_clean=cleansharing(data)

df=data.frame(service="motosharing",provider="ioscoot", city="madrid", stringsAsFactors = F)
ioscoot=st_sf(df,geom=st_geometry(data_clean))


par(mfrow=c(1,2),mar=c(1,1,1,1))
plot(data_init,main=paste(init,"-Init"),col="blue")
plot(st_geometry(data_clean),main=paste(init,"-fix"),col="blue")




#motosharing----

sharing=rbind(rbind(rbind(rbind(rbind(acciona,coup),ecooltra),movo),muving),ioscoot) %>% st_cast("MULTIPOLYGON")
st_crs(sharing)=4326
st_write(sharing,"assets/shp/sharing/sharing.gpkg",
         factorsAsCharacter = FALSE,
         layer_options = "OVERWRITE=YES")

rm(list = ls())

#Load----
a=st_read("assets/shp/sharing/sharing.gpkg")
plot(st_geometry(a),axes=T)


# Barrios Madrid------

rm(list = ls())
tempshp=paste(tempfile(),"zip",sep=".")
download.file(  "https://datos.madrid.es/egob/catalogo/200078-10-distritos-barrios.zip" ,  destfile =tempshp)
unzip(tempshp,exdir =tempdir(),junkpaths=T)
BarriosMad=st_read(paste(tempdir(),"BARRIOS.shp",sep="/"))
BarriosMad$area_km2=as.double(st_area(BarriosMad))/1000000


#http://www-2.munimadrid.es/CSE6/control/seleccionDatos?numSerie=03010102232

library(readxl)
POPMAD <- read_excel("assets/POPMAD_20190501.xls", 
                              sheet = "Import")

fin= POPMAD %>%
  select(CODBAR,
         NAMEPOB=...11,
         TOT_POP=TOT,
         WORKING_POP=age_20_69,
         NAC_POP=NAC_TOT,
         EXT_POP=EXT_TOT,
         PORC_EXT_POP=PORC_EXT)

BarriosMad=full_join(BarriosMad,fin) %>% arrange(CODBAR)
BarriosMad$DENS_WORKING_POP=BarriosMad$WORKING_POP/BarriosMad$area_km2
BarriosMad=st_transform(BarriosMad,4326)


INPERCAP <- read_excel("assets/URBAN AUDIT.xls", 
                     sheet = "IMPORT") %>% 
  subset(KEY=="BAR") %>% select(CODBAR,
                                NAMEINPERCAP=...1,
                                INCOME_PER_CAPITA)

BarriosMad=left_join(BarriosMad,INPERCAP) %>% arrange(CODBAR)

st_write(BarriosMad,"assets/shp/sharing/BarriosMad.gpkg",
         factorsAsCharacter = FALSE,
         layer_options = "OVERWRITE=YES")

plot(BarriosMad["INCOME_PER_CAPITA"],axes=T)

cd=st_read("assets/shp/sharing/BarriosMad.gpkg")
