# Initial----
rm(list = ls())
library(sp)
library(sf)
library(dplyr)
library(openxlsx)
library(cartography)
library(scales)

# Load Maps----
Counties.sf = st_read("~/R/mapslib/GADM36/gadm36_USA.gpkg",
                      stringsAsFactors = FALSE) %>%
  st_transform(2163)

States.sf = readRDS("~/R/mapslib/GADM36/gadm36_USA_1_sf.rds") %>%
  st_as_sf() %>%
  st_transform(2163)

World.sf = st_read("~/R/mapslib/EUROSTAT/CNTR_RG_03M_2016_3857.geojson",
                   stringsAsFactors = FALSE) %>%
  st_transform(2163)

Wbody = Counties.sf %>% filter(ENGTYPE_2 == "Water body")

Wbody = Wbody %>% group_by(GID_0) %>%
  summarise(dummy = 1)

plot(st_geometry(Wbody))

Counties.sf = Counties.sf %>% filter(ENGTYPE_2 != "Water body")


# Load excel----
df = read.xlsx("dfGADM_Clean.xlsx")
summary = df %>%
  filter(!is.na(ETYM)) %>%
  group_by(ETYM) %>%
  summarise(n = n()) %>%
  arrange(desc(n))


summary$LANGEND = ifelse(summary$n < 8 & summary$ETYM != "Hawaiian",
                         NA,
                         summary$ETYM)
summary = summary[!is.na(summary$LANGEND),]

df = left_join(df, summary)
df$ETYM = df$LANGEND
unique(df$ETYM)

Counties.sf = left_join(Counties.sf, df)

# Plot map----
order <- unique(arrange(summary, desc(n))
                %>%
                  select(LANGEND))

arraycols = c("#4daf4a",
              "#e41a1c",
              "#377eb8",
              "black",
              "#ff7f00",
              "#a65628",
              "#984ea3")

svg(
  "USACountyEtym.svg",
  pointsize = 90,
  width = 900 / 90,
  height = 510 / 90,
  bg = "#C6ECFF"
)

par(mar = c(0, 0, 0, 0))
plot(
  st_geometry(World.sf),
  col = "#F6E1B9",
  border = "#646464",
  bg = "#C6ECFF",
  xlim = c(-2500000, 2500000),
  ylim = c(-2300000, 730000),
)

typoLayer(
  Counties.sf ,
  var = "ETYM",
  border = "grey10",
  lwd = 0.15,
  legend.pos = "n",
  col = alpha(arraycols, 0.8),
  legend.values.order = order$LANGEND,
  colNA = "#FDFBEA",
  add = T
)
legendTypo(
  title.txt = "",
  values.cex = 0.15,
  col = alpha(arraycols, 0.8),
  categ = order$LANGEND,
  nodata = F
)

plot(st_geometry(Wbody),
     col = "#C6ECFF",
     border = "#0978AB",
     add = T)
plot(
  st_geometry(States.sf),
  add = T,
  border = "#656565",
  col = NA,
  lwd = 0.3,
)
# Alaska
marseq = rep(0, 4)
par(fig = c(0.01, 0.27, 0.01, 0.31),
    mar = marseq,
    new = TRUE)
CRSInset = 3467
INSETMAP = Counties.sf %>% st_transform(CRSInset)
INSETWORLD = World.sf %>% st_transform(CRSInset)
INSETSTATES = States.sf %>% st_transform(CRSInset)
plot(
  st_geometry(INSETWORLD),
  col = "#F6E1B9",
  border = "#646464",
  bg = "#C6ECFF",
  xlim = c(-2200000, 1500000),
  ylim = c(400000 ,
           2400000)
)
typoLayer(
  INSETMAP ,
  var = "ETYM",
  border = "grey10",
  lwd = 0.15,
  legend.pos = "n",
  col = alpha(arraycols, 0.8),
  legend.values.order = order$LANGEND,
  colNA = "#FDFBEA",
  add = T
)
plot(
  st_geometry(INSETSTATES),
  add = T,
  border = "#656565",
  col = NA,
  lwd = 0.3,
)
box(which = "figure", lwd = 1)

# Hawaii
marseq = rep(0, 4)
par(fig = c(0.28, 0.43, 0.01, 0.17),
    mar = marseq,
    new = TRUE)
CRSInset = 4135
INSETMAP = Counties.sf %>% st_transform(CRSInset)
INSETWORLD = World.sf %>% st_transform(CRSInset)
INSETSTATES = States.sf %>% st_transform(CRSInset)
plot(
  st_geometry(INSETMAP),
  col = "#F6E1B9",
  border = "#646464",
  bg = "#C6ECFF",
  xlim = c(-161, -154),
  ylim = c(18, 23)
)
typoLayer(
  INSETMAP ,
  var = "ETYM",
  border = "grey10",
  lwd = 0.15,
  legend.pos = "n",
  col = alpha(arraycols, 0.8),
  legend.values.order = order$LANGEND,
  colNA = "#FDFBEA",
  add = T
)
plot(
  st_geometry(INSETSTATES),
  add = T,
  border = "#656565",
  col = NA,
  lwd = 0.3,
)
box(which = "figure", lwd = 1)
dev.off()




#legacy----


# png(
#   "USACountyEtym.png",
#   width = 950,
#   height = 650,
#   bg = "#C7E7FB",
#   res=72*2
# )

dev.off()
svg(
  "USACountyEtym.svg",
  pointsize = 150,
  width = 1500 / 150,
  height = 850 / 150,
  bg = "#C6ECFF"
)

par(mar = c(0, 0, 0, 0))
plot(
  st_geometry(world.sf),
  col = "#F6E1B9",
  border = NA,
  bg = "#C6ECFF",
  xlim = c(-2500000, 2500000),
  ylim = c(-2300000, 730000),
)


typoLayer(
  CountySimp.sf ,
  var = "ETYM",
  border = "grey10",
  lwd = 0.15,
  legend.pos = "n",
  col = alpha(arraycols, 0.8),
  legend.values.order = order$LANGEND,
  colNA = "#FDFBEA",
  add = T
)

legendTypo(
  title.txt = "",
  values.cex = 0.08,
  col = alpha(arraycols, 0.8),
  categ = order$LANGEND,
  nodata = F
)

plot(
  st_geometry(StatesSimp.sf),
  add = T,
  border = "#656565",
  col = NA,
  lwd = 0.3,
)
box(which = "figure", lwd = 1)
dev.off()


#INSET - ALASKA----

marseq = rep(0, 4)
par(fig = c(0.01, 0.35, 0.01, 0.25),
    mar = marseq,
    new = TRUE)
CRSInset = 3467
INSETMAP = CountySimp.sf %>% st_transform(CRSInset)
INSETWORLD = world.sf %>% st_transform(CRSInset)
INSETCOUNTY = StatesSimp.sf %>% st_transform(CRSInset)


plot(
  st_geometry(INSETWORLD),
  col = "#DFDFDF",
  lwd = 0.1,
  bg = "#C7E7FB",
  xlim = c(-2200000, 1500000),
  ylim = c(400000 ,
           2400000)
)

typoLayer(
  INSETMAP,
  var = "ETYM",
  border = "grey0",
  lwd = 0.2,
  col = alpha(arraycols, 0.75),
  legend.values.order = order$LANGEND,
  legend.pos = "n",
  colNA = "#FDFBEA",
  add = T
)
plot(
  st_geometry(INSETCOUNTY),
  add = T,
  border = "#656565",
  col = NA,
  lwd = 0.3,
)
box(which = "figure", lwd = 1)

#INSET - HAWAI
par(fig = c(0.355
            , 0.5, 0.01, 0.15),
    mar = marseq,
    new = TRUE)
CRSInset = 4135
INSETMAP = CountySimp.sf %>% st_transform(CRSInset)
INSETWORLD = world.sf %>% st_transform(CRSInset)
INSETCOUNTY = StatesSimp.sf %>% st_transform(CRSInset)
plot(
  st_geometry(INSETWORLD),
  col = "#DFDFDF",
  lwd = 0.1,
  bg = "#C7E7FB",
  xlim = c(-161, -154),
  ylim = c(18, 23)
)
typoLayer(
  INSETMAP,
  var = "ETYM",
  col = alpha(arraycols, 0.75),
  legend.values.order = order$LANGEND,
  border = "grey50",
  lwd = 0.2,
  legend.pos = "n",
  colNA = "#FDFBEA",
  add = T
)
plot(
  st_geometry(INSETCOUNTY),
  add = T,
  border = "#656565",
  col = NA,
  lwd = 0.3,
)
box(which = "figure", lwd = 1)
dev.off()
