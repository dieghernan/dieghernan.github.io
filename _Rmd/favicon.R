library(giscoR)
library(sf)
library(tmap)

nuts3 <- gisco_get_nuts(
  year = "2016",
  epsg = "3035",
  resolution = "3",
  nuts_level = "3"
)

# Countries
countries <-
  gisco_get_countries(
    year = "2016",
    epsg = "3035",
    resolution = "3"
  )

# Use eurostat
library(eurostat)
library(tidyverse)

popdens <- get_eurostat("demo_r_d3dens")
popdens <- popdens[popdens$time == "2018-01-01", ]


cent <- countries %>% filter(ISO3_CODE=="AND") %>% st_centroid(of_largest_polygon = TRUE) %>%
  st_buffer(1000000)

countries_buff <- st_intersection(countries,cent)
  
nuts3.sf <- merge(nuts3,
                  popdens,
                  by.x = "NUTS_ID",
                  by.y = "geo",
                  all.x = TRUE
) %>% st_intersection(cent)



br <- c(0, 25, 50, 100, 200, 500, 1000, 2500, 5000, 10000, 30000, Inf)
nuts3.sf$cut <- cut(nuts3.sf$values, breaks=br)


logo <- ggplot() +
  geom_sf(data=cent, fill="black") +
  geom_sf(data=countries_buff,fill="grey10", colour="grey10") + 
  geom_sf(data=nuts3.sf, aes(fill=cut), col=NA, show.legend = FALSE) +
  scale_fill_manual(values=hcl.colors(10,"Spectral", rev=TRUE)) +
  theme_void() +
  theme(rect = element_rect(fill = "transparent"))


ggsave("logo.png", width = 4, height = 4, bg = "transparent")
