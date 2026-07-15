#!/usr/bin/env bash
# Run the molten-nvim container against a single notebook file.
# Usage: nvim-notebook.sh path/to/notebook.ipynb
set -euo pipefail

if [[ $# -ne 1 ]]; then
	echo "Usage: $(basename "$0") <notebook.ipynb>" >&2
	exit 1
fi

notebook="$(realpath "$1")"
notebook_name="$(basename "$notebook")"
notebook_dir="$(dirname "$notebook")"
jupyter_runtime_dir="${JUPYTER_RUNTIME_DIR:-$HOME/.local/share/jupyter/runtime}"

if [[ ! -f "$notebook" ]]; then
	echo "Notebook not found: $notebook" >&2
	exit 1
fi

# Mount the parent directory rather than the notebook file itself: jupytext
# writes via a tmp-file + atomic rename, which fails with EBUSY against a
# single-file bind mount (the rename target is the mount point itself).
docker run --rm -it \
	--network host \
	-v "$notebook_dir:/work" \
	-v "$jupyter_runtime_dir:/root/.local/share/jupyter/runtime:ro" \
	molten-nvim-env "/work/$notebook_name"
