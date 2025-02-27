---
title: "Implementing <code>group_by</code> count in Liquid"
subtitle: "See the magic happening"
excerpt: |
  This post explains implementing group_by count in Liquid for Jekyll, 
  addressing issues with Jekyll 4.1.0 and providing a solution.
tags:
  - liquid
  - jekyll
  - html
  - function
  - chulapa
output:
  html_document:
  md_document:
    variant: gfm
    preserve_yaml: yes
header_img: "https://dieghernan.github.io/assets/img/blog/og_jekyll.webp"
---

[Liquid](https://shopify.github.io/liquid/) is an open-source template 
language created by Shopify back in 2006 and written in Ruby. It is widely 
used by several frameworks, with [Jekyll](https://jekyllrb.com/) being one of 
the most famous.

This website is created using Jekyll, specifically my Jekyll template 
<span class="chulapa">Chulapa</span> 
([link](https://dieghernan.github.io/chulapa)).

Some time ago, [@cargocultprogramming](https://github.com/cargocultprogramming) 
opened [dieghernan/chulapa#29](https://github.com/dieghernan/chulapa/issues/29) 
because one of the components of the theme was broken in Jekyll `=>4.1.0`. 
Digging a bit, I saw 
[jekyll/jekyll#8214](https://github.com/jekyll/jekyll/issues/8214), exposing 
the same issue. What seemed to be a feature was indeed a bug that some 
developers were exploiting.

The change is that when applying the `group_by` Liquid filter on an array, it 
used to produce a "grouped" version of the array, while on Jekyll `=>4.1.0` 
it produces a different result that can't be used in the same way.

```html
{% raw %}

{% assign alldocs = site.exercises %}
{% assign grouptag = alldocs | map: 'tags' | join: ',' | split: ',' | group_by: tag %}

{{ grouptag }}

<!-- Jekyll < 4.1.0 result -->
{"name"=>"tag A", "items"=>["tag A"], "size"=>1}{"name"=>"Tag B", "items"=>["Tag B"], "size"=>1}{"name"=>"Virtualbox", "items"=>["Virtualbox"], "size"=>1}{"name"=>"netcat", "items"=>["netcat"], "size"=>1}{"name"=>"whois", "items"=>["whois"], "size"=>1}{"name"=>"dig", "items"=>["dig"], "size"=>1} ... {"name"=>"Hydra", "items"=>["Hydra"], "size"=>1}

<!-- Jekyll >= 4.1.0 result -->
{"name"=>"", "items"=>["tag A", "Tag B", "Virtualbox", "netcat", "whois", "dig", ... , "Hydra"], "size"=>26}

{% endraw %}
```

So basically, counting items was not easy anymore. I developed a solution in 
pure Liquid (which happens to be a quite verbose language out of the predefined
filters) that is compatible with any Jekyll version.

The algorithm is now implemented in <span class="chulapa">Chulapa</span>. You
can check the results on my [/tags](https://dieghernan.github.io/tags) page.

Note that the tables produced in the example are taken from my live site,
hence they may change as I add more posts. The results of the table should
be the same as the order and number of tags displayed on the 
[/tags](https://dieghernan.github.io/tags) page.

## Alternative `group_by` with Liquid

First, we define an array of all the tags included in the documents of my site:

```html
{% raw %}
{% assign alldocs = site.documents %}
{% assign alltags = alldocs | map: 'tags' | join: ',' | split: ',' %}
{% endraw %}
```

{% assign alldocs = site.documents %}
{% assign alltags = alldocs | map: 'tags' | join: ',' | split: ',' %}

<div markdown=0>

<p>Cool! Now we can count the number of unique elements in 
<code>alltags</code> by counting the occurrences of unique tags in the 
array:</p>

</div>

```html
<!-- Allocating array to group_by: replacement -->
{% raw %}
<!-- Unique values -->
{% assign single_tags = alltags | uniq %}

<!-- Arrays to populate -->
{% assign count_tags = '' | split: ',' %}

<!-- Iterator 0 to number of unique tags - 1 (size = number of unique tags) -->
{% assign n_tags = single_tags | size | minus: 1 %}

{% for i in (0..n_tags) %}
<!-- Populate -->
  {% assign count_this_tag = alltags | where_exp:"item", "item == single_tags[i]" | size %}
  {% assign count_tags = count_tags | push: count_this_tag %}
{% endfor %}

<!-- Display single_tags and count_tags as a table -->
<table>
  <caption>Display count of tags on this site </caption>
  <tr>
    <th>Tag</th>
    <th>Count</th>
  </tr>
  {% for i in (0..n_tags) %}
    <tr>
      <td>{{ single_tags[i] }}</td>
      <td>{{ count_tags[i] }}</td>
    </tr>
  {% endfor %}
</table>
{% endraw %}
```

{% assign single_tags = alltags | uniq %}
{% assign count_tags = '' | split: ',' %}
{% assign n_tags = single_tags | size | minus: 1 %}

{%- for i in (0..n_tags) %}
  {% assign count_this_tag = alltags | where_exp:"item", "item == single_tags[i]" | size %}
  {% assign count_tags = count_tags | push: count_this_tag %}
{%- endfor -%}

<details>
  <summary>See results</summary>
<table>
  <caption>Display count of tags on this site </caption>
  <tr>
    <th>Tag</th>
    <th>Count</th>
  </tr>
  {%- for i in (0..n_tags) %}
    <tr>
      <td>{{ single_tags[i] }}</td>
      <td>{{ count_tags[i] }}</td>
    </tr>
  {%- endfor -%}
</table>

</details>

## Sorting

How to rank the tags by the number of occurrences? We can set the maximum 
number of occurrences and loop in reverse order. The ranked array would be 
populated if a tag presents the number of occurrences in the main loop:

```html
<!-- Used in https://github.com/mmistakes/minimal-mistakes/blob/master/_includes/posts-taxonomy.html -->
{% raw %}
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

{% assign sorted_tags = sorted_tags | uniq %}

<table>
  <caption>Display sorted count of tags on this site </caption>
  <tr>
    <th>Tag</th>
    <th>Count (desc sorted)</th>
  </tr>
  {%- for i in (0..n_tags) %}
    <tr>
      <td>{{ sorted_tags[i] }}</td>
      <td>{{ sorted_count_tags[i] }}</td>
    </tr>
  {%- endfor -%}
</table>
{% endraw %}
```

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

{% assign sorted_tags = sorted_tags | uniq %}

<details>
  <summary>See results</summary>

<table>
  <caption>Display sorted count of tags on this site </caption>
  <tr>
    <th>Tag</th>
    <th>Count (desc sorted)</th>
  </tr>
  {%- for i in (0..n_tags) %}
    <tr>
      <td>{{ sorted_tags[i] }}</td>
      <td>{{ sorted_count_tags[i] }}</td>
    </tr>
  {%- endfor -%}
</table>

</details>

## Bottom line

Done! Here you have a clean version of the algorithm:

```html
{% raw %}
{% assign alldocs = site.documents %}
{% assign alltags = alldocs | map: 'tags' | join: ',' | split: ',' %}
{% assign single_tags = alltags | uniq %}

<!-- Counting -->
{% assign count_tags = '' | split: ',' %}
{% assign n_tags = single_tags | size | minus: 1 %}
{% for i in (0..n_tags) %}
  {% assign count_this_tag = alltags | where_exp:"item", "item == single_tags[i]" | size %}
  {% assign count_tags = count_tags | push: count_this_tag %}
{% endfor %}

<!-- Extra: sort -->
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

{% assign sorted_tags = sorted_tags | uniq %}
{% endraw %}
```