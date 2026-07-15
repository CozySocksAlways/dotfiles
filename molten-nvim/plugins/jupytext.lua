-- jupytext.nvim: transparently converts .ipynb <-> a plain-text buffer on
-- read/write, so Neovim edits real text (not raw JSON) and molten can
-- attach output chunks to it. Not a molten-nvim dependency itself, but molten
-- has no notebook-JSON parser of its own -- it only attaches kernels to text
-- buffers, so this is the standard companion for editing .ipynb directly.
-- Requires the `jupytext` CLI (installed via pip in the Dockerfile) on $PATH.
return {
	{
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		opts = {
			style = "markdown",
			output_extension = "md",
			force_ft = "markdown",
		},
	},
}
