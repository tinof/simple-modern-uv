# AGENTS.md

Guidelines for AI coding agents working in this repository.

## Quick Reference

| Task | Command |
|------|---------|
| Install deps | `uv sync --all-extras` |
| Format/fix code | `make fmt` |
| Run checks (CI) | `make check` |
| Run tests | `uv run pytest` |
| Run single test | `uv run pytest -k "test_name"` |
| Add dependency | `uv add <package>` |
| Add dev dependency | `uv add --dev <package>` |

## Package Manager

**STRICTLY use `uv`** for all Python operations:
- Install: `uv add <package>` or `uv add --dev <package>`
- Run: `uv run python script.py` or `uv run pytest`
- Sync: `uv sync --all-extras`

**NEVER** use `pip`, `pip3`, `python -m pip`, or `pip install` directly.

## Project Structure

```
src/{{ package_module }}/    # Source code
tests/                       # Test files
pyproject.toml              # Dependencies and config (source of truth)
uv.lock                     # Lockfile (commit this)
```

## Code Style

- **Formatter**: ruff (`uv run ruff format`)
- **Linter**: ruff (`uv run ruff check --fix`)
- **Type checker**: basedpyright (`uv run basedpyright`)
- **Line length**: 100 characters
- **Python**: >= 3.12

### Type Annotations

- Use type hints for all function signatures
- Modern syntax: `list[str]` not `List[str]`, `str | None` not `Optional[str]`
- Avoid `# type: ignore` unless absolutely necessary

## Testing

- Framework: pytest
- Write tests FIRST when adding new functionality (TDD)
- Test naming: `test_*` functions in `test_*.py` files
- Run specific test: `uv run pytest -k "test_name"`

## Workflow

1. Before making changes: `uv sync --all-extras`
2. After making changes: `make fmt` (formats and auto-fixes)
3. Before committing: `make check` (validates everything)
4. Run tests: `uv run pytest`

## CI/CD

GitHub Actions runs `make check` and `uv run pytest` on push/PR.
The `check` target is read-only and never modifies files.
