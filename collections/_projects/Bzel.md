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
  - url: https://github.com/dieghernan/Bzel
    icon: fab fa-github
    label: See on GitHub
---

**Project discontinued** due to the shutdown of Pebble. {: .alert .alert-danger
.p-3 .mx-2 .mb-3 .lead}

**Bzel** integrates the bezel into your watch face. Display minutes as digits,
as a moving dot or as a fill in the bezel.

![Bzel watch face with minutes displayed around the bezel.](https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BannerBzel.png)

::: text-center
<a class="btn btn-primary my-3 text-white" href="https://apps.rebble.io/en_US/application/59280895b67f9f43f80004c9" role="button">Download
from Rebble Appstore</a>
:::

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

:::::: row
::: {.col-sm .mb-1}
```         
    <img src="https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BezelPTR.gif" alt="Animated Bzel watch face on Pebble Time Round.">
```
:::

::: {.col-sm .mb-1}
```         
    <img src="https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BezelPT.gif" alt="Animated Bzel watch face on Pebble Time.">
```
:::

::: {.col-sm .mb-1}
```         
    <img src="https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BezelBW.gif" alt="Animated Bzel watch face on a monochrome Pebble watch.">
```
:::
::::::

## Attributions

### Fonts

- [Weather Icons](https://erikflowers.github.io/weather-icons) by Eric Flowers,
  modified and fitted to the regular alphabet instead of Unicode values.
- Custom font for icons created via Fontastic.
- Gotham Fonts downloaded from [fontsgeek.com](http://fontsgeek.com)

### Weather providers

:::::: row
::: col
<a href="https://www.yahoo.com/?ilc=401"><img src="https://poweredby.yahoo.com/purple.png" alt="Powered by Yahoo"/></a>
:::

::: col
<a href="https://www.wunderground.com/?apiref=fb6856330e74c168"><img src="https://icons.wxug.com/logos/PNG/wundergroundLogo_4c.png" alt="Weather Underground" width="120"/></a>
:::

::: col
<a href="https://openweathermap.org/"><img src="https://openweathermap.org/themes/openweathermap/assets/vendor/owm/img/icons/logo_60x60.png" alt="OpenWeatherMap" width="60"/></a>
:::
::::::

### Others

Master Key (pmkey.xyz) was a service for Pebble users that managed API keys
through a unique PIN.

## License

Developed under license
[MIT](https://raw.githubusercontent.com/dieghernan/Bzel/master/LICENSE).

**Made in Madrid, Spain ❤️**
