# Project Instructions for AI Agents

This file provides instructions and context for AI coding agents working on this
project: the tinof fork of the
[simple-modern-uv](https://github.com/jlevy/simple-modern-uv) Copier template.

## Build and Test

This is a [Copier](https://copier.readthedocs.io) template repo, not a Python project
itself; there is no package to sync at the root.
Validation means rendering the template and exercising the render:

```bash
# Auto-format all Markdown docs (including *.md.jinja); check-only variant for CI:
make format
make format-check

# Render the template non-interactively (smoke test). Without --vcs-ref, Copier
# renders the working tree, including uncommitted changes:
SMOKE_DIR=$(mktemp -d)
uvx --exclude-newer "14 days" copier@9.19.1 copy --defaults \
  --data package_name=smoke-test \
  --data package_github_org=testorg . "$SMOKE_DIR"

# Dynamic versioning needs an initial commit before installation:
cd "$SMOKE_DIR"
git init --initial-branch=main
git add .
git -c user.name=Smoke -c user.email=smoke@example.com \
  commit -m "Initial commit"
make install
make check
make test
git tag v0.1.0 && make build
```

The generated project requires the uv line pinned in `template/uv.toml`
(`required-version`); install it first if `uv --version` is older.

## Architecture Overview

- `template/`: the Copier template source that ships to generated projects (`*.jinja`
  files are rendered; everything else copies as-is).
  `template/Makefile`, `template/AGENTS.md.jinja`, and `template/.claude/` are what
  downstream projects use, not this repo.
- `copier.yml`: template questions and validation; the single source of truth for
  template variables.
- [`skills/simple-modern-uv/`](skills/simple-modern-uv/): the portable agent workflow
  bundle. Its [`SKILL.md`](skills/simple-modern-uv/SKILL.md) is the concise router; the
  one-level `references/` files own the new, selective, migration, and update
  procedures. Keep README discovery and generated agent guidance aligned with these
  routes.
- [`updating.md`](updating.md): version refreshes, merging upstream
  (jlevy/simple-modern-uv), and the release flow.
- [`docs/project/`](docs/project/README.md): maintainer research and upstream release
  evidence.

## Conventions and Patterns

- This fork deliberately differs from upstream in a few places (README, “Differences
  from Upstream”). Preserve those differences when merging upstream changes.
- Follow the [supply-chain rules](updating.md#supply-chain-hygiene): 14-day cooling-off
  before adopting new releases, pinned tool versions, full action SHAs, and
  `UV_EXCLUDE_NEWER` in workflows.
- When a pinned version changes, update every copy (see the `grep` in updating.md Step
  2); CI checks several of them against each other.
- Markdown is formatted with flowmark via `make format`; run it before committing doc
  changes.
- Copier renders the latest git tag, so template changes reach projects only after a
  release (see updating.md).

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
