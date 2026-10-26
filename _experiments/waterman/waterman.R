# Run from the repository root: Rscript _experiments/waterman/waterman.R
# R handles the data and output; V8 runs D3's Waterman projection.
packages <- c(
  "sf",
  "giscoR",
  "V8",
  "magick",
  "rsvg"
)
missing <- packages[
  !vapply(packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing)) {
  stop("Install the required packages: ", paste(missing, collapse = ", "))
}

output_dir <- file.path("_experiments", "waterman")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
cache_dir <- file.path(output_dir, "vendor")
dir.create(cache_dir, showWarnings = FALSE)

# Pin the JavaScript dependencies for reproducible rendering.
libraries <- c(
  "d3.min.js" = "https://cdn.jsdelivr.net/npm/d3@7.9.0/dist/d3.min.js",
  "d3-geo-projection.min.js" = paste0(
    "https://cdn.jsdelivr.net/npm/d3-geo-projection@4.0.0/",
    "dist/d3-geo-projection.min.js"
  ),
  "d3-geo-polygon.min.js" = paste0(
    "https://cdn.jsdelivr.net/npm/d3-geo-polygon@2.0.1/",
    "dist/d3-geo-polygon.min.js"
  )
)
ctx <- V8::v8()
for (name in names(libraries)) {
  local_file <- file.path(cache_dir, name)
  if (!file.exists(local_file)) {
    download.file(libraries[[name]], local_file, mode = "wb", quiet = TRUE)
  }
  ctx$source(local_file)
}

world <- giscoR::gisco_get_countries(year = 2024, resolution = 20)
stopifnot(inherits(world, "sf"))
layers <- list(
  world = world["CNTR_ID"]
)
for (name in names(layers)) {
  geojson <- tempfile(fileext = ".geojson")
  sf::st_write(layers[[name]], geojson, quiet = TRUE)
  ctx$eval(paste0(
    "var ",
    name,
    " = ",
    paste(readLines(geojson, warn = FALSE), collapse = ""),
    ";"
  ))
  unlink(geojson)
}

# geo-polygon clips the countries and graticule at the unfolded face edges.
invisible(ctx$eval(
  '
var width = 1600, height = 1300;
var sphere = {type: "Sphere"};
var projection = d3.geoPolyhedralWaterman()
  .rotate([20, 0])
  .fitExtent([[80, 155], [width - 80, height - 115]], sphere)
  .precision(0.15);
var path = d3.geoPath(projection).digits(3);
// Wikipedia:WikiProject Maps/Conventions/Location maps.
// The whole world is the subject, so all countries use the subject-area fill.
var colors = {land: "#FEFEE9", water: "#C6ECFF", grid: "#646464"};
// GISCO rings follow the opposite winding convention to D3 spherical polygons.
world.features.forEach(function(feature) {
  var geometry = feature.geometry;
  var polygons = geometry.type === "Polygon" ? [geometry.coordinates] : geometry.coordinates;
  polygons.forEach(function(polygon) {
    polygon.forEach(function(ring) { ring.reverse(); });
  });
});
var outline = path(sphere);
var svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="100%" height="100%" fill="#FFFFFF"/>
<text x="80" y="75" font-family="sans-serif" font-size="43" font-weight="bold" fill="#263e43">El mundo en una mariposa</text>
<text x="82" y="112" font-family="sans-serif" font-size="21" fill="#597075">Proyecci\\u00f3n poli\\u00e9drica de Waterman</text>
<path d="${outline}" fill="${colors.water}"/>
`;
world.features.forEach(function(feature) {
  svg += `<path d="${path(feature)}" fill="${colors.land}"/>`;
});
svg += `<path d="${path(d3.geoGraticule().step([15, 15])())}" fill="none" stroke="${colors.grid}" stroke-opacity="0.2" stroke-width="0.7"/>
<path d="${outline}" fill="none" stroke="#000000" stroke-width="1.6" stroke-linejoin="round"/>
<text x="80" y="1230" font-family="sans-serif" font-size="17" fill="#646464">Eurostat/GISCO 2024 (giscoR) \\u00b7 Escala 1:20 millones \\u00b7 Ret\\u00edcula cada 15\\u00b0</text>
<text x="80" y="1260" font-family="sans-serif" font-size="16" fill="#646464">Colores: Wikipedia Location maps \\u00b7 R + V8 + d3-geo-polygon</text>
</svg>`;
'
))

svg_file <- file.path(output_dir, "waterman.svg")
png_file <- file.path(output_dir, "waterman.png")
writeLines(enc2utf8(ctx$get("svg")), svg_file, useBytes = TRUE)
magick::image_read_svg(svg_file, width = 2400) |>
  magick::image_write(png_file, format = "png")
message("Map saved to ", normalizePath(png_file, winslash = "/"))
