---
title: Bzel 
subtitle: A Pebble (RIP) project
share-img: https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BannerBzel.png
date: 2017-05-25
donate: true
tags: [project,pebble,watchface,javascript,C]
permalink: /Bzel/
githuburl: https://github.com/dieghernan/Bzel
output: github_document
---

**Bzel** intregates the bezel into your watchface. Display minutes as digits, as a moving dot or as a fill in the bezel.

![Banner](https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BannerBzel.png)

#### [Download from Pebble Appstore](https://apps.getpebble.com/applications/59280895b67f9f43f80004c9)

## Features
* Clock mode:
   * Digital: Minute display based on analog movement
   * Dot: Moving dot as minute marker
   * Bezel: A bar moving around the bezel as minute marker
* Autodetection of 12h/24h based on your watch settings

## Take your pick
 * Pebble Health: Display daily steps.
 * Date - Get the weekday based on the language set on your Pebble.
 * Weather: Current conditions on °c or °f.
 * Choose your weather provider:
    * [Yahoo.com](https://www.yahoo.com/?ilc=401) _No API Key required (at this moment)_
    * [Wunderground](https://www.wunderground.com/?apiref=fb6856330e74c168)
    * [OpenWeatherMap](https://openweathermap.org/)
 * Implementation of [pmkey.xyz](https://www.pmkey.xyz)    
 * Location, based on your selected weather provider
 * On Bluetooth disconnected displays ![BTDis](https://raw.githubusercontent.com/dieghernan/Sfera/master/assets/BTDisconnectIcon.png)
 * On GPS requested but disconnected displays ![GPSDis](https://raw.githubusercontent.com/dieghernan/Sfera/master/assets/GPSDisconnectIcon.png)
 * Night theme displayed between sunset and sunrise
    
## Internationalization
Autotranslating of weekday supported for:
* English 
* Spanish
* German
* French
* Portuguese
* Italian

## Future developments
- [x] Location for weather and loc
- [x] Square support
- [x] New Minute Mode: Bezel
- [x] Steps
- [ ] More Health Metrics

# Screenshots
![GIF](https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BezelPTR.gif)
![GIF](https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BezelPT.gif)
![GIF](https://raw.githubusercontent.com/dieghernan/Bzel/master/store/BezelBW.gif)

## Attributions
### Fonts: 
 * [Weather Icons](https://erikflowers.github.io/weather-icons) by Eric Flowers, modified and fitted to regular alphabet, instead of Unicode values.
 * Custom font for icons created via [Fontastic](http://fontastic.me/).
 * [Gotham Fonts](http://fontsgeek.com/search?q=gotham) downloaded from [fontsgeek.com](http://fontsgeek.com)
  
### Weather providers  

<a href="https://www.yahoo.com/?ilc=401"><img src="https://poweredby.yahoo.com/purple.png"></a>

<a href="https://www.wunderground.com/?apiref=fb6856330e74c168"><img src="https://icons.wxug.com/logos/PNG/wundergroundLogo_4c.png" width="120" ></a>

[OpenWeatherMap.org](https://openweathermap.org/)

### Others

[Master Key](https://www.pmkey.xyz) is a service for Pebble users. Get a unique PIN and add API Keys for your favorite online services. Please check [www.pmkey.xyz](https://www.pmkey.xyz) for more info.

## License
Developed under license [MIT](https://raw.githubusercontent.com/dieghernan/Bzel/master/LICENSE).


#### Made in Madrid, Spain
