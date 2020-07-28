### Project Wiki----
rm(list = ls())

library(rvest)
library(sf)
library(cartography)
library(RColorBrewer)
library(dplyr)

### Maps----
# Map import from Eurostat
WorldMap <-
  st_read(
    "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/countries/geojson/CNTR_RG_10M_2016_3857.geojson",
    stringsAsFactors = FALSE
  ) %>%
  select(ISO_3166_3 = ISO3_CODE)

# CountryCode import
df <- read.csv(
  "https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodes.csv",
  na.strings = "",
  stringsAsFactors = FALSE,
  fileEncoding = "utf8"
)

WorldMap <- left_join(WorldMap, df)

rm(df)

# Create bbox of the world
bbox <- st_linestring(rbind(c(-180, 90),
                            c(180, 90),
                            c(180,-90),
                            c(-180,-90),
                            c(-180, 90))) %>%
  st_segmentize(5) %>%
  st_cast("POLYGON") %>%
  st_sfc(crs = 4326)

# Meat consumption (https://en.wikipedia.org/wiki/List_of_countries_by_meat_consumption)----
Meat <-
  read.csv(
    "./myprojects/wikimaps/meatconsump.csv",
    sep = ";",
    stringsAsFactors = F
  )
MeatMap <- left_join(WorldMap, Meat) %>% st_transform("+proj=robin")

br = seq(from = 0, to = 160, by = 20)


svg(
  "./myprojects/wikimaps/Meat consumption rate (kg) per capita by country gradient map (2009).svg",
  pointsize = 90,
  width =  1600 / 90,
  height = 800 / 90
)
par(mar = c(0.5, 0, 0, 0))
choroLayer(
  MeatMap  ,
  var = "KG_PERSON_2009",
  breaks = br,
  col = brewer.pal(length(br) - 1, "YlOrRd"),
  border = "#646464",
  lwd = 0.1,
  colNA = "#E0E0E0",
  legend.pos = "left",
  legend.title.txt = "",
  legend.values.cex = 0.25
)
plot(
  bbox %>% st_transform("+proj=robin"),
  add = T,
  border = "#646464",
  lwd = 0.2
)
dev.off()

svg(
  "./myprojects/wikimaps/Meat consumption rate (kg) per capita by country gradient map (2002).svg",
  pointsize = 90,
  width =  1600 / 90,
  height = 800 / 90
)
par(mar = c(0.5, 0, 0, 0))
choroLayer(
  MeatMap  ,
  var = "KG_PERSON_2002",
  breaks = br,
  col = brewer.pal(length(br) - 1, "YlOrRd"),
  border = "#646464",
  lwd = 0.1,
  colNA = "#E0E0E0",
  legend.pos = "left",
  legend.title.txt = "",
  legend.values.cex = 0.25
)
plot(
  bbox %>% st_transform("+proj=robin"),
  add = T,
  border = "#646464",
  lwd = 0.2
)
dev.off()


# Cocaine consumption-----


Base <-
  read_html("https://en.wikipedia.org/wiki/List_of_countries_by_prevalence_of_cocaine_use") %>%
  html_nodes(xpath = '//*[@id="mw-content-text"]/div/table') %>%
  html_table() %>%
  as.data.frame(stringsAsFactors = F,
                fix.empty.names = F)%>% 
  select(NAME.EN=Country.or.entity,
         PrevPercent=Annual.prevalence..percent.)
# CountryCode import
df <- read.csv(
  "https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodes.csv",
  na.strings = "",
  stringsAsFactors = FALSE,
  fileEncoding = "utf8"
)

Prev  <- inner_join(df,
                    Base
                    )


nameex <- anti_join(Base, df)


nameex$ISO_3166_3 <- c(
  "ENW",
  "UKM",
  "UKN",
  "TCA",
  "VCT",
  "BIH",
  "LCA",
  "TTO",
  "HKG",
  "CZE",
  "STP"
)

enddf=Prev %>% select(names(nameex)) %>% rbind(nameex)


WorldMap <-
  st_read(
    "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/countries/geojson/CNTR_RG_10M_2016_3857.geojson",
    stringsAsFactors = FALSE
  )  %>% mutate(ISO_3166_3=ISO3_CODE)

innersf=inner_join(WorldMap,enddf)
rd=anti_join(enddf,st_drop_geometry(WorldMap))


UK <- st_read(
  "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/geojson/NUTS_RG_10M_2016_3857_LEVL_1.geojson",
  stringsAsFactors = FALSE
) %>% filter(CNTR_CODE=="UK")

ENWAL=UK %>% filter(NUTS_ID != "UKM") %>%
  filter(NUTS_ID != "UKN") %>% group_by(CNTR_CODE) %>% summarise(d=1) %>% 
  select(-d) %>% mutate(CNTR_CODE="ENW") %>% select(ISO_3166_3=CNTR_CODE) %>% 
  inner_join(rd) %>% select(ISO_3166_3,PrevPercent)

OTUK=inner_join(UK,rd,by=c("NUTS_ID"="ISO_3166_3")) %>%
  select(ISO_3166_3=NUTS_ID,PrevPercent)

ALL.sf=innersf %>% select(ISO_3166_3, PrevPercent)%>%
  rbind(ENWAL) %>%
  rbind(OTUK)

Outer=anti_join(WorldMap,st_drop_geometry(ALL.sf)) %>% filter(
  ISO_3166_3 != "GBR"
) %>% mutate(PrevPercent=NA) %>% select(ISO_3166_3,PrevPercent) %>%
  rbind(ALL.sf) %>% st_transform("+proj=robin")


svg(
  "./myprojects/wikimaps/Prevalence of cocaine use as percentage of population by country gradient map (2009).svg",
  pointsize = 90,
  width =  1600 / 90,
  height = 800 / 90
)
par(mar = c(0.7, 0, 0, 0))
br=seq(0,2.5,by=0.5)
choroLayer(
  Outer  ,
  var = "PrevPercent",
  breaks = br,
  col = brewer.pal(length(br) - 1, "PuBu"),
  border = "#646464",
  lwd = 0.1,
  colNA = "#E0E0E0",
  legend.pos = "left",
  legend.title.txt = "",
  legend.values.cex = 0.25,
  legend.values.rnd = 2
)

# Create bbox of the world
bbox <- st_linestring(rbind(c(-180, 90),
                            c(180, 90),
                            c(180,-90),
                            c(-180,-90),
                            c(-180, 90))) %>%
  st_segmentize(5) %>%
  st_cast("POLYGON") %>%
  st_sfc(crs = 4326)

plot(
  bbox %>% st_transform("+proj=robin"),
  add = T,
  border = "#646464",
  lwd = 0.2
)
dev.off()

