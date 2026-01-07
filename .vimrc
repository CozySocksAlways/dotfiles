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

" From https://gist.github.com/maxboisvert/a63e96a67d0a83d71e9f49af73e71d93
" Minimalist-TabComplete-Plugin
inoremap <expr> <Tab> TabComplete()
fun! TabComplete()
    if getline('.')[col('.') - 2] =~ '\K' || pumvisible()
        return "\<C-P>"
    else
        return "\<Tab>"
    endif
endfun

" Minimalist-AutoCompletePop-Plugin
set completeopt=menu,menuone,noinsert
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"
autocmd InsertCharPre * call AutoComplete()
fun! AutoComplete()
    if v:char =~ '\K'
        \ && getline('.')[col('.') - 4] !~ '\K'
        \ && getline('.')[col('.') - 3] =~ '\K'
        \ && getline('.')[col('.') - 2] =~ '\K' " last char
        \ && getline('.')[col('.') - 1] !~ '\K'

        call feedkeys("\<C-P>", 'n')
    end
endfun
