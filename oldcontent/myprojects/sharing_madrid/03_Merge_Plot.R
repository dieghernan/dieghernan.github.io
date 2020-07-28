# 0. Init----
rm(list = ls())
dev.off()
library(sf)
library(classInt)
library(cartography)
library(dplyr)
library(viridis)

windowsFonts(roboto = windowsFont("Roboto"))
windowsFonts(robotobold = windowsFont("Roboto Bold"))

Barrios = st_read("myprojects/sharing_madrid/assets/Madrid_Barrios.gpkg",
                  stringsAsFactors = FALSE)
Sharing = st_read("myprojects/sharing_madrid/assets/areas_sharing.gpkg",
                  stringsAsFactors = FALSE)
tile = raster::brick("myprojects/sharing_madrid/assets/CartoVoyagerNoLabels.tif")
Highways = st_read("myprojects/sharing_madrid/assets/MadridHighways.gpkg",
                   stringsAsFactors = FALSE) %>%
  st_crop(tile)

CombArea=Sharing %>% subset(provider=="all")
rings= Highways %>% subset(Name %in% c("M30","M40"))
MC=Barrios %>% subset(G_MAreas == "Madrid Central") %>%
  st_union() %>% st_cast("LINESTRING")
MC=st_sf(Name="Madrid Central",geom=MC)
rings=rbind(rings,MC)

# 1. Get coverage----
for (i in 1:nrow(Sharing)) {
  provmap = Sharing[i, ]
  r = st_intersection(provmap, Barrios)
  r$cov = as.double(st_area(r)) / (1000 ^ 2)
  r$percov = round(r$cov / r$G_area_km2, 4)
  Fin = left_join(
    Barrios %>%
      st_drop_geometry() %>%
      select(CODBAR),
    r  %>%
      st_drop_geometry() %>%
      select(CODBAR,
             prov = percov)
  )
  names(Fin) = append("CODBAR",
                      paste("Cov",
                            unique(r$provider),
                            sep = "_"))
  Fin[is.na(Fin)] <- 0
  Barrios = left_join(Barrios, Fin)
  rm(Fin, provmap, r)
}
Barrios$Cov_DistServArea = as.integer(st_distance(st_centroid(Barrios), Sharing[1, ])) /
  1000

st_write(
  Barrios,
  "myprojects/sharing_madrid/assets/Madrid_Barrios_End.gpkg",
  factorsAsCharacter = FALSE,
  layer_options = "OVERWRITE=YES"
)
par(mar = c(1, 1, 1, 1),
    family = windowsFont("roboto"))

#2. Highways Labels----
count = Highways %>% st_cast("MULTIPOINT") %>% st_cast("POINT")
set.seed(12345)
n = count %>% count(Name) %>% st_drop_geometry()
random = runif(nrow(Highways), 0, 1)
n$mid = round(n$n * random, 0)
for (i in 1:nrow(n)) {
  name = as.character(n[i, 1])
  mid = as.numeric(n[i, 3])
  coord = count %>% subset(Name == name)
  coord = coord[mid, ]
  if (i == 1) {
    keep = coord
  } else {
    keep = rbind(keep, coord)
  }
  rm(coord)
}
labels = keep
c = st_geometry(labels) + c(1000, 0)
labels = st_sf(st_drop_geometry(labels), c)
rm(i,mid,name,random,c,count,keep)

#a. G_area----


var = Barrios$G_area_km2
classIntervals(var,
               n = 8,
               style = "kmeans")

varbreaks = as.integer(classIntervals(var,
                                      n = 8,
                                      style = "kmeans")$brks)
univar = cbind(Barrios, var)
varbreaks=c(varbreaks[1:7],  max(varbreaks))


par(mar = c(1, 1, 1, 1),
    family = windowsFont("roboto"))
tilesLayer(tile)
plot(st_geometry(Barrios), col = NA, border = NA,add=T)



choroLayer(
  univar,
  var = "var",
  border = NA,
  breaks = varbreaks,
  col = magma(length(varbreaks), alpha = 0.6, direction = -1),
  legend.pos = "n",
  add = T
)

legendChoro(
  pos = "topleft",
  breaks = paste(varbreaks, "km2", sep = " "),
  title.txt = "",
  #col = getPalette(length(varbreaks)),
  col = magma(length(varbreaks), alpha = 0.6, direction = -1),
  nodata = FALSE,
  border=NA,
)

# plot(st_geometry(Highways),
#      add = T,
#      col = "white",
#      lwd = 3)
# plot(st_geometry(Highways),
#      add = T,
#      col = "#00808080",
#      lwd = 2)
plot(st_geometry(CombArea),add=T,col="#FFFFFF30",lty=3)


layoutLayer(
  title = "Ward's area (km2)",
  col = "#008080",
  scale = 5,
  posscale = "bottomright",
  tabtitle = TRUE,
  sources = "© OpenStreetMap contributors, © CARTO \nPortal de Datos Abiertos de Madrid",
  author = "dieghernan, 2019"
)



#b. City rings----
plot(st_geometry(Barrios), col = NA, border = NA)



typoLayer(
  Barrios,
  var = "G_MAreas",
  legend.title.txt = "",
  legend.pos = "topleft",
  border = NA,
  col = magma(length(unique(Barrios$G_MAreas)), alpha = 0.6,
              direction = -1),
  add = T,
  legend.values.order = c("Madrid Central", "M-30", "M-40"),
  
)

layoutLayer(
  title = "Wards and city rings",
  col = "#008080",
  scale = 5,
  tabtitle = TRUE,
  sources = "Portal de Datos Abiertos de Madrid",
  author = "dieghernan, 2019"
)
par(family = windowsFont("robotobold"))
label
labelLayer(
  labels,
  txt = "Name",
  cex = 0.8,
  col = "#008080",
  show.lines = TRUE,
  overlap = TRUE,
  halo = TRUE
)
plot(st_geometry(Highways),
     add=T,
     col = "white",
     lwd = 3)
plot(st_geometry(Highways),
     add=T,
     col = "#00808080",
     lwd = 2)
plot(st_geometry(CombArea),add=T,col="#FFFFFF30",lty=3)
par(family = windowsFont("roboto"))

#c. Target Population-------
names(Barrios)
var = Barrios$P_TargetPop
max(var)

varbreaks = as.integer(classIntervals(var,
                                      n = 5,
                                      style = "pretty")$brks)
univar=cbind(Barrios,var)


par(mar = c(1, 1, 1, 1),
    family=windowsFont("roboto"))

#tilesLayer(tile)
choroLayer(
  univar,
  var = "var",
  border = NA,
  breaks = varbreaks,
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  legend.pos = "n"
)
legendChoro(
  pos = "topleft",
  breaks = paste(format(varbreaks, nsmall=1, big.mark=","), "pop", sep = " "),
  title.txt = "",
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  nodata = FALSE,
  border=NA,
)


layoutLayer(
  title = "Population between 20 & 69 years (2019/05)",
  col="#008080",
  scale=5,
  tabtitle = TRUE,
  sources = "Portal de Datos Abiertos de Madrid",
  author = "dieghernan, 2019"
)

plot(st_geometry(CombArea),add=T,col="#FFFFFF30",lty=3)

#d. Density----
var = Barrios$D_Density
max(var)
class
varbreaks = as.integer(classIntervals(var,
                                      style = "pretty")$brks)
univar=cbind(Barrios,var)
choroLayer(
  univar,
  var = "var",
  border = NA,
  breaks = varbreaks,
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  legend.pos = "n"
)
legendChoro(
  pos = "topleft",
  breaks = paste(format(varbreaks, nsmall=1, big.mark=","), "pop", sep = " "),
  title.txt = "",
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  nodata = FALSE,
  border=NA,
)
plot(st_geometry(CombArea),add=T,col="#FFFFFF30",lty=3)
layoutLayer(
  title = "Density: Population per km2 (2019/05)",
  col="#008080",
  scale=5,
  tabtitle = TRUE,
  sources = "Portal de Datos Abiertos de Madrid",
  author = "dieghernan, 2019"
)



#e. Foreign rate----
var = Barrios$P_PercForeign
max(var)
classIntervals(var,
               style = "pretty")
varbreaks = as.double(classIntervals(var,
                                      style = "pretty")$brks)
univar=cbind(Barrios,var)
choroLayer(
  univar,
  var = "var",
  border = NA,
  breaks = varbreaks,
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  legend.pos = "n"
)
legendChoro(
  pos = "topleft",
  breaks = paste(as.integer(varbreaks*100), "%", sep = ""),
  title.txt = "",
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  nodata = FALSE,
  border=NA,
)
plot(st_geometry(CombArea),add=T,col="#FFFFFF30",lty=3)
layoutLayer(
  title = "% Foreign born population  (2019/05)",
  col="#008080",
  scale=5,
  tabtitle = TRUE,
  sources = "Portal de Datos Abiertos de Madrid",
  author = "dieghernan, 2019"
)

#f. Wealth----
var = Barrios$W_IncomePerCap
max(var)

classIntervals(var,
               n=40,
               style = "pretty")
varbreaks = as.double(classIntervals(var,
                                     style = "pretty")$brks)


univar=cbind(Barrios,var)
choroLayer(
  univar,
  var = "var",
  border = NA,
  breaks = varbreaks,
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  legend.pos = "n"
)
legendChoro(
  pos = "topleft",
  breaks = paste(format(varbreaks, nsmall=0, big.mark=","), "€", sep = ""),
  title.txt = "",
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  nodata = FALSE,
  border=NA,
)

plot(st_geometry(CombArea),add=T,col="#FFFFFF30",lty=3)
layoutLayer(
  title = "Income per capita  (2015)",
  col="#008080",
  scale=5,
  tabtitle = TRUE,
  sources = "Urban Audit 2015",
  author = "dieghernan, 2019"
)

#g.Crime rate per 1000----
var = Barrios$C_CrimesPer1000
max(var)
classIntervals(var,
               n=10,
               style = "pretty")
varbreaks = unique(as.integer(classIntervals(var,
                                            n=10,
                                     style = "pretty")$brks*10)/10)

univar=cbind(Barrios,var)
choroLayer(
  univar,
  var = "var",
  border = NA,
  breaks = varbreaks,
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  legend.pos = "n"
)
legendChoro(
  pos = "topleft",
  breaks = paste(format(varbreaks, nsmall=0, big.mark=","), "", sep = ""),
  title.txt = "",
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  nodata = FALSE,
  border=NA,
)
plot(st_geometry(CombArea),add=T,col="#FFFFFF30",lty=3)
layoutLayer(
  title = "Crimes per 1,000 (2018)",
  col="#008080",
  scale=5,
  tabtitle = TRUE,
  sources = "Portal de Datos Abiertos de Madrid",
  author = "dieghernan, 2019"
)



#h. House ave. value----

var = Barrios$H_Office2Sup
max(var)
classIntervals(var,
               n=3,
               style = "pretty")

varbreaks = unique(as.integer(classIntervals(var,
                                             n=10,
                                             style = "pretty")$brks*10)/10)

univar=cbind(Barrios,var)
choroLayer(
  univar,
  var = "var",
  border = NA,
  breaks = varbreaks,
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  legend.pos = "n"
)
legendChoro(
  pos = "topleft",
  breaks = paste(format(varbreaks, nsmall=0, big.mark=","), "", sep = ""),
  title.txt = "",
  col = magma(length(varbreaks), alpha = 0.60,
              direction = -1),
  nodata = FALSE,
  border=NA,
)
plot(st_geometry(CombArea),add=T,col="#FFFFFF30",lty=3)

#----

table=Barrios[,c(8,10:25)] %>% st_drop_geometry() 
table=table[,-3] %>% subset(!is.na(H_House2Sup) & !is.na(W_IncomePerCap))
names=table[,1]
table=table[,-1]
corr_raw1=cor(table[,c(1:7,15)],method = (c="spearman"))
corrplot(corr_raw1,col=magma(10,direction = -1),method = "number")
corr_raw2=cor(table[,8:15],method = (c="spearman"))
corrplot(corr_raw2,col=magma(10,direction = -1),method = "number")
corr1=c(corr_raw1[,8],corr_raw2[,8])
corr1

nam=unique(names(subset(corr1,abs(corr1)>0.3 & corr1 < 1)))
nam2=c(nam,"Cov_all")
corrsel=cor(table[,nam2],method = "spearman")
corrplot(corrsel,col=magma(10,direction = -1),method = "number")
tablemodel=table[,nam2]
nam2


for (i in 1:ncol(table)) {
  td = table[, i]
  a = cut(td,
          unique(classIntervals(td, n = 6)$brks),
          labels = FALSE,
          include.lowest = T)
  a = as.data.frame(a)
  names(a) = colnames(table)[i]
  if (i == 1) {
    end = a
  } else {
    end = cbind(end, a)
  }
  rm(a,td)
}
table.cor=cor(end, method = (c="spearman"))
corrplot(table.cor,col=magma(10,direction = -1))
p=table.cor[,ncol(table.cor)]
p2= subset(p,abs(p)>0.3)
end2=end[,names(p2)]
table.cor2=cor(end2, method = (c="spearman"))
corrplot(table.cor2,col=magma(10,direction = -1),method = "number")

library(MASS)
full.model <- lm(Cov_all ~., data = end)
# Stepwise regression model
step.model <- stepAIC(full.model, direction = "backward", 
                      trace = FALSE)
summary(step.model)
step
p2
table.cor2
corrpl
p=table.cor[,ncol(table.cor)]
plot(p)
ncol(table[])
cut
c=classIntervals(table[,15],n=6)$brks
classI
a=cut(table[,15],unique(classIntervals(table[,15],n=6)$brks),labels=FALSE,
      include.lowest=T)

a
unique(classIntervals(table[,15],n=6)$brks)

classIntervals(table[,1])
rank(classIntervals(table[,1])$brks)
table.cor=cor(table, method = (c="spearman"))
corrplot(table.cor,col=magma(10,direction = -1),diag=FALSE)
heatmap(table.cor)
arrios$Cov_all
plot(st_geometry(Barrios), col = "yellow", border = NA, bg = "lightblue1")
# plot isopleth map
discLayer(Barrios,
          df=st_drop_geometry(Barrios),var = "Cov_all",
          nclass=3)

discLayer(
  x = mtq.contig, 
  df = mtq, 
  var = "MED",
  type = "rel", 
  method = "geom", 
  nclass = 3,
  threshold = 0.4,
  sizemin = 0.7, 
  sizemax = 6, 
  col = "red4",
  legend.values.rnd = 1, 
  legend.title.txt = "Relative\nDiscontinuities", 
  legend.pos = "right",
  add = TRUE
)     
           
95, #alpha
sep = "")

typoLayer(BarriosMad,var="G_M30",
          col=palM30,
          legend.title.txt = "",
          legend.pos="topleft",
          legend.values.order = c("IN","OUT"),
          border = "grey90",
          lwd = 1,
          add=T)

choroLayer(
  univar,
  var = "var",
  border = "grey",
  lwd = 2,
  breaks = varbreaks,
  col =  paste(getPalette(length(varbreaks)),
               95, #alpha
               sep = ""),
  legend.pos = "n"
)

#----




ncol(Barrios)

a=c(0,0.1,0.5,1,2,10)

choroLayer(tt,var="dist",
           breaks = a,
           legend.values.rnd = 2,
           col = rev(brewer.pal(min(9,length(a)),"Spectral" ))
)


plot(st_geometry(Sharing[1,]),add=T,col=NA,border="green",lwd=3)

a
plot(global_service)

prov="movo"
r=st_intersection(Sharing %>% subset(provider==prov),Barrios)
r$cov=as.double(st_area(r)) / (1000 ^ 2)
r$percov=round(r$cov/r$G_area_km2,4)
Fin=left_join(Barrios %>%
                st_drop_geometry() %>% 
                select(CODBAR),
              r %>% 
                st_drop_geometry() %>% 
                select(CODBAR,
                       prov=percov)
              )
Fin[is.na(Fin)]<-0
names(Fin) = append("CODBAR",paste("Cov",prov,sep="_"))
Barrios=left_join(Barrios,Fin)
drop()

roun
plot(r)

#Plot and check
abreaks = as.integer(classInt::classIntervals(BarriosMad$G_area_km2,
                                              n = 8,
                                              style = "kmeans")$brks)

getPalette = colorRampPalette(rev(brewer.pal(3, "RdYlBu")))
palarea = paste(getPalette(length(abreaks)),
                60, #alpha
                sep = "")

par(mfrow=c(1,2),mar = c(1, 1, 1, 1))

tilesLayer(tile_import)
choroLayer(
  BarriosMad,
  var = "G_area_km2",
  border = "grey90",
  lwd = 1,
  breaks = abreaks,
  col = palarea,
  legend.pos = "n",
  add = T
)

legendChoro(
  pos = "topleft",
  breaks = paste(abreaks, "km2", sep = " "),
  title.txt = "",
  col = getPalette(length(abreaks)),
  nodata = FALSE
)

layoutLayer(
  title = "Area KM2",
  postitle = "center",
  horiz = FALSE,
  coltitle = "#008080",
  col=NA,
  scale=5,
  posscale = "bottomleft",
  tabtitle = TRUE,
  sources = "Portal de Datos Abiertos de Madrid \n Maps © Thunderforest, Data © OpenStreetMap contributors"
)

# Flag M-30


palM30=paste(getPalette(2),
             60, #alpha
             sep="")

tilesLayer(tile_import)
typoLayer(BarriosMad,var="G_M30",
          col=palM30,
          legend.title.txt = "",
          legend.pos="topleft",
          legend.values.order = c("IN","OUT"),
          border = "grey90",
          lwd = 1,
          add=T)
layoutLayer(
  title = "Area inside M-30 road",
  postitle = "center",
  horiz = FALSE,
  coltitle = "#008080",
  col=NA,
  scale=5,
  posscale = "bottomleft",
  tabtitle = TRUE,
  sources = "Portal de Datos Abiertos de Madrid \n Maps © Thunderforest, Data © OpenStreetMap contributors"
)



#Plot----
par(mfrow=c(2,2),mar = c(1, 1, 1, 1))
#dev.off()

b=unlist(
  classIntervals(BarriosMad$P_TargetPop,n=5,style = "pretty")[["brks"]]
)

choroLayer(BarriosMad,var="P_TargetPop",
           breaks=b,
           col=getPalette(length(b)),
           legend.pos = "topleft")

b=unlist(
  classIntervals(BarriosMad$P_PercForeign,n=6,style = "pretty")[["brks"]]
)

choroLayer(BarriosMad,var="P_PercForeign",
           breaks=b,
           col=getPalette(length(b)),
           legend.values.rnd=2,
           legend.pos = "topleft",
)
b=unlist(
  classIntervals(BarriosMad$W_IncomePerCap,n=5,style = "jenks")[["brks"]]
)
end=b[length(b)]+10000
b=as.integer(append(append(0,b[1:length(b)-1]),end)/1000)*1000


choroLayer(BarriosMad,var="W_IncomePerCap",
           breaks=b,
           col=getPalette(length(b)),
           legend.pos = "topleft")

b=unlist(
  classIntervals(BarriosMad$D_Density,n=6,style = "pretty")[["brks"]]
)
b


choroLayer(BarriosMad,var="D_Density",
           breaks=b,
           col=getPalette(length(b)),
           legend.pos = "topleft")
