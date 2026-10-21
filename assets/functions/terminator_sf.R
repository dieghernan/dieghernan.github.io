# ADDS A TERMINATOR TO A MAP TO SHOW DAYTIME / NIGHTTIME REGIONS
# Returns a sf object with two polygons and a column identifying if it
# correspond to the day o to the night
# THIS IS A MODIFIED VERSION OF JOE GALLAGHER (https://github.com/JoGall)
# port of the Javascript Leaflet.Terminator plugin
# See https://github.com/JoGall/terminator
# Also see Dominic Roye (https://github.com/dominicroye) post:
# https://dominicroye.github.io/en/2021/visualize-the-day-night-cycle-on-a-world-map/

terminator_sf <- function(time = Sys.Date(), from = -180, to = 180, by = 0.1) {
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("sf package required for using this function")
  }
  if (!requireNamespace("lwgeom", quietly = TRUE)) {
    stop("lwgeom package required for using this function")
  }

  rad2deg <- function(rad) {
    (rad * 180) / (pi)
  }

  deg2rad <- function(deg) {
    (deg * pi) / (180)
  }

  getJulian <- function(time) {
    # get Julian day (number of days since noon on January 1, 4713 BC; 2440587.5 is number of days between Julian epoch and UNIX epoch)
    (as.integer(time) / 86400) + 2440587.5
  }

  getGMST <- function(jDay) {
    # calculate Greenwich Mean Sidereal Time
    d <- jDay - 2451545.0
    (18.697374558 + 24.06570982441908 * d) %% 24
  }

  sunEclipticPosition <- function(jDay) {
    # compute the position of the Sun in ecliptic coordinates
    # days since start of J2000.0
    n <- jDay - 2451545.0
    # mean longitude of the Sun
    L <- 280.460 + 0.9856474 * n
    L <- L %% 360
    # mean anomaly of the Sun
    g <- 357.528 + 0.9856003 * n
    g <- g %% 360
    # ecliptic longitude of Sun
    lambda <- L + 1.915 * sin(deg2rad(g)) + 0.02 * sin(2 * deg2rad(g))
    # distance from Sun in AU
    R <- 1.00014 - 0.01671 * cos(deg2rad(g)) - 0.0014 * cos(2 * deg2rad(g))

    data.frame(lambda, R)
  }

  eclipticObliquity <- function(jDay) {
    # compute ecliptic obliquity
    n <- jDay - 2451545.0
    # Julian centuries since J2000.0
    T <- n / 36525
    # compute epsilon
    23.43929111 -
      T * (46.836769 / 3600
        - T * (0.0001831 / 3600
          + T * (0.00200340 / 3600
            - T * (0.576e-6 / 3600
              - T * 4.34e-8 / 3600))))
  }

  sunEquatorialPosition <- function(sunEclLng, eclObliq) {
    # compute the Sun's equatorial position from its ecliptic position
    alpha <- rad2deg(atan(cos(deg2rad(eclObliq)) *
      tan(deg2rad(sunEclLng))))
    delta <- rad2deg(asin(sin(deg2rad(eclObliq))
    * sin(deg2rad(sunEclLng))))

    lQuadrant <- floor(sunEclLng / 90) * 90
    raQuadrant <- floor(alpha / 90) * 90
    alpha <- alpha + (lQuadrant - raQuadrant)

    data.frame(alpha, delta)
  }

  hourAngle <- function(lng, sunPos, gst) {
    # compute the hour angle of the sun for a longitude on Earth
    lst <- gst + lng / 15
    lst * 15 - sunPos$alpha
  }

  longitude <- function(ha, sunPos) {
    # for a given hour angle and sun position, compute the latitude of the terminator
    rad2deg(atan(-cos(deg2rad(ha)) / tan(deg2rad(sunPos$delta))))
  }


  # calculate latitude and longitude of terminator within specified range using time (in POSIXct format, e.g. `Sys.time()`)
  jDay <- getJulian(time)
  gst <- getGMST(jDay)

  sunEclPos <- sunEclipticPosition(jDay)
  eclObliq <- eclipticObliquity(jDay)
  sunEqPos <- sunEquatorialPosition(sunEclPos$lambda, eclObliq)

  daynight_line <- lapply(seq(from, to, by), function(i) {
    ha <- hourAngle(i, sunEqPos, gst)
    lon <- longitude(ha, sunEqPos)
    data.frame(lat = i, lon)
  })

  # Code added by dieghernan

  daynight_line <- do.call("rbind", daynight_line)

  # Create densified bounding box
  lat_bbox <- seq(from, to, by)
  lon_bbox <- seq(-90, 90, by)

  # Create borders (clockwise from -180, -90)
  l1 <- data.frame(x = rep(from, length(lon_bbox)), y = lon_bbox)
  l1_sf <- sf::st_sfc(sf::st_linestring(as.matrix(l1)))

  l2 <- data.frame(x = lat_bbox, y = rep(90, length(lat_bbox)))
  l2_sf <- sf::st_sfc(sf::st_linestring(as.matrix(l2)))

  l3 <- l1
  l3$x <- to
  l3_sf <- sf::st_sfc(sf::st_linestring(as.matrix(l3)))

  l4 <- l2
  l4$y <- -90
  l4_sf <- sf::st_sfc(sf::st_linestring(as.matrix(l4)))

  bb_pol <- sf::st_union(c(l1_sf, l2_sf, l3_sf, l4_sf))
  bb_pol <- sf::st_cast(sf::st_line_merge(bb_pol), "POLYGON")

  bb_pol <- sf::st_set_crs(bb_pol, 4326)

  # Line to sf
  daynight_line_sf <- sf::st_sfc(sf::st_linestring(as.matrix(daynight_line)))
  daynight_line_sf <- sf::st_set_crs(daynight_line_sf, 4326)


  # Split with lwgeom
  final_polys <- lwgeom::st_split(bb_pol, daynight_line_sf)

  # Get final polygons
  geoms <- sf::st_collection_extract(final_polys, "POLYGON")

  # Identify day/night
  daynight <- c("day", "night")
  if (sunEqPos$delta > 0) daynight <- rev(daynight)

  # Get final pol

  output <- sf::st_sf(day_night = daynight, geometry = geoms)

  output <- output[order(output$day_night), ]

  return(output)
}


# # EXAMPLES
# 
# library(giscoR)
# library(tidyverse)
# 
# # terminator for current time on world map
# term <- terminator_sf(Sys.Date())
# 
# ggplot(gisco_countries) +
#   geom_sf() +
#   geom_sf(data = term, aes(fill = day_night), alpha = 0.3) +
#   scale_fill_manual(values = c("white", "grey10")) +
#   coord_sf(expand = FALSE)
# 
# 
# # add terminator at a specific time to map of Europe
# term2 <- terminator_sf(
#   time = as.POSIXct("2018-01-01 07:00:00 GMT"),
#   from = -12, to = 35
# )
# 
# 
# ggplot(gisco_countries) +
#   geom_sf() +
#   geom_sf(data = term2, aes(fill = day_night), alpha = 0.3) +
#   scale_fill_manual(values = c("white", "grey10")) +
#   coord_sf(expand = FALSE, xlim = c(-12, 35), ylim = c(35, 72))
# 
# 
# # With projections
# ggplot(giscoR::gisco_countries) +
#   geom_sf() +
#   geom_sf(
#     data = terminator_sf(as.POSIXct("2018-12-21 17:40:01 PDT")),
#     aes(fill = day_night), alpha = 0.3
#   ) +
#   scale_fill_manual(values = c("white", "grey10")) +
#   coord_sf(crs = "+proj=robin")
#   