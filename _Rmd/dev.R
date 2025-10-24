library(tidyverse)
library(sf)
library(ggrepel)
library(giscoR)


# File (including ice shelves)


ant <- gisco_get_countries(year = 2024, resolution = 1,
                           country = "ATA") %>% 
  select(NAME = NAME_ENGL) |> 
  # Ortho proj centered in the South Pole
  st_transform(crs = "+proj=ortho +lat_0=-90 +lon_0=0")


ggplot(ant) +
  geom_sf(fill="white")

# Fix to avoid holes 

# 1. Explode
ant_exp <- ant |> 
  st_cast("POLYGON") |> 
  mutate(n = row_number() |> as.factor())

# Identify points on max polygon
max_ant <- ant_exp[which.max(st_area(ant_exp)),]

plot(max_ant)

coords <- st_coordinates(max_ant) |> 
  as_tibble() |> 
  mutate(np = row_number())


ggplot(coords, aes(X,Y)) +
  geom_point(size = 0.05) +
  geom_text(aes(label = np), check_overlap = TRUE) +
  coord_equal()

test <- coords |> 
  filter(np %in% seq(8200, 9200))

test |> 
  ggplot(aes(X,Y)) +
  geom_point(size = 0.05) +
  geom_text(aes(label = np), check_overlap = TRUE) +
  coord_equal()



test |> 
  filter(np %in% seq(8288, 9131)) |>
  ggplot(aes(X,Y)) +
  geom_point() +
  coord_equal()


test |> 
  filter(!np %in% seq(8289, 9130)) |>
  ggplot(aes(X,Y)) +
  geom_point() +
  coord_equal()

newpol <- coords |> 
  as.data.frame() |> 
  filter(!np %in% seq(8289, 9130)) |>
  select(X,Y) |> 
  as.matrix() |> 
  list() |> 
  st_polygon() |> 
  st_sfc() |> 
  st_set_crs(st_crs(max_ant)) 

ggplot(newpol) +
  geom_sf()

newmax <- st_sf(st_drop_geometry(max_ant), geometry = newpol)
antarctica <- bind_rows(newmax, ant_exp[-1,]) |> 
  group_by(NAME) |> 
  summarise(m = 1) |> 
  select(-m) |> 
  st_make_valid()

ggplot(antarctica) +
  geom_sf() 


# Cut to bbox
bbox <- st_bbox(antarctica)

# And the flags
antarctica |> 
  # rmapshaper::ms_simplify(keep = 0.01) |> 
  ggplot() +
  geom_sf(fill="white", color = NA) +
  theme(panel.background = element_rect(fill = "#009fdc"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()
  ) +
  labs(title = "Graham Bartram's proposal") +
  coord_sf(xlim = c(bbox[c(1,3)]) * 1.8 ,
           ylim = c(bbox[c(2,4)]) * 1.4)

# Antarctic Treaty

# Need graticules

grats <- giscoR::gisco_get_countries() |> 
  st_transform(st_crs(antarctica)) |> 
  st_graticule(lat = c(-80, -70, -60),
               lon = seq(-180, 180, 30),
               ndiscr = 10000,
               margin = 0.000001) 

# Merge meridians
plot(grats[, "degree"])


# Merge meridians
merid <- lapply(seq(-180, 0, 30), function(x){
  
  df <-  grats |> 
    filter(type == "E") |> 
    filter(degree %in% c(x, x+180))
  
  df2 <- df |> 
    st_geometry() |> 
    st_cast('MULTIPOINT') |> 
    st_union() |> 
    st_cast('LINESTRING')
  
  sf_x <- st_sf(
    degree = x,
    type = "E",
    geometry = df2
  )
}) |>  bind_rows()


grats_end <- merid |> 
  bind_rows(grats |> 
              filter(type != "E"))



grats_yes <- st_intersection(grats_end, antarctica)
grats_no <- st_difference(grats_end, antarctica)



antarctica |> 
  ggplot() +
  geom_sf(fill="white", color = NA) +
  theme(panel.background = element_rect(fill = "#072b5f"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()
  ) +
  geom_sf(data = grats_yes, color = "#072b5f", linewidth = 1) +
  geom_sf(data = grats_no, color = "white", linewidth = 1) +
  coord_sf(xlim = c(bbox[c(1,3)]) * 1.8 ,
           ylim = c(bbox[c(2,4)]) * 1.4) +
  labs(title = "Emblem of the Antarctic Treaty")


# Redesing

newmax |> 
  plot()

plastics <- st_sample(newmax, 3000) |> 
  st_union() |> 
  st_voronoi(envelope = st_geometry(newmax)) |> 
  st_collection_extract() |> 
  st_buffer(dist = -10000) 

ggplot(plastics) +
  geom_sf()

ff <- st_contains_properly(newmax,plastics, sparse = FALSE) |> 
  as.vector()

# Select random chunks
rand <- plastics[ff, ] |> 
  st_as_sf() |> 
  slice_sample(prop = 0.75)

rand$area <- st_area(rand) |> as.double() 

rand$fill <- sample(c("#ff00ec", "#9e00ec"), nrow(rand), replace = TRUE)
rand$fill <- ifelse(rand$area > quantile(rand$area, probs = 0.4),
                    "white",
                    rand$fill)

bbox2 <- st_bbox(rand)
ggplot() +
  # geom_sf(fill = NA) +
  geom_sf(data = rand, aes(fill = fill)) +
  scale_fill_identity() +
  theme(panel.background = element_rect(fill = "#009fdc"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()
  ) +
  labs(title = "New redesign") +
  coord_sf(xlim = c(bbox2[c(1,3)] * 1.8) ,
           ylim = c(bbox2[c(2,4)])*1.4) 
