---
title: Leaflet, <strong>R</strong>, Markdown, Jekyll and GitHub
subtitle: Make it work in 6 steps - a short tutorial
tags: [rstats,rspatial,leaflet,Jekyll, html, maps]
header_img: ./assets/img/blog/20190520_imgpost.png
leafletmap: true
always_allow_html: yes
last_modified_at: 2021-05-30
output: 
  md_document:
    variant: gfm
    preserve_yaml: true
---

Recently I have been struggling when trying to embed a
[leaflet](https://rstudio.github.io/leaflet) map created with
**RStudio** on my blog, hosted in GitHub via
[Jekyll](https://jekyllrb.com) (**Spoiler**: [I succeeded
<i class="fa fa-thumbs-up"></i>](https://dieghernan.github.io/201905_Where-in-the-world/)).
In my case, I use the [<span
class="chulapa">Chulapa</span>](https://dieghernan.github.io/chulapa/)
remote theme created by myself.

**Index**

1. The generated Toc will be an ordered list
{:toc}

Ready? Let’s go!

### The GitHub/Jekyll part

The first step is to install the requested libraries in your GitHub
page. As Jekyll basically transforms `markdown` into `html`, this step
is a matter of **what to include** and **where** in your own repository.

#### 1. What to include

This part is not really hard. When having a look to the source code of
[Leaflet for R](https://rstudio.github.io/leaflet/) site it can be seen
this chunk:

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

So now we have it! The only thing to remember is that we need **to load
the libraries from the leaflet server
(`https://rstudio.github.io/leaflet`)**, meaning that we have to prepend
that url to the libraries in our installation:

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

You can have a look of my implementation on
[`./_includes/leaflet.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/leaflet.html).

#### 2.Where to include

This a little bit more complicated, depending on the structure of your
Jekyll template. The code chunk should be included in the `<head>`
section of your page, so you would need to find where to put it. In the
case of <span class="chulapa">Chulapa</span> it is on
[`./_includes/custom/custom_head_before_css.html`](https://github.com/dieghernan/dieghernan.github.io/blob/master/_includes/custom/custom_head_before_css.html).

So now you just have to paste in the `<head>` the code that you got on
step 1.

<i class="fa fa-star"></i> **Pro tip:** For a better performance of the
site, include these libraries only when you need it. In my case, I added
a custom variable in my YAML front matter for those posts with a leaflet
map, `leafletmap: true`. Go to step 4 for a working example. 
{: .alert .alert-info .p-3 .mx-2 .mb-3}

### The RStudio part

#### 3. Creating the leaflet map

Now it’s time to create a leaflet map with **RStudio**. I just keep it
simple for this post, so I took the first example provided in [Leaflet
for R - Introduction](https://rstudio.github.io/leaflet/)

``` r
library(leaflet)

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map
```

It is assumed that you are [creating a post with
**RStudio**](https://rmarkdown.rstudio.com/authoring_quick_tour.html#rendering_output),
so the code presented above should be embedded in an `.Rmd` file.

#### 4. Set up the YAML front matter <a name="step4"></a>

Before knitting your `.Rmd`, you have to set up the [YAML front
matter](https://bookdown.org/yihui/rmarkdown/markdown-document.html).
Here it is **essential** to set up the option `always_allow_html: yes`,
as well as `output: github_document`. As an example, this post was
created with the front matter:

``` yaml
---
title: Leaflet, <strong>R</strong>, Markdown, Jekyll and GitHub
subtitle: Make it work in 6 steps - a short tutorial
tags: [R,leaflet,Jekyll, html, maps]
header_img: https://dieghernan.github.io/assets/figs/20190520_imgpost.png
leafletmap: true
always_allow_html: yes
last_modified_at: 2021-05-30
output: 
  md_document:
    variant: gfm
    preserve_yaml: true
---
```

We are almost there! Now “Knit” your code and get the corresponding
`.md`file.

### The Markdown part

#### ~~5. Modifying the `.md` file~~

**Update: This is not needed any more! I still leave it here for info.
You can skip to the next section.**

Have a look to the `.md` code that you have just created. Although not
displayed in the preview, you can see in the file itself a chunk that
looks like this:

``` html
  <script type="application/json"data-for="7ab57412f7b1df4d5773">
    {"x":{"options":
      ...
      "jsHooks":[]}
  </script>
```

Actually that chunk is your leaflet map, created with **RStudio**. You
can’t see it now because you are previewing a `markdown` file in your
local PC, and the libraries installed in step 1 are installed on GitHub,
but we would solve it later.

Now you just need to paste this piece of code before that chunk:

``` html
<!--html_preserve-->
<div id="htmlwidget-7ab57412f7b1df4d5773" style="width:100%;height:216px;" class="leaflet html-widget"></div>
  <script type="application/json"data-for="htmlwidget-7ab57412f7b1df4d5773">
  ...
```

<i class="fa fa-exclamation-triangle"></i> **Warning:** Be sure that the
widget id (`7ab57412f7b1df4d5773` in the example) is the same in the
`<div>` and in the `<script>` part. If not your map would not load. 
{: .alert .alert-warning .p-3 .mx-2 .my-3}

The `style="width:100%; height:216px;` part controls the actual size of
the leaflet widget. In this case, the map would adapt to the width of
the page with a fixed height of 216px. I put [some examples](#extra) at
the end of the post of different size options so you can have a look and
see which one is more suitable for your needs.

#### 6. Publish your post

Now you just have to publish your post as usual!! If everything has been
properly set, when Jekyll builds your post it would include the
libraries in the header and make the magic happens, just like this:

<div id="htmlwidget-60e5339b540855d29db4" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-60e5339b540855d29db4">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[-36.852,174.768,null,null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"The birthplace of R",null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-36.852,-36.852],"lng":[174.768,174.768]}},"evals":[],"jsHooks":[]}</script>

<i class="fa fa-exclamation-triangle"></i> **Warning:** Have you checked
the YAML front matter of your `.md` file? Have another look, specially
if you have followed my Pro tip. 
{: .alert .alert-warning .p-3 .mx-2 .my-3}

### Gallery: Size of a leaflet map <a name="extra"></a>

**A note:** For a complete understanding of this section it is
recommended to access it on multiple devices, so you can see the
different behavior on different screens. Google Chrome allows you to
simulate different devices [(more info
here)](https://developers.google.com/web/tools/chrome-devtools/device-mode/).

#### Fixed size

With these examples you can see how to control the absolute size of the
leaflet map. The disadvantage of this method is that the size would be
fixed for all the devices, so maps sized for smartphones or tables
wouldn’t look as nice in laptops, etc. and vice versa.

##### Example 1: 672x480px

Fixed size in pixels. By default in my machine:

``` r
leaflet(options = leafletOptions(minZoom = 1.25, maxZoom = 8)) %>%
  addTiles() %>%
  setMaxBounds(-200, -90, 200, 90) %>%
  setView(-3.56948, 40.49181, zoom = 3)
```

<div id="htmlwidget-0e60ff221279290607a4" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-0e60ff221279290607a4">{"x":{"options":{"minZoom":1.25,"maxZoom":8,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-200,90,200]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>

##### Example 2: 200x300px

Let’s go narrow and long with `html "width:200px;height:300px;"`:

``` r
leaflet(
  options = leafletOptions(minZoom = 1.25, maxZoom = 8),
  width = "200px", height = "300px"
) %>%
  addTiles() %>%
  setMaxBounds(-200, -90, 200, 90) %>%
  setView(-3.56948, 40.49181, zoom = 3)
```

<div id="htmlwidget-fb456eae6cf883f81850" style="width:200px;height:300px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-fb456eae6cf883f81850">{"x":{"options":{"minZoom":1.25,"maxZoom":8,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-200,90,200]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>

#### Responsive size

**Recommended option.** These maps would adapt to the width of your
screen, no matter what device you are using.

##### Example 3: 100% width

``` r
leaflet(
  options = leafletOptions(minZoom = 1.25, maxZoom = 8),
  width = "100%"
) %>%
  addTiles() %>%
  setMaxBounds(-200, -90, 200, 90) %>%
  setView(-3.56948, 40.49181, zoom = 3)
```

<div id="htmlwidget-d72518ef7cb92abb839a" style="width:100%;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-d72518ef7cb92abb839a">{"x":{"options":{"minZoom":1.25,"maxZoom":8,"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"setMaxBounds","args":[-90,-200,90,200]}],"setView":[[40.49181,-3.56948],3,[]]},"evals":[],"jsHooks":[]}</script>
