-- Feeds the last visual selection to the external `cpgen` script (~/.local/bin).
-- Usage: select, <Esc>, move to where the reply should go, then
--   :r !cpgen "make this print the culturally accepted response"
-- `:r !` gives the script no stdin, so the selection is dumped to a per-instance
-- temp file right before any `cpgen` shell command runs; path/filetype go via env.

local sel_file = vim.fn.tempname()
vim.env.CPGEN_SEL = sel_file

local function dump_selection()
	local mode = vim.fn.visualmode()
	if mode == "" then
		vim.fn.writefile({}, sel_file)
		return
	end
	local lines = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = mode })
	vim.fn.writefile(lines, sel_file)
	vim.env.CPGEN_FT = vim.bo.filetype
end

vim.api.nvim_create_autocmd("CmdlineLeave", {
	pattern = ":",
	callback = function()
		if vim.v.event.abort then
			return
		end
		if vim.fn.getcmdline():match("!%s*cpgen") then
			dump_selection()
		end
	end,
})
