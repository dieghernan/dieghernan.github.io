---
title: spain-munic-bot
subtitle: A twitter bot written in R.
excerpt: Twitter bot - random municipalities of Spain with {mapSpain} posted with {rtweet} via a GitHub Action
tags:
  - discontinued
  - project
  - R
  - maps
  - twitter
header_img: "https://dieghernan.github.io/spain-munic-bot/assets/img/sample.png"
date: 2021-01-29
permalink: /projects/spain-munic-bot/
project_links:
  - url: https://dieghernan.github.io/spain-munic-bot/
    icon: fas fa-external-link-alt
    label: Visit the website
---

<i class="fas fa-skull-crossbones"></i> **Project discontinued**
{: .alert .alert-danger .p-3 .mx-2 .mb-3 .lead .text-center}

## 🤖 Twitter bot: random municipalities of Spain 🇪🇸 with **mapSpain**, posted with **rtweet** via a GitHub Action

Hi! I am a bot 🤖 that tweets a random map of a Spanish municipality with its name, province and autonomous community (and an inset map of Spain showing the region and the community). I run 🏃‍♀️ every 20 minutes.

## [I have a website!!](https://dieghernan.github.io/spain-munic-bot/)

<a class="twitter-timeline" data-height="550" href="https://twitter.com/spainmunic?ref_src=twsrc%5Etfw">Tweets by spainmunic</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 📦 **R** packages

Core packages used in the project are:

- [{mapSpain}](https://ropenspain.github.io/mapSpain/) for the location of the municipalities, base polygons and coordinates and imagery,
- [{osmdata}](https://docs.ropensci.org/osmdata/) for the streets,
- [{tmap}](https://mtennekes.github.io/tmap/) for plotting,
- [{rtweet}](https://docs.ropensci.org/rtweet/) for posting,

Other packages used are **sf**, **dplyr** and other common supporting packages.
