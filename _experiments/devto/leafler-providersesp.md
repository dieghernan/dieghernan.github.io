---
review: always
tags_choose_4: rstats,leaflet,maps,project
description: Plugin for Leaflet.js
cover_image: https://dieghernan.github.io/assets/img/misc/leaflet-providersesp.png
cover_image_bk: ~
series: review
ai_disclosure_level: no_ai
---

Has alerts? FALSE
Has Spotify? FALSE
Has iframe? TRUE
Has details_summary? FALSE
Has math? FALSE

**Leaflet-providersESP** is a plugin for [Leaflet](https://leafletjs.com/) that contains configurations for various tile layers provided by public agencies in Spain.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4318010.svg)](https://doi.org/10.5281/zenodo.4318010)

## Demo

Full docs and examples are available at <https://dieghernan.github.io/leaflet-providersESP/>.

This code generates a Leaflet map with a layer provided by Leaflet-providersESP.

``` html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Minimal page | leaflet-providersESP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <!-- Load Leaflet -->
    <link
      rel="stylesheet"
      href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
    />
    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
    <!-- Install leaflet-providersESP -->
    <script src="https://cdn.jsdelivr.net/gh/dieghernan/leaflet-providersESP/dist/leaflet-providersESP.min.js"></script>
    <!-- Display map full page -->
    <style>
      html {
        height: 100%;
      }
      body {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      #mapid {
        height: 100%;
        width: 100%;
      }
    </style>
  </head>
  <body>
    <!-- Create map -->
    <div id="mapid"></div>
    <!-- Puerta del Sol - IDErioja server -->
    <script>
      var mymap = L.map("mapid").setView([40.4166, -3.70384], 18);
      L.tileLayer.providerESP("IDErioja").addTo(mymap);
    </script>
  </body>
</html>
```

<div class="embed-responsive embed-responsive-4by3 my-2 chulapa-rounded-lg border border-primary">
  <iframe class="embed-responsive-item" title="Leaflet-providersESP minimal map demo" src="https://dieghernan.github.io/leaflet-providersESP/demo/minimal" allowfullscreen loading="lazy"></iframe>
</div>

## All providers

{: .mt-5 .mb-2}

<p class="d-flex flex-wrap">
  <a class="btn btn-primary mr-2 mb-2" href="https://dieghernan.github.io/leaflet-providersESP/allproviders/">Open the map in a full window</a>
  <a class="btn btn-outline-primary mb-2" href="https://dieghernan.github.io/leaflet-providersESP/">Documentation</a>
</p>

<div class="embed-responsive embed-responsive-4by3 my-2 chulapa-rounded-lg border border-primary">
  <iframe class="embed-responsive-item" title="Leaflet-providersESP map with all providers" src="https://dieghernan.github.io/leaflet-providersESP/allproviders/" allowfullscreen loading="lazy"></iframe>
</div>
