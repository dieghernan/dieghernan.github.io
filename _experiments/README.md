# Cartographic experiments

Standalone R scripts and their generated maps. Run each script from the
repository root; its README describes the dependencies, data cache and outputs.

| Experiment | Purpose |
| --- | --- |
| [Romania hillshade](romania-blend/README.md) | Compare transparency and multiply blending with calculated hillshade. |
| [Spain hillshade](spain-blend/README.md) | Compare transparency, continuous multiply and binned multiply. |
| [Bolivia RGB overlay](bolivia-overlay/README.md) | Compare continuous, binned and filled-contour elevation over Esri relief. |
| [Pakistan RGB overlay](pakistan-overlay/README.md) | Repeat the RGB comparison with the Pakistan palette. |
| [Spain RGB overlay](spain-overlay/README.md) | Repeat the RGB comparison with the dem_poster palette. |
| [UK RGB overlay](uk-overlay/README.md) | Repeat the RGB comparison with the dem_print palette. |
| [Switzerland GDAL blend](switzerland-gdal-blend/README.md) | Compare GDAL pixel blending with ggblend compositing. |
| [China RGB hillshade](china-rgb-hillshade/README.md) | Test one-band RGB hillshade with a normal elevation legend on a large raster. |
| [Waterman world map](waterman/README.md) | Render D3's polyhedral Waterman projection from R through V8. |

The hillshade and RGB overlay scripts blend graphical layers through `ggblend`.
The Swiss experiment additionally creates a reusable blended GeoTIFF with GDAL.
The RGB backgrounds already contain shading and color, so multiplying them by
an elevation palette affects both the hue and brightness of the result.

These are exploratory examples. Package versions, fonts and changes in remote
data can affect rerendered maps. The raster comparison scripts save their R
session information beside the images.
