local M = {}

-- Find the ```python ... ``` fence enclosing the cursor in bufnr.
-- Returns 0-indexed start_line, end_line (exclusive) for nvim_buf_get/set_lines
-- covering just the code inside the fence, or nil if the cursor isn't inside one.
function M.find_python_fence(bufnr)
	local cursor_line = vim.fn.line(".")
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	local fence_start
	for i = cursor_line, 1, -1 do
		local line = lines[i]
		if line and line:match("^%s*```") then
			if line:match("^%s*```%s*python%s*$") then
				fence_start = i
			end
			break
		end
	end
	if not fence_start then
		return nil
	end

	local fence_end
	for i = fence_start + 1, #lines do
		if lines[i]:match("^%s*```%s*$") then
			fence_end = i
			break
		end
	end
	if not fence_end or fence_end <= fence_start + 1 then
		return nil
	end

	return fence_start, fence_end - 1
end


function M.get_min_indent(lines)
	local min_indent = nil

	-- loop lines and grab min indent
	 for _, line in ipairs(lines) do
		-- match first non white; get length of preceding whitespace
		if line:match("%S") then
			local indent = line:match("^%s*")
			local width = #indent
			if not min_indent or width < min_indent then
				min_indent = width
			end
		end
	end

	return min_indent or 0
end

function M.deindent_lines(lines, indent)
	if indent == 0 then
		return lines
	end

	local new = {}
	for i, line in ipairs(lines) do
		if line:match("%S") then
			-- : is for passing object itself as first arg
			-- substring it from indent + 1
			new[i] = line:sub(indent + 1)
		else
			new[i] = line
		end
	end
	return new		
end

-- append an indent_str to lines
function M.reindent_lines(lines, indent_str)
	if indent_str == "" then
		return lines
	end

	local new = {}
	for i, line in ipairs(lines) do
		if line ~= "" then
			new[i] = indent_str .. line
		else
			new[i] = line
		end
	end
	return new
end


return M
