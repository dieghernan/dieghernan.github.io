
#Easter egg
world=ne_countries(50,returnclass = "sf") %>% 
  st_transform("+proj=eqc") %>% #  Plate Carre
  subset(adm0_a3 != "ATA") # Delete Antarctica

pixworld=stdh_gridpol(world,to="pixel",gridsize = 300*1000)
par(mar=c(0,0,0,0))
bbox=st_bbox(pixworld) %>% st_as_sfc() 
rat=st_graticule(pixworld)
plot(st_geometry(bbox),col="#505050", border = "#505050")
plot(st_geometry(rat),add=T, col="#6e6e6e")
plot(st_geometry(pixworld),col="#1fc2ff", border="#505050" ,add=T)

