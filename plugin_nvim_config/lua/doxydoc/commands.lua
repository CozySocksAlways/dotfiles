-- Deterministic doxygen stub generator/updater (libclang-backed, see doxydoc.py).
-- Undoable: edits buffer lines directly, no save/reload round-trip.

local function doxydocify(lines, filepath, cursor_line)
	if vim.fn.executable("python3") ~= 1 then
		vim.notify("python3 not found in PATH", vim.log.levels.ERROR)
		return nil
	end

	local script = debug.getinfo(1, "S").source:match("@(.*/)") .. "doxydoc.py"
	local cmd = { "python3", script, filepath }
	if cursor_line then
		table.insert(cmd, tostring(cursor_line))
	end

	local text = table.concat(lines, "\n")
	local result = vim.fn.system(cmd, text)

	if vim.v.shell_error ~= 0 then
		vim.notify("doxydoc failed: " .. result, vim.log.levels.ERROR)
		return nil
	end

	local new_lines = vim.split(result, "\n", { plain = true })
	if #new_lines > 0 and new_lines[#new_lines] == "" then
		table.remove(new_lines)
	end
	return new_lines
end

local function run_doxydoc(cursor_line)
	local ft = vim.bo.filetype
	if ft ~= "c" and ft ~= "cpp" then
		vim.notify("doxydoc: not a c/cpp buffer", vim.log.levels.WARN)
		return
	end

	local filepath = vim.api.nvim_buf_get_name(0)
	if filepath == "" then
		vim.notify("doxydoc: buffer has no file name", vim.log.levels.WARN)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local new_lines = doxydocify(lines, filepath, cursor_line)
	if not new_lines then
		return
	end

	if vim.deep_equal(lines, new_lines) then
		vim.notify("doxydoc: nothing to add", vim.log.levels.INFO)
		return
	end

	local view = vim.fn.winsaveview()
	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
	vim.fn.winrestview(view)
end

-- <leader>dx: only the function/method the cursor is currently inside
function doxydoc_current_function()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	run_doxydoc(cursor_line)
end

-- :GenCppDocs: every function/method in the buffer
function doxydoc_buffer()
	run_doxydoc(nil)
end

vim.keymap.set("n", "<leader>dx", doxydoc_current_function, { desc = "Doxygen: stub comment for function under cursor" })
vim.api.nvim_create_user_command("GenCppDocs", doxydoc_buffer, {})
