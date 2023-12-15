---
title: Corona timelapse 
subtitle: Travel restrictions amidst the COVID crisis across time - A German perspective
header_img: "https://corona-atlas.de/timelapse/frames/D2021-04-16.png"
date: 2022-03-14
tags: [project,R,maps,leaflet,python, guest-author]
project_links:
  - url: https://corona-atlas.de/en
    icon: fas fa-external-link-alt
    label: Visit the website
author:
  name   : "Rodrigo Hernangómez"
  avatar : "https://github.com/rodrihgh.png"
  bio    : "PhD student in Electrical Engineering. Fascinated by the interplay between beauty and math."
  location: Berlin, Germany
  links:
    - url: https://uselessness.science
      icon: fas fa-external-link-alt
      label: Personal website
    - label: "LinkedIn"
      icon: "fab fa-linkedin"
      url: "https://www.linkedin.com/in/rodrigohgh/"
    - label: "Twitter/X"
      icon: "fab fa-fw fa-square-x-twitter"
      url: "https://twitter.com/rodrihgh"
    - label: "GitHub"
      icon: "fab fa-fw fa-github"
      url: "https://github.com/rodrihgh"
    - url: https://orcid.org/0000-0002-1284-4951
      icon: fa-brands fa-orcid
output: 
  md_document:
  variant: gfm
  preserve_yaml: true
---

![corona-timelapse](https://corona-atlas.de/assets/img/corona_atlas_timelapse.gif)

In April 2021, my brother Diego and I saw
the need for a friendly and automated interface to the meticulous and ever-changing restrictions that the German authorities imposed to travels abroad amid the COVID crisis.

Despite the drastic variations in this regard that most foreign countries have experienced during last year, the mild character of the currently predominant Omicron variant has finally led Germany to lift all
COVID-related obstacles to international travel. The long-awaited contemplation of an all-green world map has filled us with joy, but, to be honest, it has also rendered [our website][corona-atlas] quite boring, no matter how many languages we have translated it into (6 as of now 🇩🇪 🇬🇧 🇪🇸 🇫🇷 🇵🇱 🇹🇷).

To compensate for this, we have put all the pieces together to produce a chronology of the COVID crisis through the lenses of the [Robert Koch Institut (RKI)](https://rki.de/risikogebiete), the German entity that was responsible for COVID risk assessment of international areas. Most of the effort was already made, since we have been scraping RKI's information (via [scrapy](https://scrapy.org/)) for almost one year. To complete the puzzle, we only needed to apply our method to the old risk assesment reports that had been issued before we started the project. That is, we have just combined our already developed scraping muscle with the
[Archive.org Wayback Machine](https://archive.org/web/) as provided by
[Evan Sangaline](https://sangaline.com/post/wayback-machine-scraper/), and we have of course worked around the inconsistencies of
German bureaucracy.

After all, we hope that [corona-atlas] remains boring and that our world map remains green. Now it is finally time for quite some **Wanderlust**!

## Links
* [Read more on this site](../projects/corona-atlas)
* [Project's Website][corona-atlas]
* [Project's Repository](https://github.com/dieghernan/RKI-Corona-Atlas)

[corona-atlas]: https://corona-atlas.de/en
