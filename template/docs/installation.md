## Installing uv and Python

This project is set up to use [**uv**](https://docs.astral.sh/uv/), the new package
manager for Python. `uv` replaces traditional use of `pyenv`, `pipx`, `poetry`, `pip`,
etc. This is a quick cheat sheet on that:

On macOS or Linux, if you don't have `uv` installed, a quick way to install it:

```shell
curl -LsSf https://astral.sh/uv/install.sh | sh
```

For macOS, you prefer [brew](https://brew.sh/) you can install or upgrade uv with:

```shell
brew update
brew install uv
```

See [uv's docs](https://docs.astral.sh/uv/getting-started/installation/) for more
installation methods and platforms.

Now you can use uv to install a current Python environment:

```shell
uv python install 3.13 # Or pick another version.
```

## Global Tools

Since you have `uv` installed, you do not need `pipx` or `brew` for Python CLI tools.
Install global tools directly with `uv tool`:

```shell
uv tool install ruff
uv tool install cookiecutter
uv tool install httpie
```

These are installed globally and available from any directory.
To upgrade a tool: `uv tool upgrade <tool-name>`
To list installed tools: `uv tool list`
