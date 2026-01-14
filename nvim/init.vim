" Source vimrc
source ~/.vimrc

" Start treesitter for python"
autocmd FileType python lua vim.treesitter.start()
