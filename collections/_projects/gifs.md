---
title: Large forest fires in Spain
subtitle: MITECO data and firefly cartography with R
excerpt: Explore a dataset and infographic of large forest fires in Spain, with CSV downloads, documented methodology and Croissant metadata.
date: 2026-11-03
permalink: /projects/gifs/
tags:
  - project
  - rstats
  - rspatial
  - maps
  - dataset
  - csv
header_img: https://dieghernan.github.io/gifs/assets/social-preview.jpg
og_image: https://dieghernan.github.io/gifs/assets/social-preview.jpg
og_image_width: 1200
og_image_height: 630
og_image_type: image/jpeg
og_image_alt: "Large forest fires in Spain, 2010–2026. Dark map with orange circles sized by forest area burned."
project_links:
  - url: https://dieghernan.github.io/gifs/
    icon: fas fa-external-link-alt
    label: Visit the website
  - url: https://github.com/dieghernan/gifs
    icon: fab fa-github
    label: See on GitHub
  - url: https://doi.org/10.5281/zenodo.23929997
    icon: fas fa-database
    label: Cite the dataset
---

**GIFs** provides a dataset and an infographic of large forest fires in Spain,
compiled from the statistics of the Ministry for the Ecological Transition
and the Demographic Challenge (MITECO). Here, GIF means *gran incendio
forestal*: a fire with at least 500 hectares of forest area burned.

The project uses **R** to prepare the data and create a map inspired by
[Dominic Royé's firefly cartography](https://dominicroye.github.io/blog/firefly-maps/).

## Data and interpretation

Records span February 27, 2010 to September 26, 2026. These dates mark the
first and last records in the dataset; they do not represent complete annual
coverage. The dataset is not a real-time fire monitoring service.

The CSV contains municipality and province names, INE codes, dates and forest
area burned in hectares. It combines final statistics for 2010–2021 with
provisional reports for 2022–2026. Dates recorded as December 31, 2012 identify
the year only, rather than a confirmed day of ignition.

Map points use municipal reference locations from **mapSpain**, not exact fire
locations or perimeters. Circle sizes aggregate forest area burned at each
reference location.

## Downloads and reuse

The [project website](https://dieghernan.github.io/gifs/) provides the infographic,
a CSV download and citation information. Consult its
[documented methodology](https://github.com/dieghernan/gifs/blob/main/METODOLOGIA.md)
for collection decisions, source limitations and validation. Machine-readable
field descriptions are available in the
[Croissant metadata](https://dieghernan.github.io/gifs/croissant.json).

Data reuse follows the
[MITECO legal notice](https://www.miteco.gob.es/es/atencion-al-ciudadano/aviso-legal.html),
including attribution and preservation of the original conditions and metadata.
The repository's MIT license applies to its code and documentation. The project
is independent and does not imply MITECO participation or endorsement.

Cite the dataset using [its Zenodo DOI](https://doi.org/10.5281/zenodo.23929997).
