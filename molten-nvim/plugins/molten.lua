-- molten-nvim: Jupyter kernel client for Neovim.
-- Lives outside plugin_nvim_config/lua/plugins/ on purpose so the host
-- Neovim never loads it; only COPY'd into the container image at build time.
return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = true
			vim.g.molten_wrap_output = true
		end,
		config = function()
			vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>", { silent = true, desc = "Initialize molten" })
			vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { silent = true, desc = "Evaluate operator" })
			vim.keymap.set("n", "<localleader>rl", ":MoltenEvaluateLine<CR>", { silent = true, desc = "Evaluate line" })
			vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { silent = true, desc = "Re-evaluate cell" })
			vim.keymap.set("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { silent = true, desc = "Evaluate visual selection" })
			vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<CR>", { silent = true, desc = "Hide output" })
			vim.keymap.set("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { silent = true, desc = "Show/enter output" })
		end,
	},
}
