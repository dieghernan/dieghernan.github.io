---
title: Leaflet-providersESP
subtitle: Plugin for Leaflte.js
date: 2020-10-26
header_img: ./assets/img/misc/leaflet-providersesp.png
tags: [project,maps,leaflet]
permalink: /projects/leaflet-providersESP/
project_links:
    - url: https://dieghernan.github.io/leaflet-providersESP/
      icon: fas fa-external-link-alt
      label: Visit the website
excerpt: Leaflet plugin for adding WMS/WMTS provided by public organisms of Spain.
---

**Leaflet-providersESP** is a plugin for [Leaflet](https://leafletjs.com/) that contains configurations for various tile layers provided by public organisms of Spain.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4318010.svg)](https://doi.org/10.5281/zenodo.4318010)


## Demo

Full docs and examples on <https://dieghernan.github.io/leaflet-providersESP/>


This code would generate a leaflet map with a layer provided by Leaflet-providersESP.

```html
<!DOCTYPE html>
<html>
<head>
	<title>Minimal page | leaflet-providersESP</title>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<!-- Load Leaflet -->
	<link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
	<script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
	<!-- Install leaflet-providersESP -->
	<script src="https://cdn.jsdelivr.net/gh/dieghernan/leaflet-providersESP/dist/leaflet-providersESP.min.js"></script>
	<!-- Display map full page -->
	<style>
	html {
		height: 100%
	}
	body {
		height: 100%;
		margin: 0;
		padding: 0;
	}
	#mapid {
		height: 100%;
		width: 100%
	}
	</style>
</head>
<body>
	<!-- Create map -->
	<div id="mapid"></div>
	<!-- Puerta del Sol - IDErioja server -->
	<script>
	var mymap = L.map('mapid').setView([40.4166, -3.7038400], 18);
	L.tileLayer.providerESP('IDErioja').addTo(mymap);
	</script>
</body>
```

<div class="embed-responsive embed-responsive-4by3 my-2 chulapa-rounded-lg border border-primary">
  <iframe class="embed-responsive-item" src="https://dieghernan.github.io/leaflet-providersESP/demo/minimal" allowfullscreen loading="lazy"></iframe>
</div>

