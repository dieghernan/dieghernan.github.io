#setwd("~/R/dieghernan.github.io/myprojects/wikimaps")

# Libraries----

rm(list = ls())
library(rmapshaper)
library(readxl)
library(openxlsx)
library(sf)
library(dplyr)
library(cartography)
library(scales)
library(viridis)
library(RColorBrewer)

# Municipios----
PENIN = st_read(
  "~/R/mapslib/CNIG/LineasLimite/recintos_municipales_inspire_peninbal_etrs89.shp",
  stringsAsFactors = F
)
CAN = st_read(
  "~/R/mapslib/CNIG/LineasLimite/recintos_municipales_inspire_canarias_wgs84.shp",
  stringsAsFactors = F
) %>%
  st_transform(3857)

CAN = st_sf(
  st_drop_geometry(CAN),
  geometry = st_geometry(CAN) + c(550000, 920000),
  crs = st_crs(CAN)
)

MUNIC = rbind(st_transform(PENIN, 3857),
              st_transform(CAN, 3857))

MUNIC$CODIGOINE = substr(MUNIC$INSPIREID,
                         nchar(MUNIC$INSPIREID) - 4,
                         nchar(MUNIC$INSPIREID))

MUNIC = MUNIC %>% select(CODNUT1,
                         CODNUT2,
                         CODNUT3,
                         CODIGOINE,
                         MUNICIPIO = NAMEUNIT) %>% arrange(CODIGOINE)


# Import maps----
WORLD = st_read("~/R/mapslib/EUROSTAT/CNTR_RG_01M_2016_3857.geojson",
                stringsAsFactors = FALSE)

# # NOT RUN Mix data----
# Pad18 = read_xlsx("pobmun18.xlsx")
# Pad18$CODIGOINE = substr(paste(Pad18$CPRO, Pad18$CMUN, sep = "") , 1, 5)
# 
# LAU_NUTS <- read_excel("LAU-NUTS.xlsx", sheet = "ES")
# LAU_NUTS = LAU_NUTS %>%
#   select(
#     NAME_NUTS=`LAU NAME NATIONAL`,
#     NUTS3=`NUTS 3 CODE`,
#     AreaKM2=`TOTAL AREA (m2)`,
#     DEGURBA,
#     CODIGOINE=`LAU CODE`,
#     CITY_ID,
#     GREATER_CITY_ID,
#     GREATER_CITY_NAME,
#     FUA_ID,
#     FUA_NAME
#   )
# LAU_NUTS$AreaKM2=LAU_NUTS$AreaKM2/1000000
# MunicData=full_join(Pad18,LAU_NUTS)
# 
# # Area
# MUNdf=st_drop_geometry(MUNIC)
# MunicData = full_join(MUNdf,
#                       MunicData)
# 
# 
# MunicData$NOMBRE = ifelse(is.na(MunicData$NOMBRE),
#                            MunicData$MUNICIPIO,
#                            MunicData$NOMBRE)
# MunicData$DensKM2 = MunicData$POB18 / MunicData$AreaKM2
# 
# AU_MFom <- read_xlsx("AU_MFom18.xlsx")
# AU_MFom$CODIGOINE = AU_MFom$CODE
# 
# MunicData = left_join(MunicData %>% select(-HOMBRES,-MUJERES),
#                       AU_MFom %>% select(CODIGOINE,
#                                          AREA_URBANA)
#                       ,
#                       by = "CODIGOINE")
# 
# 
# # Urban Audit--
# UAOV20 <- read_xlsx("URBAN_AUDIT.xlsx")
# UACITY <- read_xlsx("URBAN_AUDIT_CITY.xlsx")
# 
# 
# MunicData = left_join(MunicData,
#                       UAOV20,
#                       by = "CODIGOINE")
# MunicData = left_join(MunicData,
#                       UACITY,
#                       by = "CODIGOINE")
# 
# # Experimental Statistics
# Renta <- read_xlsx("30824.xlsx", sheet = "export")
# Renta$Renta_Persona_2016 = as.double(Renta$Renta_Persona_2016)
# Renta$Renta_Hogar_2016 = as.double(Renta$Renta_Hogar_2016)
# Renta$CODIGOINE = Renta$COD
# MunicData = left_join(MunicData,
#                       Renta %>% select(-NAME),
#                       by = "CODIGOINE")
# 
# CODS_ISO = read_xlsx("~/R/mapslib/CUSTOM/Cods_ISO_ESP.xlsx")
# 
# MunicData = left_join(MunicData,
#                       CODS_ISO,
#                       by = c("CODNUT3" = "NUTS3"))
# 
# 
# 
# MunicData_export = MunicData %>% select(
#   NUTS0,
#   NUTS1,
#   NUTS2,
#   ISO1_2,
#   ISO1_3,
#   ISO2,
#   ISO3,
#   CCAA = ISO2_CCAA,
#   PROVINCIA = ISO3_PROV,
#   CPRO,
#   CMUN,
#   CODIGOINE,
#   MUNICIPIO = NOMBRE,
#   POP_2018 = POB18,
#   AREAKM2 = AreaKM2,
#   DENSKM2 = DensKM2,
#   UA_INCOME_HOUSEHOLDS_2016 = Income_Households_2016,
#   UA_INCOME_CONSUNIT_2016 = Income_ConsUnit_2016,
#   UA_PER_CAPITA_INCOME_2016 = Per_capita_income_2016,
#   UA_POPUNDER14_PERC_2018 = PopUnder14_Perc_2018 ,
#   UA_POPOVER65_PERC_2018 = PopOver65_Perc_2018 ,
#   UA_POP_HIGHERISCED_56_PERC_2011 = Population_higherISCED_56_Perc_2011,
#   UA_FOREIGNERS_PERC_2018 = Foreigners_Perc_2018 ,
#   UA_UNEMPRATE_2018 = UnemploymentRate_2018,
#   UA_AVAILBEDS_TOURISM_2017 = AvailableBeds_Tourism_2017,
#   SS_INCOMEPERCAP_2016 = Renta_Persona_2016,
#   SS_INCOMEPERHOUSEH_2016 = Renta_Hogar_2016,
#   AREA_URBANA,
#   DEGURBA,
#   CITY_ID,
#   GREATER_CITY_ID,
#   GREATER_CITY_NAME,
#   FUA_ID,
#   FUA_NAME
# ) %>% arrange(CODIGOINE)
# 
# 
# write.xlsx(MunicData_export,
#             "SpainMunic.xlsx")
# rm(
#   AU_MFom,
#   CAN,
#   CODS_ISO,
#   MunicData,
#   MunicData_export,
#   Pad18,
#   PENIN,
#   Renta,
#   UACITY,
#   UAOV20,
#   LAU_NUTS,
#   MUNdf
# )
# 

# Import and merge-----
df = read_xlsx("SpainMunic.xlsx")


MAPMUNIC = left_join(MUNIC %>% select(CODIGOINE),
                     df ,
                     by = "CODIGOINE") %>% arrange(CODIGOINE)

st_write(
  MAPMUNIC,
  "MAPMUNIC.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

# Simplify
MunicSimpl = ms_simplify(MAPMUNIC, keep_shapes = T, keep = 0.10)

ProvSimp = MunicSimpl %>%
  group_by(ISO3, PROVINCIA) %>%
  summarise(a = 1)

CCAASimp = MunicSimpl %>%
  group_by(ISO2, CCAA) %>%
  summarise(a = 1)

# Plot----
br = c(0, 10, 25, 50, 100, 200, 500, 1000, 5000, 10000, 30000)

#pdi=90
pdi = 90

svg(
  "Population per km2 by municipality in Spain (2018).svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1000 / pdi,
  bg = "#C6ECFF"
)


par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = "#E0E0E0",
     border = NA,
     bg = "#C6ECFF")

plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  bg = "#C6ECFF",
  add = T,
  lwd = 0.05
)

choroLayer(
  MunicSimpl,
  add = T,
  var = "DENSKM2",
  border = "#646464",
  # border=NA,
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)

legendChoro(
  pos = "left",
  title.txt = " ",
  title.cex = 0.5,
  values.cex = 0.25,
  breaks = c(" ", format(br, big.mark = ",")[-c(1, length(br))], " "),
  col = rev(inferno(length(br) - 1, 0.5)),
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

plot(
  st_geometry(ProvSimp),
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)
plot(
  st_geometry(CCAASimp),
  lwd = 0.25,
  border = "black",
  add = T
)

dev.off()


# Plot pop----

br = c(0,
       200,
       500,
       1000,
       5000,
       10000,
       20000,
       50000,
       100000,
       500000,
       1000000,
       5000000) %>% as.integer()

#pdi=90
pdi = 90

svg(
  "Population by municipality in Spain (2018).svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1200 / pdi,
  bg = "#C6ECFF"
)

par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = "#E0E0E0",
     border = NA,
     bg = "#C6ECFF")

plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  bg = "#C6ECFF",
  add = T,
  lwd = 0.05
)

choroLayer(
  MunicSimpl,
  add = T,
  var = "POP_2018",
  border = "#646464",
  breaks = br,
  col = rev(inferno(length(br) - 1, 0.5)),
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)


legendChoro(
  pos = "left",
  title.txt = " ",
  title.cex = 0.5,
  values.cex = 0.25,
  breaks = c(" ", format(br, big.mark = ",")[-c(1, length(br))], " "),
  col = rev(inferno(length(br) - 1, 0.5)),
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

plot(
  st_geometry(ProvSimp),
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)
plot(
  st_geometry(CCAASimp),
  lwd = 0.25,
  border = "black",
  add = T
)

dev.off()


# Plot AU----

# wikicolors = c("#e41a1c",
#                "#4daf4a",
#                "#984ea3",
#                "#ff7f00",
#                "#377eb8",
#                "#ffff33")


library(RColorBrewer)

pdi = 90

svg(
  "Large Urban Areas in Spain by population (2018).svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1000 / pdi,
  bg = "#C6ECFF"
)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = NA,
     border = NA,
     bg = "#C6ECFF")
plot(st_geometry(WORLD),
     col = "#E0E0E0",
     bg = "#C6ECFF",
     add = T)

plot(
  st_geometry(ProvSimp),
  col = "#FEFEE9",
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)

br = c(0, 50000, 100000, 600000, 10000000) %>% as.integer()

AU = MunicSimpl %>% filter(!is.na(AREA_URBANA)) %>%
  group_by(AREA_URBANA) %>% summarise(POP_2018 = sum(POP_2018)) %>% arrange(desc(POP_2018))

AU$categs = cut(AU$POP_2018, unique(br))
colAU = magma(6)[2:5]

typoLayer(
  AU,
  var = "categs",
  border = NA,
  col =  colAU,
  legend.pos = "n",
  add = T
)

legendTypo(
  pos = "left",
  title.txt = "",
  values.cex = 0.25,
  categ = rev(c(
    "<50.000", "50.000-100.000", "100.000-600.000", ">600.000"
  )),
  nodata = F,
  col =  colAU
)

plot(
  st_geometry(CCAASimp),
  lwd = 0.25,
  border = "black",
  add = T
)
dev.off()

rsvg::rsvg_png(
  "Large Urban Areas in Spain by population (2018).svg",
  "Large Urban Areas in Spain by population (2018).png"
)

# Plot AU2----

# wikicolors = c("#e41a1c",
#                "#4daf4a",
#                "#984ea3",
#                "#ff7f00",
#                "#377eb8",
#                "#ffff33")


library(RColorBrewer)

pdi = 90

svg(
  "Functional Urban Areas in Spain by population (2018).svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1000 / pdi,
  bg = "#C6ECFF"
)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = NA,
     border = NA,
     bg = "#C6ECFF")
plot(st_geometry(WORLD),
     col = "#E0E0E0",
     bg = "#C6ECFF",
     add = T)

plot(
  st_geometry(ProvSimp),
  col = "#FEFEE9",
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)

br = c(0, 50000, 100000, 600000, 10000000) %>% as.integer()

AU = MunicSimpl %>% filter(!is.na(FUA_ID)) %>%
  group_by(FUA_ID) %>% summarise(POP_2018 = sum(POP_2018)) %>% arrange(desc(POP_2018))

AU$categs = cut(AU$POP_2018, unique(br))
colAU = magma(6)[2:5]

typoLayer(
  AU,
  var = "categs",
  border = NA,
  col =  colAU,
  legend.pos = "n",
  add = T
)

legendTypo(
  pos = "left",
  title.txt = "",
  values.cex = 0.25,
  categ = rev(c(
    "<50.000", "50.000-100.000", "100.000-600.000", ">600.000"
  )),
  nodata = F,
  col =  colAU
)

plot(
  st_geometry(CCAASimp),
  lwd = 0.25,
  border = "black",
  add = T
)
dev.off()

rsvg::rsvg_png(
  "Functional Urban Areas in Spain by population (2018).svg",
  "Functional Urban Areas in Spain by population (2018).png"
)

# Plot DegUrb----
df=st_drop_geometry(MunicSimpl)
wikicolors = c("#4daf4a",
               "#e41a1c",
               "#984ea3")

show_col(wikicolors)
library(RColorBrewer)

pdi = 90

svg(
  "DegUrb.svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1000 / pdi,
  bg = "#C6ECFF"
)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = NA,
     border = NA,
     bg = "#C6ECFF")
plot(st_geometry(WORLD),
     col = "#E0E0E0",
     bg = "#C6ECFF",
     add = T)

plot(
  st_geometry(ProvSimp),
  col = "#FEFEE9",
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)


typoLayer(
  MunicSimpl,
  var = "DEGURBA",
  border = NA,
  col =  wikicolors,
  legend.pos = "n",
  add = T
)

legendTypo(
  pos = "left",
  title.txt = "",
  values.cex = 0.25,
  categ = c("Área Rural","Zona periférica","Ciudad" ),
  nodata = T,
  col =  wikicolors
)

plot(
  st_geometry(CCAASimp),
  lwd = 0.25,
  border = "black",
  add = T
)
dev.off()


# Plot muns----
pdi = 90

svg(
  "Muns.svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1000 / pdi,
  bg = "#C6ECFF"
)
par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = NA,
     border = NA,
     bg = "#C6ECFF")
plot(st_geometry(WORLD),
     col = "#E0E0E0",
     bg = "#C6ECFF",
     add = T)
plot(
  st_geometry(MunicSimpl),
  add = T,
  col = "#FEFEE9",
  border = "grey50",
  lwd = 0.3
)
plot(
  st_geometry(ProvSimp),
  lwd = 0.4,
  lty = 3,
  border = "grey5",
  add = T
)
plot(
  st_geometry(CCAASimp),
  lwd = 0.35,
  border = "black",
  add = T
)


dev.off()

# Renta per capita----

df = st_drop_geometry(MunicSimpl) %>% filter(!is.na(SS_INCOMEPERCAP_2016))

mean = weighted.mean(df$SS_INCOMEPERCAP_2016, df$POP_2018)
down = seq(mean, 0, by = -1000)[1:5]
up = seq(mean, 30000, by = 1000)[1:5]
br = sort(unique(c(0, down, up, 30000))) %>% as.integer()

#br = c(0, seq(8000, 16000, 1000), 30000) %>% as.integer()


#pdi=90
pdi = 90

svg(
  "RentaPers.svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1200 / pdi,
  bg = "#C6ECFF"
)

par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = "#E0E0E0",
     border = NA,
     bg = "#C6ECFF")

plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  bg = "#C6ECFF",
  add = T,
  lwd = 0.05
)

pal = (alpha(brewer.pal(length(br) - 1, "PRGn"), 0.5))
choroLayer(
  MunicSimpl,
  add = T,
  var = "SS_INCOMEPERCAP_2016",
  border = "#646464",
  breaks = br,
  col = pal,
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)


legendChoro(
  pos = "left",
  title.txt = " ",
  title.cex = 0.5,
  values.cex = 0.25,
  breaks = c(" ", format(br, big.mark = ",")[-c(1, length(br))], " "),
  col = pal,
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

plot(
  st_geometry(ProvSimp),
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)
plot(
  st_geometry(CCAASimp),
  lwd = 0.25,
  border = "black",
  add = T
)

dev.off()


# Renta per household----

df = st_drop_geometry(MunicSimpl) %>% filter(!is.na(SS_INCOMEPERHOUSEH_2016))
# summary(df$SS_INCOMEPERHOUSEH_2016)
# mean=weighted.mean(df$SS_INCOMEPERHOUSEH_2016,df$POP_2018)
# down=seq(mean,0,by=-1000)[1:5]
# up=seq(mean,30000,by=1000)[1:5]
# br=sort(unique(c(0,down,up,30000))) %>% as.integer()

#mean=weighted.mean(df$SS_INCOMEPERCAP_2016,df$POP_2018)
down = seq(25000, 0, by = -2500)[1:5]
up = seq(25000, 50000, by = 2500)[1:5]
br = sort(unique(c(0, down, up, 300000))) %>% as.integer()

#pdi=90
pdi = 90

svg(
  "RentaHH.svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1200 / pdi,
  bg = "#C6ECFF"
)

par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = "#E0E0E0",
     border = NA,
     bg = "#C6ECFF")

plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  bg = "#C6ECFF",
  add = T,
  lwd = 0.05
)

pal = (alpha(brewer.pal(length(br) - 1, "PRGn"), 0.5))
choroLayer(
  MunicSimpl,
  add = T,
  var = "SS_INCOMEPERHOUSEH_2016",
  border = "#646464",
  breaks = br,
  col = pal,
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)


legendChoro(
  pos = "left",
  title.txt = " ",
  title.cex = 0.5,
  values.cex = 0.25,
  breaks = c(" ", format(br, big.mark = ",")[-c(1, length(br))], " "),
  col = pal,
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

plot(
  st_geometry(ProvSimp),
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)
plot(
  st_geometry(CCAASimp),
  lwd = 0.25,
  border = "black",
  add = T
)

dev.off()

# UA unemployment---
# Renta per capita----

df = st_drop_geometry(MunicSimpl) %>% filter(!is.na(SS_INCOMEPERCAP_2016))

mean = weighted.mean(df$SS_INCOMEPERCAP_2016, df$POP_2018)
down = seq(mean, 0, by = -1000)[1:5]
up = seq(mean, 30000, by = 1000)[1:5]
br = sort(unique(c(0, down, up, 30000))) %>% as.integer()

#br = c(0, seq(8000, 16000, 1000), 30000) %>% as.integer()


#pdi=90
pdi = 90

svg(
  "RentaPers.svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1200 / pdi,
  bg = "#C6ECFF"
)

par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = "#E0E0E0",
     border = NA,
     bg = "#C6ECFF")

plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  bg = "#C6ECFF",
  add = T,
  lwd = 0.05
)

pal = (alpha(brewer.pal(length(br) - 1, "PRGn"), 0.5))
choroLayer(
  MunicSimpl,
  add = T,
  var = "SS_INCOMEPERCAP_2016",
  border = "#646464",
  breaks = br,
  col = pal,
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)


legendChoro(
  pos = "left",
  title.txt = " ",
  title.cex = 0.5,
  values.cex = 0.25,
  breaks = c(" ", format(br, big.mark = ",")[-c(1, length(br))], " "),
  col = pal,
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

plot(
  st_geometry(ProvSimp),
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)
plot(
  st_geometry(CCAASimp),
  lwd = 0.25,
  border = "black",
  add = T
)

dev.off()


# FOREIGN----

df = st_drop_geometry(MunicSimpl) %>% filter(!is.na(MunicSimpl$UA_FOREIGNERS_PERC_2018))
summary(df$UA_FOREIGNERS_PERC_2018)
# mean=weighted.mean(df$SS_INCOMEPERHOUSEH_2016,df$POP_2018)
# down=seq(mean,0,by=-1000)[1:5]
# up=seq(mean,30000,by=1000)[1:5]
# br=sort(unique(c(0,down,up,30000))) %>% as.integer()

#mean=weighted.mean(df$SS_INCOMEPERCAP_2016,df$POP_2018)
br = c(seq(0, 0.45, by = 0.05), 1)

#pdi=90
pdi = 90

svg(
  "Paro.svg",
  pointsize = pdi,
  width =  1600 / pdi,
  height = 1200 / pdi,
  bg = "#C6ECFF"
)

par(mar = c(0, 0, 0, 0))
plot(st_geometry(ProvSimp),
     col = "#E0E0E0",
     border = NA,
     bg = "#C6ECFF")

plot(
  st_geometry(WORLD),
  col = "#E0E0E0",
  bg = "#C6ECFF",
  add = T,
  lwd = 0.05
)

pal = (alpha(brewer.pal(length(br) - 1, "PRGn"), 0.5))
choroLayer(
  MunicSimpl,
  add = T,
  var = "UA_FOREIGNERS_PERC_2018",
  border = "#646464",
  breaks = br,
  col = pal,
  lwd = 0.05,
  legend.pos = "n",
  colNA = "#E0E0E0"
)


legendChoro(
  pos = "left",
  title.txt = " ",
  title.cex = 0.5,
  values.cex = 0.25,
  breaks = c(" ", format(br, big.mark = ",")[-c(1, length(br))], " "),
  col = pal,
  nodata = T,
  nodata.txt = "n.d.",
  nodata.col = "#E0E0E0"
)

plot(
  st_geometry(ProvSimp),
  lwd = 0.3,
  lty = 3,
  border = "black",
  add = T
)
plot(
  st_geometry(CCAASimp),
  lwd = 0.25,
  border = "black",
  add = T
)

dev.off()
