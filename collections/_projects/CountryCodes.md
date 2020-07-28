---
title: Country Codes & Organizations
subtitle: A database with geocodes
header_img: https://dieghernan.github.io/assets/figs/20190427_mapfin-1.png
tags: [project,R,webscrapping]
permalink: /Country-Codes-and-International-Organizations/
date: 2019-04-11
project_links:
    - url: https://github.com/dieghernan/Country-Codes-and-International-Organizations
      icon: fab fa-github
      label: See on Github
show_toc: true
---

Complete database of countries and territories, their different country codes under common standards (ISO-3166, GEC *(Formerly FIPS*), M49 (*UN*), STANAG (*NATO*), NUTS (*EU*), etc.) and their membership in different international organizations.

<sup>*Note that blanks are presented as* `""` *instead of* `NA` *since ISO-3166-ALPHA 2 for Namibia is* **NA**.</sup>

**[vignette: Using Country Codes](https://dieghernan.github.io/201904_Using-CountryCodes/)**

## A. Country Codes `.csv`

Main `.csv` file [(Link)](https://github.com/dieghernan/Country-Codes-and-International-Organizations/tree/master/outputs/Countrycodes.csv) containing:

* Country and regional codes
* Currency, dependency status ans sovereignty info
* Names in english and spanish as provided by [Unicode CLDR](http://cldr.unicode.org/translation/displaynames/country-names)
* Additional information (demographics, capital, area, etc.)

### Codes included

Field | Description | Source |Notes 
--- | --------- | -----|-----
ISO_3166_1|ISO 3166-1 numeric |Wikipedia
ISO_3166_2|ISO 3166-1 alpha-2 |Wikipedia
ISO_3166_3|ISO 3166-1 alpha-3 |Wikipedia
FIPS_GEC|Geopolitical Entities and Codes (GEC)| CIA World Factbook|[Formerly FIPS 1PUB 10-4](https://www.cia.gov/library/publications/the-world-factbook/appendix/appendix-d.html)
STANAG|STANAG 1059 Country Codes| CIA World Factbook|  Used by NATO
M49|UN Country Code| UN Stats
NUTS|NUTS 0 code |Wikipedia |Used by EU
geonameId|geonameId|geonames
continentcode|geonames Continent Code|geonames
regioncode|UN Regional Code|UN Stats
interregioncode|Interregional Code|UN Stats
subregioncode|Subregion Code|UN Stats
ISO_3166_3.sov|Sovereign code |Wikipedia, Statoids | If non-independent

### Other information included

* Currency
* Dependency status
* Names in english and spanish: Country, Continents & Regions, capital
* Population, area (km<sup>2</sup>) and developed region


## B. International Organizations `.csv`

A single `.csv` file [(Link)](https://github.com/dieghernan/Country-Codes-and-International-Organizations/tree/master/outputs/CountrycodesOrgs.csv) describing the membership status of each country across 186 international organizations.

Field | Description
--- | ---------
ISO_3166_2| Matches with Countrycodes `.csv`
ISO_3166_3| Matches with Countrycodes `.csv`
NAME.EN| Matches with Countrycodes `.csv`
source| Main data source
org_name| Name of the organization
org_id | Abbreviation or internal ID
org_member | Membership status

## C. Full json file `.json`

This `.json` file [(Link)](https://github.com/dieghernan/Country-Codes-and-International-Organizations/tree/master/outputs/Countrycodesfull.json) combines the previous files:

```json
[
  ...
  {
    "ISO_3166_1": 12,
    "ISO_3166_2": "DZ",
    "ISO_3166_3": "DZA",
    "ISO_Official": true,
    "FIPS_GEC": "AG",
    "STANAG": "DZA",
    "M49": 12,
    "geonameId": 2589581,
    "continentcode": "AF",
    "regioncode": 2,
    "subregioncode": 15,
    "currency": "DZD",
    "independent": true,
    "NAME.EN": "Algeria",
    "CONTINENT.EN": "Africa",
    "REGION.EN": "Africa",
    "SUBREGION.EN": "Northern Africa",
    "CAPITAL.EN": "Algiers",
    "NAME.ES": "Argelia",
    "CONTINENT.ES": "Africa",
    "REGION.ES": "África",
    "SUBREGION.ES": "África septentrional",
    "CAPITAL.ES": "Argel",
    "pop": 34586184,
    "area_km2": 2381740,
    "Developed": "Developing",
    "org_id": ["ABEDA", "ACP", "ADB", "AFDB", "AFESD", "AG", "AL", 
    ...
    ],
    "org_member": ["member", null, null, "member", "member", null,
    "member",
    ...
    ]
  },
  ...
]
```
A complementary function (intended to be used in **R**) has been developed:

```r
ISO_memcol = function(df, #Input dataframe
                      orgtosearch #org id
) {
  ind = match(orgtosearch, unlist(df[1, "org_id"]))
  or = lapply(1:nrow(df), function(x)
    unlist(df[x, "org_member"])[ind])
  or = data.frame(matrix(unlist(or)), stringsAsFactors = F)
  names(or) = orgtosearch
  df2 = as.data.frame(cbind(df, or, stringsAsFactors = F))
  return(df2)
}
```


## D. Data sources

* Wikipedia, the free encyclopedia
  * [ISO-3166](https://en.wikipedia.org/wiki/ISO_3166-1)
  * [NUTS](https://es.wikipedia.org/wiki/Nomenclatura_de_las_Unidades_Territoriales_Estad%C3%ADsticas)
* The World Factbook - CIA: [https://www.cia.gov/library/publications/the-world-factbook/index.html](https://www.cia.gov/library/publications/the-world-factbook/index.html) 
* [United Nations Statistical Division](https://unstats.un.org/unsd/methodology/m49/overview/)
* [geonames](https://www.geonames.org/)
* [REST COUNTRIES](https://restcountries.eu/)
* [Unicode Common Locale Data Repository (CLDR) Project](https://github.com/unicode-cldr)
* [http://www.statoids.com/](http://www.statoids.com/)
