# Makefile for easy development workflows.
# See docs/development.md for docs.
# Note GitHub Actions call uv directly, not this Makefile.

.DEFAULT_GOAL := default

.PHONY: default install fmt check test upgrade build clean

default: install check test

install:
	uv sync --all-extras

# Format and auto-fix (mutates files - use locally)
fmt:
	uv run ruff check --fix
	uv run ruff format

# Check only (CI-safe, never mutates)
check:
	uv run ruff check
	uv run ruff format --check
	uv run basedpyright

test:
	uv run pytest

upgrade:
	uv sync --upgrade --all-extras --dev

build:
	uv build

clean:
	-rm -rf dist/
	-rm -rf *.egg-info/
	-rm -rf .pytest_cache/
	-rm -rf .ruff_cache/
	-rm -rf .venv/
	-find . -type d -name "__pycache__" -exec rm -rf {} +