# One World

> R packages, spatial data, maps and open-source projects by dieghernan.

This repository contains the source of [One World](https://dieghernan.github.io/), my personal blog and portfolio. I share R tutorials, mapping experiments and the tools I build along the way.

The site runs on [Jekyll](https://jekyllrb.com/) with my [Chulapa](https://dieghernan.github.io/chulapa/) theme and is hosted on GitHub Pages.

## Explore the site

- [Blog](https://dieghernan.github.io/blog/): R tutorials, package updates and experiments with geographic data.
- [Projects](https://dieghernan.github.io/projects): R packages, datasets and other open-source work, including historical Pebble projects.
- [Gallery](https://dieghernan.github.io/gallery): Maps, plots and Wikimedia contributions.
- [About](https://dieghernan.github.io/about): A little about me and where to find my work.
- [Archive](https://dieghernan.github.io/archive): Posts and projects ordered by date.

Featured packages include [tidyterra](https://dieghernan.github.io/tidyterra/), [giscoR](https://ropengov.github.io/giscoR/), [mapSpain](https://ropenspain.github.io/mapSpain/) and [geobounds](https://dieghernan.github.io/geobounds/) for spatial data, [cffr](https://docs.ropensci.org/cffr/) for software citation and [resmush](https://dieghernan.github.io/resmush/) for image optimization.

## Repository structure

| Path | Contents |
| --- | --- |
| [index.md](index.md) | Home page. |
| [_pages/](_pages/) | About, projects, gallery, archives and other site pages. |
| [collections/_posts/](collections/_posts/) | Published blog articles in Markdown. |
| [collections/_projects/](collections/_projects/) | Individual project pages. |
| [_Rmd/](_Rmd/) | R Markdown sources for tutorials and mapping experiments. |
| [_includes/](_includes/) and [_layouts/](_layouts/) | Site customizations that extend Chulapa. |
| [assets/](assets/) | Styles, scripts and other static assets. |
| [_config.yml](_config.yml) | Jekyll configuration and site settings. |
| [llms.txt](llms.txt) | A curated guide to the site for language models. |

## Run locally

Use Ruby 3.4, as specified in [.ruby-version](.ruby-version), and Bundler. The [Gemfile](Gemfile) specifies Jekyll 4.4 and the site's plugins.

From the repository root:

```sh
bundle install
bundle exec jekyll serve
```

Open [localhost:4000](http://localhost:4000/) to preview the site. Jekyll downloads the remote Chulapa theme during the build, so an internet connection is required.

To build without starting a server:

```sh
bundle exec jekyll build
```

The generated site is written to `_site/`, which is ignored by Git.

## Deployment

The [GitHub Actions workflows](.github/workflows/) build the site and deploy it to GitHub Pages when changes are pushed to `main` or `master`. Deployment can also be started manually from the Actions tab.

The root [llms.txt](llms.txt) follows the [llms.txt proposal](https://llmstxt.org/). Jekyll copies it unchanged to `/llms.txt`, and the deployment workflows include it with the generated site. Update its selected links when the site structure or featured resources change.

## License

This repository is distributed under the [MIT license](LICENSE).
