#!/usr/bin/env bash
# Claude Code SessionStart hook: in cloud sessions (Claude Code on the web), make sure
# the pinned uv and all project dependencies are installed, so `make check` and
# `make test` work immediately. Local sessions are left alone.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Keep in sync with the uv version in .github/workflows/ci.yml and uv.toml.
UV_VERSION="0.13.1"

cd "${CLAUDE_PROJECT_DIR:-.}"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# True if uv is installed and on the same minor line as UV_VERSION (uv.toml's
# required-version rejects other lines).
uv_ok() {
  command -v uv >/dev/null 2>&1 || return 1
  local installed
  installed="$(uv --version | awk '{print $2}')"
  [ "${installed%.*}" = "${UV_VERSION%.*}" ] && [ "$(printf '%s\n%s\n' "$UV_VERSION" "$installed" | sort -V | head -1)" = "$UV_VERSION" ]
}

if ! uv_ok; then
  echo "Installing uv $UV_VERSION..."
  if command -v uv >/dev/null 2>&1 && uv self update "$UV_VERSION" >/dev/null 2>&1; then
    :
  else
    curl -LsSf "https://astral.sh/uv/$UV_VERSION/install.sh" | sh
  fi
fi

# Persist PATH for the rest of the session's commands.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >>"$CLAUDE_ENV_FILE"
fi

# Dynamic versioning needs a git repo; a fresh session always has one, but be safe.
if git rev-parse --git-dir >/dev/null 2>&1; then
  make install
else
  echo "Not a git repository yet; skipping make install."
fi
