stdh_png2map <- function(sf, png, align = "center") {
  shp <- sf
  if (file.exists(png)) {
    flag = brick(readPNG(png) * 255)
  } else {
    dirfile = paste(tempdir(), "flag.png", sep = "/")
    curl_download(png, dirfile)
    flag = brick(readPNG(dirfile) * 255)
  }
  if (!align %in% c("left", "right", "center")) {
    stop("align should be 'left','right' or 'center'")
  }
  #Geotagging the raster
  #Adding proj4string
  projection(flag) <- CRS(st_crs(shp)[["proj4string"]])
  #Now cover with the flag the whole extent of the shape
  ratioflag = dim(flag)[2] / dim(flag)[1]
  
  #Middle point
  extshp = extent(shp)
  w = (extshp@xmax - extshp@xmin) / 2
  h = (extshp@ymax - extshp@ymin) / 2
  w_mp = extshp@xmin + w
  h_mp = extshp@ymin + h
  # Depending of the shape the fitting could be in height or width
  if (w > h * ratioflag) {
    new_ext = c(extshp@xmin,
                extshp@xmax,
                h_mp - w / ratioflag,
                h_mp + w / ratioflag)
  } else {
    if (align == "center") {
      new_ext = c(w_mp - h * ratioflag,
                  w_mp + h * ratioflag,
                  extshp@ymin,
                  extshp@ymax)
    }   else if (align == "left") {
      new_ext = c(extshp@xmin,
                  extshp@xmin + 2 * h * ratioflag,
                  extshp@ymin,
                  extshp@ymax)
    }   else {
      new_ext = c(extshp@xmax - 2 * h * ratioflag,
                  extshp@xmax ,
                  extshp@ymin,
                  extshp@ymax)
    }
    
  }
  extent(flag) <- new_ext
  # Mask
  fig = mask(flag, shp)
  return(fig)
}