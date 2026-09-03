-- K looks up docs via pydoc from a dedicated venv that has numpy,
-- matplotlib, etc. installed, instead of the system python. Plain
-- keywordprg isn't enough for `np.empty_like`: (1) '.' isn't in
-- iskeyword by default so K only grabs "empty_like", and (2) pydoc
-- needs the real module name, not a local import alias like "np".
-- So we capture the full dotted expression and resolve the alias
-- against this buffer's import lines before calling pydoc.
local PYDOC = os.getenv('HOME') .. '/repos/dotfiles/pydocs/.venv/bin/python -m pydoc'

vim.opt_local.iskeyword:append('.')

local function resolve_alias(name)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    local mod = line:match('^%s*import%s+([%w_.]+)%s+as%s+' .. name .. '%s*$')
    if mod then return mod end
    local frommod = line:match('^%s*from%s+([%w_.]+)%s+import%s+' .. name .. '%s*$')
    if frommod then return frommod .. '.' .. name end
  end
  return name
end

-- Run pydoc into a scratch buffer rather than `:!`: Neovim's `:!` shells
-- out without a real tty, so pydoc's pager falls back to plain_pager and
-- output only gets Neovim's own "-- More --" prompt (space/enter to page,
-- no `/` search). A normal buffer gives real search, yanking, etc.
local function pydoc_lookup()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end
  local parts = vim.split(word, '.', { plain = true })
  parts[1] = resolve_alias(parts[1])
  local target = table.concat(parts, '.')
  local output = vim.fn.system(PYDOC .. ' ' .. target)

  vim.cmd('new')
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'python'
  vim.api.nvim_buf_set_name(buf, 'pydoc://' .. target)
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
end

vim.keymap.set('n', 'K', pydoc_lookup, { buffer = true, desc = 'pydoc lookup (venv, alias-aware)' })
