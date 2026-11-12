---
giscus_discussion: 39
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
og_image_width: 1200
og_image_height: 630
og_image_type: "image/webp"
og_image_alt: "White document-and-picture icon on an abstract multicolored geometric background."
syndication:
  - https://dev.to/dieghernan/implementing-groupby-count-in-liquid-2f4d

---

[Liquid](https://shopify.github.io/liquid/) is a template language used by
[**Jekyll**](https://jekyllrb.com/), the static site generator behind this website
and my theme, <span class="chulapa">Chulapa</span>
([link](https://dieghernan.github.io/chulapa)).

Some time ago, [@cargocultprogramming](https://github.com/cargocultprogramming)
reported a broken theme component in
[dieghernan/chulapa#29](https://github.com/dieghernan/chulapa/issues/29).
The problem appeared with Jekyll 4.1.0 and was also reported in
[jekyll/jekyll#8214](https://github.com/jekyll/jekyll/issues/8214).

The affected code used `group_by` to count repeated strings in an array:

```liquid
{% raw %}
{% assign alldocs = site.exercises %}
{% assign grouptag = alldocs | map: 'tags' | join: ',' | split: ',' | group_by: tag %}
{{ grouptag }}
{% endraw %}
```

In that example, `tag` is an undefined variable, rather than the name of a
property on each item. Jekyll 4.0.1 produced separate groups for the strings,
but 4.1.0 placed them in a single group with an empty name. This specific
usage changed. Grouping objects by a named property remains supported.

The workaround below counts string occurrences without custom plugins.
It uses Liquid templates with Jekyll-specific filters, including `where_exp`
and `push`, so it is not portable to every Liquid environment.
[`where_exp` requires **Jekyll** 3.2.0 or later](https://jekyllrb.com/docs/liquid/filters/).
The live examples run with the version used to build this site.

The algorithm is implemented in <span class="chulapa">Chulapa</span>.
The expandable tables use this site's documents and change as posts are
added. You can also see the tags on the [/tags](https://dieghernan.github.io/tags)
page.

## Counting tag occurrences

For a small example, an input array of `['ruby', 'jekyll', 'ruby']` gives
these two parallel arrays:

```text
single_tags = ['ruby', 'jekyll']
count_tags  = [2, 1]
```

There are two distinct tags. Each position in `count_tags` holds the number
of occurrences of the tag at the same position in `single_tags`.

First, collect the tags from `site.documents`. Then keep the unique tags
and count how often each appears in the full array:

```liquid
{% raw %}
{% assign alldocs = site.documents %}
{% assign alltags = alldocs | map: 'tags' | join: ',' | split: ',' %}
{% assign single_tags = alltags | uniq %}
{% assign count_tags = '' | split: ',' %}

{% for tag in single_tags %}
  {% assign count_this_tag = alltags | where_exp: "item", "item == tag" | size %}
  {% assign count_tags = count_tags | push: count_this_tag %}
{% endfor %}
{% endraw %}
```

The `join` and `split` filters flatten the tag arrays using a comma as a
separator. This assumes that tag names contain no commas. The algorithm
counts occurrences, so a repeated tag within one document would be counted
more than once. Tag comparisons are case-sensitive.

To display the counts, iterate over the unique tags and use
`forloop.index0` to retrieve the corresponding count. An empty input
produces no table rows.

```liquid
{% raw %}
<table>
  <caption>Tag counts on this site</caption>
  <thead>
    <tr>
      <th scope="col">Tag</th>
      <th scope="col">Count</th>
    </tr>
  </thead>
  <tbody>
    {% for tag in single_tags %}
      <tr>
        <td>{{ tag | escape }}</td>
        <td>{{ count_tags[forloop.index0] }}</td>
      </tr>
    {% endfor %}
  </tbody>
</table>
{% endraw %}
```

{% assign alldocs = site.documents %}
{% assign alltags = alldocs | map: 'tags' | join: ',' | split: ',' %}
{% assign single_tags = alltags | uniq %}
{% assign count_tags = '' | split: ',' %}

{% for tag in single_tags %}
  {% assign count_this_tag = alltags | where_exp: "item", "item == tag" | size %}
  {% assign count_tags = count_tags | push: count_this_tag %}
{% endfor %}

<details>
  <summary>See results</summary>

<table>
  <caption>Tag counts on this site</caption>
  <thead>
    <tr>
      <th scope="col">Tag</th>
      <th scope="col">Count</th>
    </tr>
  </thead>
  <tbody>
    {% for tag in single_tags %}
      <tr>
        <td>{{ tag | escape }}</td>
        <td>{{ count_tags[forloop.index0] }}</td>
      </tr>
    {% endfor %}
  </tbody>
</table>

</details>

## Sorting

To sort by descending frequency, find the largest count and work down to
one. For each frequency, append the matching tags and their counts to two
new arrays. This approach is also used in
[Minimal Mistakes](https://github.com/mmistakes/minimal-mistakes/blob/master/_includes/posts-taxonomy.html).

```liquid
{% raw %}
{% assign sorted_tags = '' | split: ',' %}
{% assign sorted_count_tags = '' | split: ',' %}

{% if single_tags.size > 0 %}
  {% assign n_tags = single_tags | size | minus: 1 %}
  {% assign items_max = count_tags | sort | last %}
  {% for i in (1..items_max) reversed %}
    {% for j in (0..n_tags) %}
      {% if count_tags[j] == i %}
        {% assign sorted_tags = sorted_tags | push: single_tags[j] %}
        {% assign sorted_count_tags = sorted_count_tags | push: i %}
      {% endif %}
    {% endfor %}
  {% endfor %}
{% endif %}
{% endraw %}
```

Tags with equal counts retain their order of first appearance in `alltags`.
The empty-input check avoids constructing index ranges or finding a maximum
when there are no tags. Each unique tag is appended once, so a final `uniq`
filter is unnecessary.

```liquid
{% raw %}
<table>
  <caption>Tag counts in descending order</caption>
  <thead>
    <tr>
      <th scope="col">Tag</th>
      <th scope="col">Count</th>
    </tr>
  </thead>
  <tbody>
    {% for tag in sorted_tags %}
      <tr>
        <td>{{ tag | escape }}</td>
        <td>{{ sorted_count_tags[forloop.index0] }}</td>
      </tr>
    {% endfor %}
  </tbody>
</table>
{% endraw %}
```

{% assign sorted_tags = '' | split: ',' %}
{% assign sorted_count_tags = '' | split: ',' %}

{% if single_tags.size > 0 %}
  {% assign n_tags = single_tags | size | minus: 1 %}
  {% assign items_max = count_tags | sort | last %}
  {% for i in (1..items_max) reversed %}
    {% for j in (0..n_tags) %}
      {% if count_tags[j] == i %}
        {% assign sorted_tags = sorted_tags | push: single_tags[j] %}
        {% assign sorted_count_tags = sorted_count_tags | push: i %}
      {% endif %}
    {% endfor %}
  {% endfor %}
{% endif %}

<details>
  <summary>See results</summary>

<table>
  <caption>Tag counts in descending order</caption>
  <thead>
    <tr>
      <th scope="col">Tag</th>
      <th scope="col">Count</th>
    </tr>
  </thead>
  <tbody>
    {% for tag in sorted_tags %}
      <tr>
        <td>{{ tag | escape }}</td>
        <td>{{ sorted_count_tags[forloop.index0] }}</td>
      </tr>
    {% endfor %}
  </tbody>
</table>

</details>

The counting step scans all tag occurrences for each unique tag, requiring
roughly `O(U * N)` comparisons, where `U` is the number of unique tags and
`N` is the total number of occurrences. The nested sorting loops perform
`O(U * M)` comparisons, where `M` is the largest count. Array copying by
`push` adds overhead. This is practical for small blogs, but large sites
may benefit from computing tag counts outside the template.

## Complete example

Here is the combined counting and sorting code. The resulting
`sorted_tags` and `sorted_count_tags` arrays can be displayed with the table
above.

```liquid
{% raw %}
{% assign alldocs = site.documents %}
{% assign alltags = alldocs | map: 'tags' | join: ',' | split: ',' %}
{% assign single_tags = alltags | uniq %}
{% assign count_tags = '' | split: ',' %}

{% for tag in single_tags %}
  {% assign count_this_tag = alltags | where_exp: "item", "item == tag" | size %}
  {% assign count_tags = count_tags | push: count_this_tag %}
{% endfor %}

{% assign sorted_tags = '' | split: ',' %}
{% assign sorted_count_tags = '' | split: ',' %}

{% if single_tags.size > 0 %}
  {% assign n_tags = single_tags | size | minus: 1 %}
  {% assign items_max = count_tags | sort | last %}
  {% for i in (1..items_max) reversed %}
    {% for j in (0..n_tags) %}
      {% if count_tags[j] == i %}
        {% assign sorted_tags = sorted_tags | push: single_tags[j] %}
        {% assign sorted_count_tags = sorted_count_tags | push: i %}
      {% endif %}
    {% endfor %}
  {% endfor %}
{% endif %}
{% endraw %}
```
