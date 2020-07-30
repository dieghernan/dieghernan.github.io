---
layout: landingpage
title: "One World"
subtitle: "Blog & Projects"
header_type: hero
header_img: /assets/img/site/banner.png
---

## Recent posts
{: .display-3 .mb-5 }


{% include_cached components/indexcards.html cacheddocs=site.posts cachedlimit=3 %}

<div class="text-right mx-3">
		<a href="./blog/" class="btn btn-outline-primary border-0">Blog <i class="fa fa-chevron-right fa-lg" aria-hidden="true"></i><span class="sr-only">Go</span></a>
</div>

* * *
{: .my-5 .bg-primary }


## Projects
{: .display-3 .mb-5 }

{%- assign alldocs = site.documents | 
                          where_exp: "item", "item.collection == 'projects'" | sort: date | reverse -%}

{% include_cached components/indexcards.html cacheddocs=alldocs cachedlimit=3 %}

<div class="text-right mx-3">
		<a href="./projects" class="btn btn-outline-primary border-0">More projects <i class="fa fa-chevron-right fa-lg" aria-hidden="true"></i><span class="sr-only">Go</span></a>
</div>