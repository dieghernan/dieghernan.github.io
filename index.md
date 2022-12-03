---
title: "One World"
subtitle: "Blog & Projects"
header_type: hero
header_img: /assets/img/site/banner.png
---

## <a href="./blog" class="text-dark">Recent posts</a>
{: .mb-5 }


{% include_cached components/indexcards.html cacheddocs=site.posts cachedlimit=3 %}

<div class="text-right mx-3">
		<a href="./blog/" class="btn btn-outline-primary border-0">Blog <i class="fa fa-chevron-right fa-lg" aria-hidden="true"></i><span class="sr-only">Go</span></a>
</div>

* * *
{: .my-5 .bg-primary }


## <a href="./projects" class="text-dark">Projects</a>
{: .mb-5 }

{%- assign alldocs = site.documents | 
                          where_exp: "item", "item.collection == 'projects'" | sort: date | reverse -%}

{% include_cached components/indexcards.html cacheddocs=alldocs cachedlimit=3 %}

<div class="text-right mx-3">
		<a href="./projects" class="btn btn-outline-primary border-0">More projects <i class="fa fa-chevron-right fa-lg" aria-hidden="true"></i><span class="sr-only">Go</span></a>
</div>

  {%- assign alldocs = site.documents -%}
  {%- assign showcol = true -%}



{% assign alldocs = alldocs | sort: 'date' | reverse %}
{% assign grouptag =  alldocs | map: 'tags' | join: ','  | split: ','  | group_by: tag | sort: 'size' | reverse %}
{%- for tag in grouptag -%}
  {%- if forloop.first -%}
    {%- assign sizemax = tag.size -%}
  {%- elsif forloop.last -%}
    {% assign mid = tag.size | plus: sizemax | divided_by: 2  %}
  {%- endif -%}
{%- endfor -%}

<div class="row g-0 pt-5" id="tags">
<div class="col">
	{%- for tag in grouptag -%}
	<a href="./tags#{{- tag.name | replace: " ", "-" -}}" class="btn btn-primary m-1" role="button" style="font-size: min(1.2rem , max(0.8rem , calc(1rem + 0.025*({{ tag.size }}rem - {{ mid }}rem))));"><i class="fa fa-tag mr-2" aria-hidden="true"></i>{{- tag.name -}}<span class="badge rounded-pill chulapa-pill-bg-primary ml-2">{{tag.size}}</span></a>
	{%- endfor -%}
	</div>
</div>
