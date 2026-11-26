stdh_cast_substring <- function(x, to = "MULTILINESTRING") {
  to <- match.arg(to, c("MULTILINESTRING", "LINESTRING"))
  geometry <- sf::st_geometry(x)

  if (!all(sf::st_geometry_type(geometry) %in% c("LINESTRING", "POLYGON"))) {
    stop(
      "Input must contain only LINESTRING or POLYGON geometries.",
      call. = FALSE
    )
  }

  pieces <- lapply(geometry, function(feature) {
    parts <- if (inherits(feature, "POLYGON")) {
      unclass(feature)
    } else {
      list(unclass(feature))
    }

    segments <- lapply(parts, function(part) {
      lapply(seq_len(max(0L, nrow(part) - 1L)), \(i) {
        part[c(i, i + 1L), , drop = FALSE]
      })
    })

    sf::st_multilinestring(
      unlist(segments, recursive = FALSE),
      dim = class(feature)[1]
    )
  })

  result <- sf::st_sfc(
    pieces,
    crs = sf::st_crs(geometry),
    precision = sf::st_precision(geometry)
  )
  if (inherits(x, "sf")) {
    result <- sf::st_set_geometry(x, result)
  }

  if (to == "LINESTRING") {
    result <- sf::st_cast(result, "LINESTRING")
  }
  result
}
