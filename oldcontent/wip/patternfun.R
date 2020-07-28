

# Imported from cartography package---
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

# checkfunction

checkpatterLayer <- function(x, mode, pattern) {
  if (length(st_geometry(x)) == 0) {
    stop("No layer added, Check input object")
  }
  
  todot = c("dot", "text")
  tolines = c(
    "diamond",
    "grid",
    "hexagon",
    "horizontal",
    "vertical",
    "zigzag",
    "left2right",
    "right2left"
  )
  if (!unique(st_geometry_type(x)) %in% c("POLYGON", "MULTIPOLYGON")) {
    stop("Input should be  MULTIPOLYGON or POLYGON")
  }
  
  if (!mode %in% c("plot", "legend", "sfc")) {
    stop("mode should be  'plot' or 'sfc'")
  }
  
  if (!pattern %in% c(todot, tolines)) {
    stop(
      "Patterns available are 'dot', 'text', 'grid', 'hexagon', 'diamond', 'horizontal', 'vertical', 'left2right','right2left','zigzag'"
    )
  }
  
}

patternLayer = function(x,
                        pattern = "dot",
                        density = 1,
                        txt = "a",
                        ...) {
  options(warn = -1)
  # Assign default options
  dots = list(...)
  mode = ifelse(is.null(dots$mode), "plot",
                dots$mode)
  col = ifelse(is.null(dots$col), par()$col, dots$col)
  bg = ifelse(is.null(dots$bg), par()$bg, dots$bg)
  pch = ifelse(is.null(dots$pch), par()$pch, dots$pch)
  lty = ifelse(is.null(dots$lty), par()$lty, dots$lty)
  cex = ifelse(is.null(dots$cex), par()$cex, dots$cex)
  lwd = ifelse(is.null(dots$lwd), par()$lwd, dots$lwd)
  add = ifelse(is.null(dots$add), F, dots$add)
  # End defaults
  
  #Crop if necessary
  
  if (mode != "legend" & add == T) {
    devplot = par()$usr
    devplot <- devplot[c(1, 3, 2, 4)]
    class(devplot) <- "bbox"
    x = st_crop(x, devplot)
  }
  
  #Checks
  checkpatterLayer(x, mode, pattern)
  
  todot = c("dot", "text")
  tolines = c(
    "diamond",
    "grid",
    "hexagon",
    "horizontal",
    "vertical",
    "zigzag",
    "left2right",
    "right2left"
  )
  #- Dimensions - by default 10 cells on the shortest dimensions -#
  
  dist = min(diff(st_bbox(x)[c(1, 3)]),
             diff(st_bbox(x)[c(2, 4)])) / (10 * density)
  
  #- Superseed if cellsize option provided -#
  dist = ifelse(is.null(dots$cellsize), dist, dots$cellsize)
  
  #- Prepare to grid -#
  if (pattern %in% c("dot", "text")) {
    if (mode != "legend") {
      ops = list(cellsize = dist ,
                 what = "corners",
                 square = F)
    } else {
      # Mode
      ops = list(cellsize = dist ,
                 what = "centers",
                 square = T)
    }
  } else {
    tops <- pattern != "hexagon"
    ops = list(cellsize = dist ,
               what = "polygons",
               square = tops)
  }
  
  #- Create grid -#
  if (mode == "legend") {
    fillgrid = st_make_grid(x,
                            n = c(3, 3),
                            what = ops[2],
                            square = as.logical(ops[3]))
  } else {
    fillgrid = st_make_grid(
      x,
      cellsize = as.numeric(ops[1]),
      what = ops[2],
      square = as.logical(ops[3])
    )
  }
  
  # Create patterns
  if (pattern %in% c("dot", "text")) {
    #- A. Dot and Text -#
    x2 = st_buffer(x, dist = -dist / 5)
    endsf = fillgrid[st_contains(x2, fillgrid, sparse = F)]
    
    if (pattern == "text") {
      endsf = st_sf(txt = txt, geometry = endsf)
    } else {
      endsf = st_union(endsf)
      # End Dot/Text
    }
  } else if (pattern %in% c("grid", "hexagon")) {
    #- B. Hexagon & Grid -#
    endsf = st_cast(fillgrid, "LINESTRING") %>%
      st_intersection(x)
    endsf = endsf[st_geometry_type(endsf)
                  %in% c("LINESTRING", "MULTILINESTRING")]
    endsf = endsf %>% st_union() %>% st_line_merge()
  } else if (!pattern %in% c("zigzag", "diamond")) {
    # Straight Lines #
    ex = list(
      horizontal = c(1, 2),
      vertical = c(1, 4),
      left2right = c(2, 4),
      right2left = c(1, 3)
    )
    endsf = lapply(1:length(fillgrid), function(j)
      st_linestring(st_coordinates(fillgrid[j])[ex[[pattern]], 1:2])) %>%
      st_sfc(crs = st_crs(x)) %>%
      st_intersection(x)
    
    endsf = endsf[st_geometry_type(endsf)
                  %in% c("LINESTRING", "MULTILINESTRING")]
    endsf = endsf %>% st_union() %>% st_line_merge()
    # End Straight Lines #
  } else {
    l2r = lapply(1:length(fillgrid), function(j)
      st_linestring(st_coordinates(fillgrid[j])[c(2, 4), 1:2])) %>%
      st_sfc(crs = st_crs(x))
    r2l = lapply(1:length(fillgrid), function(j)
      st_linestring(st_coordinates(fillgrid[j])[c(1, 3), 1:2])) %>%
      st_sfc(crs = st_crs(x))
    
    if (pattern == "diamond") {
      endsf = st_union(l2r %>%
                         st_union() %>%
                         st_line_merge(),
                       r2l %>%
                         st_union() %>%
                         st_line_merge()) %>% st_intersection(x)
    } else {
      ncols = as.integer(diff(st_bbox(fillgrid)[c(1, 3)]) / (dist))
      nrows = as.integer(length(fillgrid) / ncols)
      if (mode=="legend"){
        nrows=3
        ncols=3
      }
      id_grid = seq(1, length(fillgrid))
      row_id = cut(id_grid, nrows, labels = F)
      col_id = id_grid - (row_id - 1) * ncols
      endsf = st_union(l2r[col_id %in% seq(1, ncols + 1, 2)] %>%
                         st_union() %>%
                         st_line_merge(),
                       r2l[col_id %in% seq(2, ncols + 1, 2)] %>%
                         st_union() %>%
                         st_line_merge()) %>% st_intersection(x)
    }
    endsf = endsf[st_geometry_type(endsf)
                  %in% c("LINESTRING", "MULTILINESTRING")]
    endsf = endsf %>% st_union() %>% st_line_merge()
  }
  options(warn = 0)
  
  #Outputs
  
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
      plot(st_geometry(x),
           add = add,
           col = NA,
           border = NA)
      text(
        x = st_coordinates(endsf)[, 1],
        y = st_coordinates(endsf)[, 2],
        labels = endsf$txt,
        col = col,
        cex = cex
      )
    } else {
      plot(
        st_geometry(endsf),
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


legendPattern <- function(pos = "left",
                          title.txt = "Title",
                          title.cex = 0.8,
                          values.cex = 0.6,
                          pattern.categ ,
                          pattern.type,
                          pattern.col = "black",
                          pattern.bg = "white",
                          pattern.style = 1,
                          pattern.cex = 0.1,
                          pattern.txt = "a",
                          pattern.txt.cex = 0.6,
                          pattern.lwd = 1,
                          cex = 1,
                          frame = FALSE) {
  pattern.categ <- rev(as.character(pattern.categ))
  
  # Controls---
  pattypes = c(
    "dot",
    "text",
    "diamond",
    "grid",
    "hexagon",
    "horizontal",
    "vertical",
    "zigzag",
    "left2right",
    "right2left"
  )
  if (!unique(pattern.type %in% pattypes)) {
    stop(
      "Pattern types available are 'dot', 'text', 'grid', 'hexagon', 'diamond', 'horizontal', 'vertical',
    'left2right','right2left','zigzag'"
    )
  }
  
  if (length(pattern.categ) != length(pattern.type)) {
    stop("pattern.categ do no match pattern.type ")
  }
  if (length(pattern.style) > 1 &
      length(pattern.style)  != length(pattern.categ)) {
    stop("pattern.categ do no match pattern.style ")
  }
  ltext=pattern.type[pattern.type=="text"]
  if (length(ltext)>0 & length(ltext) != length(pattern.txt)){
    stop("pattern.txt do no match pattern.type = text ")
  }
  
  pattern.type <- rev(pattern.type)
  pattern.txt <- rev(pattern.txt)
  
  if (length(pattern.col) == 1) {
    pattern.col = rep(pattern.col, length(pattern.categ))
  } else {
    pattern.col = rev(pattern.col[1:length(pattern.categ)])
  }
  if (length(pattern.bg) == 1) {
    pattern.bg = rep(pattern.bg, length(pattern.categ))
  } else {
    pattern.bg = rev(pattern.bg)
  }
  if (length(pattern.cex) == 1) {
    pattern.cex = rep(pattern.cex, length(pattern.categ))
  } else {
    pattern.cex = rev(pattern.cex)
  }
  
  if (length(pattern.lwd) == 1) {
    pattern.lwd = rep(pattern.lwd, length(pattern.categ))
  } else {
    pattern.lwd = rev(pattern.lwd)
  }
  
  if (length(pattern.style) == 1) {
    pattern.style = rep(pattern.style, length(pattern.categ))
  } else {
    pattern.style = rev(pattern.style)
  }


  
  
  # End - some controls added - when single value on function a vector with dimensions equal categories created
  # exit for none
  positions <- c(
    "bottomleft",
    "topleft",
    "topright",
    "bottomright",
    "left",
    "right",
    "top",
    "bottom",
    "center",
    "bottomleftextra"
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
  longVal <-
    pattern.categ[strwidth(pattern.categ, cex = values.cex) ==
                    max(strwidth(pattern.categ, cex = values.cex))][1]
  
  longVal <- max(strwidth(c(longVal, 0), cex = values.cex))
  
  legend_xsize <- max(width + longVal,
                      strwidth(title.txt, cex = title.cex) - delta2) - delta2
  # ysize
  legend_ysize <-
    (length(pattern.categ)) * height + delta2 * (length(pattern.categ)) +
    strheight(title.txt, cex = title.cex) - delta2
  
  # Get legend position
  # Could be imported from cartography package
  legcoord <-
    legpos(
      pos = pos,
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
    rect(
      xref - delta1 * 0.8,
      yref - delta1 * 0.8,
      xref + legend_xsize + delta1 * 1.8,
      yref + legend_ysize + delta1 * 1.8,
      border = "black",
      col = "white"
    )
  }
  
  n_txt = 1
  # Legends
  for (i in 0:(length(pattern.categ) - 1)) {
    # Plot rect
    rect = c(xref,
             yref + i * height + i * delta2,
             xref + width,
             yref + height + i * height + i * delta2)
    
    class(rect) <- "bbox"
    rect = st_as_sfc(rect)
    plot(st_geometry(rect), col = pattern.bg[i + 1], add = T)
    # Fill text
    if (pattern.type[i + 1] == "text") {
      centre = st_centroid(rect) %>% st_coordinates()
      text(
        x = centre[1],
        y = centre[2]
        ,
        labels = pattern.txt[n_txt],
        cex = pattern.txt.cex * 1.1,
        col = pattern.col[i + 1]
      )
      n_txt = n_txt + 1
      
    } else {
      patt = patternLayer(rect, pattern = pattern.type[i + 1], mode = "legend")
      
      # Prepare dot
      if (pattern.type[i + 1] == "dot") {
        pp = st_cast(patt, "POINT")
        a = st_contains(rect, pp, sparse = F)
        patt = pp[a]
        plot(
          st_geometry(patt),
          add = T,
          col = pattern.col[i + 1],
          pch = pattern.style[i + 1],
          cex = pattern.cex[i + 1]
        )
      } else {
        plot(
          st_geometry(patt),
          add = T,
          col = pattern.col[i + 1],
          lty = pattern.style[i + 1],
          lwd = pattern.lwd[i + 1]
        )
      }
      
      # Fill all except text
      
      
      # Overlap box - borders only
      plot(st_geometry(rect), col = NA, add = T)
    }
    # Label legend
    j <- i + 1
    text(
      x = xref + width + delta2 ,
      y = yref + height / 2 + i * height + i * delta2,
      labels = pattern.categ[j],
      adj = c(0, 0.5),
      cex = values.cex
    )
  }
  # Affichage du titre
  text(
    x = xref,
    y = yref + length(pattern.categ) * height + length(pattern.categ) * delta2 + delta2,
    labels = title.txt,
    adj = c(0, 0),
    cex = title.cex
  )
}
