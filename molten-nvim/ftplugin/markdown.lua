-- jupytext.nvim renders .ipynb as markdown (see jupytext.lua), but
-- plugin_nvim_config/init.lua only auto-starts treesitter for a fixed list
-- of filetypes that doesn't include markdown. Rather than changing that
-- list (which would affect the host's regular markdown editing too), this
-- container-only ftplugin activates treesitter -- with injections -- just
-- for buffers opened here, so python/etc. code fences get real highlighting.
vim.treesitter.start()
