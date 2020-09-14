
# A. Helper functions----
# a.1 legpos - copied from https://github.com/riatelab/cartography/blob/master/R/legends.R----
# Note: this dependence could be removed in the case of integration with the cartography package
legpos <- function(pos,
                   x1,
                   x2,
                   y1,
                   y2,
                   delta1,
                   delta2,
                   legend_xsize,
                   legend_ysize) {
  # Position
  if (length(pos) == 2) {
    return(list(xref = pos[1], yref = pos[2]))
  }
  if (pos == "bottomleft") {
    xref <- x1 + delta1
    yref <- y1 + delta1
  }
  if (pos == "bottomleftextra") {
    xref <- x1 + delta1
    yref <-
      y1 + delta1 + graphics::strheight(s = "hp\nhp", cex = 0.6, font = 3)
  }
  if (pos == "topleft") {
    xref <- x1 + delta1
    yref <- y2 - 2 * delta1 - legend_ysize
  }
  if (pos == "topright") {
    xref <- x2 - 2 * delta1 - legend_xsize
    yref <- y2 - 2 * delta1 - legend_ysize
  }
  if (pos == "bottomright") {
    xref <- x2 - 2 * delta1 - legend_xsize
    yref <- y1 + delta1
  }
  if (pos == "left") {
    xref <- x1 + delta1
    yref <- (y1 + y2) / 2 - legend_ysize / 2 - delta2
  }
  if (pos == "right") {
    xref <- x2 - 2 * delta1 - legend_xsize
    yref <- (y1 + y2) / 2 - legend_ysize / 2 - delta2
  }
  if (pos == "top") {
    xref <- (x1 + x2) / 2 - legend_xsize / 2
    yref <- y2 - 2 * delta1 - legend_ysize
  }
  if (pos == "bottom") {
    xref <- (x1 + x2) / 2 - legend_xsize / 2
    yref <- y1 + delta1
  }
  if (pos == "center") {
    xref <- (x1 + x2) / 2 - legend_xsize / 2
    yref <- (y1 + y2) / 2 - legend_ysize / 2 - delta2
  }
  return(list(xref = xref, yref = yref))
}

# a.2 checkpatterLayer - validity check for inputs on patternLayer----

checkpatterLayer <- function(x, mode, pattern) {
  if (length(sf::st_geometry(x)) == 0) {
    stop("No layer added, Check input object")
  }
  todot = c("dot", "text")
  tolines = c("diamond","grid","hexagon",
              "horizontal", "vertical","zigzag",
              "left2right","right2left","circle")
  
  if (!unique(sf::st_geometry_type(x)) %in% c("POLYGON", "MULTIPOLYGON")) {
    stop("Input should be  MULTIPOLYGON or POLYGON")
  }
  
  if (!mode %in% c("plot", "legend", "sfc")) {
    stop("mode should be  'plot' or 'sfc'")
  }
  
  
  if (!pattern %in% c(todot, tolines)) {
    stop(
      paste("Patterns available are",
            gsub(",",
                 ", ",
                 paste(c(todot,tolines),sep = "", collapse = ",")
            ),
            sep = " "
      )
    )
  }
}

# B. Final functions - to be exported----
# patternLayer #
patternLayer = function(x,
                        pattern = "dot",
                        density = 1,
                        txt = "a",
                        ...) {
  options(warn = -1)
  # Assign default options #
  dots = list(...)
  mode = ifelse(is.null(dots$mode), "plot", dots$mode)
  col = ifelse(is.null(dots$col), par()$col, dots$col)
  bg = ifelse(is.null(dots$bg), par()$bg, dots$bg)
  pch = ifelse(is.null(dots$pch), par()$pch, dots$pch)
  lty = ifelse(is.null(dots$lty), par()$lty, dots$lty)
  cex = ifelse(is.null(dots$cex), par()$cex, dots$cex)
  lwd = ifelse(is.null(dots$lwd), par()$lwd, dots$lwd)
  add = ifelse(is.null(dots$add), F, dots$add)
  # End defaults #
  
  # Crop to device when adding the layer #
  if (mode != "legend" & add == T) {
    devplot = par()$usr
    devplot <- devplot[c(1, 3, 2, 4)]
    class(devplot) <- "bbox"
    x = sf::st_crop(x, devplot)
  }
  # End crop #
  
  # Check inputs #
  checkpatterLayer(x, mode, pattern)
  # End check
  
  todot = c("dot", "text")
  tolines = c("diamond","grid","hexagon",
              "horizontal", "vertical","zigzag",
              "left2right","right2left","circle")
  
  
  # Dimensions #
  # by default 10 cells on the shortest dimensions #
  dist = min(diff(sf::st_bbox(x)[c(1, 3)]),
             diff(sf::st_bbox(x)[c(2, 4)])
  ) / (10 * density)
  
  # Superseed if cellsize option provided #
  dist = ifelse(is.null(dots$cellsize), dist, dots$cellsize)
  
  # Prepare to grid #
  if (pattern %in% c("dot", "text")) {
    ops = list(cellsize = dist ,
               what = "corners",
               square = F
    )
  } else {
    tops <- pattern != "hexagon"
    ops = list(cellsize = dist ,
               what = "polygons", 
               square = tops)
  }
  if (mode == "legend") {
    fillgrid = sf::st_make_grid(x,
                                n = c(3, 3),
                                what = ops[2],
                                square = as.logical(ops[3])
    )
  } else {
    fillgrid = sf::st_make_grid(x,
                                cellsize = as.numeric(ops[1]),
                                what = ops[2],
                                square = as.logical(ops[3])
    )
  }
  # Grid created #
  
  # Create patterns #
  # 1. circle #
  if (pattern == "circle") {
    x = sf::st_union(x)
    centr = sf::st_centroid(sf::st_geometry(x),
                            of_largest_polygon = T)
    rad = min(diff(sf::st_bbox(x)[c(1, 3)]),
              diff(sf::st_bbox(x)[c(2, 4)]))
    # by default 21 circles would be created.
    # if cellsize provided the number of circles would be adjusted
    if (mode == "legend") {
      ntimes = 3
    } else if (is.null(dots$cellsize)) {
      ntimes = as.integer(20 * density) + 1
    } else {
      ntimes = as.integer(rad / dots$cellsize) + 1
    }
    seg = rad / ntimes
    # Initial circle #
    lp = sf::st_buffer(centr, seg / 8)
    lp = sf::st_cast(lp , "LINESTRING")
    
    for (i in 1:ntimes) {
      join = sf::st_buffer(centr, dist = seg * i)
      join = sf::st_cast(join, "LINESTRING")
      lp = sf::st_union(lp, join)
    }
    endsf =  sf::st_intersection(lp, x)
  } else if (pattern %in% c("dot", "text")) {
    # 2. dot and text #
    polys = sf::st_union(x) 
    polys = sf::st_cast(polys,"POLYGON")
    cntrd = sf::st_geometry(sf::st_centroid(polys))
    polys = sf::st_geometry(polys)
    polyred = (polys - cntrd)  * 0.95 + cntrd
    sf::st_crs(polyred) <- sf::st_crs(x)
    polyred = sf::st_union(polyred)
    endsf = fillgrid[sf::st_contains(polyred,
                                     fillgrid, 
                                     sparse = F
    )
    ]
    
    if (pattern == "text") {
      endsf = sf::st_sf(txt = txt, geometry = endsf)
    } else {
      endsf = sf::st_union(endsf)
    }
  } else if (pattern %in% c("grid", "hexagon")) {
    # 3. grid and hexagon #
    endsf = sf::st_cast(fillgrid, "LINESTRING")
    endsf = sf::st_intersection(endsf, x)
    endsf = endsf[sf::st_geometry_type(endsf)
                  %in% c("LINESTRING", "MULTILINESTRING")
    ]
    endsf = sf::st_line_merge(sf::st_union(endsf))
  } else if (!pattern %in% c("zigzag", "diamond")) {
    # 4. rest except zigzag and diamonds #
    ex = list( horizontal = c(1, 2),
               vertical = c(1, 4),
               left2right = c(2, 4),
               right2left = c(1, 3)
    )
    endsf = lapply(1:length(fillgrid), function(j)
      sf::st_linestring(
        sf::st_coordinates(
          fillgrid[j])[ex[[pattern]], 1:2]
      )
    )
    endsf = sf::st_sfc(endsf, crs = sf::st_crs(x)) 
    endsf = sf::st_intersection(endsf,x)
    endsf = endsf[sf::st_geometry_type(endsf)
                  %in% c("LINESTRING", "MULTILINESTRING")
    ]
    endsf = sf::st_line_merge(sf::st_union(endsf))
  } else {
    # 5. zigzag and diamonds #
    l2r = lapply(1:length(fillgrid), function(j)
      sf::st_linestring(
        sf::st_coordinates(fillgrid[j])[c(2, 4), 1:2])
    )
    l2r = sf::st_sfc(l2r, crs = sf::st_crs(x))
    r2l = lapply(1:length(fillgrid), function(j)
      sf::st_linestring(
        sf::st_coordinates(fillgrid[j])[c(1, 3), 1:2])
    )
    r2l = sf::st_sfc(r2l, crs = sf::st_crs(x))
    
    if (pattern == "diamond") {
      l2r = sf::st_line_merge(sf::st_union(l2r))
      r2l = sf::st_line_merge(sf::st_union(r2l))
      endsf = sf::st_union(l2r,
                           r2l
      )
    } else {
      if (mode == "legend") {
        nrows = 3
        ncols = 3
      } else {
        ncols = as.integer(
          diff(sf::st_bbox(fillgrid)[c(1, 3)]
          ) / (dist)
        )
        nrows = as.integer(length(fillgrid) / ncols)
      }
      id_grid = seq(1, length(fillgrid))
      row_id = cut(id_grid, nrows, labels = F)
      col_id = id_grid - (row_id - 1) * ncols
      l2r = l2r[col_id %in% seq(1, ncols + 1, 2)]
      l2r = sf::st_line_merge(sf::st_union(l2r))
      r2l = r2l[col_id %in% seq(2, ncols + 1, 2)]
      r2l = sf::st_line_merge(sf::st_union(r2l))
      endsf = sf::st_union(l2r,
                           r2l
      )
    }
    endsf = sf::st_intersection(endsf,x)
    endsf = endsf[sf::st_geometry_type(endsf)
                  %in% c("LINESTRING", "MULTILINESTRING")
    ]
    endsf = sf::st_line_merge(sf::st_union(endsf))
  }
  # End patterns#
  options(warn = 0)
  
  #Outputs
  
  # Mode plot: plotting
  # Mode sfc: return object plotted
  # Mode legend: return object to plot on legend
  
  
  if (mode == "plot") {
    if (pattern == "dot") {
      plot(
        endsf,
        add = add,
        col = col,
        bg = bg,
        cex = cex,
        pch = pch
      )
    } else if (pattern == "text") {
      plot(sf::st_geometry(x),
           add = add,
           col = NA,
           border = NA)
      text(
        x = sf::st_coordinates(endsf)[, 1],
        y = sf::st_coordinates(endsf)[, 2],
        labels = endsf$txt,
        col = col,
        cex = cex
      )
    } else {
      plot(
        sf::st_geometry(endsf),
        add = add,
        col = col,
        lwd = lwd,
        lty = lty
      )
    }
  } else {
    return(endsf)
  }
}


legendPattern <- function(pos = "topleft",
                          title.txt = "Title of the legend",
                          title.cex = 0.8,
                          values.cex = 0.6,
                          categ,
                          patterns,
                          ptrn.bg = "white",
                          ptrn.text = "X",
                          dot.cex = 0.5,
                          text.cex = 0.5,
                          cex = 1,
                          frame = FALSE,
                          ...) {
  # Basic controls #
  todot = c("dot", "text")
  tolines = c("diamond","grid","hexagon",
              "horizontal", "vertical","zigzag",
              "left2right","right2left","circle")
  
  if (!unique(patterns %in% c(todot, tolines)) ||
      length(unique(patterns %in% c(todot, tolines))) > 1) {
    stop(
      paste("Patterns available are",
            gsub(",",
                 ", ",
                 paste(c(todot,tolines),sep = "",
                       collapse = ",")
            ),
            sep = " "
      )
    )
  }
  
  
  # Store defaults #
  # Goal is to create a df with all the graphical params to be applied
  dots = list(...) #additional params
  ncat = length(categ)
  params = data.frame(categ = categ,
                      stringsAsFactors = F
  )
  params$pattern = rep(patterns, ncat)[1:ncat]
  params$legendfill = rep(ptrn.bg, ncat)[1:ncat]
  col = ifelse(rep(is.null(dots$col), ncat),
               par()$col,
               dots$col)
  
  params$col = col
  rm(patterns, ptrn.bg, col)
  
  # params forLines
  nlines = nrow(params[params$pattern %in% tolines,])
  ltydef = ifelse(is.null(dots$lty), par()$lty, NA)
  if (!is.na(ltydef)) {
    ltytext = c("blank","solid",
                "dashed","dotted",
                "dotdash","longdash",
                "twodash")
    ltytopar <- match(ltydef, ltytext) - 1
    ltytopar = rep(ltytopar, nlines)[1:nlines]
  } else {
    ltytopar = rep(dots$lty, nlines)[1:nlines]
  }
  auxlist = rep(NA, ncat)
  auxlist[params$pattern %in% tolines] <- ltytopar
  params$line.lty = auxlist
  lwd = ifelse(rep(is.null(dots$lwd), nlines),
               par()$lwd, dots$lwd
  )
  auxlist[params$pattern %in% tolines] <- lwd
  params$line.lwd = auxlist
  rm(lwd, nlines)
  
  # params for Dots
  ndots = nrow(params[params$pattern == "dot",])
  pch = ifelse(rep(is.null(dots$pch), ndots),
               par()$pch,
               dots$pch
  )
  auxlist = rep(NA, ncat)
  auxlist[params$pattern == "dot"] <- pch
  params$dot.pch = auxlist
  rm(pch)
  
  auxlist[params$pattern == "dot"] <- rep(dot.cex, 
                                          ndots)[1:ndots]
  params$dot.cex.pch = auxlist
  rm(dot.cex)
  
  bg = ifelse(rep(is.null(dots$bg), ndots),
              par()$bg,
              dots$bg)
  auxlist[params$pattern == "dot"] <- bg
  params$dot.bg = auxlist
  rm(bg, ndots)
  
  # params for Text
  ntxt = nrow(params[params$pattern == "text", ])
  ptrn.text = rep(ptrn.text, ntxt)[1:ntxt]
  auxlist = rep(NA, ncat)
  auxlist[params$pattern == "text"] <- ptrn.text
  params$text.value = auxlist
  rm(ptrn.text)
  
  text.cex = rep(text.cex, ntxt)[1:ntxt]
  auxlist[params$pattern == "text"] <- text.cex
  params$text.cex = auxlist
  rm(text.cex, ntxt)
  #Reversing table 
  params = params[nrow(params):1,]
  # End params table
  
  # exit for none
  positions <- c("bottomleft","topleft",
                 "topright","bottomright",
                 "left","right","top",
                 "bottom","center","bottomleftextra"
  )
  if (length(pos) == 1) {
    if (!pos %in% positions) {
      return(invisible())
    }
  }
  
  # figdim in geo coordinates
  x1 <- par()$usr[1]
  x2 <- par()$usr[2]
  y1 <- par()$usr[3]
  y2 <- par()$usr[4]
  
  # offsets
  delta1 <- xinch(0.15) * cex
  delta2 <- delta1 / 2
  
  # variables internes
  width <- (x2 - x1) / (30 / cex)
  height <- width / 1.5
  
  # xsize
  categ <- params$categ
  
  longVal <- categ[
    strwidth(categ, cex = values.cex) == max(strwidth(categ, cex = values.cex))
  ][1]
  longVal <- max(strwidth(c(longVal), cex = values.cex))
  legend_xsize <- max(width + longVal,
                      strwidth(title.txt,
                               cex = title.cex) - delta2
  ) - delta2
  # ysize
  legend_ysize <-
    (length(categ)) * height + delta2 * (length(categ)) +
    strheight(title.txt, cex = title.cex) - delta2
  
  
  
  # Get legend position
  legcoord <- legpos(pos = pos,
                     x1 = x1,
                     x2 = x2,
                     y1 = y1,
                     y2 = y2,
                     delta1 = delta1,
                     delta2 = delta2,
                     legend_xsize = legend_xsize,
                     legend_ysize = legend_ysize
  )
  xref <- legcoord$xref
  yref <- legcoord$yref
  
  # Frame
  if (frame == TRUE) {
    rect(xref - delta1,
         yref - delta1,
         xref + legend_xsize + delta1 * 2,
         yref + legend_ysize + delta1 * 2,
         border = "black",
         col = "white"
    )
  }
  
  for (i in 0:(length(categ) - 1)) {
    j <- i + 1
    
    # Overlay pattern
    rect = c(xref,
             yref + i * height + i * delta2,
             xref + width,
             yref + height + i * height + i * delta2)
    
    class(rect) <- "bbox"
    rect = sf::st_as_sfc(rect)
    plot(
      sf::st_geometry(rect),
      col = params$legendfill[j],
      border = "black",
      lwd = 0.4,
      add = T
    )
    
    if (params$pattern[j] == "text") {
      centre = sf::st_centroid(rect) 
      centre = sf::st_coordinates(centre)
      text(x = centre[1],
           y = centre[2],
           labels = params$text.value[j],
           col = params$col[j],
           cex = as.double(params$text.cex[j])
      )
    } else if (params$pattern[j] == "dot") {
      fr = sf::st_make_grid(rect, 
                            n = c(2, 2), 
                            what = "centers")
      plot(sf::st_geometry(fr),
           pch = as.integer(params$dot.pch[j]),
           cex = as.double(params$dot.cex.pch[j]),
           col = params$col[j],
           bg = params$dot.bg[j],
           add = T
      )
    } else {
      patt = patternLayer(rect,
                          pattern = params$pattern[j],
                          mode = "legend")
      plot(sf::st_geometry(patt),
           add = T,
           col = params$col[j],
           lwd = as.double(params$line.lwd[j]),
           lty = as.integer(params$line.lty[j])
      )
      # Add border #
      plot(sf::st_geometry(rect),
           add = T,
           col = NA,
           border = "black",
           lwd = 0.4
      )
    }
    
    
    # Label Legend
    text(x = xref + width + delta2 ,
         y = yref + height / 2 + i * height + i * delta2,
         labels = params$categ[j],
         adj = c(0, 0.5),
         cex = values.cex
    )
  }
  
  
  # Affichage du titre
  text(
    x = xref,
    y = yref + length(categ) * height + length(categ) * delta2 + delta2,
    labels = title.txt,
    adj = c(0, 0),
    cex = title.cex
  )
}