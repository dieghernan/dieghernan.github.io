# Castles and fortress----
rm(list = ls())

library(jsonlite)
library(sf)
library(cartography)
library(lwgeom)
library(dplyr)
library(scales)

API_KEY_GEONAMES = "dieghernan"


#World Map
download.file(
  "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/countries/geojson/CNTR_RG_10M_2016_3857.geojson",
  "ct.geojson"
)


CNTRY.sf = st_read("ct.geojson",
                   stringsAsFactors = FALSE)
file.remove("ct.geojson")

# Countries
Codes.df <- read.csv(
  "https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodes.csv",
  na.strings = "",
  stringsAsFactors = FALSE,
  fileEncoding = "utf8"
)


EU.df <- Codes.df %>%
  filter(continentcode == "EU") %>%
  select(NUTS,
         ISO_3166_2,
         ISO_3166_3)

NUTS <- as.vector(EU.df$NUTS)
ISO3 <- as.vector(EU.df$ISO_3166_3)
ISO2 <- as.vector(EU.df$ISO_3166_2)

fcodes <- c("FT", "CSTL", "PAL", "WALL", "WALLA")


#geonames
for (iter in 1:length(fcodes)) {
  for (iter2 in c(1, 901, 1901, 2901, 3901, 4901, 4999)) {
    download.file(
      paste(
        "http://api.geonames.org/searchJSON?formatted=true&username=",
        API_KEY_GEONAMES,
        "&style=full&fcode=",
        fcodes[iter],
        "&lang=EN&continentCode=EU&startRow=",
        iter2,
        "&maxRows=1000",
        sep = ""
      ),
      "r1.json"
    )
    
    geonames = fromJSON("r1.json")
    if (length(geonames[["geonames"]]) > 0) {
      geonames = data.frame(geonames[["geonames"]], row.names = NULL)
      cd = geonames$alternateNames
      geonames$links = lapply(1:nrow(geonames),
                              function(x)
                                if (is.data.frame(cd[[x]])) {
                                  flatten(cd[[x]]) %>% filter(lang == "link") %>% select(name) %>% as.character()
                                } else {
                                  NA
                                })
      geonames = geonames %>%
        select(
          Name = asciiName,
          countryCode,
          countryName,
          fcodeName,
          long = lng,
          lat,
          links
        )
      geonames$links = unlist(geonames$links)
      geonames$links = ifelse(geonames$links == "character(0)", NA, geonames$links)
      
      if (exists("final")) {
        final = rbind(final, geonames)
        final = unique(final)
      } else {
        final = geonames
      }
    }
    rm(geonames)
  }
}


summ = final %>% group_by(countryName) %>% tally()


summ2 = final %>% group_by(fcodeName) %>% tally()

final.sf = st_as_sf(final, coords = c("long", "lat"), crs = 4326) %>%
  lwgeom::st_make_valid() %>% st_transform(st_crs(CNTRY.sf))

final.sf$fcodeName <- ifelse(final.sf$fcodeName == "ancient wall",
                             "wall",
                             final.sf$fcodeName)

unique(final.sf$fcodeName)
#Plot it----
colorcast = c("#e41a1c", "#4daf4a",
              "#984ea3", "#ff7f00")

svg(
  "cast.svg",
  pointsize = 90,
  width =  1050 / 90,
  height =  1050 / 90
)
par(mar = c(0, 0, 0, 0), cex = 0.25)
trans = 0.15
plot(
  st_geometry(CNTRY.sf),
  xlim = c(-2800000, 5001225),
  ylim = c(4283039, 10354234),
  col = "#E0E0E0",
  border = "#E0E0E0",
  lwd = 0.1,
  bg = "#FFFFFF"
)

cntrcast = final.sf %>% st_drop_geometry() %>%
  select(countryCode,
         countryName) %>% unique()

cntrcast = left_join(cntrcast,
                     Codes.df %>% select(ISO_3166_3,
                                         countryCode = ISO_3166_2))

plot(
  st_geometry(CNTRY.sf %>% filter(
    ISO3_CODE %in% unique(cntrcast$ISO_3166_3)
  )),
  col = "#FEFEE9",
  border = "#646464",
  lwd = 0.1,
  add = T
)
plot(
  st_geometry(final.sf %>% filter(fcodeName == "castle")),
  add = T,
  col = alpha(colorcast[1], trans),
  pch = 16,
  cex = 0.5
)
plot(
  st_geometry(final.sf %>% filter(fcodeName == "fort")),
  add = T,
  col = alpha(colorcast[2], trans),
  pch = 16,
  cex = 0.5
)
plot(
  st_geometry(final.sf %>% filter(fcodeName == "palace")),
  add = T,
  col = alpha(colorcast[3], trans),
  pch = 16,
  cex = 0.5
)
plot(
  st_geometry(final.sf %>% filter(fcodeName == "wall")),
  add = T,
  col = alpha(colorcast[4], trans),
  pch = 16,
  cex = 0.5
)
legendTypo(
  "left",
  title.txt = "",
  values.cex = 0.70,
  nodata = FALSE,
  categ = unique(final.sf$fcodeName),
  col = alpha(colorcast[1:4], 0.6)
)

layoutLayer(
  title = "",
  horiz = FALSE,
  frame = FALSE,
  scale = 500,
  posscale = "bottomleft",
  source = "© EuroGeographics for the administrative boundaries, geonames",
  author = "dieghernan, 2019"
)
dev.off()
rsvg::rsvg_png("cast.svg", "cast.png")

toexport=final.sf
toexport$links=ifelse(is.na(toexport$links),"https://en.wikipedia.org/wiki/List_of_castles_in_Europe",toexport$links)


st_write(
  toexport,
  "geocastles.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)
