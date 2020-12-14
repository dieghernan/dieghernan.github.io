# Referencia: https://ggplot2tutor.com/streetmaps/streetmaps/

library(tidyverse)
library(osmdata)
library(sf)


# Place

place <- "Alquife, Spain"
level <- 3


# Conseguir coordenadas para ggplot
getbb(place)



opq_string(opq(getbb(place)))

add_osm

# Extraer lugares del mapa
streets <- getbb(place) %>%
  opq() %>%
  add_osm_feature(key = "highway",
                  value = c("motorway", "primary", "secondary", "tertiary")) %>%
  osmdata_sf()


Q551370


dat1 <- opq_osm_id(type="node",id="347698") %>% opq_string() %>%
  osmdata_sf()

id <- c (347698)

dat1 <- opq_osm_id (type = "way", id = id) %>%
  opq_string () %>%
  osmdata_sf ()


dat1

aa <- dat1$

plot(st_geometry(dat1$osm_polygons), axes = TRUE)
plot(st_geometry(dat1$osm_lines))



polys <- getbb("Menorca, Spain") %>%
  opq() %>%
  add_osm_feature(key = "boundary",
                  value = c("administrative")) %>%
  osmdata_sf()

ff <- polys$osm_multipolygons

plot(st_geometry(polys$osm_polygons))

plot(st_geometry(streets$osm_lines))

if (level == 3) {
  small_streets <- getbb(place) %>%
    opq() %>%
    add_osm_feature(key = "highway") %>%
    osmdata_sf()
} else {
  small_streets <- getbb("Granada, España") %>%
    opq() %>%
    add_osm_feature(
      key = "highway",
      value = c(
        "residential",
        "living_street",
        "unclassified",
        "service",
        "footway"
      )
    ) %>%
    osmdata_sf()
}


river <- getbb(place) %>%
  opq() %>%
  add_osm_feature(key = "waterway", value = "river") %>%
  osmdata_sf()

water <- getbb(place) %>%
  opq() %>%
  add_osm_feature(key="natural", value="water") %>% 
  osmdata_sf()

forest <- getbb(place) %>%
  opq() %>%
  add_osm_feature(key="landuse", value="forest") %>% 
  osmdata_sf()

map <- ggplot() +
  # Calles
  geom_sf(
    data = streets$osm_lines,
    inherit.aes = FALSE,
    color = "#ffbe7f",
    size = .4,
    alpha = .8
  ) +
  # Pequeñas calles
  geom_sf(
    data = small_streets$osm_lines,
    inherit.aes = FALSE,
    color = "#ffbe7f",
    size = .2,
    alpha = .8
  ) +
  # Ríos
  geom_sf(
    data = river$osm_lines,
    inherit.aes = FALSE,
    color = "#7fc0ff",
    size = .8,
    alpha = .5
  ) +
  geom_sf(data=water$osm_polygons,
          fill="#7fc0ff",
          color = NA,
          alpha = .5) +  # Límites del mapa en coordenadas
  geom_sf(
    data=forest$osm_polygons,
    fill="#acd29c",
    color = NA,
    alpha = .5
  ) +
  coord_sf(
    xlim = c(-3.125,-3.101),
    ylim = c(37.173, 37.21),
    expand = FALSE
  ) 

map

map + theme_void()  + theme(line=element_line(color=NA), plot.background =  element_rect(fill = "grey80", colour = NA))

# Exportación de mapa
ggsave("18.png", width = 6, height = 6, bg="#282828")
