---
title: "Optimize your images with R and reSmush.it"
subtitle: "Introducing the resmush package"
excerpt: Compress the size of your images with R, resmush and reSmush.it
tags:
- r_bloggers
- r_package
- resmush
output:
  md_document:
    variant: gfm
    preserve_yaml: yes
  html_document:
header_img: https://dieghernan.github.io/assets/img/misc/compress-img.png
---

The **resmush** package has recently been released
[CRAN](https://cran.r-project.org/package=resmush)! This small utility package 
allows for the optimization (i.e., compression) of local and online images 
using [reSmush.it](https://resmush.it/).

You can install **resmush** from
[**CRAN**](https://CRAN.R-project.org/package=resmush) with:

``` r
install.packages(“resmush”)
```

## What is reSmush.it?

reSmush.it is a **free online API** that provides image optimization and has 
been implemented on WordPress, Drupal, or Magento. Some features of reSmush.it
include:

- Free optimization services, no API key required.
- Optimization of local and online images.
- Supported image file formats: PNG, JPG/JPEG, GIF, BMP, TIFF, WebP.
- Maximum image size: 5 MB.
- Compression using several algorithms:
  - [**PNGQuant**](https://pngquant.org/): Strip unneeded chunks from
    PNGs while preserving full alpha transparency.
  - [**JPEGOptim**](https://github.com/tjko/jpegoptim)**:** Lossless 
    optimization based on optimizing the Huffman tables.
  - [**OptiPNG**](https://optipng.sourceforge.net/): `png` reducer
    used by several online optimizers.

**reSmush.it** is free of charge, but its team is planning to offer more 
serves as well as extend the service to support other types of image files. If 
you enjoy this API (as I do), you can consider supporting them.

<div class="text-center my-3">
<a title="Support reSmush.it on ko-fi.com" class="kofi-button" style="background-color:#ff5e5b;" href="https://ko-fi.com/E1E51PW00" target="_blank">
<span class="kofitext"><img src="https://storage.ko-fi.com/cdn/cup-border.png" alt="Ko-fi reSmush.it donations" class="kofiimg">Support reSmush.it on Ko-fi</span></a>
</div>

## Why the resmush package?

One of the main reasons I developed **resmush** is because I usually
include [precomputed 
 vignettes](https://ropensci.org/blog/2019/12/08/precompute-vignettes/) 
with my packages (see [**tidyterra**](https://cran.r-project.org/web/packages/tidyterra/vignettes/welcome.html) 
as an example). I found that the plots created on CRAN with the standard 
configuration (i.e., not precomputed vignettes but built on CRAN itself) were 
not very satisfying. In some of the packages I developed, especially those 
related to mapping, they didn’t do justice to the actual results when a user 
runs them.

Precomputing vignettes has the drawback of producing higher-quality images at 
the expense of size. To avoid exceeding [CRAN’s 5Mb maximum size 
policy](https://cran.r-project.org/web/packages/policies.html), I developed 
**resmush**, which enables me to reduce the size of the images without a 
significant loss in quality.

Another use case for **resmush** is optimizing images in the context of web page
development and SEO optimization. For example, I optimized all the images on 
this blog using `resmush_dir()`, which is a shorthand for optimizing all files 
in a specific folder.

There are other alternatives that I would discuss [at the end of this 
post](#other-alternatives), but in one line, the reSmush.it API performs fast 
with minimal configuration for a wide range of formats without needing an API 
key.


## Using the resmush package

### With local files

Let’s present an example of how a local file can be optimized. First we create 
a large plot with **ggplot2**

``` r
library(tidyterra)
library(ggplot2)
library(terra)
library(maptiles)

cyl <- vect(system.file("extdata/cyl.gpkg", package = "tidyterra")) %>%
  project("EPSG:3857")
cyl_img <- get_tiles(cyl, "Esri.WorldImagery", zoom = 8, crop = TRUE)
cyl_gg <- autoplot(cyl_img, maxcell = Inf) +
  geom_spatvector(data = cyl, alpha = 0.3)

cyl_gg
```

<div class="figure">

<img src="https://dieghernan.github.io/assets/img/samples/cyl.png" alt="Original file" width="100%" />
<p class="caption">
Original file
</p>

</div>

``` r

# And we save it for resmushing
ggsave("cyl.png", width = 5, height = 0.7 * 5)
```

Cool, but the file has a size of 1.7 Mb. So we can use `resmush_file()` to 
reduce it, see:

``` r
library(resmush)
resmush_file("cyl.png")
#> ══ resmush summary ══════════════════════════════════════════
#> ℹ Input: 1 file with size 1.7 Mb
#> ✔ Success for 1 file: Size now is 762.2 Kb (was 1.7 Mb). Saved 948.9 Kb (55.46%).
#> See result in directory '.'.

# Check
png::readPNG("cyl_resmush.png") %>%
  grid::grid.raster()
```

<div class="figure">

<img src="https://dieghernan.github.io/assets/img/samples/cyl_resmush.png" alt="Optimized file" width="100%" />
<p class="caption">
Optimized file
</p>

</div>

By default, `resmush_file()` and `resmush_dir()` do not overwrite the original 
file, although this behavior may be modified with the `overwrite = TRUE` 
parameter. Now, the resmushed file (`"cyl_resmush.png"`) has a size of 762.2 Kb.

Let’s compare the results side-by-side:

<div class="figure row no-gutters">
<a href="https://dieghernan.github.io/assets/img/samples/cyl.png" class="col-sm-6 p-1">
<img src="https://dieghernan.github.io/assets/img/samples/cyl.png" alt="Original online figure">
</a>
<a href="https://dieghernan.github.io/assets/img/samples/cyl_resmush.png" class="col-sm-6 p-1">
<img src="https://dieghernan.github.io/assets/img/samples/cyl_resmush.png" alt="Optimized figure">
</a>
<p class="caption">
Original picture (left/top) 1.7 Mb and optimized picture (right/bottom) 762.2 Kb
(Compression 55.46%). Click in the images to enlarge.
</p>
</div>

We can verify that the image has been compressed without reducing its 
dimensions.

``` r
size_src <- file.size("cyl.png") %>%
  `class<-`("object_size") %>%
  format(units = "auto")
size_dest <- file.size("cyl_resmush.png") %>%
  `class<-`("object_size") %>%
  format(units = "auto")

dim_src <- dim(png::readPNG("cyl.png"))[1:2] %>% paste0(collapse = "x")
dim_dest <- dim(png::readPNG("cyl_resmush.png"))[1:2] %>% paste0(collapse = "x")

data.frame(
  source = c("original file", "compressed file"),
  size = c(size_src, size_dest),
  dimensions = c(dim_src, dim_dest)
) %>%
  knitr::kable()
```

| source          | size     | dimensions |
|:----------------|:---------|:-----------|
| original file   | 1.7 Mb   | 1050x1500  |
| compressed file | 762.2 Kb | 1050x1500  |

### With online files

We can also optimize online files with `resmush_url()` and download them to 
disk. In this example, I demonstrate a feature of all the functions in 
**resmush**: they return an invisible data frame with a summary of the process.

``` r
url <- "https://dieghernan.github.io/assets/img/samples/sample_1.3mb.jpg"

# Invisible data frame
dm <- resmush_url(url, "sample_optimized.jpg", report = FALSE)
```

``` r
knitr::kable(dm)
```

| src_img                                                            | dest_img             | src_size | dest_size | compress_ratio | notes | src_bytes | dest_bytes |
|:-------------------------------------------------------------------|:---------------------|:---------|:----------|:---------------|:------|----------:|-----------:|
| <https://dieghernan.github.io/assets/img/samples/sample_1.3mb.jpg> | sample_optimized.jpg | 1.3 Mb   | 985 Kb    | 26.63%         | OK    |   1374693 |    1008593 |

<div class="figure row no-gutters">
<a href="https://dieghernan.github.io/assets/img/samples/sample_1.3mb.jpg" class="col-sm-6 p-1">
<img
src="https://dieghernan.github.io/assets/img/samples/sample_1.3mb.jpg" alt="Original online figure">
</a>

<a href="https://dieghernan.github.io/assets/img/samples/sample_optimized.jpg" class="col-sm-6 p-1">
<img src="https://dieghernan.github.io/assets/img/samples/sample_optimized.jpg" alt="Optimized online figure" >
</a>
<p class="caption">

Original picture (left/top) 1.3 Mb and optimized picture (right/bottom) 985 Kb
(Compression 26.63%). Click in the images to enlarge.

</p>

</div>

## Other alternatives

There are other alternatives for optimizing images with **R**, but first…

<div class="alert alert-info p-3 mx-2 mb-3">

<p>
  <a href="https://yihui.org/">Yihui Xie</a>, one of the most prominent figures
  in the <strong>R</strong> community, was recently laid off from his position 
  at Posit PBC (formerly RStudio) 
  (<a href="https://yihui.org/en/2024/01/bye-rstudio/">more info here</a>).
</p>
<p>
  Yihui is the developer of <strong>knitr</strong>, <strong>markdown</strong>, 
  <strong>blogdown</strong>, and <strong>bookdown</strong>, among others, and he 
  has been one of the key contributors (if not the most) to the reproducible 
  research space with <strong>R</strong> through his libraries.
</p>
<p>
  If you have ever used and enjoyed his packages, consider sponsoring him on 
  GitHub.
</p>


<div class="text-center my-3">

      <a class="btn btn-light border border-dark" role="button" aria-label="Sponsor @yihui" target="_top" href="https://github.com/sponsors/yihui?o=esb">
      <i class="fa-regular fa-heart fa-lg mr-2" aria-hidden="true" style="color: #bf3989;"></i><span class="font-weight-bold">Sponsor Yihui Xie</span>
      </a>

</div>

</div>

- One of the many packages developed by Yihui is 
  [**xfun**](https://cran.r-project.org/package=xfun), which includes the 
  following functions for optimizing image files:
  - `xfun::tinify()` is similar to `resmush_file()` but uses 
    [**TinyPNG**](https://tinypng.com/). An API key is required.
  - `xfun::optipng()` compresses local files with **OptiPNG** (which needs to be 
    installed locally).
- [**tinieR**](https://jmablog.github.io/tinieR/) package by 
  [jmablog](https://jmablog.com/). An **R** package that provides a full 
  interface with [**TinyPNG**](https://tinypng.com/).
- [**optout**](https://github.com/coolbutuseless/optout) package by 
  [@coolbutuseless](https://coolbutuseless.github.io/). Similar to 
  `xfun::optipng()` with additional options. Requires additional software to 
  be installed locally.

<table class="table table-sm table-striped">
    <caption>Table 1: <strong>R</strong> packages: Comparison of alternatives for optimizing
images.</caption>
<thead class="text-center">
   <tr>
     <th class="align-middle">tool</th>
     <th class="align-middle">CRAN</th>
     <th class="align-middle">Additional software?</th>
     <th class="align-middle">Online?</th>
     <th class="align-middle">API Key?</th>
     <th class="align-middle">Limits?</th>
   </tr>
 </thead>
 <tbody>
   <tr>
     <td><code class="language-plaintext highlighter-rouge">xfun::tinify()</code></td>
     <td>Yes</td>
     <td>No</td>
     <td>Yes</td>
     <td>Yes</td>
     <td>500 files/month (Free tier)</td>
   </tr>
   <tr>
     <td><code class="language-plaintext highlighter-rouge">xfun::optipng()</code></td>
     <td>Yes</td>
     <td>Yes</td>
     <td>No</td>
     <td>No</td>
     <td>No</td>
   </tr>
   <tr>
     <td><strong>tinieR</strong></td>
     <td>No</td>
     <td>No</td>
     <td>Yes</td>
     <td>Yes</td>
     <td>500 files/month (Free tier)</td>
   </tr>
   <tr>
     <td><strong>optout</strong></td>
     <td>No</td>
     <td>Yes</td>
     <td>No</td>
     <td>No</td>
     <td>No</td>
   </tr>
   <tr>
     <td><strong>resmush</strong></td>
     <td>Yes</td>
     <td>No</td>
     <td>Yes</td>
     <td>No</td>
     <td>Max size 5Mb</td>
   </tr>
 </tbody>
</table>

<table class="table table-striped">
<caption>Table 2: <strong>R</strong> packages: Formats admitted.</caption>
    <thead>
   <tr>
     <th class="align-middle">tool</th>
     <th class="align-middle">png</th>
     <th class="align-middle">jpg</th>
     <th class="align-middle">gif</th>
     <th class="align-middle">bmp</th>
     <th class="align-middle">tiff</th>
     <th class="align-middle">webp</th>
     <th class="align-middle">pdf</th>
   </tr>
 </thead>
 <tbody>
   <tr>
     <td><code class="language-plaintext highlighter-rouge">xfun::tinify()</code></td>
     <td>✅</td>
     <td>✅</td>
     <td>❌</td>
     <td>❌</td>
     <td>❌</td>
     <td>✅</td>
     <td>❌</td>
   </tr>
   <tr>
     <td><code class="language-plaintext highlighter-rouge">xfun::optipng()</code></td>
     <td>✅</td>
     <td>❌</td>
     <td>❌</td>
     <td>❌</td>
     <td>❌</td>
     <td>❌</td>
     <td>❌</td>
   </tr>
   <tr>
     <td><strong>tinieR</strong></td>
     <td>✅</td>
     <td>✅</td>
     <td>❌</td>
     <td>❌</td>
     <td>❌</td>
     <td>✅</td>
     <td>❌</td>
   </tr>
   <tr>
     <td><strong>optout</strong></td>
     <td>✅</td>
     <td>✅</td>
     <td>❌</td>
     <td>❌</td>
     <td>❌</td>
     <td>❌</td>
     <td>✅</td>
   </tr>
   <tr>
     <td><strong>resmush</strong></td>
     <td>✅</td>
     <td>✅</td>
     <td>✅</td>
     <td>✅</td>
     <td>✅</td>
     <td>✅</td>
     <td>❌</td>
   </tr>
 </tbody>
</table>

Additionally, if you host your projects on GitHub, you can try 
[Imgbot](https://imgbot.net/), which is free for open-source projects. Imgbot 
provides automatic optimization for files in your repositories, and the 
optimized files will be included in specific pull requests before merging into 
your work.
