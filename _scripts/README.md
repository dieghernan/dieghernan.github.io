# Scripts

This directory contains site-maintenance utilities, project-specific scripts
and tests. Run commands from the repository root.

## Standard.site utilities

- `standard-document-check.mjs <at://...>` fetches and prints one
  `site.standard.document` record:

  ```sh
  node _scripts/standard-document-check.mjs at://did:plc:example/site.standard.document/example
  ```

- `standard-document-missing.mjs` checks the pages in the Bridgy Fed
  `site.standard.document` collection for a matching `<link>` in each page's
  `<head>`. It makes requests to Bridgy Fed and the listed pages:

  ```sh
  node _scripts/standard-document-missing.mjs
  ```

- `check-standard-site.mjs` inspects the blog's `site.standard.publication`
  record, including the Unicode code points in its name.

## Other utilities

- `indexnow.mjs` submits built `.html` paths to IndexNow:

  ```sh
  node _scripts/indexnow.mjs _site/example/index.html
  ```

- `webmentions.py` sends outgoing Webmentions. See the
  [Webmentions documentation](../README.md#outgoing-webmentions) for the
  workflow and dry-run instructions.
- `postal-codes-spain.R` renders the postal-code project image. Its
  prerequisites and invocation are documented in the script header.
- `flights.R` and `DemoMadrid.R` are project-specific R scripts.
- `test_*.py` contains Python tests. See the repository
  [checks](../README.md#checks) for test commands and requirements.

The [social-card guide](social/README.md) documents the files and workflow for
the social preview images.
