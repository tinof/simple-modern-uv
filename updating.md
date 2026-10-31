# Updating This Template

How to keep this template current: refresh tool versions, merge improvements from
upstream [jlevy/simple-modern-uv](https://github.com/jlevy/simple-modern-uv), and cut a
release so new and existing projects pick the changes up.

This repo’s own CI (`.github/workflows/ci.yml`) makes every PR self-validating: it
renders the template with default and non-default options, runs the full
install/check/test/build cycle on each render, tests the update path from the previous
release tag, and validates the agent skill (`skills/simple-modern-uv/`). There is no
separate downstream gate repo; a green CI run on the merge commit is the release gate.

## How Releases Reach Projects

Copier renders the **latest git tag** of this repo, not `main`. A change reaches
`copier copy gh:tinof/simple-modern-uv` and `copier update` only after a release tag is
published.

This fork inherited jlevy’s `v0.2.x` tags, so its own releases start at **`v1.0.0`** to
stay clearly above anything inherited.
Never push upstream’s tags to this repo (fetch upstream with `--no-tags`, as below), or
Copier could pick an upstream tag over ours.

## Release Sequence

1. **Finish the PR:** freeze the version inventory (Step 1), update files (Step 2), and
   require every CI job to pass.
2. **Merge** into `main` and wait for the `main` CI run on that merge commit to pass.
3. **Publish a GitHub Release** targeting that commit (Step 4). GitHub creates the tag;
   do not push a bare tag separately.
4. **Smoke-test the public tag:** render it into a scratch directory and run
   `make && make build` (see the smoke test in [AGENTS.md](AGENTS.md)).

## Step 1: Check Latest Versions

Take one timestamped inventory, compute the cut-off, and freeze it for the release.
This standard-library script prints the newest stable release of each tool and the
newest one at least 14 days old:

```shell
python3 - <<'PY'
import datetime as dt
import json
import re
import urllib.request

packages = [
    "uv", "copier", "flowmark-rs", "pytest", "pytest-sugar", "ruff",
    "codespell", "basedpyright", "hatchling", "uv-dynamic-versioning",
]
now = dt.datetime.now(dt.timezone.utc)
cutoff = now - dt.timedelta(days=14)
stable = re.compile(r"^[0-9]+(?:\.[0-9]+)*$")
print(f"audit={now.isoformat()} cutoff={cutoff.isoformat()}")

for package in packages:
    url = f"https://pypi.org/pypi/{package}/json"
    with urllib.request.urlopen(url, timeout=30) as response:
        data = json.load(response)
    releases = []
    for version, files in data["releases"].items():
        if not stable.fullmatch(version):
            continue
        timestamps = [
            dt.datetime.fromisoformat(file["upload_time_iso_8601"].replace("Z", "+00:00"))
            for file in files
            if not file.get("yanked")
        ]
        if timestamps:
            releases.append((tuple(map(int, version.split("."))), version, min(timestamps)))
    latest = max(releases)
    eligible = max(r for r in releases if r[2] <= cutoff)
    print(f"{package:24} eligible={eligible[1]:12} latest={latest[1]:12}")
PY
```

Also check:

- **GitHub Actions** (`actions/checkout`, `astral-sh/setup-uv`, `oven-sh/setup-bun`):
  review releases, then resolve the commit SHA of the chosen tag, e.g.
  `git ls-remote --tags https://github.com/astral-sh/setup-uv | grep v9.0.0`. Dependabot
  in generated projects proposes these bumps too.
- **The uv checksum** for the pinned version:
  `curl -sL https://github.com/astral-sh/uv/releases/download/X.Y.Z/uv-x86_64-unknown-linux-gnu.tar.gz.sha256`.
- **The uv changelog** for breaking changes when moving to a new minor line
  (`required-version` in `template/uv.toml` pins one minor line).
  See the [uv changes research](docs/project/research/research-uv-changes.md).
- **Bun and npm-registry tools** (`bun`, `skills`, `skills-ref`): check publish dates
  with `curl -s https://registry.npmjs.org/<package>` (the `time` field) and pick
  versions at least 14 days old.
- **New Python releases** for the CI matrix and classifiers.

### Supply Chain Hygiene

These practices follow
[supply-chain-hardening](https://github.com/jlevy/supply-chain-hardening).

- **Cooling-off period:** do not adopt any release published within the last 14 days.
  Prefer the newest release that is at least 14 days old and not yanked.
  Generated `uv.toml`, CI, the generated Makefile, and this repo’s Makefile all enforce
  a 14-day window.
- **Vet changes:** for each bumped item, skim the release notes between the old and new
  versions and check for advisories (for example on [osv.dev](https://osv.dev)). Review
  the full rendered `uv.lock` diff, not just direct packages.
- **Pin:** full commit SHAs for actions, exact versions for build backends and executed
  tools (`copier@X.Y.Z`, `flowmark-rs@X.Y.Z`, `skills@X.Y.Z`). npm-registry tools run
  through Bun’s `bunx --ignore-scripts --minimum-release-age 1209600`, so lifecycle
  scripts stay off and the same 14-day cool-off applies.
- Avoid new dependencies when a little first-party code will do.

## Step 2: Update the Template Files

- **Dev dependency floors** in `template/pyproject.toml.jinja` (`>=` floors; the lock
  and cool-off pick the actual versions).
- **Build backend pins** in both `[build-system].requires` and the `build` dependency
  group of `template/pyproject.toml.jinja`; keep them identical.
- **uv version and checksum** in `template/.github/workflows/ci.yml`, the publish
  workflow, `UV_VERSION`/`UV_CHECKSUM` in this repo’s `.github/workflows/ci.yml`,
  `UV_VERSION` in `template/.claude/hooks/session-start.sh`, and `required-version` in
  `template/uv.toml`.
- **Action SHAs** and version comments in all workflow files (template and this repo).
- **Python matrix** in `template/.github/workflows/ci.yml`, the classifiers in
  `template/pyproject.toml.jinja`, and the README badge.
- **Bun version** (`BUN_VERSION` in this repo’s `.github/workflows/ci.yml`) and the
  `skills@X.Y.Z` / `skills-ref@X.Y.Z` pins in the README and CI.
- **Pinned Copier version** (`copier@X.Y.Z`) everywhere it appears: `copier.yml`,
  README, AGENTS.md, the skill references, generated `pyproject.toml` comments, and CI.
- **The agent skill** (`skills/simple-modern-uv/`): update the FAQ and checklists if
  behavior changed.

Find every pin quickly with:

```shell
grep -rnE 'copier@|flowmark-rs@|skills(-ref)?@|version: "|checksum|required-version|_VERSION|@[0-9a-f]{40}' \
  --exclude-dir=.git .
```

Then format the docs (CI’s `format-check` job enforces this):

```shell
make format
make format-check
```

### Changing Template Questions (Answer-Schema Evolution)

Whenever a question is added to or changed in `copier.yml`:

1. **Behavior-preserving defaults:** a new question’s default must reproduce what the
   template generated before the question existed, so `copier update --defaults` is a
   no-op for existing projects.
2. **Old answer files stay valid:** never require manual edits to `.copier-answers.yml`;
   `--defaults --skip-answered` fills new keys.
3. **Hand customizations are reconciled by the skill** with explicit `--data` (see
   [customize.md](skills/simple-modern-uv/references/customize.md)).
4. **CI guards the update path:** the `update-path` job renders the previous release,
   updates it to the candidate, and checks it converges with a fresh render.
5. **Call it out in release notes**, naming new keys and their defaults.

## Step 3: Merging Upstream Changes

jlevy/simple-modern-uv keeps improving; merge it in periodically rather than letting the
fork drift.

```shell
git remote add upstream https://github.com/jlevy/simple-modern-uv.git  # once
git fetch --no-tags upstream main
git log --oneline HEAD..upstream/main      # what is new upstream
git switch -c sync-upstream origin/main
git merge upstream/main
```

When resolving conflicts, keep this fork’s deliberate differences (listed in the README
under “Differences from Upstream”):

- `make fmt`/`make check` in the Makefile, CI, and docs instead of `devtools/lint.py`
  (map upstream `make lint` to `make fmt` and `make lint-check` to `make check`).
- Python 3.12+ and the fork’s ruff, pytest, and package-skeleton choices.
- Links and `gh:` sources pointing at `tinof/simple-modern-uv`.
- The `.claude/` settings and SessionStart hook in `template/`.

Drop upstream’s maintainer-only tooling that this fork doesn’t use (currently the `tbd`
issue tracker in `.tbd/`, `.claude/`, `.codex/`, and `.agents/` at the repo root).
Then run Steps 1 and 2 for any versions upstream changed, and the smoke test in
[AGENTS.md](AGENTS.md).

## Step 4: Create the Release

Choose the version:

- **Minor** (`v1.1.0`): new or changed template questions, new files in the render, or
  other feature-level changes.
- **Patch** (`v1.0.1`): routine version bumps and doc fixes that leave the render’s
  shape unchanged.

Write release notes in a file (so backticks and `$` are not shell-expanded), then create
the release targeting the validated merge commit:

```shell
NEW_TAG="v1.X.Y"
TEMPLATE_COMMIT=$(git rev-parse origin/main)
gh release create "$NEW_TAG" --target "$TEMPLATE_COMMIT" --title "$NEW_TAG" \
  --notes-file tmp/release-notes.md
```

Release notes use `## What's Changed` with grouped sections (dependency updates,
template changes, new or changed questions with defaults), ending with a concrete
compare link such as
`https://github.com/tinof/simple-modern-uv/compare/v1.0.0...v1.1.0`.

## Step 5: Update Your Projects

In each project made from this template (clean working tree first):

```shell
uvx --exclude-newer "14 days" copier@9.19.1 update --defaults --skip-answered
make
```

Resolve any `*.rej` files, commit, and confirm the project’s CI passes.
Or ask your agent: “Update this project to the latest simple-modern-uv template.”

<!-- This document follows common-doc-guidelines.md.
See github.com/jlevy/practical-prose and review guidelines before editing.
-->
