-- Treesitter
-- On machine without root access, might have to
-- add 'config' spec to this return with the setup call
-- to change install tree cause default goes to
-- /opt/nvim-linux-x86_64/lib/nvim/parser/c.so if nvim installed
-- with root, it went to the binary folder like here
-- /users/jos/nvim_bin/lib/nvim/parser/c.so
return {
	{
		'nvim-treesitter/nvim-treesitter',
		 branch = 'main',
		 lazy = false,
		 build = ':TSUpdate',
		 config = function()
			 -- This is the rewritten "main"-branch nvim-treesitter API:
			 -- setup() only takes install_dir; there is no ensure_installed
			 -- or highlight.enable anymore (those keys are silently
			 -- ignored). Parsers must be installed explicitly, and
			 -- highlighting is started per-buffer via vim.treesitter.start()
			 -- (see the FileType autocmd in init.lua).
			 require("nvim-treesitter").setup()
			 require("nvim-treesitter").install({ "python", "cpp", "markdown", "markdown_inline" })
		end
  }
}
