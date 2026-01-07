set number
syntax on
inoremap jk <Esc> 
nnoremap <C-y> 3<C-y>
nnoremap <C-e> 3<C-e>

" Indentation
set tabstop=4
set shiftwidth=4
set softtabstop=0
set noexpandtab
set autoindent
set smartindent
set cindent
filetype plugin indent on

" Bracket autocompletion
inoremap { {}<Esc>ha
inoremap ( ()<Esc>ha
inoremap [ []<Esc>ha
inoremap " ""<Esc>ha
inoremap ' ''<Esc>ha
inoremap ` ``<Esc>ha
