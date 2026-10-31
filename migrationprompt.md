# Migration Prompt

A copy-paste prompt for asking a coding agent (Claude Code or another) to migrate an
existing Python project to this template.
The detailed procedure lives in the agent skill, so this prompt stays short and never
goes stale.

Install the skill first if you can (see the README’s Quick Start), then paste:

```text
Migrate this project to the simple-modern-uv template (github.com/tinof/simple-modern-uv).

Use the simple-modern-uv skill. If it is not installed, fetch
https://github.com/tinof/simple-modern-uv/blob/main/skills/simple-modern-uv/SKILL.md
and the references it links for this workflow (adopt-existing.md for a full migration,
adopt-selectively.md if I only want some features), all from the same git revision.

- Work on a new branch and inspect the repo before changing anything.
- Infer the template answers (name, module, description, author, GitHub org, license,
  publish_to_pypi) and confirm them with me in one message, flagging any change to
  supported Python versions, layout, build backend, versioning, license, publishing, or CI.
- Render the template beside the project and merge it in deliberately; never blindly
  overwrite. Keep existing source structure and behavior.
- Delete superseded files (setup.py, setup.cfg, requirements*.txt, poetry.lock,
  standalone ruff/mypy/pyright configs) only after porting their content.
- Verify with `make install`, `make fmt`, `make check`, `make test`, and `make build`
  if publishing. Report pre-existing test failures separately.
- Summarize what was adopted, adapted, preserved, deferred, and removed.
```

For a selective change, replace the first line with what you want, for example “Add
simple-modern-uv’s uv lock policy and CI to this repo, but keep its build backend.”

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
