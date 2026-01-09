set number
syntax on
nnoremap <C-y> 3<C-y>
nnoremap <C-e> 3<C-e>
set hlsearch

" Escape to normal mode and toggle hl search"
nnoremap gh :nohl<CR> 
inoremap jk <Esc>:noh<CR>

" Move one char right in insert mode" 
imap jh <right> 

" Indentation
set tabstop=4
set shiftwidth=4
set softtabstop=0
set noexpandtab
set autoindent
set smartindent
set cindent
filetype plugin indent on

" Color Scheme"
colorscheme slate

" Show matching bracket"
set showmatch

" Indent and unindent lines by tab width in visual mode"
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

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
set completeopt=menu,menuone,noinsert,noselect
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

" Source: ChatGP'ed to suit requirement from this reddit post https://www.reddit.com/r/vim/comments/i02w3v/code_commenting_without_plugins/
" Toggle comment function
function! ToggleComment(comment_char, startLine, endLine)
    for lnum in range(a:startLine, a:endLine)
        let line = getline(lnum)
        " Regex: optional leading whitespace, then the comment char
        if line =~ '^\s*' . a:comment_char
            " Remove comment char (with optional space after it)
            let line = substitute(line, '^\(\s*\)' . a:comment_char . '\s\?', '\1', '')
        else
            " Add comment char after leading whitespace
            let line = substitute(line, '^\(\s*\)', '\1' . a:comment_char . ' ', '')
        endif
        call setline(lnum, line)
    endfor
endfunction

" Normal mode mappings (single line)
autocmd FileType vim nnoremap <buffer> gc :call ToggleComment('"', line("."), line("."))<CR>
autocmd FileType python,sh,zsh,bash nnoremap <buffer> gc :call ToggleComment("#", line("."), line("."))<CR>
autocmd FileType c,cpp nnoremap <buffer> gc :call ToggleComment("//", line("."), line("."))<CR>
autocmd FileType php,markdown nnoremap <buffer> gc :call ToggleComment("#", line("."), line("."))<CR>

" Visual mode mappings (multi-line)
autocmd FileType vim vnoremap <buffer> gc :<C-U>call ToggleComment('"', line("'<"), line("'>"))<CR>
autocmd FileType python,sh,zsh,bash vnoremap <buffer> gc :<C-U>call ToggleComment("#", line("'<"), line("'>"))<CR>
autocmd FileType c,cpp vnoremap <buffer> gc :<C-U>call ToggleComment("//", line("'<"), line("'>"))<CR>
autocmd FileType php,markdown vnoremap <buffer> gc :<C-U>call ToggleComment("#", line("'<"), line("'>"))<CR>
