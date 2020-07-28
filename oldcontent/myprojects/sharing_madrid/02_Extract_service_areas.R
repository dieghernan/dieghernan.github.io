# 0. Init----
rm(list = ls())
library(sf)
library(jsonlite)
library(dplyr)

cleansharing <- function(data, service, city, provider) {
  geom = lapply(1:length(data[["areas"]][["coordinates"]]), function(x) {
    st_linestring(data[["areas"]][["coordinates"]][[x]][, 1:2]) %>% st_cast("POLYGON")
  }) %>% st_sfc()
  
  df = st_sf(area = st_area(geom) / 1000, geom)
  df = df %>% arrange(desc(area))
  df$a = 1
  df = df[, 3]
  for (i in 1:nrow(df)) {
    if (i == 1) {
      keep = df[i,]
    } else {
      if (st_contains(keep, df[i,], sparse = FALSE)) {
        keep = st_difference(keep, df[i,])
        keep = keep[, 1]
      } else {
        geom = st_combine(rbind(keep, df[i,]))
        keep = st_sf(st_drop_geometry(keep), geom)
        keep = st_buffer(keep, 0)
        rm(geom)
      }
    }
  }
  df = data.frame(
    service = service,
    city = city,
    provider = provider,
    stringsAsFactors = FALSE
  )
  keepdf = st_sf(df,
                 geom = st_geometry(keep)) %>%
    st_cast("MULTIPOLYGON")
  st_crs(keepdf) <- 4326
  return(keepdf)
}

urbipath = "https://storage.googleapis.com/providers/a"
filetemp = paste(tempdir(), "test.json", sep = "/")

#1. Coup----
download.file(paste(urbipath, "coup-madrid.json", sep = "/"),
              destfile = filetemp)
data = fromJSON(filetemp)
motosharing = cleansharing(data, "motosharing", "madrid", "coup")
plot(motosharing[nrow(motosharing), ])


#2. Muving----
download.file(paste(urbipath, "muving-madrid.json", sep = "/"),
              destfile = filetemp)
data = fromJSON(filetemp)
motosharing = rbind(motosharing,
                    cleansharing(data,
                                 "motosharing",
                                 "madrid", "muving"))
plot(motosharing[nrow(motosharing), ])

#3. Acciona----
download.file(paste(urbipath, "acciona-madrid.json", sep = "/"),
              destfile = filetemp)
data = fromJSON(filetemp)
motosharing = rbind(motosharing,
                    cleansharing(data,
                                 "motosharing",
                                 "madrid", "acciona"))
plot(motosharing[nrow(motosharing), ])

dataAcciona=data
#4. Movo----
download.file(paste(urbipath, "movo-madrid.json", sep = "/"),
              destfile = filetemp)
data = fromJSON(filetemp)

aa=cleansharing(data,
             "motosharing",
             "madrid", "movo")

motosharing = rbind(motosharing,
                    cleansharing(data,
                                 "motosharing",
                                 "madrid", "movo"))
plot(motosharing[nrow(motosharing), ])

#5. eCooltra----
download.file(paste(urbipath, "cooltra-madrid.json", sep = "/"),
              destfile = filetemp)
data = fromJSON(filetemp)
motosharing = rbind(motosharing,
                    cleansharing(data,
                                 "motosharing",
                                 "madrid", "ecooltra"))
plot(motosharing[nrow(motosharing), ])

#6. ioscoot----
download.file(paste(urbipath, "ioscoot-madrid.json", sep = "/"),
              destfile = filetemp)
data = fromJSON(filetemp)
motosharing = rbind(motosharing,
                    cleansharing(data,
                                 "motosharing",
                                 "madrid", "ioscoot"))
plot(motosharing[nrow(motosharing), ])

#7. Areas coverage----
global_service = motosharing %>% group_by(service, city) %>%
  summarise(drop = n()) %>% select(-drop) %>%
  mutate(provider = "all")

motosharing = rbind(motosharing, global_service)

motosharing$area_km2 = as.double(st_area(motosharing)) / (1000 ^ 2)


global_service = motosharing %>% group_by(service, city) %>%
  summarise(drop = n()) %>% select(-drop) %>%
  mutate(provider = "all")

global_service$area_km2 = as.double(st_area(global_service)) / (1000 ^ 2)
Sharing = rbind(motosharing, global_service)


# Timestamp
motosharing$timestamp = Sys.time()

motosharing = arrange(motosharing, desc(area_km2))
plot(motosharing)

# Transform to crs

Mad = st_read("myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg")
motosharing = st_transform(motosharing, st_crs(Mad))


#8. Crea gpkg----

st_write(
  motosharing,
  "myprojects/sharing_madrid/assets/areas_sharing.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)

rm(list = ls())
