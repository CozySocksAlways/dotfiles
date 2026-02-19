return 
{
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = {"nvim-treesitter/nvim-treesitter"},
  config = function()
    require("treesitter-context").setup{
		enable = true, -- can use TSContext command with enable, disable and toggle to switch
		max_lines = 10, -- How many lines the context window should span
		trim_scope = 'inner', -- Which context to cut when max lines exceeded
		separator = '-',
	}

	-- Set context bg to transparent
	vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "none"})
  end
}
