---
title: "One World"
subtitle: "R packages, spatial data, maps and open-source projects"
header_type: hero
header_img: /assets/img/site/banner.png
excerpt: A personal portfolio and blog by dieghernan.
description: "R packages, spatial data, maps and open-source projects by dieghernan."
og_image: /assets/img/site/social-preview.jpg
og_image_alt: One World. R packages, maps and open-source projects by dieghernan,
  with a raster map in magenta, orange, yellow and turquoise.
og_image_width: 1200
og_image_height: 630
og_image_type: image/jpeg
seo_title: "One World: R packages, maps and open-source projects"
og_title: "One World: R packages, maps and open-source projects"
---

## <a href="./blog" class="text-body">Recent posts</a>
{: .mb-5 }

<div class="blog-listing-cards">
  {% include_cached components/indexcards.html cacheddocs=site.posts cachedlimit=3 %}
</div>

<div class="text-right mx-3">
  <a href="./blog/" class="btn btn-primary border-0">Blog <i class="fa fa-chevron-right fa-lg" aria-hidden="true"></i><span class="sr-only">Go</span></a>
</div>

* * *
{: .my-5 .bg-primary }

## <a href="./projects" class="text-body">Projects</a>
{: .mb-5 }

{%- assign alldocs = site.documents |
                          where_exp: "item", "item.collection == 'projects'" | sort: date | reverse -%}

{% include_cached components/indexcards.html cacheddocs=alldocs cachedlimit=3 %}

<div class="text-right mx-3">
  <a href="./projects" class="btn btn-primary border-0">More projects <i class="fa fa-chevron-right fa-lg" aria-hidden="true"></i><span class="sr-only">Go</span></a>
</div>

{% include custom/kofi.html %}

<!-- Verification -->

<a href="https://github.com/dieghernan" rel="me" class="d-none">github.com/dieghernan</a>
<a rel="me" href="https://fosstodon.org/@dhernangomez" class="d-none">Mastodon Verification</a>
<a rel="me" href="https://web.brid.gy/r/https://dieghernan.github.io/" class="d-none">Bridgy Fed Verification</a>
<a rel="me" href="https://gravatar.com/dieghernan" class="d-none">gravatar Verification</a>
<a rel="me" href="https://bsky.brid.gy/ap/did:plc:u6qwdnceaaq3us43vpvrcve4" class="d-none">Bridgy Mastodon Verification</a>

