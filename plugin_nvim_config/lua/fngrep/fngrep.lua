local M = {}

-- Doc string; also shown by running :FnGrep with no args
M.help = [[
FnGrep - vimgrep that lists the functions containing a match

Usage (same syntax as :vimgrep):
  :FnGrep /pat/[g] files   e.g. :FnGrep /\cself/ **/*.py
  :FnGrep pat [files]      pattern without delimiters is a single word
  :FnGrep /pat/            no files given -> current buffer
  :FnGrep                  show this help

Pattern is a vim regex. Result goes to the quickfix list:
  - one entry per function (deduped), shown as "file | Class.method"
  - jumping to an entry lands on the first matching line in that function
  - matches outside functions show as "ClassName" or "<module>"
  - decorator lines count as part of the decorated function
  - unsupported languages fall back to plain vimgrep entries

Languages: python (via treesitter). Add more in the `langs` table.
Source: lua/fngrep/fngrep.lua]]

-- Per-language treesitter knowledge; add c/cpp entries here later
-- func: node types that count as a function (dedup unit)
-- scope: node types that only qualify the name (Class.method)
-- name: get the name text of a func/scope node
local langs = {
	python = {
		func = { function_definition = true },
		scope = { class_definition = true },
		name = function(node, bufnr)
			local n = node:field("name")[1]
			return n and vim.treesitter.get_node_text(n, bufnr) or "?"
		end,
	},
}

-- Split vimgrep style args "/pat/flags files" or "pat files" into a vimgrep cmd
local function build_vimgrep(args)
	local pat, flags, files
	local delim = args:sub(1, 1)
	if delim:match("[^%w%s\"|]") then
		-- find closing delimiter that is not backslash escaped
		local i = 2
		while i <= #args do
			local c = args:sub(i, i)
			if c == "\\" then
				i = i + 1
			elseif c == delim then
				break
			end
			i = i + 1
		end
		pat = args:sub(2, i - 1)
		flags, files = args:sub(i + 1):match("^([gjf]*)%s*(.*)$")
		pat = delim .. pat .. delim
	else
		local word, rest = args:match("^(%S+)%s*(.*)$")
		pat, flags, files = "/" .. word:gsub("/", "\\/") .. "/", "", rest
	end
	-- no files given: search current buffer
	if files == "" then
		files = "%"
	end
	-- j so vimgrep doesn't jump, we open the list ourselves
	return string.format("vimgrep %s%sj %s", pat, flags:gsub("j", ""), files)
end

-- Get treesitter root of a buffer; vimgrep skips FileType, so detect lang here
local function get_root(bufnr)
	vim.fn.bufload(bufnr)
	local ft = vim.filetype.match({ buf = bufnr }) or vim.bo[bufnr].filetype
	local lang = ft and vim.treesitter.language.get_lang(ft)
	if not lang or not langs[lang] then
		return nil
	end
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
	if not ok or not parser then
		return nil
	end
	return parser:parse()[1]:root(), langs[lang]
end

-- Walk up from the match: returns the dedup node and qualified name
local function enclosing(root, spec, bufnr, row, col)
	local node = root:named_descendant_for_range(row, col, row, col)
	local key_node, names, prev = nil, {}, nil
	while node do
		local cur = node
		-- decorators sit outside the function node; if we came up from the
		-- decorator side, count the match as inside the decorated def
		if cur:type() == "decorated_definition" then
			local def = cur:field("definition")[1]
			if def and not (prev and prev:equal(def)) then
				cur = def
			end
		end
		local t = cur:type()
		if spec.func[t] or spec.scope[t] then
			table.insert(names, 1, spec.name(cur, bufnr))
			key_node = key_node or cur
		end
		prev = node
		node = node:parent()
	end
	if not key_node then
		return root, "<module>"
	end
	return key_node, table.concat(names, ".")
end

-- Quickfix window display: "file | Class.method", files padded to align
function M.qftext(info)
	local items = vim.fn.getqflist({ id = info.id, items = 1 }).items
	local fnames, width = {}, 0
	for i = info.start_idx, info.end_idx do
		local f = vim.fn.fnamemodify(vim.fn.bufname(items[i].bufnr), ":~:.")
		fnames[i] = f
		width = math.max(width, vim.fn.strdisplaywidth(f))
	end
	local lines = {}
	for i = info.start_idx, info.end_idx do
		local pad = string.rep(" ", width - vim.fn.strdisplaywidth(fnames[i]))
		table.insert(lines, fnames[i] .. pad .. " | " .. items[i].text)
	end
	return lines
end

function M.fngrep(opts)
	if opts.args == "" then
		print(M.help)
		return
	end
	local cmd = build_vimgrep(opts.args)
	local ok, err = pcall(vim.cmd, "silent " .. cmd)
	if not ok then
		vim.notify(err:gsub("^.-:E", "E"), vim.log.levels.WARN)
		return
	end

	-- vimgrep returns matches in file then line order, so the first hit per
	-- function is its first matching line
	local seen, qfs = {}, {}
	for _, item in ipairs(vim.fn.getqflist()) do
		local root, spec = get_root(item.bufnr)
		if root then
			local node, name = enclosing(root, spec, item.bufnr, item.lnum - 1, item.col - 1)
			local srow, scol = node:range()
			local key = string.format("%d:%d:%d", item.bufnr, srow, scol)
			if not seen[key] then
				seen[key] = true
				item.text = name
				table.insert(qfs, item)
			end
		else
			-- unsupported language: keep the plain vimgrep entry
			table.insert(qfs, item)
		end
	end

	-- replace vimgrep's list so only one new list lands in the qf history
	vim.fn.setqflist({}, "r", {
		items = qfs,
		title = "FnGrep " .. opts.args,
		quickfixtextfunc = M.qftext,
	})
	vim.cmd("copen")
end

vim.api.nvim_create_user_command("FnGrep", M.fngrep, { nargs = "*", complete = "file" })

return M
