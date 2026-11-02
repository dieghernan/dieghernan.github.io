# Blog-specific structured data

This layer complements Chulapa without replacing or normalizing its JSON-LD.
The gallery is deliberately excluded.

`_data/structured_data.json` contains the profile, project entity summaries and
explicit page-to-project relationships. Reuse canonical identifiers from the
project websites. Do not copy their release dates, versions or distributions.
New locally described resources have stable identifiers on their project page.

The featured package list reads `featured_packages` from the Projects page,
so its markup follows the visible cards. Chulapa retains responsibility for
the general collection list, articles, pages and breadcrumbs.

Project summaries use `subjectOf` to reference the existing project WebPage or
BlogPosting. Only explicitly selected articles receive these relationships;
code examples alone do not qualify. Package article summaries reuse the same
featured package definitions. Do not infer licenses, versions or sole authorship.

The existing ProfilePage uses the shared personal identity, preserving its
sameAs profiles and ORCID. This does not alter the theme's author entities.

Build with `bundle exec jekyll build`, then run
`py -m unittest discover -s _scripts -p test_structured_data.py`.
