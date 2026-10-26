# Switzerland: GDAL raster blending

A small comparison of **ggblend** compositing and GDAL pixel blending, using the
same Swiss SRTM elevation grid, `dem_poster` colors and grayscale hillshade.
Both use `multiply` with hillshade opacity of 85%. An elevation layer beneath
the opaque blended result supplies the same legend for both maps.

Run from the repository root:

```r
source("_experiments/switzerland-gdal-blend/switzerland-gdal-blend.R")
```

R dependencies: **terra**, **tidyterra**, **ggplot2**, **geodata**, **scales**,
**ggblend**,
**gdalraster**, **ragg** and **magick**.

The script prefers `gdalraster::gdal_run()` when its algorithm registry exposes
`raster blend` with `multiply`. Otherwise it uses an external `gdal` executable,
selected through `GDAL_BLEND_EXE`, the PATH or the isolated local environment
created for this experiment.

Two version details matter on this Windows installation:

- **gdalraster** 2.7.0 links GDAL 3.12.1 but exposes only `driver` in its CLI
  registry. See the [Windows algorithm API issue](https://github.com/firelab/gdalraster/issues/982).
- The external GDAL 3.12.4 build offers `raster blend` but only `src-over` and
  `hsv-value`. GDAL 3.13.3 provides `multiply` and was used for this experiment.

The isolated executable can be installed with micromamba, without replacing the
GDAL libraries used by R:

```powershell
micromamba create -y -p "$env:USERPROFILE/.cache/codex-gdal-blend-cli" --override-channels -c conda-forge "libgdal-core=3.13.3"
```

For another GDAL installation, set its executable before running:

```r
Sys.setenv(GDAL_BLEND_EXE = "C:/path/to/gdal.exe")
```

Outputs include two individual maps, `switzerland-comparison.png`, the input
RGBA GeoTIFFs and the blended GeoTIFF. `validation.txt` records the backend and
the results of checks for grid alignment, exterior transparency and the
channel-wise multiply formula, allowing a rounding difference of up to 3 units
on the 0–255 scale.

The pixel check compares GDAL with the mathematical formula. The visual
comparison with **ggblend** also involves the graphics device and raster
interpolation, so the exported plot images need not be pixel-identical.

Reference: [GDAL raster blend documentation](https://gdal.org/programs/gdal_raster_blend.html).
