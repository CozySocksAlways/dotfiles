# pydocs

Reference: https://til.codeinthehole.com/posts/about-how-to-use-keywordprg-effectively/

Dedicated venv for `K` (keywordprg) doc lookups in Neovim, separate from
whatever python/venv a project uses. Lets `K` on `numpy.array` etc. show
real docstrings instead of nothing.

## Setup

```
python3 -m venv pydocs/.venv
pydocs/.venv/bin/pip install numpy matplotlib
```

`.venv/` is gitignored — reinstall packages after a fresh clone.

`plugin_nvim_config/after/ftplugin/python.lua` remaps `K` for python
buffers to a function that captures the dotted name under the cursor,
resolves any import alias (e.g. `np` -> `numpy`) against the buffer's
`import`/`from` lines, and calls `<this venv>/bin/python -m pydoc` on
the resolved name.

## Bugs hit during setup

- `vim.fn.expand()` respects `wildignore`, which is set elsewhere in
  this config to `*/venv/*,*/.venv/*,...`. `expand('~/.../.venv/bin/python')`
  silently returned `""`. Fix: don't use `expand()` for paths under
  `.venv` — build the path with `os.getenv('HOME')` string concatenation
  instead. Watch for this in any other config code that expands paths
  into a venv.
- Plain `keywordprg` wasn't enough for e.g. `np.empty_like`: Python's
  default `iskeyword` doesn't include `.`, so `K` only grabbed
  `empty_like`; and even with the full dotted name, `pydoc` needs the
  real module (`numpy`), not a local import alias (`np`). Fixed by
  appending `.` to `iskeyword` and remapping `K` to a small function
  that resolves the alias before calling pydoc, instead of relying on
  `keywordprg` alone.

## Expanding

- More packages: `pydocs/.venv/bin/pip install <pkg>`.
- More filetypes: add sibling files under
  `plugin_nvim_config/after/ftplugin/<filetype>.lua`, each pointing
  `keywordprg` at whatever doc tool/venv makes sense for that language.
