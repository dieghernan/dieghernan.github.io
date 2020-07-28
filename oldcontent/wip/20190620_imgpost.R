library(png)
library(curl)
library(raster)
library(sf)
library(dplyr)
library(jsonlite)

source("assets/functions/stdh_png2map.R")

df = fromJSON("https://raw.githubusercontent.com/dieghernan/Country-Codes-and-International-Organizations/master/outputs/Countrycodesfull.json")
ISO_memcol = function(df,
                      orgtosearch 
) {
  ind = match(orgtosearch, unlist(df[1, "org_id"]))
  or = lapply(1:nrow(df), function(x)
    unlist(df[x, "org_member"])[ind])
  or = data.frame(matrix(unlist(or)), stringsAsFactors = F)
  names(or) = orgtosearch
  df2 = as.data.frame(cbind(df, or, stringsAsFactors = F))
  return(df2)
}
df_org = ISO_memcol(df, "EU") %>% select(
  CNTR_CODE=NUTS,
  EU) %>% subset(EU=="member")

NUTS1 = st_read(
  "https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/geojson/NUTS_RG_03M_2016_3035_LEVL_1.geojson",
  stringsAsFactors = FALSE
) %>% inner_join(df_org)

noplot=c("FRY","ES7","PT2","PT3")
NUTS1_Clean=NUTS1 %>% subset(!id %in% noplot) %>% 
  group_by(CNTR_CODE) %>% summarise(drop=n()) %>%
  select(-drop)

url="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Flag_of_Europe.svg/800px-Flag_of_Europe.svg.png"

flagcut=stdh_png2map(
  NUTS1_Clean,
  url
)


dirfile = paste(tempdir(), "flag.png", sep = "/")
curl_download(url, dirfile)
flag = brick(readPNG(dirfile) * 255)
extent(flag)<-extent(flagcut)
plotRGB(flag,alpha=150)
plotRGB(flagcut,bgalpha=0,add=T)

