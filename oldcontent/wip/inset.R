rm(list = ls())

library(sf)
library(dplyr)
library(rnaturalearth)


world <- ne_countries(scale='medium',returnclass = 'sf')
USA <- subset(world, admin == "United States of America")

# Download file with USA states----
# url <-
#   "https://www2.census.gov/geo/tiger/TIGER2019/STATE/tl_2019_us_state.zip"
# curl_download(url, "trash.zip")
# States.sf = st_read("tl_2019_us_state.shp",
#                     stringsAsFactors = FALSE)



# Plot mainland USA----
par(mar=c(0,0,0,0))
plot(
  st_geometry(USA %>%
                st_transform(2163)),
  xlim = c(-2500000, 2500000),
  ylim = c(-2300000, 730000)
)

plot(
  st_geometry(USA %>%
                st_transform(3467)),
  xlim = c(-2400000, 1600000),
  ylim = c(200000, 2500000)
  )

plot(
  st_geometry(USA %>%
                st_transform(4135)),
  xlim = c(-161, -154),
  ylim = c(18, 23)
)

# Placing inset----
dev.off()
par(mar=c(0,0,0,0))
plot(
  st_geometry(USA %>%
                st_transform(2163)),
  xlim = c(-2500000, 2500000),
  ylim = c(-2300000, 730000)
)
par(fig=c(0.05,0.25,0.05,0.35),
    new = TRUE)
plot(
  st_geometry(USA %>%
                st_transform(3467)),
  xlim = c(-2400000, 1600000),
  ylim = c(200000, 2500000)
)
box(which = "figure", lwd = 1)

par(fig=c(0.27,0.38,0.05,0.23),
    new = TRUE)
plot(
  st_geometry(USA %>%
                st_transform(4135)),
  xlim = c(-161, -154),
  ylim = c(18, 23)
)

box(which = "figure", lwd = 1)

