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

## Bridgy Fed

The blog uses its discoverable Atom and RSS feeds to publish through
[Bridgy Fed](https://fed.brid.gy/web/dieghernan.github.io). The home page's
representative `h-card` supplies the blog's display name, avatar, banner and bio.
Keep its `u-url` pointing to the site's canonical home page.
Edit `indieweb_profile` in `_config.yml` to update the name, nickname, bio,
location, topics and profile links. The `custom/h-card.html` include renders
the card outside the home page's `h-entry` so parsers can discover it directly.

The file [`.well-known/atproto-did`](.well-known/atproto-did) contains the DID of
the blog's bridged Bluesky account, not the author's personal account. Jekyll
includes `.well-known` explicitly so the file is published without HTML layout.
After deployment, check that `https://dieghernan.github.io/.well-known/atproto-did`
returns only the DID, then complete the custom Bluesky handle change from the
blog's Bridgy Fed user page. Publishing the file alone does not change the handle.
Refresh the profile there after publishing changes to the `h-card`.

Keep feed-based publishing enabled: sending even one webmention to Bridgy Fed
switches the site to webmention-based publishing and stops feed polling. The
incoming webmention.io endpoint is separate and can remain enabled. Feed polling
is asynchronous; the current Bridgy Fed implementation schedules checks between
two hours and one day apart. A profile refresh does not import posts.

## Syndicated copies of posts

When a post also exists on another service, add its actual public permalink
(not a profile URL) to the post's frontmatter:

```yaml
syndication:
  - https://social.example/@author/123456
  - https://bsky.app/profile/example.com/post/example
```

These are illustrative URLs, not existing copies of this site's posts. Replace
them with the real permalinks before publishing. If the post has an equivalent
`.Rmd` source, keep its frontmatter synchronized.

The default layout displays an “Also published on” list outside the article's
`e-content` and inside its `h-entry`. Each link has `u-syndication` and
`rel="syndication"`, allowing IndieWeb readers to identify the copies. Only
absolute HTTP(S) links with a hostname are rendered; no section appears when
there are no usable links. No JavaScript, notifications or new service is
required. This does not change Bridgy Fed's feed-based publishing.

## Outgoing Webmentions

The independent `Send outgoing Webmentions` workflow runs after a successful
Pages deployment on `main`, or manually from Actions. Automatic runs read the
exact deployed HTML artifact; manual runs build the blog without deploying it.
The sender processes links inside posts' editorial `e-content`, excluding
navigation, syndicated-copy footers and project pages. Each source must match
its live public page before sending; unpublished edits and stale CDN content
remain pending.

The first execution of ledger version 3 rebuilds the earlier baseline and
processes the historical archive, including links previously recorded without
being sent. The previous `state.json` is preserved as `state-before-v3.json`
in the `webmention-state` branch and remains available in Git history. The
migration is checkpointed before delivery and never repeats once version 3 has
been saved. Completed targets are checkpointed atomically, so interrupted runs
resume pending work. Acceptance means the receiver accepted the submission,
not that verification or publication has finished.

Subsequent runs skip unchanged deliveries and retry failed requests. Links
without an endpoint are recorded, too. Edited articles can notify existing
destinations again. Removing links or deleting posts does not send deletion
notifications. Keep the state branch: restoring it from Git preserves delivery
history, whereas losing it causes the archive to be processed again.

Internal blog links are excluded. Links to `/chulapa` and `/chulapa/` paths on
the same domain are eligible; other same-domain links remain excluded. All
`fed.brid.gy` destinations, including subdomains, endpoints and redirects,
remain excluded to preserve Bridgy Fed's feed-based publishing. Discovery
supports HTTP `Link` headers and HTML `rel="webmention"`.

The sender pins connections to validated public IPs while retaining the
original hostname for HTTPS certificate checks. It rejects non-public
addresses, configured forward proxies and endpoint POST redirects. No extra
secret or service is needed: `GITHUB_TOKEN` writes the delivery-state branch.
The independent workflow's failures do not affect the completed deployment.
Inspect its logs for accepted, unsupported and retryable targets. Disabling
this workflow stops outgoing notifications without affecting incoming mentions.

Local checks do not send notifications:

```sh
python -m unittest discover -s _scripts -p 'test_*.py'
python _scripts/webmentions.py --site _site --state /tmp/webmention-state.json --dry-run
```

## License

This repository is distributed under the [MIT license](LICENSE).
