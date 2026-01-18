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
		 lazy = false,
		 build = ':TSUpdate',
  }
}
