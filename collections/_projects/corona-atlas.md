---
title: Corona Atlas 
subtitle: Interactive map of the international COVID-19 risk areas as designated by the German authorities.
header_img: "https://corona-atlas.de/assets/img/og_corona_atlas.png"
date: 2021-04-30
tags: [project,R,maps,leaflet,python]
permalink: /corona-atlas/
project_links:
    - url: https://corona-atlas.de/
      icon: fas fa-external-link-alt
      label: Visit the website
excerpt: Interactive map of the international COVID-19 risk areas as designated by the German authorities. The data is updated periodically from the website of the Robert Koch Institute.
---

![corona-logo](https://corona-atlas.de/assets/img/corona-atlas-icon.png)

Visit https://corona-atlas.de/


Interactive map of the international COVID-19 risk areas as designated by the German authorities.

The data is updated periodically from the website of the [Robert Koch Institute][rki].

Data scraping is performed on **Python** with
[**scrapy**](https://scrapy.org/).
The scraper also uses
[**pandas**](https://pandas.pydata.org/) and
[**pycountry**](https://pypi.org/project/pycountry/).

Map visualization is created with **R** and generates a map via [{rmarkdown}](https://rmarkdown.rstudio.com/). The map is created using [{leaflet}](http://rstudio.github.io/leaflet/), [{giscoR}](https://dieghernan.github.io/giscoR/) and some packages included on the [tidyverse](https://www.tidyverse.org/).
