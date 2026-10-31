@AGENTS.md

<!-- Claude Code reads CLAUDE.md rather than AGENTS.md; the @AGENTS.md line above
imports it so both stay in sync. Add any Claude-specific instructions below. -->

## Claude Code

- `.claude/settings.json` pre-approves the read-only and routine project commands
  (`make install|fmt|check|test|build`, `uv run pytest|ruff|basedpyright`). Adding
  dependencies (`uv add`) still asks first, so new packages get a human look.
- In cloud sessions, `.claude/hooks/session-start.sh` installs the pinned uv and runs
  `make install`, so checks and tests work right away.
- Put personal overrides in `.claude/settings.local.json` (gitignored).
