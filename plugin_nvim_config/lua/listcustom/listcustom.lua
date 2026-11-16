local M = {}

-- Doc string; also shown by running :ListCustom ?
M.help = [[
ListCustom - list the commands, keymaps and functions defined in my config

Usage:
  :ListCustom          list everything
  :ListCustom pat      only rows containing pat (e.g. cmd, map, fn, leader, ruff)
  :ListCustom ?        show this help

In the list:  <CR> jump to definition,  q close

Scans ~/.vimrc and every lua file under stdpath("config") (not plugins
installed by lazy). Description = nearest comment above the definition in the
same paragraph, or the keymap's `desc`.
Source: lua/listcustom/listcustom.lua]]

-- Vimscript map tokens that come before the lhs
local map_flags = { ["<silent>"] = true, ["<expr>"] = true, ["<buffer>"] = true,
	["<nowait>"] = true, ["<unique>"] = true, ["<script>"] = true }

-- Nearest comment above lnum, stopping at a blank line
local function comment_above(lines, lnum, is_lua)
	for i = lnum - 1, 1, -1 do
		local l = vim.trim(lines[i])
		if l == "" then return "" end
		local c = is_lua and l:match("^%-%-+%s*(.*)") or l:match('^"%s*(.-)"?$')
		if c then return c end
	end
	return ""
end

-- Parse one line into an entry {kind, mode, name, desc} or nil
local function parse_vim(line)
	local name = line:match("^%s*com?m?a?n?d?!?%s+(.*)")
	if name and line:match("^%s*com") then
		-- skip -nargs=... style attributes
		for tok in name:gmatch("%S+") do
			if not tok:match("^%-") then return { kind = "cmd", mode = "", name = tok } end
		end
	end
	local fn = line:match("^%s*fu?n?c?t?i?o?n?!?%s+([%w_:#.]+)%s*%(")
	if fn then return { kind = "fn", mode = "", name = fn .. "()" } end
	local mode, rest = line:match("^%s*([nvxoicslt]?)n?o?r?e?map!?%s+(.*)")
	if rest and line:match("map") then
		local toks = vim.split(rest, "%s+", { trimempty = true })
		local i = 1
		while toks[i] and map_flags[toks[i]:lower()] do i = i + 1 end
		if toks[i] then
			local rhs = table.concat(toks, " ", i + 1)
			return { kind = "map", mode = mode ~= "" and mode or "nvo", name = toks[i], rhs = rhs }
		end
	end
end

local function parse_lua(line)
	local cmd = line:match("nvim_create_user_command%(%s*[\"']([^\"']+)")
	if cmd then return { kind = "cmd", mode = "", name = cmd } end
	local modes, lhs = line:match("keymap%.set%(%s*(%b{})%s*,%s*[\"']([^\"']+)")
	if not modes then modes, lhs = line:match("keymap%.set%(%s*[\"']([^\"']*)[\"']%s*,%s*[\"']([^\"']+)") end
	if lhs then
		return { kind = "map", mode = modes:gsub("[{}\"',%s]", ""), name = lhs,
			desc = line:match("desc%s*=%s*[\"']([^\"']+)") }
	end
end

-- Collect entries from all config files
function M.collect()
	local cfg = vim.fn.stdpath("config")
	local files = { vim.fn.resolve(vim.fn.expand("~/.vimrc")) }
	vim.list_extend(files, vim.fn.globpath(cfg, "**/*.lua", false, true))
	vim.list_extend(files, { cfg .. "/init.lua" })

	local entries, seen = {}, {}
	for _, f in ipairs(files) do
		f = vim.fn.resolve(f)
		if not seen[f] and vim.fn.filereadable(f) == 1 then
			seen[f] = true
			local is_lua = f:match("%.lua$") ~= nil
			local lines = vim.fn.readfile(f)
			for lnum, line in ipairs(lines) do
				-- skip commented-out definitions
				if not line:match(is_lua and "^%s*%-%-" or '^%s*"') then
					local e = (is_lua and parse_lua or parse_vim)(line)
					-- this file's own buffer-local q/<CR> maps are noise
					if e and e.kind == "map" and line:match("buffer = buf") then e = nil end
					if e then
						e.file, e.lnum = f, lnum
						local c = comment_above(lines, lnum, is_lua)
						e.desc = e.desc or (c ~= "" and c) or e.rhs or ""
						table.insert(entries, e)
					end
				end
			end
		end
	end

	local order = { cmd = 1, map = 2, fn = 3 }
	table.sort(entries, function(a, b)
		if a.kind ~= b.kind then return order[a.kind] < order[b.kind] end
		return a.name:lower() < b.name:lower()
	end)
	return entries
end

function M.list(opts)
	if opts.args == "?" then
		vim.notify(M.help)
		return
	end

	local home = vim.fn.expand("~")
	local rows, targets = {}, {}
	for _, e in ipairs(M.collect()) do
		local loc = e.file:gsub("^" .. vim.pesc(home), "~") .. ":" .. e.lnum
		local row = string.format("%-4s %-4s %-18s %-55s %s", e.kind, e.mode, e.name, e.desc, loc)
		if opts.args == "" or row:lower():find(opts.args:lower(), 1, true) then
			table.insert(rows, row)
			table.insert(targets, e)
		end
	end

	vim.cmd("botright new")
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, rows)
	vim.bo[buf].modifiable = false
	vim.wo.wrap = false
	vim.wo.cursorline = true
	vim.api.nvim_buf_set_name(buf, "ListCustom " .. opts.args)
	vim.api.nvim_win_set_height(0, math.min(#rows, 25))

	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf })
	vim.keymap.set("n", "<CR>", function()
		local e = targets[vim.fn.line(".")]
		if not e then return end
		vim.cmd("close")
		vim.cmd("edit " .. vim.fn.fnameescape(e.file))
		vim.api.nvim_win_set_cursor(0, { e.lnum, 0 })
	end, { buffer = buf })
end

vim.api.nvim_create_user_command("ListCustom", M.list, { nargs = "?" })

return M
