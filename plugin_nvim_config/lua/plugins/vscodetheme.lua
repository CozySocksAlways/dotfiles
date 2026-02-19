return {
	{
		'Mofiqul/vscode.nvim',
		config = function()
			local c = require('vscode.colors').get_colors()
			require("vscode").setup {
				italic_comments = true,
				group_overrides = {
					Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
					-- dict/table keys that have @ must be quoted
					-- ["@keyword.repeat"] = { fg = c.vscBlueGreen, bg = 'NONE' },
					-- Repeat = { fg = c.vscBlueGreen, bg = 'NONE' }
				}
			}
		end
	}
}
