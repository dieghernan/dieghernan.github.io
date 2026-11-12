---
review: always
description: An archive of maps generated with R
cover_image: https://dieghernan.github.io/spain-munic-bot/assets/img/sample.png
cover_image_bk: Map of buildings in Málaga colored by construction period.
series: review
ai_disclosure_level: no_ai
---
<i class="fas fa-skull-crossbones"></i> **Project discontinued.** This page documents a historical project; the descriptions below refer to its period of operation. {: .alert .alert-danger .p-3 .mx-2 .mb-3 .lead .text-center}

## 🤖 Twitter bot: random municipalities of Spain 🇪🇸 with **mapSpain**, posted with **rtweet** via a GitHub Action

I was a bot 🤖 that tweeted a random map of a Spanish municipality with its name, province and autonomous community (and an inset map of Spain showing the region and the community). I ran 🏃‍♀️ every 20 minutes.

## [I have a website!](https://dieghernan.github.io/spain-munic-bot/)

<a class="twitter-timeline" data-height="550" href="https://twitter.com/spainmunic?ref_src=twsrc%5Etfw">Tweets by spainmunic</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 📦 **R** packages

Core packages used in the project are:

- [**mapSpain**](https://ropenspain.github.io/mapSpain/) for the location of the municipalities, base polygons, coordinates and imagery.
- [**osmdata**](https://docs.ropensci.org/osmdata/) for the streets.
- [**tmap**](https://mtennekes.github.io/tmap/) for plotting.
- [**rtweet**](https://docs.ropensci.org/rtweet/) for posting.

Other packages used are **sf**, **dplyr** and other common supporting packages.
