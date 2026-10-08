---
layout: indexcategory
title: 'Projects'
subtitle: 'R packages, spatial data and open-source tools'
permalink: /projects
include_collection: projects
index_sort: date
excerpt: Explore spatial tools, software citation, image optimization and other projects by dieghernan.
header_type: hero
header_img: /assets/img/site/banner.png
show_breadcrumb   : true
featured_packages:
  - name: tidyterra
    description: Tidyverse methods and ggplot2 tools for terra spatial data.
    documentation: https://dieghernan.github.io/tidyterra/
    source: https://github.com/dieghernan/tidyterra
  - name: cffr
    description: Create and maintain CITATION.cff files for R packages.
    documentation: https://docs.ropensci.org/cffr/
    source: https://github.com/ropensci/cffr
  - name: giscoR
    description: Access GISCO geographic data from Eurostat in R.
    documentation: https://ropengov.github.io/giscoR/
    source: https://github.com/ropengov/giscoR
  - name: mapSpain
    description: Access Spanish geographic boundaries and mapping data in R.
    documentation: https://ropenspain.github.io/mapSpain/
    source: https://github.com/ropenspain/mapSpain
  - name: geobounds
    description: Access geoBoundaries administrative boundaries in R.
    documentation: https://dieghernan.github.io/geobounds/
    source: https://github.com/dieghernan/geobounds
  - name: resmush
    description: Optimize images from R using the reSmush.it service.
    documentation: https://dieghernan.github.io/resmush/
    source: https://github.com/dieghernan/resmush
description: "Explore R packages for spatial data, software citation and image optimization, plus other open-source projects by dieghernan."
---


## R packages

Tools for working with spatial data, creating maps, citing software and optimizing images.

<div class="row">
{% for package in page.featured_packages %}
  <div class="col-12 col-md-6 mb-3">
    <article class="card h-100 chulapa-border-card-index" aria-labelledby="package-{{ package.name | slugify }}">
      <div class="card-body d-flex flex-column">
        <h3 class="h5 card-title" id="package-{{ package.name | slugify }}">{{ package.name | escape }}</h3>
        <p class="card-text">{{ package.description | escape }}</p>
        <div class="mt-auto">
          <a href="{{ package.documentation | escape }}" class="mr-3" aria-label="{{ package.name | escape }} documentation">Documentation</a>
          <a href="{{ package.source | escape }}" aria-label="{{ package.name | escape }} source code">Source code</a>
        </div>
      </div>
    </article>
  </div>
{% endfor %}
</div>

## More projects

Explore other work on maps, datasets, bots and Pebble watch faces.
