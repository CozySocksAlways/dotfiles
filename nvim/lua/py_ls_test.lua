-- module definition
local M = {}

function M.list_tests_quickfix()
	-- get full file path; % is current buffer; :p gives absolute path
	local file_path = vim.fn.expand("%:p")

	-- grep test kind of functions; -n for line no, -E for extended regular exps
	local output = vim.fn.systemlist("grep -nE ^def test_' " .. filepath)
	
	if vim.tbl_isempty(output) then
		print("Could'nt find test funcs")
		return
	end
