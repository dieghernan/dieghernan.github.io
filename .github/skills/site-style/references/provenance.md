# Preference provenance

This file distinguishes explicit preferences from observed conventions.
The policy lives in `SKILL.md` and the publication reference, not in copied
conversation logs. Recheck repository paths and helpers as the project evolves.

## Explicit preferences recovered on 2026-11-05

From the active postal-code drafting conversation:

- Posts are in English, including prose, variables, functions, chunk labels,
  plot text, alt text and captions. Original source titles remain accurate.
- Use absolute web links in posts/projects, bold software/package names,
  Chulapa alerts, relevant tags and consistent references.
- Every image needs alt text. The author leaves their own figures in posts
  without visible captions and explicitly allows optional captions for figures
  produced by others. Project pages retain the earlier caption requirement.
- The previous reference style followed the hillshade post of 2022-10-17, explicitly
  chosen by the user over the newer template. Use plain article titles,
  italic journal/publication details and visible DOI/URL autolinks.
- Use YAML `#|` chunk options and the knitr conversion helper.
- Keep the new site agent separate from the installed global `review-docs`.
- Avoid semicolons in prose. Use the intermediate, approachable tone instead
  of making every transition playful.
- Respect local-only work and explicit no-render/no-build instructions.
- Preserve figure proportions and crop unwanted exterior margins. The user
  intentionally retained PNGs while diagnosing rendering.

The global `C:/Users/diego/.codex/AGENTS.md`, also supplied in the conversation,
records US English, sentence-case headings, no Oxford comma, concise wording,
duplicate-line/blank-line cleanup and user-facing-message proofreading. These
preferences are applied here without copying the global review agent.

## Retrieved historical conversations

These are actual retrieved user requests, not inferred memories. Titles are
recorded verbatim. Thread identifiers support later retrieval when available,
but are not required to run this portable skill.

- “Proponer post sobre piel de naranja”
  (`01a16dcd-ca67-7cd0-a7f4-f5512f98c8ad`): absolute image paths, including
  YAML/OG metadata, WebP output, an executable Rmd source, synchronized
  references and real article URLs in `syndication`. Publishing and pushing
  were separate user instructions, not implied by writing a draft.
- “Revisa y unifica referencias”
  (`01a1a3d7-983a-7640-a59d-7de30901f6cc`): bullet lists across references,
  DOI verification when requested, Royé's own recommended citation and an
  explicit request to keep Goerlich's existing reference wording.
- “Revisar y mejorar la redacción”
  (`01a176da-5343-79e0-9ff6-d68410eef5da`): the user specifically checked that
  Rmd sources were synchronized after Markdown updates. A preference against
  **ggnewscale** concerned a hillshade experiment and is not a universal ban
  on that package or a writing rule.
- “Comparar JSON-LD con sitios fuente”
  (`01a1a083-1245-7d61-b59a-780136753288`): original project websites are the
  source of truth for their summaries, syndication uses the existing site
  mechanism and commits/pushes happen at the end when authorized.
- “Actualiza el post de resmush”
  (`01a1a6b2-dd0f-7a42-8ccd-c81ff67a571d`): a supplied iframe was to be used
  without additional CSS. Treat this as evidence to reuse existing components,
  not as a blanket prohibition on CSS in every future implementation task.

## Repository evidence and editorial defaults

The user explicitly requires project-wide formatting with **air** for R
scripts and **styler** for R code in Rmd sources. This is a formatting rule,
not permission to refactor code or execute analyses.

`_maintenance/references-audit.md` records the reference normalization and
its intentional exceptions. `_maintenance/link-audit.md` records preserved
links and explains why crawler restrictions are inconclusive.

Chulapa alert syntax appears in existing published posts and project pages.
The tag vocabulary is drawn from `collections/_posts/` and
`collections/_projects/`. Voice examples include `_Rmd/2026-10-24-orange-peel.Rmd`,
`_Rmd/2022-05-01-Unknown-pleasures-R.Rmd` and
`_Rmd/2026-02-12-geobounds.Rmd`. Their light hooks, practical transitions and
step-by-step explanations are style guidance, not mandatory formulas.

The user later adopted APA 7 for bibliographic entries and alphabetical
ordering across posts, projects and drafts, with Markdown bullets and
inline links retained. That decision supersedes the earlier hillshade
post as the reference formatting model. Keep explicit citation exceptions.

Legacy relative links and incomplete figure
metadata are issues to fix within scope, not counterexamples overriding the
user's explicit newer requirements.
