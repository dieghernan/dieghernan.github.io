---
title: Postal codes of Spain
subtitle: Estimated postal code areas from open data
excerpt: Explore estimated postal code areas for Spain and download GeoPackage files for R, Python and QGIS.
tags:
  - project
  - rstats
  - rspatial
  - maps
  - dataset
  - sf
  - gpkg
  - leaflet
header_img: https://dieghernan.github.io/assets/img/misc/postal-codes-spain.webp
og_image: https://dieghernan.github.io/assets/img/misc/postal-codes-spain.jpg
date: 2026-11-03
project_links:
  - url: https://dieghernan.github.io/codigospostales/
    icon: fas fa-external-link-alt
    label: Visit the website
  - url: https://github.com/dieghernan/codigospostales
    icon: fab fa-github
    label: See on GitHub
og_image_width: 1200
og_image_height: 800
og_image_type: "image/jpeg"
og_image_alt: "Map of estimated postal code areas in Spain with prefix 28."
syndication:
  - https://dev.to/dieghernan/postal-codes-of-spain-4g3j
  - https://oneworldwithr.substack.com/p/postal-codes-spain

---

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23698418.svg)](https://doi.org/10.5281/zenodo.23698418)

**Códigos postales de España** provides estimated postal code areas for Spain,
built from open address data from [CartoCiudad](https://www.cartociudad.es/web/portal/)
and administrative boundaries. Explore the results on interactive maps and
download the data for use in **R**, **Python** or **QGIS**.

## Background

Postal code polygons are useful for linking addresses and statistics to areas
on a map. According to [Goerlich (2022)](https://doi.org/10.12842/WPIVIE_0322),
the Correos polygons available through CartoCiudad stopped being offered for
download in early 2017. This project explores a reproducible alternative based
on open address data.

An early reference is José Ignacio Sánchez's
[2020 article in NoSoloSIG](https://www.nosolosig.com/articulos/asi-hice-el-mapa-de-los-codigos-postales-de-espana-con-sig-y-datos-abiertos),
which describes how to estimate postal areas from CartoCiudad addresses using
GIS tools. This project applies the approach developed in
[Francisco José Goerlich's 2022 work](https://www.uv.es/goerlich/Ivie/CodPost.html),
with its own choices for selecting addresses and handling areas without an
assignment.

## Maps and data

The [project website](https://dieghernan.github.io/codigospostales/) includes
interactive maps and two GeoPackage downloads: a full version for spatial
analysis and a simplified version for visualization. Both include postal code
areas and administrative areas pending assignment.

The data is shared under a
[Creative Commons Attribution 4.0 International license](https://creativecommons.org/licenses/by/4.0/).

### Interactive map

Search for a postal code or address, select a two-digit prefix and compare the
estimated areas with CartoCiudad. The viewer uses the simplified data and does
not display areas pending assignment. Its controls are in Spanish.

<p class="d-flex flex-wrap">
  <a class="btn btn-primary mr-2 mb-2" href="https://dieghernan.github.io/codigospostales/visor/mapa/#prefix=28">Open the map in a full window</a>
  <a class="btn btn-outline-primary mb-2" href="https://dieghernan.github.io/codigospostales/visor/">Viewer guide</a>
</p>

<div class="embed-responsive embed-responsive-4by3 my-2 chulapa-rounded-lg border border-primary">
  <iframe class="embed-responsive-item" title="Interactive map of estimated postal code areas in Spain" src="https://dieghernan.github.io/codigospostales/visor/mapa/#prefix=28" allowfullscreen loading="lazy"></iframe>
</div>

## Methodology

Following Goerlich's approach, the workflow treats each separate component of
an administrative area independently. When the selected addresses share a
single postal code, it assigns that code to the whole component. When several
codes are present, it builds Voronoi polygons around the address locations,
clips them to the administrative boundary and merges areas with the same code.
The final polygons are dissolved by postal code across provinces.

This implementation selects addresses using an inward buffer of 200 m, with a
second attempt at 50 m if none are found, rather than the 20 m described by
Goerlich. Components without selected addresses remain unassigned unless the
municipality has a single postal code recovered from its other components.
The administrative boundaries come from
[LAU2boundaries4Spain](https://doi.org/10.5281/zenodo.15345101), by Francisco José
Goerlich and Pedro Pérez Vázquez.

These are estimated areas, not official postal boundaries. Coverage depends on
the source addresses and some areas remain unassigned. The
[repository](https://github.com/dieghernan/codigospostales) documents the sources,
methodology, limitations and steps to reproduce the data.

## References

- Centro Nacional de Información Geográfica. (n.d.). *CartoCiudad*
  [Data set]. <https://www.cartociudad.es/web/portal/>
- Correos. (n.d.). *Base de datos de códigos postales y capa cartográfica*
  [Product information]. [Product page](https://www.correos.es/es/es/empresas/marketing/identifica-a-tus-clientes-potenciales/base-de-datos-de-codigos-postales)
- Goerlich, F. J. (2022). *Elaboración de un mapa de códigos postales de España
  con recursos libres: Cómo evitar pagar por disponer de información de
  referencia* (Working Paper No. 2022-3). Ivie.
  <https://doi.org/10.12842/WPIVIE_0322>
  ([Updated online version](https://www.uv.es/goerlich/Ivie/CodPost.html))
- Goerlich, F. J., & Pérez Vázquez, P. (2025). *Base de datos histórica de
  contornos municipales de España –LAU2boundaries4Spain–* (Version 2)
  [Data set]. Zenodo. <https://doi.org/10.5281/zenodo.15345101>
- Hernangómez, D. (2026). *Códigos postales de España* (Version 1.0.0)
  [Data set]. Zenodo. <https://doi.org/10.5281/zenodo.23698418>
  ([Project documentation](https://dieghernan.github.io/codigospostales/))
- Instituto Geográfico Nacional. (n.d.). *Servicios de visualización de
  CartoCiudad: Direcciones y códigos postales* [WMS documentation].
  [Service documentation](https://www.cartociudad.es/web/portal/directorio-de-servicios/visualizacion)
- Sánchez, J. I. (2020, November 13). Así hice el mapa de los códigos
  postales de España con SIG y datos abiertos. *Nosolosig*.
  [Article](https://www.nosolosig.com/articulos/asi-hice-el-mapa-de-los-codigos-postales-de-espana-con-sig-y-datos-abiertos)
