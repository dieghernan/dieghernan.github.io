# Reference audit

Reviewed: 2026-11-04.

Scope: all 38 entries in nine `References` sections in published posts and projects (and the
six matching R Markdown sources). Inline links elsewhere in articles are not
part of this bibliography audit. Existing historical data versions are retained;
a citation to the data actually used should not silently switch to a newer release.

## Changes

- Use Markdown bullets throughout, with surname and initials followed by year
  in parentheses. Preserve titles, DOI links and publication details.
- Keep the celestial project's citation anchors while replacing CSL HTML blocks
  with list entries. Correct Pebesma's page range from `439446` to `439–446`.
- Explain that Grossenbacher's 2016 article now redirects to his 2019 tutorial,
  rather than presenting the 2019 destination as the original article.
- Expand the orange-peel prose into two separate bibliographic entries.
- Make the Bertin source bibliography explicit so rerendering retains the list
  format instead of regenerating CSL blocks. Preserve the bibliography file.

## Availability and currency

There are 30 distinct cited URLs. Successful HTTP responses establish availability
at the time of review, not that every tutorial's code works with current software.
Historical papers, books and archived data remain appropriate citations for the
original posts. No newer data release is substituted without reproducing the
analysis. Books without URLs have not been checked for newer editions.

Grossenbacher's redirect was verified against the author's current article,
which identifies the old tutorial as no longer available. Publisher metadata
confirms White's 2019 article and Pebesma's 2018 article. The LAU2boundaries4Spain
Zenodo record confirms the cited 2025 v2 release. Crossref metadata also confirms
the titles of Jiang's scaling and goodness-of-space papers and Patterson and
Jenny's article. The API follow-up below completes DOI registration checks.

A 403, 406, timeout or rejected page is inconclusive. These references are
preserved and listed below for follow-up; none is declared broken from that alone.

| URL | Result | Destination or note |
| --- | --- | --- |
| <https://danielredondo.com/blog/2020-01-25-joy_division/> | 200 | Mapas estilo Joy Division con QGIS y R / Daniel Redondo |
| <https://dieghernan.github.io/celestial_data/> | 200 | Celestial Data / Celestial datasets in GeoJSON and GeoPackage formats |
| <https://doi.org/10.1080/00045608.2013.765773> | HTTP Error 403: Forbidden |  |
| <https://doi.org/10.1080/00045608.2013.834239> | HTTP Error 403: Forbidden |  |
| <https://doi.org/10.1080/00330124.2012.700499> | HTTP Error 403: Forbidden |  |
| <https://doi.org/10.12842/WPIVIE_0322> | 200 | https://www.ivie.es/downloads/docs/wpivie/wpivie-2022-03.pdf |
| <https://doi.org/10.14714/CP69.20> | 200 | The Development and Rationale of Cross-blended Hypsometric Tints / Cartographic Perspectives |
| <https://doi.org/10.14714/CP92.1536> | 200 | Cartographic Pleasures: Maps Inspired by Joy Division’s Unknown Pleasures Album Art / Cartographic Perspectives |
| <https://doi.org/10.21105/joss.05751> | 200 | Journal of Open Source Software: Using the tidyverse with terra objects: the tidyterra package |
| <https://doi.org/10.2760/098587> | 200 | GHSL data package 2023 - Publications Office of the EU |
| <https://doi.org/10.2905/3C60DDF6-0586-4190-854B-F6AA0EDC2A30> | 200 | HTTP 200 serves a rejection page; dataset content remains unverified. |
| <https://doi.org/10.32614/RJ-2018-009> | 200 | The R Journal: Simple Features for R: Standardized Support for Spatial Vector Data |
| <https://doi.org/10.3390/su11154091> | HTTP Error 403: Forbidden |  |
| <https://doi.org/10.5281/zenodo.15345101> | HTTP Error 403: Forbidden | Zenodo record verified through web fetch: May 5, 2025, version v2. |
| <https://doi.org/10.5281/zenodo.23698418> | HTTP Error 403: Forbidden |  |
| <https://doi.org/10.5281/zenodo.7561601> | HTTP Error 403: Forbidden | Citation confirmed on the dataset website and source README; Zenodo availability unverified. |
| <https://dominicroye.github.io/blog/firefly-maps/> | 200 | Firefly cartography – Dr Dominic Royé |
| <https://dominicroye.github.io/blog/hillshade-effect/> | 200 | Hillshade effects – Dr Dominic Royé |
| <https://github.com/ofrohn/d3-celestial/> | 200 | GitHub - ofrohn/d3-celestial: A star map with d3.js · GitHub |
| <https://kimnewzealand.github.io/2019/02/21/celestial-maps/> | 200 | Celestial Maps &middot; Kim Fitter |
| <https://pyranhia.eu/posts/202609-carto-proj-avancees/carto-proj-avancees.html> | 200 | Projections cartographiques : le guide pour ne pas y laisser sa santé mentale – Pyranhia |
| <https://r-spatial.org/r/2020/06/17/s2.html> | 200 | In r-spatial, the Earth is no longer flat |
| <https://squarewidget.com/astronomical-calculations-sidereal-time/> | HTTP Error 406: Not Acceptable | Content verified through web browser fetch. |
| <https://timogrossenbacher.ch/bivariate-maps-with-ggplot2-and-sf/> | 200 | Bivariate maps with ggplot2 and sf |
| <https://wilkelab.org/practicalgg/articles/goode.html> | 200 | Interrupted Goode homolosine • practicalgg |
| <https://www.cartociudad.es/web/portal/> | 200 | CartoCiudad |
| <https://www.cartociudad.es/web/portal/directorio-de-servicios/visualizacion> | 200 | CartoCiudad |
| <https://www.correos.es/es/es/empresas/marketing/identifica-a-tus-clientes-potenciales/base-de-datos-de-codigos-postales> | 200 | Contrata la base de datos de códigos postales/ Correos.es |
| <https://www.nosolosig.com/articulos/asi-hice-el-mapa-de-los-codigos-postales-de-espana-con-sig-y-datos-abiertos> | 200 | Así hice el mapa de los códigos postales de España con SIG y datos abiertos |
| <https://www.washingtonpost.com/entertainment/music/how-joy-divisions-unknown-pleasures-image-went-from-underground-album-cover-to-piece-of-cultural-ubiquity/2019/06/14/26e75338-8c76-11e9-adf3-f70f78c156e8_story.html> | The read operation timed out |  |

## Validation

Jekyll built successfully with `_config.yml,_config_build.yml`. Parsed the nine
rendered reference sections: all contain HTML lists, totaling 38 items. Both
celestial citation anchors remain present. All six R Markdown reference sections
match their published Markdown counterparts. `git diff --check` passed.

## DOI API follow-up

Checked on 2026-11-04: all 14 distinct bibliography DOIs returned registered
metadata. Eight are registered with Crossref and four with DataCite. The two
remaining DOIs use mEDRA and the EU Publications Office (OP); their metadata
was retrieved using DOI content negotiation (`Accept:
application/vnd.citationstyles.csl+json`). A 404 from Crossref or DataCite does
not imply an invalid DOI registered by another agency.

API metadata confirms the cited titles, with one difference: Goerlich's 2022
working paper uses the subtitle “Cómo evitar pagar a Correos 6.000 € por
información de referencia”. At the author's request, the existing wording in
the project bibliography is preserved.
Jiang and Yin's ht-index paper has a 2013 online date; the bibliography retains
2014, the year of its journal volume. API records establish registration and
metadata, not whether the publisher's landing page permits automated access.

Royé's two references now reproduce the author's own “For attribution, please
cite this work as” blocks, retaining the site's bullet list formatting. This
applies to Firefly Cartography in the star-map post and GIFs project, and
Hillshade Effects in the hillshade post, including matching R Markdown sources.

Raw API results, including failed fallback attempts and agency metadata, are
saved in `doi-api-results.json`.

| DOI | API / agency | Result |
| --- | --- | --- |
| 10.1080/00045608.2013.765773 | [Crossref](https://api.crossref.org/works/10.1080/00045608.2013.765773) | Registered metadata retrieved |
| 10.1080/00045608.2013.834239 | [Crossref](https://api.crossref.org/works/10.1080/00045608.2013.834239) | Registered metadata retrieved |
| 10.1080/00330124.2012.700499 | [Crossref](https://api.crossref.org/works/10.1080/00330124.2012.700499) | Registered metadata retrieved |
| 10.12842/WPIVIE_0322 | [mEDRA](https://doi.org/10.12842/WPIVIE_0322) | Registered metadata retrieved |
| 10.14714/CP69.20 | [Crossref](https://api.crossref.org/works/10.14714/CP69.20) | Registered metadata retrieved |
| 10.14714/CP92.1536 | [Crossref](https://api.crossref.org/works/10.14714/CP92.1536) | Registered metadata retrieved |
| 10.21105/joss.05751 | [Crossref](https://api.crossref.org/works/10.21105/joss.05751) | Registered metadata retrieved |
| 10.2760/098587 | [OP](https://doi.org/10.2760/098587) | Registered metadata retrieved |
| 10.2905/3C60DDF6-0586-4190-854B-F6AA0EDC2A30 | [DataCite](https://api.datacite.org/dois/10.2905/3C60DDF6-0586-4190-854B-F6AA0EDC2A30) | Registered metadata retrieved |
| 10.32614/RJ-2018-009 | [Crossref](https://api.crossref.org/works/10.32614/RJ-2018-009) | Registered metadata retrieved |
| 10.3390/su11154091 | [Crossref](https://api.crossref.org/works/10.3390/su11154091) | Registered metadata retrieved |
| 10.5281/zenodo.15345101 | [DataCite](https://api.datacite.org/dois/10.5281/zenodo.15345101) | Registered metadata retrieved |
| 10.5281/zenodo.23698418 | [DataCite](https://api.datacite.org/dois/10.5281/zenodo.23698418) | Registered metadata retrieved |
| 10.5281/zenodo.7561601 | [DataCite](https://api.datacite.org/dois/10.5281/zenodo.7561601) | Registered metadata retrieved |
