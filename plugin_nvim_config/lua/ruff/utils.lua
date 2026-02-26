local M = {}


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
