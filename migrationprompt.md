Migration Prompt
 Migrate Project to Modern Python Template
 Task
Migrate this project to the modern 2026 Python template conventions.
 IMPORTANT: Consult @librarian First
Before making changes, use @librarian to fetch and analyze https://github.com/tinof/simple-modern-uv for the authoritative template conventions. The template is the source of truth - this prompt provides guidance but the template may have updates.
 Target State
 1. Build System
- Use `hatchling` with `uv-dynamic-versioning` for VCS-based versioning
- Or keep existing build backend if migration is risky
 2. Create/Update Configuration Files
**Makefile** - Use `make upgrade` target and all standard targets:
.DEFAULT_GOAL := default
.PHONY: default install fmt check test upgrade build clean
default: install check test
install:
	uv sync --all-extras
fmt:
	uv run ruff check --fix
	uv run ruff format
check:
	uv run ruff check
	uv run ruff format --check
	uv run basedpyright
test:
	uv run pytest
upgrade:
	uv sync --upgrade --all-extras
build:
	uv build
clean:
	rm -rf dist .pytest_cache .ruff_cache .venv
	find . -type d -name "__pycache__" -exec rm -rf {} +
.editorconfig - Standard editor configuration (check template)
3. Update pyproject.toml
Key sections (verify against template):
- [dependency-groups] for dev dependencies (NOT [project.optional-dependencies])
- [tool.ruff.lint] with extend-select = ["E", "F", "I", "UP", "B"]
- [tool.basedpyright] with appropriate warning suppression for legacy code
- [tool.pytest.ini_options] configuration
- project.urls pointing to correct repository
4. Update Documentation
- AGENTS.md: Command reference table including upgrade, uv instructions
- README.md: Use uv tool install as primary installation method (not pip/pipx)
5. Generate Lock File
uv lock
git add uv.lock
6. Update CI Workflow
Replace pip with uv:
- name: Install uv
  uses: astral-sh/setup-uv@v4
- name: Install dependencies
  run: uv sync --all-extras
- name: Run checks
  run: |
    uv run ruff check
    uv run ruff format --check
    uv run basedpyright
- name: Run tests
  run: uv run pytest
7. Delete Obsolete Files
- requirements.txt, requirements-dev.txt
- setup.py / setup.cfg
- pyrightconfig.json (move to pyproject.toml)
- ruff.toml (move to pyproject.toml)
- Redundant documentation files
Constraints
- Keep existing source code structure
- Preserve git history
- Don't break existing functionality
- Run make check and make test to verify after changes
Verification Checklist
- [ ] @librarian consulted for latest template conventions
- [ ] All Makefile targets work (install, fmt, check, test, upgrade, build, clean)
- [ ] pyproject.toml uses [dependency-groups] format
- [ ] README uses uv tool install for installation
- [ ] CI workflow uses uv
- [ ] make check passes
- [ ] make test runs (note pre-existing failures separately)
