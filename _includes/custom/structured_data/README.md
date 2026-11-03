# Blog-specific structured data

This layer complements Chulapa without replacing or normalizing its JSON-LD.
The gallery is deliberately excluded.

`_data/structured_data.json` contains the profile, project entity summaries and
explicit page-to-project relationships. Reuse canonical identifiers from the
project websites. Do not copy their release dates, versions or distributions.
New locally described resources have stable identifiers on their project page.

The featured package list reads `featured_packages` from the Projects page,
so its markup follows the visible cards. Chulapa retains responsibility for
the general collection list, articles, pages and breadcrumbs.

Project summaries use `subjectOf` to reference the existing project WebPage or
BlogPosting. Only explicitly selected articles receive these relationships;
code examples alone do not qualify. Package article summaries reuse the same
featured package definitions. Software licenses are checked against the upstream
license files and R package DESCRIPTION files. Celestial Data retains the
collection's BSD-3-Clause license and both creators. Do not infer a data license
from a repository's software license, or invent versions or sole authorship.

The existing ProfilePage uses the shared personal identity, preserving its
sameAs profiles and ORCID. This does not alter the theme's author entities.

Build with `bundle exec jekyll build`, then run
`py -m unittest discover -s _scripts -p test_structured_data.py`.

## Upstream verification

Last checked: November 3, 2026. This is a manual synchronization, not a live
import. Recheck these sources when updating a project summary. Keep canonical
resource identifiers, URLs, DOI identifiers, licenses and author identities
aligned with upstream. English names and descriptions may summarize or translate
the original, including its limitations. The blog adds its own `subjectOf` link.

| Project | Source of truth | Result |
| --- | --- | --- |
| Códigos postales de España | [Dataset JSON-LD](https://dieghernan.github.io/codigospostales/) | Canonical dataset ID, DOI, CC BY 4.0 license and creator match. |
| Celestial Data | [Collection JSON-LD](https://dieghernan.github.io/celestial_data/) | Canonical collection ID, DOI, BSD license and both creators match. Preserve the distinction between current downloads and the DOI archive. |
| leaflet-providersESP | [Software JSON-LD](https://dieghernan.github.io/leaflet-providersESP/) | Canonical source-code ID, repository, MIT license, author and Leaflet runtime match. |
| COVID19 | [Dataset JSON-LD](https://dieghernan.github.io/COVID19/) | Dataset ID and creator match. Preserve the February–April 2020 coverage. Upstream does not declare a dataset license. |
| spain-munic-bot | [Software JSON-LD](https://dieghernan.github.io/spain-munic-bot/) | Canonical source-code ID, repository, MIT license, author and R runtime match. Posting remains disabled. |
| Country codes and international organizations | [Repository README](https://github.com/dieghernan/Country-Codes-and-International-Organizations#readme) and [LICENSE](https://github.com/dieghernan/Country-Codes-and-International-Organizations/blob/HEAD/LICENSE) | No project JSON-LD found. Retain the blog-assigned dataset ID. Do not apply the software MIT license to the aggregated data. |
| Corona Atlas | [Repository](https://github.com/dieghernan/corona-atlas.de), especially `_config.yml`, README and LICENSE | No dedicated software JSON-LD found. Retain the blog-assigned source-code ID and MIT license. The configuration credits “Diego & Rodrigo”; do not infer sole authorship. |
| 7egment | [Repository](https://github.com/dieghernan/7egment), especially `package.json`, README and LICENSE | No project JSON-LD found. Retain the blog-assigned source-code ID. MIT license and author handle verified. |
| Bzel | [Repository](https://github.com/dieghernan/Bzel), especially `package.json`, README and LICENSE | No project JSON-LD found. Retain the blog-assigned source-code ID. MIT license and author handle verified. |
| Sfera | [Repository](https://github.com/dieghernan/Sfera), especially `package.json`, README and LICENSE | No project JSON-LD found. Retain the blog-assigned source-code ID. MIT license and author handle verified. |
| TextWatch Clima | [Repository](https://github.com/dieghernan/TextWatchClima), especially `package.json`, README and `MIT License` | No project JSON-LD found. Retain the blog-assigned source-code ID. MIT license and author handle verified. |
| tidyterra | [DESCRIPTION](https://github.com/dieghernan/tidyterra/blob/HEAD/DESCRIPTION) and [CITATION.cff](https://github.com/dieghernan/tidyterra/blob/HEAD/CITATION.cff) | Documentation URL, source repository, MIT license, author and JOSS DOI verified. |
| cffr | [DESCRIPTION](https://github.com/ropensci/cffr/blob/HEAD/DESCRIPTION) and [CITATION.cff](https://github.com/ropensci/cffr/blob/HEAD/CITATION.cff) | Documentation URL, source repository, GPL-3.0-or-later license, author and JOSS DOI verified. |
| giscoR | [DESCRIPTION](https://github.com/rOpenGov/giscoR/blob/HEAD/DESCRIPTION) and [CITATION.cff](https://github.com/rOpenGov/giscoR/blob/HEAD/CITATION.cff) | Documentation URL, source repository, GPL-3.0-only license, author and CRAN DOI verified. |
| mapSpain | [DESCRIPTION](https://github.com/rOpenSpain/mapSpain/blob/HEAD/DESCRIPTION) and [CITATION.cff](https://github.com/rOpenSpain/mapSpain/blob/HEAD/CITATION.cff) | Documentation URL, source repository, GPL-3.0-only license, author and CRAN DOI verified. |
| geobounds | [DESCRIPTION](https://github.com/dieghernan/geobounds/blob/HEAD/DESCRIPTION) and [CITATION.cff](https://github.com/dieghernan/geobounds/blob/HEAD/CITATION.cff) | Documentation URL, source repository, MIT license, author and CRAN DOI verified. |
| resmush | [DESCRIPTION](https://github.com/dieghernan/resmush/blob/HEAD/DESCRIPTION) and [CITATION.cff](https://github.com/dieghernan/resmush/blob/HEAD/CITATION.cff) | Documentation URL, source repository, MIT license, author and CRAN DOI verified. |

The six package homepages do not currently publish package JSON-LD. Their
`#source-code` IDs remain blog-assigned summary identifiers. Their `sameAs`
values use the JOSS DOI declared in CITATION.cff for tidyterra and cffr. The
remaining entries use their verified CRAN DOI. All six files identify Diego
Hernangómez as the
author, so the summaries reuse the shared profile. Package software licenses
do not describe the licenses of downloaded geographic data.

Corona Atlas also publishes legacy theme JSON-LD, including a malformed WebPage
block. This blog does not copy that markup; the repository's configuration and
license provide the author credit and software license for its summary.
