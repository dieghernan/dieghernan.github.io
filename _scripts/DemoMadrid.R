library(sf)

url <- "https://geoportal.madrid.es/fsdescargas/IDEAM_WBGEOPORTAL/ESTADISTICA/ESTRUCTURA_DEMOGRAFICA/estructura_demografica.zip"
tempzip <- tempfile(fileext = ".zip")

download.file(url, tempzip)

files <- unzip(tempzip, list=TRUE)
unzip(tempzip, exdir = tempdir(), junkpaths = TRUE)


shp_cens <- st_read(file.path(tempdir(),"Estructura_demografica_seccion_censal.shp" ))
shp_barrio <- st_read(file.path(tempdir(),"Estructura_demografica_barrio.shp" ))
shp_dist <- st_read(file.path(tempdir(),"Estructura_demografica_distrito.shp" ))



library(ggplot2)

extr_cens <- ggplot(shp_cens) +
  geom_sf(aes(fill=Proporci_3), color=NA) +
  geom_sf(data=shp_dist, fill=NA, color="grey5", size=0.1)+
  scale_fill_gradientn(colours = hcl.colors(10,"Lajolla"),
                       labels = function(x) paste0(x,"%"),
                       name="",
                         guide = guide_colorsteps(barheight=10,
                                                  barwidth=0.6)
                       ) +
  theme_void()

ggsave("./assets/img/wiki/PorcExtMadrid2020.svg", width = 7, height = 7)


extr_barr <- ggplot(shp_barrio) +
  geom_sf(aes(fill=Proporci_3), color=NA) +
  geom_sf(data=shp_dist, fill=NA, color="grey5", size=0.1)+
  scale_fill_gradientn(colours = hcl.colors(10,"Lajolla"),
                       labels = function(x) paste0(x,"%"),
                       name="",
                       breaks= seq(0,35,5),
                       guide = guide_colorsteps(barheight=10,
                                                barwidth=0.6)
  ) +
  theme_void()

extr_barr
ggsave("./assets/img/wiki/PorcExtMadrid2020Barrio.svg", width = 7, height = 7)


extr_dist <- ggplot(shp_dist) +
  geom_sf(aes(fill=Proporci_3), color=NA) +
  geom_sf(data=shp_dist, fill=NA, color="grey5", size=0.1)+
  scale_fill_gradientn(colours = hcl.colors(10,"Lajolla"),
                       labels = function(x) paste0(x,"%"),
                       breaks = seq(0,25,5),
                       name="",
                       guide = guide_colorsteps(barheight=10,
                                                barwidth=0.6)
  ) +
  theme_void()

ggsave("./assets/img/wiki/PorcExtMadrid2020Dist.svg", width = 7, height = 7)

ggplot(shp_dist) +
  geom_sf(aes(fill=Densidad), color=NA) +
  geom_sf(data=shp_dist, fill=NA, color="grey5", size=0.1)+
  scale_fill_gradientn(colours = hcl.colors(10,"Lajolla"),
                       labels = scales::label_comma(),
                       name="pop/km2",
                       breaks = seq(0,350,50),
                       guide = guide_colorsteps(barheight=10,
                                                barwidth=0.6)
  ) +
  theme_void()


ggsave("./assets/img/wiki/DensMadrid2020Dist.svg", width = 7, height = 7)
