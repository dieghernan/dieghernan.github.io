rm(list = ls())

library(rvest)
library(dplyr)
library(sf)
library(readxl)
library(curl)
library(raster)
library(png)

setwd("/cloud/project/wip")

# Work with provinces----
ISOESP = read_xlsx("../assets/custom/Cods_ISO_ESP.xlsx")


ESPPROV = st_read("https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/geojson/NUTS_RG_20M_2016_3857_LEVL_3.geojson",
                  stringsAsFactors = F) %>%
  filter(CNTR_CODE == "ES")

ESPPROV2 = left_join(ESPPROV, ISOESP, by = c("NUTS_ID" = "NUTS3"))
ESPROV_CLEAN = ESPPROV2 %>% group_by(ISO2, ISO2_CCAA, ISO3, ISO3_PROV) %>%
  summarise(do_union = T)
rm(ESPPROV,ESPPROV2)

#Get data----
Base <-
  read_html("https://www.datacentric.es/ranking-empresas-espana/") %>%
  html_nodes(xpath = '//*[@id="table-preview"]/table') %>%
  html_table() %>%   as.data.frame(
    stringsAsFactors = F,
    fix.empty.names = F
  )

namesProvs<-Base$Provincia
namesProvs[namesProvs=="Lleida"]<-"Lérida"
namesProvs[namesProvs=="Asturias"]<-"Principado de Asturias"
namesProvs[namesProvs=="Girona"]<-"Gerona"
namesProvs[namesProvs=="Coruña"]<-"A Coruña"
namesProvs[namesProvs=="Ourense"]<-"Orense"
namesProvs[namesProvs=="Islas Baleares"]<-"Baleares"
namesProvs[namesProvs=="Guipuzcoa"]<-"Guipúzcoa"

Base$ISO3_PROV=namesProvs
ESPROV_END=left_join(ESPROV_CLEAN,Base, by="ISO3_PROV")
ESPROV_END[is.na(ESPROV_END$Empresa),] %>% st_drop_geometry()
polys=st_geometry(ESPROV_END)
cntrd=st_centroid(polys)
explode = (polys - cntrd)  * .9 + cntrd  
ESPexplode=st_as_sf(x=st_drop_geometry(ESPROV_END),
                    geometry=explode,
                    crs = st_crs(ESPROV_END))




list=ls()
list=list[list != "ESPexplode"]
rm(list=list)

# Load function

source("../assets/functions/stdh_png2map.R")


# Download logos
Empresas=data.frame(Empresa=ESPexplode$Empresa, stringsAsFactors = F)




library(jpeg)
curl_download("http://www.granadamasbaloncesto.es/images/portfolio/pulevaG.jpg",
              "puleva.jpg")

writePNG(jpeg::readJPEG("puleva.jpg"),"puleva.png")
file.remove("puleva.jpg")
curl_download("http://www.grupoifa.com/logos/cashlepe.jpg",
              "cashlepe.jpg")

writePNG(jpeg::readJPEG("cashlepe.jpg"),"cashlepe.png")
file.remove("cashlepe.jpg")


logourl=c("https://upload.wikimedia.org/wikipedia/commons/a/a0/Logo_Cosentino.png",
          "https://upload.wikimedia.org/wikipedia/commons/8/8b/Acerinox.png",
          "https://calidalia.com/img/logosint/deoleo.png",
          "puleva.png",
          "cashlepe.png",
          "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Valeo_Logo.svg/800px-Valeo_Logo.svg.png",
          "http://www.ccociopia.com/wp-content/uploads/2017/04/logo-mayoral-tienda-ociopia-web.png")

# Set Spain
png("bc.png",
   height = 800,
    width = 800,
   pointsize =  72)
par(mar=c(0,0,0,0))
plot(st_geometry(ESPexplode[ESPexplode$ISO2 != "ES-CN", ]), col=NA)

for (i in 1:length(logourl)){
  emp=stdh_png2map(ESPexplode[i,],
                   as.character(logourl[i])
  )
  plotRGB(emp, add=T, bgalpha=0)
}
dev.off()


