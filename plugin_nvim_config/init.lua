-- Source vimrc
vim.cmd('source ~/.vimrc')

-- Load lazy.vim plugin manager
require("config.lazy")

vim.cmd.colorscheme("vscode")

vim.api.nvim_create_user_command('Diff', function(opts)
  vim.cmd('DiffviewOpen ' .. (opts.args or ''))
end, { nargs = '?' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'cpp', 'c', 'cuda', 'cmake', 'yaml', 'snakemake', 'dockerfile', 'latex' },
  callback = function()
    vim.treesitter.start()
    -- Treesitter-based folding (zc/zo/za); start with all folds open
    vim.wo[0][0].foldmethod = 'expr'
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldlevel = 99
  end,
})


-- Load commands
require("ruff.commands")
require("doxydoc.commands")
require("cpgen.cpgen")
require("fngrep.fngrep")
require("listcustom.listcustom")

-- black bg
vim.cmd([[
  highlight Normal guibg=#000000
  highlight NormalFloat guibg=#000000
  highlight LineNr guifg=#888888 guibg=#000000
]])

-- nipython
require("nipython.nipython")
