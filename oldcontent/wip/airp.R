#0. Cleaning and set-up R----
rm(list = ls())
source("pass.R")

library(pacman)
p_load(dplyr,
       jsonlite)

library(readxl)

#Find airports----
myflights <- read_excel("drafts/flights.xlsx")
tosearch=data.frame(toloc=(sort(append(myflights$start,myflights$end))),
                    stringsAsFactors = F) 
tosearch = tosearch %>% count(toloc) %>% arrange(desc(n)) %>% as.data.frame()
tosearch$tofun = gsub(" ", "+", tosearch$toloc)
tosearch$tofun=ifelse(tosearch$toloc=="San Sebastian",
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
  geonames = geonames %>% select(
    tofun=search,
    toponymName,
    countryCode,
    long=lng,
    lat
  )
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
final$long=as.numeric(final$long)
final$lat=as.numeric(final$lat)

#Some statistics----
#Number times per city----
ndots=left_join(tosearch,final) %>% 
  select(
    name=toloc,
    countryCode,
    Airport=toponymName,
    n,
    long,
    lat
)

# Connecting Routes----
connect=myflights %>% count(start,end) %>% arrange(desc(n))
connect=left_join(connect,
                  ndots %>%
                    select(
                      start=name,
                      long_init=long,
                      lat_init=lat
                    ))
connect=left_join(connect,
                  ndots %>%
                    select(
                      end=name,
                      long_end=long,
                      lat_end=lat
                    ))

library(geosphere)
connectflights = gcIntermediate(
  connect[, c("long_init", "lat_init")],
  connect[, c("long_end", "lat_end")],
  n = 1000,
  breakAtDateLine = T,
  sp = T
)

# Leaflet-----
library(leaflet)

map <- leaflet( options = leafletOptions(minZoom = 2)) %>%
  addProviderTiles(providers$CartoDB.DarkMatter,
                   options = list(detectRetina = TRUE,
                                  noWrap = TRUE)) %>%
  setView(-3.56948,  40.49181, zoom = 3) %>%
  setMaxBounds(-180,-90,180,90) %>%
  addCircles(
    data=ndots,
    lng = ~ long,
    lat = ~ lat,
    weight = 5,
    radius =  sqrt(ndots$n) * 8000,
    popup = ~ name,
    color = "blue",
    group = "Destinies"
  )

map <-  addPolylines(map,weight=2*sqrt(connect$n),data = connectflights, opacity = sqrt(connect$n)/5,
                    col="blue" ,group = "Flights")

map <-   addEasyButton(map,easyButton(
  icon="fa-globe", title="Zoom to Level 1",
  onClick=JS("function(btn, map){ map.setZoom(1); }")))


library(leaflet.extras)
addH
map <- addHeatmap(map,data = ndots, intensity = ~ n,
                   radius = 10,max=30, blur=50, group = "Heatmap")
map <-   addLayersControl(map,
                          overlayGroups = c("Destinies","Flights","Heatmap"),
                          options = layersControlOptions(collapsed = FALSE)
)
map <- hideGroup(map,c("Destinies","Flights"))
map

names=read.csv("https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodes.csv")
