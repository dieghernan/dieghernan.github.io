---
review: always
tags_choose_4: rstats,COVID19,discontinued,guest-author,leaflet,maps,project,python
description: Travel restrictions amidst the COVID crisis across time - A German perspective
cover_image: https://raw.githubusercontent.com/dieghernan/corona-atlas.de/master/timelapse/frames/D2021-04-16.png
cover_image_bk: ~
series: review
ai_disclosure_level: no_ai
---

Has alerts? TRUE
Has Spotify? FALSE
Has iframe? FALSE
Has details_summary? FALSE
Has math? FALSE

<i class="fas fa-skull-crossbones"></i> **Project discontinued.** This post reflects the situation in March 2022 and is preserved as a historical account, not current travel information. {: .alert .alert-danger .p-3 .mx-2 .mb-3 .lead .text-center}

![Animated map tracking the spread of COVID-19 over time.](https://dieghernan.github.io/corona-atlas.de/assets/img/corona_atlas_timelapse.gif)

In April 2021, my brother Diego and I saw the need for a friendly and automated interface to the meticulous and ever-changing restrictions that the German authorities imposed on travel abroad amid the COVID crisis.

Despite the drastic variations in this regard that most foreign countries have experienced during the last year, the mild character of the currently predominant Omicron variant has finally led Germany to lift all COVID-related obstacles to international travel. The long-awaited contemplation of an all-green world map has filled us with joy, but, to be honest, it has also rendered [our website](https://dieghernan.github.io/corona-atlas.de/en) quite boring, no matter how many languages we have translated it into (6 as of now 🇩🇪 🇬🇧 🇪🇸 🇫🇷 🇵🇱 🇹🇷).

To compensate for this, we have put all the pieces together to produce a chronology of the COVID crisis through the lenses of the [Robert Koch Institut (RKI)](https://rki.de/risikogebiete), the German entity that was responsible for COVID risk assessment of international areas. Most of the effort was already made, since we have been scraping RKI's information (via [scrapy](https://scrapy.org/)) for almost one year. To complete the puzzle, we only needed to apply our method to the old risk assessment reports that had been issued before we started the project. That is, we have just combined our already developed scraping muscle with the [Archive.org Wayback Machine](https://archive.org/web/) as provided by [Evan Sangaline](https://sangaline.com/post/wayback-machine-scraper/), and we have of course worked around the inconsistencies of German bureaucracy.

After all, we hope that [corona-atlas](https://dieghernan.github.io/corona-atlas.de/en) remains boring and that our world map remains green. Now it is finally time for quite some **Wanderlust**!

## Links

- [Read more on this site](https://dieghernan.github.io/projects/corona-atlas/)
- [Project's Website](https://dieghernan.github.io/corona-atlas.de/en)
- [Project's Repository](https://github.com/dieghernan/corona-atlas.de)
