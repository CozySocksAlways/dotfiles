-- Source vimrc
vim.cmd('source ~/.vimrc')

-- Load lazy.vim plugin manager
require("config.lazy")

vim.cmd.colorscheme("vscode")

vim.api.nvim_create_user_command('Diff', function(opts)
  vim.cmd('DiffviewOpen ' .. (opts.args or ''))
end, { nargs = '?' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python' },
  callback = function() vim.treesitter.start() end,
})


-- Load commands
require("ruff.commands")

-- black bg
vim.cmd([[
  highlight Normal guibg=#000000
  highlight NormalFloat guibg=#000000
  highlight LineNr guifg=#888888 guibg=#000000
]])
