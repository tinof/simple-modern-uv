# Makefile for easy development workflows.
# See docs/development.md for docs.
# Note GitHub Actions call uv directly, not this Makefile.

.DEFAULT_GOAL := default

# Use only the checked-in project configuration. Otherwise uv merges user- and
# system-level settings into uv.lock, which can make it fail on another machine.
UV_CONFIG_FILE := $(CURDIR)/uv.toml
export UV_CONFIG_FILE

# Safe default for every dependency resolution invoked through this Makefile.
UV_EXCLUDE_NEWER ?= 14 days
export UV_EXCLUDE_NEWER

# Paths for spell checking. Keep in sync with .github/workflows/ci.yml.
CODESPELL_PATHS := src tests docs README.md AGENTS.md

.PHONY: default install fmt check lint lint-check typecheck test upgrade build clean

default: install fmt check test

install:
	uv sync --all-extras --all-groups

# Format and auto-fix (mutates files; use locally).
fmt:
	uv run codespell --write-changes $(CODESPELL_PATHS)
	uv run ruff check --fix
	uv run ruff format

# Check only, matching CI (never mutates files).
check:
	uv run codespell $(CODESPELL_PATHS)
	uv run ruff check
	uv run ruff format --check
	uv run basedpyright

typecheck:
	uv run basedpyright

# Aliases matching upstream simple-modern-uv naming.
lint: fmt typecheck
lint-check: check

test:
	uv run pytest

upgrade:
	uv sync --upgrade --all-extras --all-groups

build: install
	uv build --no-build-isolation

clean:
	-rm -rf dist/
	-rm -rf *.egg-info/
	-rm -rf .pytest_cache/
	-rm -rf .ruff_cache/
	-rm -rf .mypy_cache/
	-rm -rf .venv/
	-find . -type d -name "__pycache__" -exec rm -rf {} +
