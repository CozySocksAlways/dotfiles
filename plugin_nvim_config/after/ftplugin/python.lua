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

local function pydoc_lookup()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end
  local parts = vim.split(word, '.', { plain = true })
  parts[1] = resolve_alias(parts[1])
  vim.cmd('!' .. PYDOC .. ' ' .. table.concat(parts, '.'))
end

vim.keymap.set('n', 'K', pydoc_lookup, { buffer = true, desc = 'pydoc lookup (venv, alias-aware)' })
