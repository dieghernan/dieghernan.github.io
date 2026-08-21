---
title: Sfera
subtitle: A Pebble <i class="fas fa-skull-crossbones"></i> project
excerpt: Sfera for Pebble Time Round is a highly customizable watch face that gets the most out of the smartwatch capabilities. Set your preferences and enjoy this beautifully designed watch face.
tags:
  - discontinued
  - project
  - pebble
  - watchface
  - javascript
  - C
header_img: https://raw.githubusercontent.com/dieghernan/Sfera/master/assets/SferaBanner.png
date: 2017-03-14
permalink: /projects/Sfera/
project_links:
  - url: https://github.com/dieghernan/Sfera
    icon: fab fa-github
    label: See on GitHub
---

**Project discontinued** due to the shutdown of Pebble.
{: .alert .alert-danger .p-3 .mx-2 .mb-3 .lead}

**Sfera** for Pebble Time Round is a highly customizable watch face that gets
the most out of the smartwatch capabilities. Set your preferences and enjoy this
beautifully designed watch face.

![Banner](https://raw.githubusercontent.com/dieghernan/Sfera/master/assets/SferaBanner.png)

<div class="text-center">
<a class="btn btn-primary my-3 text-white" href="https://apps.rebble.io/en_US/application/58c2f7110dfc32a52a00081f?native=false&query=Sfera&section=watchfaces" role="button">Download from Rebble Appstore</a>
</div>

## Features

- Clock mode:
  - Analog: Classic analog watch face
  - Digital: Centered hour and minute display based on analog movement
  - Dual: Analog and digital, all in one
  - Mix: Digital hour and analog minute
- Autodetection of 12h/24h mode based on your watch settings

## Take your pick

- Date - Get the weekday based on the language set on your Pebble.
- Dots as minute markers - choose your color
- Battery level displayed beautifully as an arc near the bezel. Choose your color and, below 20%, it turns red!
- Weather: Current conditions in °C or °F.
- Choose your weather provider:
  - [Yahoo.com](https://www.yahoo.com/?ilc=401) _No API key required at this moment_
  - [Wunderground](https://www.wunderground.com/?apiref=fb6856330e74c168)
  - [OpenWeatherMap](https://openweathermap.org/)
- Implementation of [pmkey.xyz](https://www.pmkey.xyz)
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

- [x] 12/24h mode
- [x] Night theme
- [x] Several weather providers available
- [x] [pmkey.xyz](https://www.pmkey.xyz) implemented for easy API key management

## Screenshots

![GIF](https://raw.githubusercontent.com/dieghernan/Sfera/master/assets/SferaGif.gif)

## Attributions

### Fonts

- [Weather Icons](https://erikflowers.github.io/weather-icons) by Eric Flowers,
  modified and fitted to the regular alphabet instead of Unicode values.
- Custom font for icons created via **Fontastic** downloaded from [fontsgeek.com](http://fontsgeek.com)

### Weather providers

<div class="row">
<div class="col">
<a href="https://www.yahoo.com/?ilc=401"><img src="https://poweredby.yahoo.com/purple.png" alt="wp"></a>
</div>
<div class="col">
<a href="https://www.wunderground.com/?apiref=fb6856330e74c168"><img src="https://icons.wxug.com/logos/PNG/wundergroundLogo_4c.png" width="120" alt="wp"></a>
</div>
<div class="col">
<a href="https://openweathermap.org/"><img src="https://openweathermap.org/themes/openweathermap/assets/vendor/owm/img/icons/logo_60x60.png" width="60" alt="wp"></a>
</div>
</div>

### Others

[Master Key](https://www.pmkey.xyz) is a service for Pebble users. Get a unique
PIN and add API keys for your favorite online services. Please check
[www.pmkey.xyz](https://www.pmkey.xyz) for more info.

## License

Developed under license [MIT](https://raw.githubusercontent.com/dieghernan/Sfera/master/LICENSE).

**Made in Madrid, Spain ❤️**
