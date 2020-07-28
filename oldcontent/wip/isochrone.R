#devtools::install_github("rCarto/osrm",force = TRUE)
library(osrm)
library(sf)

Sol=c(-3.703665, 40.417058)
#Sol=c(151.207049, -33.886475)

# Get isochones with lon/lat coordinates
iso <- osrmIsochrone(loc =Sol, 
                     breaks = seq(from = 0,to = 25, by = 5),
                     res=200,
                     returnclass="sf")



iso$drive_times <- factor(paste(iso$max, "min."))

factpal <- colorFactor(rev(heat.colors(nrow(iso))), iso$drive_times)


leaflet() %>% 
  setView(Sol[1],Sol[2], zoom = 11) %>%
  addProviderTiles("CartoDB.Positron", group="Greyscale") %>% 
  addPolygons(fill=TRUE, stroke=TRUE, color = "black",
              fillColor = ~factpal(iso$drive_times),
              weight=0.5, fillOpacity=0.2,
              data = iso, popup = iso$drive_times,
              group = "Drive Time") %>% 
  # Legend
  addLegend("bottomright", pal = factpal, values = iso$drive_time,   title = "Drive Time")


