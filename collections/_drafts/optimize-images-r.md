---
title: "Optimize your images with R and reSmush.it"
subtitle: "Introducing the resmush package"
tags:
- r_bloggers
- r_package
- resmush
output:
  html_document:
  md_document:
    variant: gfm
    preserve_yaml: yes
header_img: https://dieghernan.github.io/assets/img/misc/compress-img.png
---

Intro TODO

## Working with resmush

TODO


## Alternatives

There are other alternatives for optimizing images for **R**, but first...

<div class="alert alert-info p-3 mx-2 mb-3">
   <p><a href="https://yihui.org/">Yihui Xie</a>, one of the most prominent figures in the <strong>R</strong> community, has recently been laid off from his 
      position at Posit PBC (formerly RStudio) (<a href="https://yihui.org/en/2024/01/bye-rstudio/">more info</a>).
   </p>
   <p>Yihui is the developer of <code>knitr</code>, <code>markdown</code>, <code>blogdown</code>, and <code>bookdown</code>, among others, and he has been one of the 
      key contributors (if not the most) to reproducible research space with <strong>R</strong> his libraries.
   </p>
   <p>If you have ever used and enjoyed his packages consider sponsor him.</p>
   <div class="text-center my-3">
      <a class="btn btn-light border border-dark" role="button" aria-label="Sponsor @yihui" target="_top" href="https://github.com/sponsors/yihui?o=esb">
      <i class="fa-regular fa-heart fa-lg mr-2" aria-hidden="true" style="color: #bf3989;"></i><span class="font-weight-bold">Sponsor Yihui Xie</span>
      </a>
   </div>
</div>

-   [**xfun**](https://cran.r-project.org/package=xfun) package by Yihui Xie has
    the following functions that optimize image files:

    -   `xfun::tinify()` is similar to `resmush_file()` but uses
        [TinyPNG](https://tinypng.com/). API key required.
    -   `xfun::optipng()` compress local files with OptiPNG (that needs to be
        installed locally).

-   [**tinieR**](https://jmablog.github.io/tinieR/) package by
    [jmablog](https://jmablog.com/). **R** package that provides a full
    interface with [TinyPNG](https://tinypng.com/).

-   [**optout**](https://github.com/coolbutuseless/optout) package by
    [@coolbutuseless](<https://coolbutuseless.github.io/>). Similar to
    `xfun::optipng()` with additional options. Needs additional software
    installed locally.

| tool              | CRAN | Formats                           | Additional software? | Need online? | API Key? | Limits?                     |
|-------------------|------|-----------------------------------|----------------------|--------------|----------|-----------------------------|
| `xfun::tinify()`  | Yes  | `png, jpg, webp`                  | No                   | Yes          | Yes      | 500 files/month (Free tier) |
| `xfun::optipng()` | Yes  | `png`                             | Yes                  | No           | No       | No                          |
| **tinieR**        | No   | `png, jpg, webp`                  | No                   | Yes          | Yes      | 500 files/month (Free tier) |
| **optout**        | No   | `png, jpeg, pdf`                  | Yes                  | No           | No       | No                          |
| **resmush**       | Yes  | `png, jpeg, gif, bmp, tiff, webp` | No                   | Yes          | No       | Max size 5Mb                |

Additionally, if you host your projects in GitHub, you can try
[Imgbot](https://imgbot.net/) that is free for open-source projects. Imgbot
provides automatic optimization for files in your repos and the optimized files
would be included in specific PR before merging in your work.