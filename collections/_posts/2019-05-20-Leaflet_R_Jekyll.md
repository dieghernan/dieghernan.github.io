---
title: Leaflet, <strong>R</strong>, Markdown, Jekyll and GitHub
subtitle: Make it work in 6 steps - a short tutorial
tags: [R,leaflet,Jekyll, html, maps]
header_img: https://dieghernan.github.io/assets/figs/20190520_imgpost.png
linktormd: true
leafletmap: true
always_allow_html: yes
last_modified_at: 2020-09-03
show_toc: true
output: 
  md_document:
    variant: gfm
    preserve_yaml: true
---

Recently I have been struggling when trying to embed a [leaflet](https://rstudio.github.io/leaflet) map created with **RStudio** on my blog, hosted in GitHub via [Jekyll](https://jekyllrb.com) (**Spoiler**: [I succeeded <i class="fas fa-thumbs-up"></i>](https://dieghernan.github.io/201905_Where-in-the-world)). In my case, I use ~~the [**Beautiful Jekyll**](https://deanattali.com/beautiful-jekyll/getstarted/) implementation created by [@daattali](https://github.com/daattali).~~ my own Jekyll template,  <a href="https://dieghernan.github.io/chulapa" class="chulapa">chulapa</a>.

So I decided to spend a good amount of time shaping this small tutorial. It can be longer than expected but after doing this process 3 or 4 times it becomes almost trivial.

Ready? Let's go!

### The GitHub/Jekyll part 

The first step is to install the requested libraries in your GitHub page. As Jekyll basically transforms `markdown` into `html`, this step is a matter of **what to include** and **where** in your own repository.


## 1. What to include

This part is not really hard. When having a look to the source code of [Leaflet for R](https://rstudio.github.io/leaflet/) site it can be seen this chunk:

``` html
<head>
  <!--code-->
  
  <script src="libs/jquery/jquery.min.js"></script>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="libs/bootstrap/css/flatly.min.css" rel="stylesheet" />
  <script src="libs/bootstrap/js/bootstrap.min.js"></script>
  <script src="libs/bootstrap/shim/html5shiv.min.js"></script>
  
  ...
  <!--more libraries-->
  ...
  
  <link href="libs/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
  <script src="libs/leaflet-binding/leaflet.js"></script>
  
  <!--code-->
</head>
```

So now we have it! The only thing to remember is that we need **to load the libraries from the leaflet server (`https://rstudio.github.io/leaflet`)**, meaning that we have to prepend that url to the libraries in our installation:

``` html
  <script src="https://rstudio.github.io/leaflet/libs/jquery/jquery.min.js"></script>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://rstudio.github.io/leaflet/libs/bootstrap/css/flatly.min.css" rel="stylesheet" />
  
  ...
  <!--more libraries-->
  ...
  
  <link     href="https://rstudio.github.io/leaflet/libs/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
  <script src= "https://rstudio.github.io/leaflet/libs/leaflet-binding/leaflet.js"></script>
```

You can have a look of my implementation on [`./_includes/leaflet.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/leaflet.html).


## 2.Where to include

This a little bit more complicated, depending on the structure of your Jekyll template. The code chunk should be included in the `<head>` section of your page, so you would need to find where to put it. In the case of **Beautiful Jekyll** it is on [`./_includes/head.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/head.html).

So now you just have to paste in the `<head>` the code that you got on [step 1](#step1).

{: .box-note}
<i class="fa fa-star"></i> **Pro tip:** For a better performance of the site, include these libraries only when you need it. In my case, I added a custom variable in my YAML front matter for those posts with a leaflet map, `leafletmap: true`. Go to [step 4](#step4) for a working example.


## The RStudio part

## 3. Creating the leaflet map
 
Now it's time to create a leaflet map with **RStudio**. I just keep it simple for this post, so I took the first example provided in [Leaflet for R - Introduction](https://rstudio.github.io/leaflet/)

``` r
library(leaflet)

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map
```

It is assumed that you are [creating a post with **RStudio**](https://rmarkdown.rstudio.com/authoring_quick_tour.html#rendering_output), so the code presented above should be embedded in an `.Rmd` file.


## 4. Set up the YAML front matter

Before knitting your `.Rmd`, you have to set up the [YAML front matter](https://bookdown.org/yihui/rmarkdown/markdown-document.html). Here it is **essential** to set up the option `always_allow_html: yes`, as well as `output: github_document`. As an example, this post was created with the front matter:
``` 
layout: post
title: Leaflet, R, Markdown, Jekyll and GitHub
subtitle: Make it work in 6 steps - a short tutorial
tags: [R,leaflet,Jekyll, html, maps]
linktormd: true
leafletmap: true
always_allow_html: yes
output: github_document
``` 

We are almost there! Now "Knit" your code and get the corresponding `.md`file.

## The Markdown part

## 5. Modifying the `.md` file

*Update: Depending on how you render your file this step may not be neccesary.*

Have a look to the `.md` code that you have just created. Although not displayed in the preview, you can see in the file itself a chunk that looks like this:

``` html
<!--html_preserve-->

  <script type="application/json" data-for="htmlwidget-7ab57412f7b1df4d5773">
    {"x":{"options":
      ...
      "jsHooks":[]}
  </script>
<!--/html_preserve-->
```

Actually that chunk is your leaflet map, created with **RStudio**. You can't see it now because you are previewing a `markdown` file in your local PC, and the libraries installed in [step 1](#step1) are installed on GitHub, but we would solve it later.

Now you just need to paste this piece of code before that chunk:

``` html
<!--html_preserve-->
<div id="htmlwidget-7ab57412f7b1df4d5773" style="width:100%;height:216px;" class="leaflet html-widget"></div>
  <script type="application/json" data-for="htmlwidget-7ab57412f7b1df4d5773">
  ...
```

{: .box-warning}
<i class="fa fa-exclamation-triangle"></i> **Warning:** Be sure that the widget id (`7ab57412f7b1df4d5773` in the example) is the same in the `<div>` and in the `<script>` part. If not your map would not load.

The `style= "width: 100%; height: 216px;"` part controls the actual size of the leaflet widget. In this case, the map would adapt to the width of the page with a fixed height of 216px. I put [some examples](#extra) at the end of the post of different size options so you can have a look and see which one is more suitable for your needs.


## 6. Publish your post

Now you just have to publish your post as usual!! If everything has been properly set, when Jekyll builds your post it would include the libraries in the header and make the magic happens, just like this:

<!--html_preserve-->
<div id="htmlwidget-7ab57412f7b1df4d5773" style="width:100%;height:216px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-7ab57412f7b1df4d5773">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[-36.852,174.768,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"The birthplace of R",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-36.852,-36.852],"lng":[174.768,174.768]}},"evals":[],"jsHooks":[]}</script>
<!--/html_preserve-->



{: .box-warning}
<i class="fa fa-exclamation-triangle"></i> **Warning:** Have you checked the YAML front matter of your `.md` file? Have another look, specially if you have followed my [Pro tip](#step2).
 
 
---

---
## Gallery: Size of a leaflet map

{: .box-note}
For a complete understanding of this section it is recommended to access it on multiple devices (you can easily simulate a bunch of them with Google Chrome, right-click “Inspector”, and using the ["Device Mode"](https://developers.google.com/web/tools/chrome-devtools/device-mode/)), so you can see the different behavior on different screens.

Let's start creating a new leaflet map: <a class="linked-section" name="setleaf">&nbsp;</a>

``` r
map <- leaflet(options = leafletOptions(minZoom = 1.25, maxZoom = 8)) %>%
  addTiles() %>%
  setMaxBounds(-200, -90, 200, 90) %>%
  setView(-3.56948,  40.49181, zoom = 3) %>%
  addEasyButton(easyButton(
    icon = "fa-globe",
    title = "World view",
    onClick = JS("function(btn, map){ map.setZoom(1.25); }")
  )) %>%
  addEasyButton(easyButton(
    icon = "fa-crosshairs",
    title = "Locate Me",
    onClick = JS("function(btn, map){ map.locate({setView: true}); }")
  ))
```
---
### Fixed size

With these examples you can see how to control the absolute size of the leaflet map. The disadvantage of this method is that the size would be fixed for all the devices, so maps sized for smartphones or tables wouldn't look as nice in laptops, etc. and vice versa. To test it, just zoom in and out this post from your smartphone and have a look on how **Example 1** looks like compared with the rest of maps.

---
#### Example 1: 640x480px

Fixed size in pixels. By default in my machine is `"width: 640px; height: 480px;"`, so if i want to keep it the next `<div>` should be included:

``` html
<div id="htmlwidget-xxxxxxxxxxxxxxxx" style="width:640px; height:480px;" class="leaflet html-widget"></div>
```

<!--html_preserve-->
<div id="htmlwidget-96518065375607980e8e" style="width:640px; height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-96518065375607980e8e">{"x":{"options":{"minZoom":1.25,"maxZoom":8,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-200,90,200]},{"method":"addEasyButton","args":[{"icon":"fa-globe","title":"World view","onClick":"function(btn, map){ map.setZoom(1.25); }","position":"topleft"}]},{"method":"addEasyButton","args":[{"icon":"fa-crosshairs","title":"Locate Me","onClick":"function(btn, map){ map.locate({setView: true}); }","position":"topleft"}]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":["calls.2.args.0.onClick","calls.3.args.0.onClick"],"jsHooks":[]}</script>
<!--/html_preserve-->


---
Note that this leaflet map could be wider than some screens (specially smartphones) and it would mess a little bit the overall apearance of this post.

#### Example 2: 100x300px

Let's go narrow and long with `"width: 100px;height: 300px;"`:

``` html
<div id="htmlwidget-xxxxxxxxxxxxxxxx" style="width:100px; height:300px;" class="leaflet html-widget"></div>
```

<!--html_preserve-->
<div id="htmlwidget-4c16fbc18b7ff85979fe" style="width:100px; height:300px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-4c16fbc18b7ff85979fe">{"x":{"options":{"minZoom":1.25,"maxZoom":8,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-200,90,200]},{"method":"addEasyButton","args":[{"icon":"fa-globe","title":"World view","onClick":"function(btn, map){ map.setZoom(1.25); }","position":"topleft"}]},{"method":"addEasyButton","args":[{"icon":"fa-crosshairs","title":"Locate Me","onClick":"function(btn, map){ map.locate({setView: true}); }","position":"topleft"}]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":["calls.2.args.0.onClick","calls.3.args.0.onClick"],"jsHooks":[]}</script>
<!--/html_preserve-->

---
### Dynamic size

**Recommended option.** These maps would adapt to the width of your screen, no matter what device you are using. Additionally, you can adapt the aspect ratio to different flavours.

---
#### Example 3: *16:9* aspect ratio

Most common aspect ratio for televisions and computer monitors. Note that the value `56.25%` is just the result of dividing 9 by 16.

``` html
<div id="htmlwidget-xxxxxxxxxxxxxxxx" style="position: relative; width: 100%;padding-top: 56.25%;" class="leaflet html-widget"></div>
```

<!--html_preserve-->
<div id="htmlwidget-6de1353fc8d81455f3ce" style="position: relative; width: 100%;padding-top: 56.25%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-6de1353fc8d81455f3ce">{"x":{"options":{"minZoom":1.25,"maxZoom":8,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-200,90,200]},{"method":"addEasyButton","args":[{"icon":"fa-globe","title":"World view","onClick":"function(btn, map){ map.setZoom(1.25); }","position":"topleft"}]},{"method":"addEasyButton","args":[{"icon":"fa-crosshairs","title":"Locate Me","onClick":"function(btn, map){ map.locate({setView: true}); }","position":"topleft"}]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":["calls.2.args.0.onClick","calls.3.args.0.onClick"],"jsHooks":[]}</script>
<!--/html_preserve-->


---
#### Example 4: *4:3* aspect ratio

"Old" standard for televisions and computer monitors.

``` html
<div id="htmlwidget-xxxxxxxxxxxxxxxx" style="position: relative; width: 100%;padding-top: 75%;" class="leaflet html-widget"></div>
```

<!--html_preserve-->
<div id="htmlwidget-7222a1441ac6bec31f76" style="position: relative; width: 100%;padding-top: 75%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-7222a1441ac6bec31f76">{"x":{"options":{"minZoom":1.25,"maxZoom":8,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-200,90,200]},{"method":"addEasyButton","args":[{"icon":"fa-globe","title":"World view","onClick":"function(btn, map){ map.setZoom(1.25); }","position":"topleft"}]},{"method":"addEasyButton","args":[{"icon":"fa-crosshairs","title":"Locate Me","onClick":"function(btn, map){ map.locate({setView: true}); }","position":"topleft"}]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":["calls.2.args.0.onClick","calls.3.args.0.onClick"],"jsHooks":[]}</script>
<!--/html_preserve-->


---
#### Example 5: *4:1* aspect ratio (Polyvision)

Rare aspect ratio (also known as [Polyvision](https://en.wikipedia.org/wiki/Polyvision)) used only on the 1927 silent french film *Napoléon*. It is unlikely that you use this one but illustrates an extreme aspect ratio.

``` html
<div id="htmlwidget-xxxxxxxxxxxxxxxx" style="position: relative; width: 100%;padding-top: 25%;" class="leaflet html-widget"></div>
```

<!--html_preserve-->
<div id="htmlwidget-6fa038b19035c1fdc62e" style="position: relative; width: 100%;padding-top: 25%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-6fa038b19035c1fdc62e">{"x":{"options":{"minZoom":1.25,"maxZoom":8,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-200,90,200]},{"method":"addEasyButton","args":[{"icon":"fa-globe","title":"World view","onClick":"function(btn, map){ map.setZoom(1.25); }","position":"topleft"}]},{"method":"addEasyButton","args":[{"icon":"fa-crosshairs","title":"Locate Me","onClick":"function(btn, map){ map.locate({setView: true}); }","position":"topleft"}]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":["calls.2.args.0.onClick","calls.3.args.0.onClick"],"jsHooks":[]}</script>
<!--/html_preserve-->




---
#### <i class="fa fa-star"></i> Example 6: *10:7* aspect ratio

Suitable for all devices. My personal choice.

``` html
<div id="htmlwidget-xxxxxxxxxxxxxxxx"  style="position: relative; width: 100%;padding-top: 70%;" class="leaflet html-widget"></div>
```

<!--html_preserve-->
<div id="htmlwidget-f76acb08ab6f5db5e531"  style="position: relative; width: 100%;padding-top: 70%;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-f76acb08ab6f5db5e531">{"x":{"options":{"minZoom":1.25,"maxZoom":8,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-200,90,200]},{"method":"addEasyButton","args":[{"icon":"fa-globe","title":"World view","onClick":"function(btn, map){ map.setZoom(1.25); }","position":"topleft"}]},{"method":"addEasyButton","args":[{"icon":"fa-crosshairs","title":"Locate Me","onClick":"function(btn, map){ map.locate({setView: true}); }","position":"topleft"}]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":["calls.2.args.0.onClick","calls.3.args.0.onClick"],"jsHooks":[]}</script>
<!--/html_preserve-->





---

{: .box-note} 
<i class="fa fa-star"></i> **Pro tip:** Try to use dynamic sizing unless you really need a fixed width. I did some tests and **10:7 (70%)** is a good ratio for overall purposes, specially if your leaflet map is
intended to show a full world map. In that case, combine it with `minZoom`, `maxZoom` and `setMaxBounds` options [(see example)](#setleaf) for optimal results.
