local utils = require("ruff.utils")

-- Make table with ruff check
function parse_ruff_check()
	-- get file name
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		print("no file")
		return
	end

	-- run ruff check
	local cmd = string.format("ruff check --output-format=json %s",
				vim.fn.shellescape(filepath))
	local output = vim.fn.systemlist(cmd)
	local decoded = vim.fn.json_decode(table.concat(output, "\n"))

	-- make a quickfix list
	local bufnr = vim.api.nvim_get_current_buf()
	local qfs = {}
	for _, item in ipairs(decoded) do
		-- -- get the help message
		-- local help = ""
		-- if item.fix and item.fix.message then
		-- 	help = "\n-> " .. item.fix.message
		-- end

		table.insert(qfs, {
		bufnr = bufnr,
		lnum = item.location.row,
		col = item.location.column,
		-- text = string.format("[%s] %s%s", item.code, item.message, help),
		text = string.format("[%s] %s", item.code, item.message),
		type = "E",
		})
	end
	vim.fn.setqflist(qfs, 'r')
	vim.cmd("copen")
end

-- Run ruff formating on current buffer with confirm
-- ToDo: Make it undoable by passing file through stdin and making nvim edit buffer
function ruff_format_buffer()
	-- Check if python
	if vim.bo.filetype ~= "python" then
		return
	end

	-- Ask for confirm; Maybe remove later
	-- The letter after the '&' is the shortcut key; 2 is No (0 for keyinterupt)
	local choice = vim.fn.confirm(
	"Format with ruff?(will save here before formating)",
	"&Yes\n&No", 2
	)

	if choice ~= 1 then
		return
	end

	-- Save file
	vim.cmd("write")
	
	-- Get buffer name. 0 for current buffer
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Buffer has no file name", vim.log.levels.WARN)
		return
	end
	
	-- Run ruff; ToDo fn.system is blocking, i.e sync; try for async api
	local result = vim.fn.system({"ruff", "format", file})
	if vim.v.shell_error ~= 0 then
		vim.notify("Ruff format failed" .. result, vim.log.levels.ERROR)
		return
	end

	-- Reload buffer after format
	vim.cmd("checktime")
	vim.notify("Ruff formatting complete", vim.log.levels.INFO)
end

local function ruffify(lines)
	if vim.fn.executable("ruff") ~= 1 then
        vim.notify("ruff not found in PATH", vim.log.levels.ERROR)
        return nil
    end

	local text = table.concat(lines, "\n")
	local formatted = vim.fn.system({"ruff", "format", "-"}, text)

	if vim.v.shell_error ~= 0 then
		vim.notify("Ruff format failed" .. formatted, vim.log.levels.ERROR)
		return
	end

	local new_lines = vim.split(formatted, "\n", {plain = true})

	-- remove empty lines
	if #new_lines > 0 and new_lines[#new_lines] == "" then
		table.remove(new_lines)
	end

	return new_lines
end

function ruff_format_buffer_undoable(mode)
	-- Check if python
	if vim.bo.filetype ~= "python" then
		return
	end

	local start_line, end_line
	if mode == "visual" then
		print("visualruff")
		start_line = vim.fn.line("'<") - 1
		end_line = vim.fn.line("'>")
	else
		start_line = 0
		end_line = -1
	end

	-- Get buffer name. 0 for current buffer
	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
	
	-- If visual deindent
	local base_indent = ""
	if mode == "visual" then
		local min_indent = utils.get_min_indent(lines)
		base_indent = string.rep(" ", min_indent)
		lines = utils.deindent_lines(lines, min_indent)
	end

	local new_lines = ruffify(lines)
	if not new_lines then
		return
	end

	--Reindent
	if mode == "visual" then
		new_lines = utils.reindent_lines(new_lines, base_indent)
	end

	-- skip if no changes
	if vim.deep_equal(lines, new_lines) then
		return
	end

	-- I guess this is to save the wndow view; then set lines
	local view = vim.fn.winsaveview()
	vim.api.nvim_buf_set_lines(0, start_line, end_line, false, new_lines)
	vim.fn.winrestview(view)

end

-- ToDo
-- Open nvim.diffview with a tmp file where mods are made
function ruff_diff()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		print("no file")
		return
	end
end

-- Map commands to functions
vim.api.nvim_create_user_command("RuffDiff", ruff_diff, {})
vim.api.nvim_create_user_command("RuffCheck", parse_ruff_check, {})
vim.keymap.set("n", "<leader>rv", function() ruff_format_buffer_undoable("visual") end)
vim.keymap.set("n", "<leader>rf", function() ruff_format_buffer_undoable() end)
