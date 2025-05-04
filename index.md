---
layout: default
title: Recipe Index
---

## All Recipes
<ul id="recipe-index">
{% assign sorted = site.recipes | sort: 'title' %}
{% for r in sorted %}
  <li><a href="{{ r.url | relative_url }}">{{ r.title }}</a></li>
{% endfor %}
</ul>