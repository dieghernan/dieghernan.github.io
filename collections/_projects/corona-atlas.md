---
title: Corona Atlas 
subtitle: Interactive map of the international COVID-19 risk areas as designated by the German authorities.
header_img: "https://corona-atlas.de/assets/img/og_corona_atlas.png"
date: 2021-04-30
tags: [project,R,maps,leaflet,python]
permalink: /projects/corona-atlas/
project_links:
    - url: https://corona-atlas.de/
      icon: fas fa-external-link-alt
      label: Visit the website
excerpt: Interactive map of the international COVID-19 risk areas as designated by the German authorities. The data is updated periodically from the website of the Robert Koch Institute.
---

<img src="https://corona-atlas.de/assets/img/corona-atlas-icon.png" alt="corona-logo" style="width: 25%;">

Visit <https://corona-atlas.de/>


Interactive map of the international COVID-19 risk areas as designated by the German authorities.

The data is updated periodically from the website of the [Robert Koch Institute](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Risikogebiete_neu.html).

Data scraping is performed on **Python** with
[**scrapy**](https://scrapy.org/).
The scraper also uses
[**pandas**](https://pandas.pydata.org/) and
[**pycountry**](https://pypi.org/project/pycountry/).

For the prototype version, map visualization was created with **R** and generated a map via [{rmarkdown}](https://rmarkdown.rstudio.com/) using [{leaflet}](http://rstudio.github.io/leaflet/), [{giscoR}](https://dieghernan.github.io/giscoR/) and some packages included on the [tidyverse](https://www.tidyverse.org/).
For the deployment, map logic has moved to Javascript to escalate with multiple languages.

[Read more in this post](/202203_Corona-timelapse)
