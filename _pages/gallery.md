---
title: 'Gallery'
subtitle: 'Pieces of work at a glance'
permalink: /gallery
header_type: hero
header_img: /assets/img/site/banner.png
---


## Wikimedia

Uploaded files on [Wikipedia](https://commons.wikimedia.org/wiki/Special:ListFiles?limit=50&user=dieghernan84).

{% assign externalgallery = "
https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/DO_Rueda_locator_map.svg/800px-DO_Rueda_locator_map.svg.png,
https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/DO_Rioja_locator_map.svg/800px-DO_Rioja_locator_map.svg.png,
https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/DO_Navarra_locator_map.svg/800px-DO_Navarra_locator_map.svg.png,
https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/DO_Cava_Catalu%C3%B1a_locator_map.svg/800px-DO_Cava_Catalu%C3%B1a_locator_map.svg.png,
https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Population_density_by_NUTS_3_region_%282017%29.svg/1000px-Population_density_by_NUTS_3_region_%282017%29.svg.png,
https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Population_by_municipality_in_Spain_%282018%29.svg/1000px-Population_by_municipality_in_Spain_%282018%29.svg.png,
https://upload.wikimedia.org/wikipedia/commons/d/d8/Large_Urban_Areas_in_Spain_%282018%29.png,
https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Meat_consumption_rate_%28kg%29_per_capita_by_country_gradient_map_%282002%29.svg/1000px-Meat_consumption_rate_%28kg%29_per_capita_by_country_gradient_map_%282002%29.svg.png,
https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Meat_consumption_rate_%28kg%29_per_capita_by_country_gradient_map_%282002%29.svg/1000px-Meat_consumption_rate_%28kg%29_per_capita_by_country_gradient_map_%282002%29.svg.png,
https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Organ_donor_rate_per_million_by_country_gradient_map_%282017%29.svg/1000px-Organ_donor_rate_per_million_by_country_gradient_map_%282017%29.svg.png,
https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Population_per_km2_in_Spain_%282011%29.svg/2560px-Population_per_km2_in_Spain_%282011%29.svg.png" %}

{% include_cached snippets/carousel.html external=externalgallery  random="true" controls="true" indicators="true" %}


## Blog

Plots used on my posts.

{% include_cached snippets/masonry.html internal="imgblog" index_sort="basename" %}