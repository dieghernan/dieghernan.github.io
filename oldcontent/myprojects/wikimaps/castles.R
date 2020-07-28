library(leaflet)
library(sf)
setwd("/cloud/project/myprojects/wikimaps")
aa = st_read("geocastles.gpkg", stringsAsFactors = FALSE) %>%
  st_transform("+proj=longlat +datum=WGS84")

cntry = st_read("geocastlesCount2.gpkg", stringsAsFactors = FALSE) %>%
  st_transform("+proj=longlat +datum=WGS84")
par(mar = c(0, 0, 0, 0))




map <- leaflet(options = leafletOptions(minZoom = 1.25)) %>%
  addProviderTiles(
    providers$CartoDB.Positron,
    group = "Political",
    options = list(noWrap = TRUE,
                   detectRetina = TRUE)
  ) %>%
  addProviderTiles(
    providers$Esri.WorldShadedRelief,
    group = "Relief",
    options = list(noWrap = TRUE,
                   detectRetina = TRUE)
  ) %>%
  setView(4.5,  45, zoom = 3) %>%
  setMaxBounds(-180, -90, 180, 90) %>%
  addPolygons(data = cntry,
              fillOpacity =  0.05,
              weight = 1)
map

colorcast = c("#e41a1c", "#4daf4a",
              "#984ea3", "#ff7f00")

toplot = aa %>% filter(fcodeName == "castle")

map <- map %>% addCircleMarkers(
  data = toplot,
  stroke = T,
  col = colorcast[1],
  weight = 1,
  popup = toplot$Name,
  radius = 3,
  group = "Castles"
)

toplot = aa %>% filter(fcodeName == "fort")

map <- map %>% addCircleMarkers(
  data = toplot,
  stroke = T,
  col = colorcast[2],
  weight = 1,
  popup = toplot$Name,
  radius = 3,
  group = "Forts"
)
toplot = aa %>% filter(fcodeName == "palace")

map <- map %>% addCircleMarkers(
  data = toplot,
  stroke = T,
  col = colorcast[3],
  weight = 1,
  popup = toplot$Name,
  radius = 3,
  group = "Palaces"
)

toplot = aa %>% filter(fcodeName == "wall")

map <- map %>% addCircleMarkers(
  data = toplot,
  stroke = T,
  col = colorcast[4],
  weight = 1,
  popup = toplot$Name,
  radius = 3,
  group = "Walls"
)


map <-   addLayersControl(
  map,
  baseGroups = c("Political", "Relief"),
  overlayGroups = c("Castles", "Forts", "Palaces", "Walls"),
  options = layersControlOptions(collapsed = FALSE)
) %>%   addEasyButton(easyButton(
  icon = "fa-crosshairs",
  title = "Locate Me",
  onClick = JS("function(btn, map){ map.locate({setView: true}); }")
))

map


