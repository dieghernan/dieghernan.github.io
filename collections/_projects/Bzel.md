---
title: Bzel
subtitle: A Pebble <i class="fas fa-skull-crossbones"></i> project
excerpt: Bzel integrates the bezel into your watch face. Display minutes as digits, as a moving dot or as a fill in the bezel.
tags:
  - discontinued
  - project
  - pebble
  - watchface
  - javascript
  - C
header_img: https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BannerBzel.png
date: 2017-05-25
permalink: /projects/Bzel/
project_links:
  - url: https://dieghernan.github.io/Bzel/
    icon: fas fa-external-link-alt
    label: Visit the website
  - url: https://github.com/dieghernan/Bzel
    icon: fab fa-github
    label: See on GitHub
og_image_alt: "Bzel watch face showing minutes around the bezel of Pebble watches."
---

<div role="note" aria-label="Important" class="callout-important" markdown="1">
**Project discontinued.** Development ended when Pebble shut down.
</div>

**Bzel** integrates the bezel into your watch face. Display minutes as digits,
as a moving dot or as a fill in the bezel.

![Bzel watch face with minutes displayed around the bezel.](https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BannerBzel.png)
<p class="caption">Bzel uses the bezel as an extra space for displaying the minutes.</p>

<div class="text-center">
<a class="btn btn-primary my-3 text-white" href="https://apps.rebble.io/en_US/application/59280895b67f9f43f80004c9">Download
from Rebble Appstore</a>
</div>

## Features

- Clock mode:
  - Digital: Minute display based on analog movement
  - Dot: Moving dot as a minute marker
  - Bezel: A bar moving around the bezel as a minute marker
- Autodetection of 12h/24h mode based on your watch settings

## Take your pick

- Pebble Health: Display daily steps.
- Date - Get the weekday based on the language set on your Pebble.
- Weather: Current conditions in °C or °F.
- Choose your weather provider:
  - [Yahoo.com](https://www.yahoo.com/?ilc=401) *No API key required at this
    moment*
  - [Wunderground](https://www.wunderground.com/?apiref=fb6856330e74c168)
  - [OpenWeatherMap](https://openweathermap.org/)
- Historical integration with Master Key (pmkey.xyz)
- Location based on your selected weather provider
- Night theme displayed between sunset and sunrise

## Internationalization

Automatic weekday translation is supported for:

- English
- Spanish
- German
- French
- Portuguese
- Italian

## Future developments

- [x] Location for weather
- [x] Square support
- [x] New minute mode: bezel
- [x] Steps
- [ ] More health metrics

## Screenshots

<div class="row">
<div class="col-sm mb-1">
    <img src="https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BezelPTR.gif" alt="Animated Bzel watch face on Pebble Time Round.">
    <p class="caption">Minute progress displayed around the Pebble Time Round bezel.</p>
</div>
<div class="col-sm mb-1">
    <img src="https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BezelPT.gif" alt="Animated Bzel watch face on Pebble Time.">
    <p class="caption">The bezel minute indicator adapted to the Pebble Time screen.</p>
</div>
<div class="col-sm mb-1">         
    <img src="https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BezelBW.gif" alt="Animated Bzel watch face on a monochrome Pebble watch.">
    <p class="caption">Monochrome version of the bezel-based minute display.</p>
</div>
</div>

## Attributions

### Fonts

- [Weather Icons](https://erikflowers.github.io/weather-icons) by Eric Flowers,
  modified and fitted to the regular alphabet instead of Unicode values.
- Custom font for icons created via Fontastic.
- Gotham Fonts downloaded from [fontsgeek.com](http://fontsgeek.com)

### Weather providers

<div class="row">
<div class="col">
<a href="https://www.wunderground.com/?apiref=fb6856330e74c168"><img src="https://icons.wxug.com/logos/PNG/wundergroundLogo_4c.png" width="120" alt="Weather Underground"></a>
</div>
<div class="col">
<a href="https://openweathermap.org/"><img src="https://openweathermap.org/themes/openweathermap/assets/vendor/owm/img/icons/logo_60x60.png" width="60" alt="OpenWeatherMap"></a>
</div>
</div>

### Others

Master Key (pmkey.xyz) was a service for Pebble users that managed API keys
through a unique PIN.

## License

Licensed under the [MIT license](https://raw.githubusercontent.com/dieghernan/Bzel/master/LICENSE).

**Made in Madrid, Spain ❤️**
