---
review: always
description: EGIF reports, reconciled fire records and cartography with R
cover_image: https://dieghernan.github.io/assets/img/misc/gifs-social.jpg
cover_image_bk: https://dieghernan.github.io/assets/img/misc/gifs-social.jpg
series: review
ai_disclosure_level: no_ai
---
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23932940.svg)](https://doi.org/10.5281/zenodo.23932940)

**GIFs** brings together structured data on large forest fires in Spain and **R** code for an infographic inspired by [Dominic Royé's firefly cartography](https://dominicroye.github.io/blog/firefly-maps/). Here, GIF means *gran incendio forestal*: a fire with at least 500 hectares of forest area burned.

The project combines exports from MITECO's General Forest Fire Statistics (EGIF) with its annual reports and provisional updates. It preserves source information and reconciliation notes so that users can trace how records were selected, grouped and located.

![Large forest fires in Spain, 2010–2026. Dark map with orange circles sized by forest area burned.](https://dieghernan.github.io/gifs/gif_spain.png)

## Two related data products

The collection currently provides two complementary views:

- **EGIF reports:** 329 selected reports from 2010–2023. Each row has a unique `egif_part_id` and includes source fields, burned areas, cause, provenance, notes and coordinates where they can be interpreted.
- **Reconciled fires:** 455 fire records from 2010–2026, used by the infographic. Each fire has a stable `fire_id`; a fire may bring together several EGIF reports.

These are different units of observation. Do not add the two tables' row counts or burned areas together. The 500-hectare threshold is applied after explicitly documented groupings of reports belonging to the same fire.

EGIF takes priority when a documented match exists. Records without a match retain their original MITECO annual report or provisional update. Reports awaiting reconciliation keep an empty `fire_id` and are not automatically added as new fires, which helps avoid double counting.

## Coverage and limitations

The fire-level records span February 27, 2010 to September 26, 2026. These are the first and last dates in the file, not evidence of complete annual coverage. The project is not a real-time monitoring service.

The documented reconciliation still has nine earlier fire records and eight selected EGIF reports awaiting a match. Two additional records retain their provisional source because their province has no reports in the 2023 EGIF export. That export contains no records for seven provinces, so an absence from these files should not be interpreted as an absence of fires.

The [methodology](https://github.com/dieghernan/gifs/blob/main/METODOLOGIA.md) explains source priority, explicit groupings and unresolved cases. The [data guide](https://github.com/dieghernan/gifs/blob/main/data-raw/README.md) documents the source exports and processing. The original ZIP files are preserved with SHA-256 checksums.

## Coordinates and the infographic

Geographic coordinates use EPSG:4326, keeping the Canary Islands in their actual location. EGIF coordinates are transformed only when their coordinate system can be interpreted. Missing coordinates or an unknown datum leave the geographic coordinates empty rather than producing an invented point.

The fire-level view uses interpretable EGIF coordinates where available and an identified municipal reference location otherwise. `location_method` distinguishes these sources. For fires with several reports, the view records which report supplies its reference point. Declared municipality codes and municipalities obtained through a spatial join are retained separately.

The points are reference locations, not fire perimeters. Municipal reference locations come from IGN through SIANE and **mapSpain**. The infographic reads the reconciled fire view and uses circle sizes to show forest area burned.

## Downloads, citation and reuse

Both products are available in **CSV**, **JSON** and **GeoJSON** from the [project website](https://dieghernan.github.io/gifs/). Read identifiers and municipality codes as text to preserve their representation. JSON supplies explicit types and null values; GeoJSON retains records without usable coordinates with `geometry: null`.

Machine-readable field descriptions are provided separately in the [EGIF report Croissant metadata](https://dieghernan.github.io/gifs/croissant/parts.json) and the [fire-level Croissant metadata](https://dieghernan.github.io/gifs/croissant/fires.json).

For reproducible analyses, cite the DOI of the version used. The collection's [version 2.0.0 DOI](https://doi.org/10.5281/zenodo.23932940) identifies the archived release; the [general DOI](https://doi.org/10.5281/zenodo.23929996) groups the project's releases.

Data reuse follows the [MITECO legal notice](https://www.miteco.gob.es/es/atencion-al-ciudadano/aviso-legal.html), including attribution and preservation of the original conditions and metadata. The municipal cartography credits CartoBase ANE 2006–2024, CC BY 4.0, IGN. The repository's MIT license applies to code and documentation. The project is independent and does not imply MITECO participation or endorsement.

## References

- Royé, D. (2021, June 1). Firefly cartography. *Dr Dominic Royé*. <https://dominicroye.github.io/blog/firefly-maps/>
