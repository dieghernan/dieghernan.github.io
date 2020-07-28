# https://stackoverflow.com/questions/59208954/how-to-obtain-hexagonal-type-sample-from-st-sample-r-package-sf

rm(list = ls())

library(sf)
nc <- st_read(system.file("shape/nc.shp", package = "sf"))

# Hexagonal grid
nc_samples_hexagonal = st_make_grid(nc[1,],
                                    what = "corners",
                                    square = F,
                                    n = 20)

# Extra: Shrink original shape to 95% to erase dots close to the edge
polys = st_geometry(st_cast(nc[1,] , "POLYGON"))
cntrd = st_geometry(st_centroid(polys))
polyred = (polys - cntrd)  * 0.95 + cntrd
st_crs(polyred) <- st_crs(nc[1,])
nc_samples_hexagonal = nc_samples_hexagonal[st_contains(polyred,  nc_samples_hexagonal, sparse = F)]
png("/cloud/project/assets/figs/hexgridsample.png")
par(mar=c(0,0,0,0))
plot(st_geometry(nc[1,]))
plot(st_geometry(nc_samples_hexagonal) , add = T)
dev.off()


