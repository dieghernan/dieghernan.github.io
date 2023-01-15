---
title: "Star Map with R"
subtitle: 'Creating Star Map Visualizations Based on Location and Date'
tags:
- r_bloggers
- rstats
- rspatial
- maps
- ggplot2
- s2
- astronomy
output:
  html_document:
  md_document:
    variant: gfm
    preserve_yaml: yes
header_img: xxx.png
---



Intro...

## Libraries

On this post we would use the following libraries:


```r
## Libraries

# Spatial manipulation
library(sf)
library(s2)
library(nominatimlite)

## Wrange data and dates
library(dplyr)
library(lubridate)
library(lutz)

## Visualization
library(ggplot2)
library(ggfx)
library(ggshadow)
```

## Helper funs


```r

autoplot_sf <- function(x, ...) {
  ggplot(x) +
    geom_sf(...)
}

# Derive rotation degrees of the projection given a date and a longitude
mst_rot <- function(datetime, lon) {
  # Convert datetime to UTC datetime using Meeus
  # See https://squarewidget.com/julian-day/
  desired_date_utc <- with_tz(datetime, "UTC")


  yr <- year(desired_date_utc)
  mo <- month(desired_date_utc)
  dy <- day(desired_date_utc)
  h <- hour(desired_date_utc)
  m <- minute(desired_date_utc)
  s <- second(desired_date_utc)

  if ((mo == 1) || (mo == 2)) {
    yr <- yr - 1
    mo <- mo + 12
  }

  # Adjust times before Gregorian Calendar
  if (as_date(datetime) > as.Date("1582-10-14")) {
    a <- floor(yr / 100)
    b <- 2 - a + floor(a / 4)
  } else {
    b <- 0
  }
  c <- floor(365.25 * yr)
  d <- floor(30.6001 * (mo + 1))


  # days since J2000.0
  jd_r <- b + c + d - 730550.5 + dy + (h + m / 60.0 + s / 3600.0) / 24.0
  t <- jd_r / 36525

  # Rotation
  mst <- 280.46061837 + 360.98564736629 * jd_r +
    0.000387933 * t^2 - t^3 / 38710000.0 + lon

  # Modulo 360 degrees
  lon_prj <- mst %% 360

  return(lon_prj)
}

# Cut a sf object with a buffer using spherical s2 geoms
# Optionally, project and flip

sf_spherical_cut <- function(x, the_buff, the_crs = st_crs(x), flip = NULL) {
  # Keep df
  the_df <- st_drop_geometry(x)
  the_geom <- st_geometry(x)

  the_cut <- the_geom %>%
    st_as_s2() %>%
    s2_intersection(the_buff) %>%
    st_as_sfc() %>%
    st_sf(the_df, geometry = .) %>%
    filter(!st_is_empty(.)) %>%
    st_transform(crs = the_crs) %>%
    filter(!st_is_empty(.))

  if (!is.null(flip)) {
    the_cut <- the_cut %>%
      mutate(geometry = geometry * flip) %>%
      st_set_crs(the_crs)
  }

  return(the_cut)
}
```

## Inputs


```r

desired_place <- "Madrid, Spain"
desired_date <- make_datetime(
  year = 2019,
  month = 6,
  day = 1,
  hour = 20,
  min = 38
)


# Geocode place
desired_place_geo <- geo_lite(desired_place, full_results = TRUE)

desired_place_geo %>%
  select(address, lat, lon)
#> # A tibble: 1 × 3
#>   address                                                                                    lat   lon
#>   <chr>                                                                                    <dbl> <dbl>
#> 1 Madrid, Área metropolitana de Madrid y Corredor del Henares, Comunidad de Madrid, España  40.4 -3.70

# And get the coordinates
desired_loc <- desired_place_geo %>%
  select(lat, lon) %>%
  unlist()

desired_loc
#>       lat       lon 
#> 40.416705 -3.703582
```


```r

# Get tz
get_tz <- tz_lookup_coords(desired_loc[1], desired_loc[2], warn = FALSE)

get_tz
#> [1] "Europe/Madrid"

# Force it to be local time
desired_date_tz <- force_tz(desired_date, get_tz)

desired_date_tz
#> [1] "2019-06-01 20:38:00 CEST"
```


```r
# Get the rotation and prepare buffer and projection

lon_prj <- mst_rot(desired_date_tz, desired_loc[2])
lat_prj <- desired_loc[1]

c(lon_prj, lat_prj)
#>      lon      lat 
#> 165.7549  40.4167

# Create proj4string w/ Airy projection

target_crs <- paste0("+proj=airy +x_0=0 +y_0=0 +lon_0=", lon_prj, " +lat_0=", lat_prj)

# We need to flip celestial objects
# Flip matrix
flip_matrix <- matrix(c(-1, 0, 0, 1), 2, 2)


# And create an s2 buffer of the visible hemisphere on the given location
hemisphere_s2 <- s2_buffer_cells(as_s2_geography(paste0("POINT(", lon_prj, " ", lat_prj, ")")),
  9800000,
  max_cells = 5000
)

# This one is for plotting
hemisphere_sf <- hemisphere_s2 %>%
  st_as_sf() %>%
  st_transform(crs = target_crs) %>%
  st_cast("LINESTRING") %>%
  st_make_valid()
```

## Celestial data

### Constellations


```r

url <- "https://raw.githubusercontent.com/ofrohn/d3-celestial/master/data/constellations.lines.json"
basefile <- basename(url)

local_path <- here::here("assets", "data", basefile)

if (!file.exists(local_path)) {
  download.file(url, local_path, mode = "wb", quiet = TRUE)
}


const_init <- st_read(local_path, quiet = TRUE)

# Cut to buffer
const_cut <- sf_spherical_cut(const_init,
  the_buff = hemisphere_s2,
  the_crs = 4326,
  flip = flip_matrix
)

const_end <- sf_spherical_cut(const_init,
  the_buff = hemisphere_s2,
  # Change the crs
  the_crs = target_crs,
  flip = flip_matrix
)


const_init %>%
  st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180")) %>%
  autoplot_sf()

const_cut %>%
  st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180")) %>%
  autoplot_sf()

const_end %>% autoplot_sf()
```

<img src="https://dieghernan.github.io/assets/img/drafts/xxx_constellations-1.png" alt="plot of chunk xxx_constellations" width="33%" /><img src="https://dieghernan.github.io/assets/img/drafts/xxx_constellations-2.png" alt="plot of chunk xxx_constellations" width="33%" /><img src="https://dieghernan.github.io/assets/img/drafts/xxx_constellations-3.png" alt="plot of chunk xxx_constellations" width="33%" />

### Stars


```r

url <- "https://raw.githubusercontent.com/ofrohn/d3-celestial/master/data/stars.6.json"
basefile <- basename(url)

local_path <- here::here("assets", "data", basefile)

if (!file.exists(local_path)) {
  download.file(url, local_path, mode = "wb", quiet = TRUE)
}


stars_init <- st_read(local_path, quiet = TRUE)

# Adjust Brightness relative to mag = 0
stars_init$rel_bright <- (100^(-1 * stars_init$mag / 5))

# Cut to buffer
stars_cut <- sf_spherical_cut(stars_init,
  the_buff = hemisphere_s2,
  the_crs = 4326,
  flip = flip_matrix
)

stars_end <- sf_spherical_cut(stars_init,
  the_buff = hemisphere_s2,
  # Change the crs
  the_crs = target_crs,
  flip = flip_matrix
)


stars_init %>%
  st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180")) %>%
  autoplot_sf()

stars_cut %>%
  st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180")) %>%
  autoplot_sf()

stars_end %>% autoplot_sf()
```

<img src="https://dieghernan.github.io/assets/img/drafts/xxx_stars-1.png" alt="plot of chunk xxx_stars" width="33%" /><img src="https://dieghernan.github.io/assets/img/drafts/xxx_stars-2.png" alt="plot of chunk xxx_stars" width="33%" /><img src="https://dieghernan.github.io/assets/img/drafts/xxx_stars-3.png" alt="plot of chunk xxx_stars" width="33%" />

### The Milky Way


```r

url <- "https://raw.githubusercontent.com/dieghernan/dieghernan.github.io/master/assets/data/milkyway_R.json"
basefile <- basename(url)

local_path <- here::here("assets", "data", basefile)

if (!file.exists(local_path)) {
  download.file(url, local_path, mode = "wb", quiet = TRUE)
}


mw_init <- st_read(local_path, quiet = TRUE)

# Add colors to MW to use on fill
cols <- colorRampPalette(c("white", "yellow"))(5)
mw_init$fill <- factor(cols, levels = cols)

# Cut to buffer
mw_cut <- sf_spherical_cut(mw_init,
  the_buff = hemisphere_s2,
  the_crs = 4326,
  flip = flip_matrix
)

mw_end <- sf_spherical_cut(mw_init,
  the_buff = hemisphere_s2,
  # Change the crs
  the_crs = target_crs,
  flip = flip_matrix
)


mw_init %>%
  st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180")) %>%
  autoplot_sf()

mw_cut %>%
  st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180")) %>%
  autoplot_sf()

mw_end %>% autoplot_sf()
```

<img src="https://dieghernan.github.io/assets/img/drafts/xxx_mw-1.png" alt="plot of chunk xxx_mw" width="33%" /><img src="https://dieghernan.github.io/assets/img/drafts/xxx_mw-2.png" alt="plot of chunk xxx_mw" width="33%" /><img src="https://dieghernan.github.io/assets/img/drafts/xxx_mw-3.png" alt="plot of chunk xxx_mw" width="33%" />

### Graticules


```r

grat_init <- st_graticule(
  ndiscr = 5000,
  lat = seq(-90, 90, 10),
  lon = seq(-180, 180, 30)
)

# Cut to buffer, we dont flip this one (it is not an object of the space)
grat_cut <- sf_spherical_cut(grat_init,
  the_buff = hemisphere_s2,
  the_crs = 4326
)

grat_end <- sf_spherical_cut(grat_init,
  the_buff = hemisphere_s2,
  # Change the crs
  the_crs = target_crs
)


grat_init %>%
  st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180")) %>%
  autoplot_sf()

grat_cut %>%
  st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180")) %>%
  autoplot_sf()

grat_end %>% autoplot_sf()
```

<img src="https://dieghernan.github.io/assets/img/drafts/xxx_grat-1.png" alt="plot of chunk xxx_grat" width="33%" /><img src="https://dieghernan.github.io/assets/img/drafts/xxx_grat-2.png" alt="plot of chunk xxx_grat" width="33%" /><img src="https://dieghernan.github.io/assets/img/drafts/xxx_grat-3.png" alt="plot of chunk xxx_grat" width="33%" />

## Final plot (with special effects)


```r


const_end_lines <- const_end %>%
  st_cast("MULTILINESTRING") %>%
  st_coordinates() %>%
  as.data.frame()


ggplot() +
  geom_sf(data = grat_end, color = "grey60", linewidth = 0.25) +
  with_blur(
    geom_sf(
      data = mw_end, aes(fill = fill),
      alpha = 0.1, color = NA,
      show.legend = FALSE
    ),
    sigma = 8
  ) +
  scale_fill_identity() +
  geom_glowpoint(
    data = stars_end, aes(
      alpha = rel_bright,
      size = rel_bright,
      geometry = geometry
    ),
    color = "white", show.legend = FALSE,
    stat = "sf_coordinates"
  ) +
  geom_sf(
    data = const_end,
    linewidth = 0.5, color = "white"
  ) +
  geom_glowpath(
    data = const_end_lines, aes(X, Y,
      group = interaction(L1, L2)
    ),
    color = "white",
    size = 0.01,
    alpha = 0.001,
    shadowsize = 0.4,
    shadowalpha = 0.01,
    shadowcolor = "white",
    linejoin = "round",
    lineend = "round"
  ) +
  geom_sf(
    data = hemisphere_sf,
    color = "white", linewidth = 1
  ) +
  # Scales
  scale_size_continuous(range = c(0.05, 0.75)) +
  # scale_sha
  scale_alpha_continuous(range = c(0.1, 0.5)) +
  theme_void() +
  theme(
    text = element_text(colour = "white"),
    panel.border = element_blank(),
    plot.background = element_rect(fill = "#191d29", color = "#191d29"),
    plot.margin = margin(20, 20, 20, 20)
  )
```

<img src="https://dieghernan.github.io/assets/img/drafts/xxx_final-1.png" alt="plot of chunk xxx_final" width="100%" />
