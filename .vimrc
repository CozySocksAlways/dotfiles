set relativenumber
set number " Show current line number instead of 0"
syntax on
nnoremap <C-y> 3<C-y>
nnoremap <C-e> 3<C-e>
set hlsearch

" Map space to leader in normal mode"
nnoremap <Space> <Nop>
let mapleader = " "

" Add cursor line highlight"
set cursorline

" open current split in own tab (like zoom in tmux) and keep cursor pos
nnoremap <LEADER>z mx:tabedit %<CR>g`x

" Tab and pane open and close with leader"
nnoremap <LEADER>t :tabnew<CR>
nnoremap <LEADER>x :tabclose<CR>
nnoremap <LEADER>v :vsplit<CR>
nnoremap <LEADER>q :quit<CR>

" Copen leader alias"
nnoremap <LEADER>n :cnext<CR>
nnoremap <LEADER>p :cprevious<CR>

" Run git blame on current line"
command! Bline execute '!git blame -L ' . line('.') . ',' . line('.') . ' %'

" Escape to normal mode and toggle hl search"
nnoremap gh :nohl<CR> 
" inoremap jk <Esc>:noh<CR>

" Move one char right in insert mode" 
imap jk <right>

" Show matches in search"
set shortmess-=S

"  Search down sub-folders, useful for tab completion"                                                                                                                
set path+=**                                                                                                                                                          
                                                                                                                                                                      
" Display matching files in tab completion"                                                                                                                           
set wildmenu                                                                                                                                                          
set wildignore+=*/venv/*,*/.venv/*,*/__pycache__/*,*/.tags/*,*/.git/*,*/.pytest_cache/*

" No mouse                                                                                                                                                            
set mouse=

" Vertical split to right"
set splitright

" Indentation
set tabstop=4
set shiftwidth=4
set softtabstop=0
set noexpandtab
set autoindent
set smartindent

" set cindent
filetype plugin indent on

" Set whitespace character; use set list / nolist to toggle
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣

" Color Scheme"
colorscheme sorbet

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

" Leader switch tabs"
noremap <LEADER>1 1gt
noremap <LEADER>2 2gt
noremap <LEADER>3 3gt
noremap <LEADER>4 4gt
noremap <LEADER>5 5gt
noremap <LEADER>6 6gt
noremap <LEADER>7 7gt
noremap <LEADER>8 8gt
noremap <LEADER>9 9gt
noremap <LEADER>0 :tablast<CR>
" Go to last active tab
au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <c-l> :exe "tabn ".g:lasttab<CR>
vnoremap <silent> <c-l> :exe "tabn ".g:lasttab<CR>

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

" Blame and show commit"
function! BlameAndShow()
	let lnum = line('.')
	let file = expand('%:p')
	let hash = system('git blame -L ' . lnum . ',' . lnum . ' ' . shellescape(file))
	let hash = split(hash)[0]
	execute '!git show -s --format="\%h | \%an | \%ad | \%s" --date=short ' . hash
endfunction

" Blame and show current line"
command! -nargs=0 Sline call BlameAndShow()

" Snippets "
let g:snippet_dir = expand('~/repos/dotfiles/snippets')

function! InsertSnippet(snippet_name)
	execute "read " . g:snippet_dir . "/" . a:snippet_name
endfunction

nnoremap <LEADER>r1 :call InsertSnippet('logger.txt')<CR>
nnoremap <LEADER>r2 :call InsertSnippet('pytestmark.txt')<CR>
nnoremap <LEADER>r3 :call InsertSnippet('pymain.txt')<CR>
nnoremap <LEADER>r4 :call InsertSnippet('debug.txt')<CR>
