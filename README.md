# simple-modern-uv (tinof fork)

[![python](https://img.shields.io/badge/python-3.12%20%7C%203.13%20%7C%203.14%20%7C%203.15-blue?logo=python&logoColor=white)](https://www.python.org/downloads/)
[![uv](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/uv/main/assets/badge/v0.json)](https://github.com/astral-sh/uv)
[![Copier](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/copier-org/copier/master/img/badge/badge-grayscale-border.json)](https://github.com/copier-org/copier)

## What Is This?

A minimal, modern **Python project template** (Python 3.12–3.15) built on
[**uv**](https://docs.astral.sh/uv/), designed for humans and AI coding agents (Claude
Code first) to work on Python projects together.

It is a fork of Joshua Levy’s excellent
[**jlevy/simple-modern-uv**](https://github.com/jlevy/simple-modern-uv) and tracks it
closely. Upstream improvements are merged in regularly; this fork adds a few opinions of
its own (see [Differences from Upstream](#differences-from-upstream)).

A generated project includes:

- [**uv**](https://github.com/astral-sh/uv) for Python, dependencies, and builds, with a
  committed `uv.lock` and a project-owned `uv.toml`.
- [**ruff**](https://github.com/astral-sh/ruff) for linting and formatting,
  [**codespell**](https://github.com/codespell-project/codespell) for spelling, and
  [**BasedPyright**](https://github.com/detachhead/basedpyright) for type checking.
- [**pytest**](https://github.com/pytest-dev/pytest) (strict mode) with
  [pytest-sugar](https://github.com/Teemu/pytest-sugar).
- **GitHub Actions** CI across Python 3.12–3.15 with SHA-pinned actions, a checksummed
  uv, and `uv sync --locked`, plus Dependabot to keep the pinned actions current.
- **Tag-driven releases** via
  [uv-dynamic-versioning](https://github.com/ninoseki/uv-dynamic-versioning/) and PyPI
  trusted publishing (optional; private projects skip it).
- **Agent guidance**: `AGENTS.md` (the [AGENTS.md](https://agents.md) standard),
  `CLAUDE.md` that imports it, and `.claude/settings.json` with safe command
  pre-approvals and a SessionStart hook that sets up cloud sessions automatically.
- **Supply-chain defaults**: a 14-day cool-off on new releases everywhere uv resolves
  dependencies.

## Quick Start

### With Claude Code (or Another Agent)

Install the [simple-modern-uv skill](skills/simple-modern-uv/SKILL.md) with the
[skills CLI](https://github.com/vercel-labs/skills).
It follows the [Agent Skills](https://agentskills.io) format and works with Claude Code,
Codex, Cursor, Gemini CLI, and other compatible agents:

```shell
NPM_CONFIG_IGNORE_SCRIPTS=true NPM_CONFIG_BEFORE=2026-07-31T18:59:05Z \
  npx --yes skills@1.5.18 add tinof/simple-modern-uv \
    --skill simple-modern-uv --yes
```

Then describe the outcome you want:

| Goal | Example prompt | Result |
| --- | --- | --- |
| Start fresh | “Start a new Python project called `my-package` using simple-modern-uv.” | A complete, template-managed project |
| Add features ad hoc | “Add simple-modern-uv’s uv lock policy and CI to this repo, but keep its build backend.” | Only the selected, compatible feature bundles |
| Upgrade a project | “Migrate this package from Poetry to simple-modern-uv and preserve its public behavior.” | A full migration with future Copier updates |
| Update later | “Update this project to the latest simple-modern-uv template.” | Template changes reconciled with local adaptations |

No installer handy? Tell the agent to fetch
[`SKILL.md`](skills/simple-modern-uv/SKILL.md) and the reference it links for the chosen
workflow, from the same Git revision.
For a ready-made migration prompt, see [migrationprompt.md](migrationprompt.md).

The skill treats adoption as a choice, not pass/fail: **selective** (only named
features), **core toolchain** (uv, lock, lint, types, tests, CI, agent guidance), or
**full template-managed** (rendered structure plus `.copier-answers.yml` for
`copier update`). Changes to supported Python versions, layout, build backend,
versioning, license, publishing, or CI always stay your decision.

### By Hand with Copier

```shell
cd ~/projects   # Wherever you keep projects.
uvx --exclude-newer "14 days" copier@9.19.1 copy \
  gh:tinof/simple-modern-uv YOURNEWREPO
```

Answer the prompts (or press enter and search for `changeme` later), then:

```shell
cd YOURNEWREPO
git init --initial-branch=main
git add .
git commit -m "Initial commit from simple-modern-uv."
# Sync after the first commit so dynamic versioning gives a real version.
# This creates uv.lock; commit it so CI can install with --locked.
make install
git add uv.lock
git commit -m "Add uv.lock."
# Create an empty repo on GitHub (no README, .gitignore, or license), then:
git remote add origin git@github.com:OWNER/YOURNEWREPO.git
git push -u origin main
```

License and publishing are template questions: `package_license` (MIT, Apache-2.0,
BSD-3-Clause, AGPL-3.0-or-later, Proprietary, or None to decide later) and
`publish_to_pypi` (no omits the publish workflow and docs and adds the
`Private :: Do Not Upload` classifier).
Change them later by re-answering rather than deleting files, e.g.
`uvx --exclude-newer "14 days" copier@9.19.1 update --data package_license=Apache-2.0`.

## Daily Workflow in a Generated Project

```shell
make            # install, fmt, check, test
make install    # uv sync --all-extras --all-groups
make fmt        # auto-fix: codespell -w, ruff check --fix, ruff format
make check      # verify like CI: codespell, ruff, ruff format --check, basedpyright
make test       # uv run pytest
make build      # wheel and sdist from the locked build backend
make upgrade    # upgrade deps within the 14-day cool-off

uv run pytest -k "test_name"                             # one test
UV_CONFIG_FILE=uv.toml uv add --exclude-newer "14 days" requests  # add a dependency
```

Global Python CLI tools don’t need pipx or brew: `uv tool install ruff`,
`uv tool upgrade ruff`, `uv tool list`, or run once with `uvx ruff`.

## Differences from Upstream

| Area | jlevy/simple-modern-uv | This fork |
| --- | --- | --- |
| Python | 3.11+ | 3.12+ (CI also tests 3.15) |
| Lint commands | `make lint` / `make lint-check` via `devtools/lint.py` (adds rich and funlog dev deps) | `make fmt` / `make check` calling the tools directly; `lint`/`lint-check` kept as aliases |
| Ruff rules | E, F, UP, B, I | Adds SIM, C4, PT, and RUF |
| pytest | `[tool.pytest.ini_options]` | Native `[tool.pytest]` with `strict = true` |
| uv | 0.12 line | 0.13 line |
| Claude Code | `CLAUDE.md` imports `AGENTS.md` | Also `.claude/settings.json` (command pre-approvals) and a SessionStart hook that installs the pinned uv and deps in cloud sessions |
| Package skeleton | `from .module import *` | Explicit `__all__`, `__main__.py` for `python -m`, a smoke test that imports the package |
| Repo hygiene |  | `.editorconfig`, Dependabot for SHA-pinned actions (14-day cooldown), CI concurrency and timeouts |

## Updating Your Project

Projects created with Copier (or the agent skill) record their answers in
`.copier-answers.yml` and can pull template improvements at any time:

```shell
uvx --exclude-newer "14 days" copier@9.19.1 update --defaults --skip-answered
```

Or ask your agent: “Update this project to the latest simple-modern-uv template.”

## Supply Chain Hardening

Dependencies are an attack surface.
This template follows Joshua Levy’s
[**supply-chain-hardening**](https://github.com/jlevy/supply-chain-hardening) guide:

- **Cool-off period:** no release younger than 14 days, via uv’s relative
  [dependency cooldown](https://docs.astral.sh/uv/concepts/resolution/#dependency-cooldowns)
  in generated `uv.toml`, CI, and the Makefile.
  Standard workflows select the checked-in `uv.toml` explicitly so ambient user settings
  cannot make `uv.lock` nonportable.
- **Vet what you add:** only add dependencies you can verify upstream; prefer a little
  first-party code over a new dependency.
- **Pin and lock:** commit `uv.lock`, pin GitHub Actions to full commit SHAs, and verify
  the uv binary by checksum in CI.

See [updating.md](updating.md#supply-chain-hygiene) for how the template applies these.

## Type Checking: Why BasedPyright?

BasedPyright is fast, well maintained, stricter than Pyright, and has a
[VSCode extension](https://marketplace.visualstudio.com/items?itemName=detachhead.basedpyright)
that works in Cursor and other forks.
Astral’s [**ty**](https://github.com/astral-sh/ty) is very fast and promising but still
pre-1.0 and behind on typing-spec coverage, so the template stays on BasedPyright for
now. See the
[type-checker research doc](docs/project/research/research-python-type-checkers.md) for
the comparison.

## What This Template Does Not Include

Docker, private package indexes (see
[uv’s alternative index docs](https://docs.astral.sh/uv/guides/integration/alternative-indexes/)),
docs sites, Conda, non-GitHub CI, and project-management boilerplate (issue templates,
contributing guides, and so on).
Add them per project as needed.

## Maintaining This Template

This repo is a [Copier](https://copier.readthedocs.io) template, not a Python package.
See [AGENTS.md](AGENTS.md) for how to render and test it, and
[**updating.md**](updating.md) for refreshing tool versions, merging upstream changes
from jlevy/simple-modern-uv, and cutting releases.
Copier uses the **latest git tag** of this repo, so changes reach new projects only
after a release tag is pushed.

## Credits

Created by [Joshua Levy](https://github.com/jlevy) as
[simple-modern-uv](https://github.com/jlevy/simple-modern-uv) (MIT licensed).
This fork is maintained by [tinof](https://github.com/tinof).
Other good uv templates: [cookiecutter-uv](https://github.com/fpgmaas/cookiecutter-uv)
and [copier-uv](https://github.com/pawamoy/copier-uv).

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
