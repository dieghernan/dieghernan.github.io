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

<div class="mt-5 pt-3 mb-3 text-center">
			<script type='text/javascript' src='https://storage.ko-fi.com/cdn/widget/Widget_2.js'></script><script type='text/javascript'>kofiwidget2.init('Support Me on Ko-fi', '#000000', 'K3K43H86Z');kofiwidget2.draw();</script> 
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
{% assign alltags =  alldocs | map: 'tags' | join: ','  | split: ','  %}

{%- assign single_tags =  alltags | uniq  -%}
{% assign count_tags = '' | split: ',' %}
{% assign n_tags = single_tags | size |  minus: 1 %}

{%- for i in (0..n_tags) %}
  {% assign count_this_tag = alltags | where_exp:"item", "item == single_tags[i]" | size %}
  {% assign count_tags = count_tags | push: count_this_tag %}
{%- endfor -%}

{% assign items_max = count_tags | sort | last %}
{% assign sorted_tags = '' | split: ',' %}
{% assign sorted_count_tags = '' | split: ',' %}

{% for i in (1..items_max) reversed %}
  {% for j in (0..n_tags) %}
    {% if count_tags[j] == i %}
     {% assign sorted_tags = sorted_tags | push: single_tags[j] %}
     {% assign sorted_count_tags = sorted_count_tags | push: i %}
    {% endif %}
  {% endfor %}
{% endfor %}

{% assign sorted_tags= sorted_tags | uniq %}

{%- assign sizemax = sorted_count_tags | first -%}
{% assign mid = sorted_count_tags | last | plus: sizemax | divided_by: 2  %}

<div class="row g-0 pt-5" id="tags">
<div class="col">
	{%- for i in (0..n_tags)-%}
	<a href="./tags#{{- sorted_tags[i] | replace: "demo", "dmo" | replace: " ", "-" -}}" class="btn btn-primary m-1" role="button" style="font-size: min(1.2rem , max(0.8rem , calc(1rem + 0.025*({{ sorted_count_tags[i] }}rem - {{ mid }}rem))));"><i class="fa fa-tag mr-2" aria-hidden="true"></i>{{- sorted_tags[i] -}}<span class="badge rounded-pill chulapa-pill-bg-primary ml-2">{{ sorted_count_tags[i]}}</span></a>
	{%- endfor -%}
	</div>
</div>

<!-- Verification -->

<a href="https://github.com/dieghernan" rel="me" class="d-none">github.com/dieghernan</a>
<a rel="me" href="https://fosstodon.org/@dhernangomez" class="d-none">Mastodon Verification</a>

<span class="h-card d-none">
  <a rel="me" href="https://dieghernan.github.io" class="u-url u-uid" >dieghernan</a>
  <img class="u-photo" src="https://dieghernan.github.io/assets/img/site/avatar.png" />
  <img class="u-featured" src="https://dieghernan.github.io/assets/img/site/banner.png" />
  <span class="p-note">I just love maps.</span>
</span>








