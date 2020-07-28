# 0. Init----
rm(list = ls())
library(sf)
library(jsonlite)
library(dplyr)
library(readxl)

# 1. Download shapefile----

# source:Portal de Datos Abiertos de Madrid https://datos.madrid.es
tempfile(fileext = ".zip")
tempfile(fileext = ".zip")
tempdir()
filetemp = paste(tempdir(), "temp.zip", sep = "/")
tempdir()

download.file(
  "https://datos.madrid.es/egob/catalogo/200078-10-distritos-barrios.zip",
  filetemp
)
unzip(filetemp, exdir = tempdir(), junkpaths = T)
BarriosMad = st_read(paste(tempdir(), "BARRIOS.shp", sep = "/"),
                     stringsAsFactors = FALSE)
BarriosMad = st_transform(BarriosMad, 4326)

library(raster)
library(rosm)
library(sp)

BMad_sp=BarriosMad %>% st_transform(4326) %>% as_Spatial()
ns=sp::bbox(BMad_sp)
osm.types()
x <- osm.raster(ns, type="cartolight", cachedir=tempdir(),crop=TRUE,zoom=1,forcedownload = TRUE)
par(mar=c(0,0,0,0))
plotRGB(x)


BarriosMad$area_km2 = as.double(st_area(BarriosMad)) / (1000 ^ 2)

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

# 2. Population 2019/05----
#http://www-2.munimadrid.es/TSE6/control/seleccionDatosBarrio
POPMAD <-
  read_excel("myprojects/sharing_madrid/assets/POPMAD_20190501.xls",
             sheet = "Import")

# 3. Income per capita----
# Urban Audit 2015
# Source: https://www.madrid.es/portales/munimadrid/es/Inicio/El-Ayuntamiento/Estadistica/Areas-de-informacion-estadistica/Economia/Renta/?vgnextfmt=default&vgnextchannel=ef863636b44b4210VgnVCM2000000c205a0aRCRD&vgnextoid=ef863636b44b4210VgnVCM2000000c205a0aRCRD

INCOME <-
  read_excel("myprojects/sharing_madrid/assets/URBAN AUDIT.xls",
             sheet = "Import")
# Adding data----
BarriosMad = left_join(BarriosMad,
                       POPMAD %>%
                         select(CODBAR,
                                POB_20_69,
                                POP_TOT,
                                POB_NAC,
                                POB_EXT,
                                PORC_EXT))

BarriosMad = left_join(BarriosMad,
                       INCOME %>%
                         select(CODBAR,
                                INCOME_PER_CAPITA))

# 4. Crime 2018 ----

for (i in 1:12) {
  d = as.Date(paste("2018", i, "1", sep = "-"))
  url = paste(
    "https://datos.madrid.es/egob/catalogo/212616",
    48 + i,
    "policia-estadisticas.xlsx",
    sep = "-"
  )
  destfile <- paste(tempdir(), "police.xlsx", sep = "/")
  download.file(url,
                destfile)
  est <- read_excel(destfile,
                    skip = 1)
  est$refdate=d
  if (i==1){
    police=est
  } 
  else {
    police=rbind(police,est)
  }
  rm(d,est)
}
rm(i,destfile,filetemp,url)
names(police)
polmad= police %>% 
  group_by(DISTRITOS) %>%
  summarise(PERS_CRIME=sum(`RELACIONADAS CON LAS PERSONAS`),
            PROPERTY=sum(`RELACIONADAS CON EL PATRIMONIO`),
            WEAPON=sum(`POR TENENCIA DE ARMAS`)
            )


allcrimes=rowSums(polmad[,2:ncol(polmad)])
polmad=cbind(polmad,allcrimes)



tojoin= BarriosMad %>% st_drop_geometry() %>% 
  select(DISTRITOS=NOMDIS,
         CODDIS,POP_TOT) %>% 
  group_by(CODDIS,DISTRITOS) %>%
  summarise(DIST_POP=sum(POP_TOT)) 


tojoin$DISTRITOS=toupper(tojoin$DISTRITOS)

polmad=left_join(polmad,
                    tojoin)
polmad$DIST_CRIMES_PER_1000=1000*polmad$allcrimes/polmad$DIST_POP

BarriosMad = left_join(BarriosMad,
                       polmad %>% select(
                         CODDIS,
                         DIST_CRIMES_PER_1000
                         )
                       ) %>% arrange(desc(CODBAR))


# Merge and keep----

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

#5. Land use----
# 2017
# https://datos.madrid.es/egob/catalogo/211328-10-valores-catastrales-barrio.xls

url="https://datos.madrid.es/egob/catalogo/211328-10-valores-catastrales-barrio.xls"
destfile <- paste(tempdir(), "land.xls", sep = "/")
download.file(url,
              destfile)
land <- read_excel(destfile)

valueHouses= land %>% 
  subset(uso_cod=="V") %>%
  select(
    CODBAR=barrio_cod,
    HOUSE_AVE_VAL=val_cat_medio)

BarriosMad = left_join(BarriosMad,valueHouses)

off_building_area= land %>% 
  subset(uso_cod=="O") %>%
  select(
    CODBAR=barrio_cod,
    OFFICES_AREA=sup_cons_barrio)


BarriosMad = left_join(BarriosMad,off_building_area)

# Merge and keep----

st_write(
  BarriosMad,
  "myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

rm(list = ls())

# Test----

test=st_read("myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg")

names(test)
ncol(test)
plot(test[,10:19])
