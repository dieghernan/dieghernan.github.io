rm(list = ls())

#output: github_document always_allow_html: yes

library(pacman)
rm(list = ls())

source("./pass.R")

library(pacman)
p_load(dplyr,
       jsonlite,
       readxl,
       geosphere,
       leaflet,
       leaflet.extras,
       sf)


# Find airports----
myflights <- read_excel("./_data/flights.xlsx")
tosearch = data.frame(toloc = 
                        (sort(append(
                          myflights$start, 
                          myflights$end))),
                      stringsAsFactors = F)

tosearch = tosearch %>% 
  count(toloc) %>% 
  arrange(desc(n)) %>% 
  as.data.frame()

tosearch$tofun = gsub(" ", "+", tosearch$toloc)
tosearch$tofun = ifelse(tosearch$toloc == "San Sebastian",
                        "san+sebastian+es",
                        tosearch$tofun)

airports <- function(place, n = 1, lang = "en") {
  url = paste(
    "http://api.geonames.org/searchJSON?formatted=true&username=",
    GEONAMES_USER,
    "&style=medium&fcode=AIRP&lang=",
    lang,
    "&maxRows=",
    paste(n),
    "&q=",
    place,
    sep = ""
  )
  geonames = fromJSON(url)
  geonames = data.frame(geonames[["geonames"]])
  geonames$search = place
  geonames = geonames %>% select(tofun = search,
                                 toponymName,
                                 countryCode,
                                 long = lng,
                                 lat)
  return(geonames)
}
#Return
for (i in 1:nrow(tosearch)) {
  res = airports(tosearch[i, c("tofun")])
  row.names(res) <- i
  if (i == 1) {
    final = res
  } else {
    final = rbind(final, res)
  }
  rm(res)
}
rm(i)
final$long = as.numeric(final$long)
final$lat = as.numeric(final$lat)

#Some statistics----
#Number times per city----
ndots = left_join(tosearch, final) %>%
  select(name = toloc,
         countryCode,
         Airport = toponymName,
         n,
         long,
         lat)

# Connecting Routes----
connect = myflights %>% count(start, end) %>% arrange(desc(n))
connect = left_join(connect,
                    ndots %>%
                      select(
                        start = name,
                        long_init = long,
                        lat_init = lat
                      ))
connect = left_join(connect,
                    ndots %>%
                      select(
                        end = name,
                        long_end = long,
                        lat_end = lat
                      ))


connectflights = gcIntermediate(
  connect[, c("long_init", "lat_init")],
  connect[, c("long_end", "lat_end")],
  n = 200,
  addStartEnd=TRUE,
  breakAtDateLine = T,
  sp = T
)

linessf=st_as_sf(connectflights)
data=st_sf(connect,st_geometry(linessf))
kms=sum((as.numeric(st_length(data))*data$n)/1000)
outline <- ndots[chull(ndots$long, ndots$lat),]
# Leaflet-----
map <- leaflet(options = leafletOptions(minZoom = 1.25)) %>%
  addProviderTiles(providers$CartoDB.DarkMatter,
                   options = list(noWrap = TRUE,
                                  detectRetina=TRUE)) %>%
  setView(-3.56948,  40.49181, zoom = 3) %>%
  setMaxBounds(-180,-90, 180, 90) %>%
  addCircleMarkers(data=ndots,radius = ndots$n^(1/5)*5,
                  stroke=T, fillOpacity = 0.3,group = "Destinations")
map <-addPolygons(map=map,data = outline,
            lng = ~long, lat = ~lat,
            fillColor = "white", 
            fillOpacity = 0.05,
            stroke = F,
            group = "Outline")
map <-
  addPolylines(
    map,
    weight = log(connect$n)*6+3,
    opacity = 0.3,
    data = connectflights,
    col = "green" ,
    group = "Flights"
  )
map <-   addEasyButton(map,
                       easyButton(
                         icon = "fa-globe",
                         title = "Zoom to Level 1",
                         onClick = JS("function(btn, map){ map.setView([ 40.49181,-3.56948],1.25); }")
                       ))
map <- addHeatmap(
  map,
  data = ndots,
  intensity = ndots$n^(1/5),
  max=max(ndots$n^(1/5)),
  minOpacity = 0.3,
  radius = 35,
  blur = 30,
  group = "Heatmap"
)

map <-   addLayersControl(
  map,
  overlayGroups = c("Heatmap","Destinations", "Flights","Outline"),
  options = layersControlOptions(collapsed = TRUE)
)

map <- hideGroup(map, c("Destinations", "Flights","Outline"))
map

#----

explode = data.frame(name = 
                       (sort(append(
                         myflights$start, 
                         myflights$end))),
                     stringsAsFactors = F)

explodefin=left_join(explode,ndots)

map2 <- leaflet(options = leafletOptions(minZoom = 1.25)) %>%
  addProviderTiles(providers$CartoDB.DarkMatter,
                   options = list(noWrap = TRUE,
                                  detectRetina=TRUE)) %>%
  setView(-3.56948,  40.49181, zoom = 3) %>%
  setMaxBounds(-180,-90, 180, 90)


map3 <-  addPolygons(map=map2,data = outline,
                     lng = ~long, lat = ~lat,
                     fillColor = "white", 
                     fillOpacity = 0.05,
                     stroke = F,
                     group = "Outline")

map3
addP
map3 <- addHeatmap(
  map2,
  data = ndots,
  intensity = ndots$n^(1/5),
  max=max(ndots$n^(1/5)),
  minOpacity = 0.3,
  radius = 35,
  blur = 30
)
map3
map4 <- addCircleMarkers(map=map2,data=ndots,radius = ndots$n^(1/5)*5,
                         stroke=T, fillOpacity = 0.3)
map4
map3
ndots$n^(1/5)
addC
map <-   addLayersControl(
  map,
  overlayGroups = c("Heatmap","Destinations", "Flights","Outline"),
  options = layersControlOptions(collapsed = TRUE)
)

map <- hideGroup(map, c("Destinations", "Flights",))
map