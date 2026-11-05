# Repository editorial agents

For house-style checks or authoring of this site's posts, project pages and
matching Rmd sources, use `.github/agents/site-editor.agent.md` with
`.github/skills/site-style/SKILL.md`.

Keep the project's R scripts formatted with `air` and the R code in Rmd sources
formatted with `styler::style_file()` or `styler::style_dir()`. Formatting must
preserve behavior, prose, YAML chunk options and figure dimensions. Do not
render or execute chunks to apply formatting.

`site-editor` complements the globally installed `review-docs` agent. Generic
proofreading still uses the global agent and its paired skill. Do not create
local `review-docs` or `proofread-docs` definitions that shadow them.

Keep explicit preferences separate from conventions inferred from examples.
Respect the user's current scope and no-render/no-build/local-only requests. Do
not expand an editorial task into code refactoring or archive-wide changes.
