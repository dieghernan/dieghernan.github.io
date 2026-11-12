---
review: always
description: A compilation of celestial data files
cover_image: https://dieghernan.github.io/celestial_data/assets/img/ogimage.webp
cover_image_bk: Map of stars and constellations from the Celestial Data collection.
series: review
ai_disclosure_level: no_ai
---
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7561601.svg)](https://doi.org/10.5281/zenodo.7561601)

This project provides several datasets of celestial objects as of the J2000 epoch in GeoJSON and GeoPackage formats.

The original files were provided by the [d3-celestial plugin](https://github.com/ofrohn/d3-celestial/) ([Frohn 2015](https://dieghernan.github.io/projects/celestial-data/#ref-frohn2015)) under [BSD 3-Clause](https://opensource.org/licenses/BSD-3-Clause). The datasets produced by this project consist of the same data provided by the [d3-celestial plugin](https://github.com/ofrohn/d3-celestial/) processed with the **R** package **sf** ([Pebesma 2018](https://dieghernan.github.io/projects/celestial-data/#ref-pebesma2018)) to ensure its validity:

- The spatial data objects are bounded by
  ``` math
  [-180, -90, 180, 90]
  ```
  .

- The coordinates represent J2000 celestial directions in degrees. [EPSG:4326](https://epsg.io/4326) is assigned for compatibility with GIS software. The angles are right ascension and declination.

- All geometries are valid as per [ST_IsValid](https://postgis.net/docs/ST_IsValid.html) (GEOS **3.9.3**).

## Distribution

These URLs serve the same minified GeoJSON file from the main branch.

``` html
<!-- From GitHub -->
https://raw.githubusercontent.com/dieghernan/celestial_data/main/data/mw.min.geojson

<!-- From the website -->
https://dieghernan.github.io/celestial_data/data/mw.min.geojson

<!-- From jsDelivr -->
https://cdn.jsdelivr.net/gh/dieghernan/celestial_data@main/data/mw.min.geojson
```

## Data

Data are provided in GeoJSON (`*.geojson`) and GeoPackage (`*.gpkg`) formats. Additionally, for GeoJSON files a minified version (`*.min.geojson`) is also provided.

The data source can be found in the corresponding [GitHub repo](https://github.com/dieghernan/celestial_data/tree/main/data).

<details markdown=1 class="my-2">
<summary>
List of files provided:
</summary>

- `asterisms.geojson`
- `asterisms.gpkg`
- `asterisms.min.geojson`
- `constellations.borders.cn.geojson`
- `constellations.borders.cn.gpkg`
- `constellations.borders.cn.min.geojson`
- `constellations.borders.geojson`
- `constellations.borders.gpkg`
- `constellations.borders.min.geojson`
- `constellations.borders.min.min.geojson`
- `constellations.bounds.cn.geojson`
- `constellations.bounds.cn.gpkg`
- `constellations.bounds.cn.min.geojson`
- `constellations.bounds.geojson`
- `constellations.bounds.gpkg`
- `constellations.bounds.min.geojson`
- `constellations.cn.csv`
- `constellations.cn.geojson`
- `constellations.cn.gpkg`
- `constellations.cn.min.geojson`
- `constellations.csv`
- `constellations.geojson`
- `constellations.gpkg`
- `constellations.lines.cn.geojson`
- `constellations.lines.cn.gpkg`
- `constellations.lines.cn.min.geojson`
- `constellations.lines.geojson`
- `constellations.lines.gpkg`
- `constellations.lines.min.geojson`
- `constellations.min.geojson`
- `dsonames.cn.csv`
- `dsonames.csv`
- `dsos.14.geojson`
- `dsos.14.gpkg`
- `dsos.14.min.geojson`
- `dsos.20.geojson`
- `dsos.20.gpkg`
- `dsos.20.min.geojson`
- `dsos.6.geojson`
- `dsos.6.gpkg`
- `dsos.6.min.geojson`
- `dsos.bright.geojson`
- `dsos.bright.gpkg`
- `dsos.bright.min.geojson`
- `lg.geojson`
- `lg.gpkg`
- `lg.min.geojson`
- `messier.geojson`
- `messier.gpkg`
- `messier.min.geojson`
- `mw.geojson`
- `mw.gpkg`
- `mw.min.geojson`
- `starnames.cn.csv`
- `starnames.csv`
- `stars.14.geojson`
- `stars.14.gpkg`
- `stars.14.min.geojson`
- `stars.6.geojson`
- `stars.6.gpkg`
- `stars.6.min.geojson`
- `stars.8.geojson`
- `stars.8.gpkg`
- `stars.8.min.geojson`

</details>

See additional details in the [data description](https://dieghernan.github.io/celestial_data/data).

## Citation

Please cite these datasets as:

Frohn, O., & Hernangómez, D. (2023). Celestial Data \[Data set\]. <https://doi.org/10.5281/zenodo.7561601>

A BibTeX entry:

``` bibtex

@misc{frohnhernangomez:2023,
    title        = {Celestial Data},
    author       = {Olaf Frohn and Diego Hernangómez},
    year         = 2023,
    doi          = {10.5281/zenodo.7561601},
    url          = {https://dieghernan.github.io/celestial_data/},
}
```

## References

- <span id="ref-frohn2015"></span> Frohn, O. (2015). *d3-celestial* \[Computer software\]. GitHub. <https://github.com/ofrohn/d3-celestial/>
- <span id="ref-pebesma2018"></span> Pebesma, E. (2018). Simple features for R: Standardized support for spatial vector data. *The R Journal, 10*(1), 439–446. <https://doi.org/10.32614/RJ-2018-009>
