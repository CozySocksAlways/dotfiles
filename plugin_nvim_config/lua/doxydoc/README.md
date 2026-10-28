# doxydoc

Deterministic Doxygen stub generator/updater for C/C++. No LLM, no descriptions — just blank `@brief`/`@param`/`@tparam`/`@return` stubs.

## Usage

Open a `.c`/`.cpp`/`.h`/`.hpp` buffer.

- `<leader>dx` — document only the function/method the cursor is currently inside.
- `:GenCppDocs` — document every function/method in the buffer.

- Function/method has no doc comment directly above it -> inserts a full blank stub block.
- Function/method already has a doc comment -> only *appends* missing `@param`/`@tparam`/`@return` lines just before the closing `*/`. Existing lines are never rewritten, reordered, or deleted — including stale `@param` entries for parameters that were since removed from the signature. Fix those by hand.
- Classes/structs themselves are not documented, only functions/methods/ctors/dtors.

Edits are applied to the buffer in place (undoable with `u`), no save required.

## How it's wired up

- `doxydoc.py` — parses the buffer's C/C++ AST via `libclang` (reads source from stdin via `unsaved_files`, writes updated source to stdout). Takes an optional 3rd arg, the 1-indexed cursor line; when given, only the innermost enclosing function/method is processed, otherwise the whole file is. All comment-block detection/insertion is plain text-line manipulation around the AST's declaration locations.
- `commands.lua` — pipes the current buffer through `doxydoc.py` and swaps in the result via `nvim_buf_set_lines`, same pattern as `../ruff/commands.lua`. `doxydoc_current_function()` passes the cursor line (bound to `<leader>dx`); `doxydoc_buffer()` doesn't (bound to `:GenCppDocs`).
- `<leader>dx` keymap, `:GenCppDocs` command, and `require("doxydoc.commands")` registered in `../../init.lua`.

Compile flags for parsing: looks for `compile_commands.json` or `compile_flags.txt` walking up from the file's directory; falls back to `-std=c++17` (or `-std=c11` for `.c`) if neither exists.

## Deps

- `python3` with the `clang.cindex` bindings (`import clang.cindex`) — comes from the system `clang` package on Arch (`pacman -Q clang`), not pip. On another machine, install your distro's `clang`/`clang-python` package, or `pip install libclang` as a fallback.
