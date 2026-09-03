" C++ formater
let g:clang_style = '{
      \ BasedOnStyle: GNU,
      \ AlwaysBreakAfterDefinitionReturnType: None,
      \ BreakAfterReturnType: None,
      \ BreakTemplateDeclarations: Yes,
      \ PointerAlignment: Left,
      \ ReferenceAlignment: Left,
      \ SpaceBeforeParens: Custom,
      \ SpaceBeforeParensOptions: {
      \   AfterControlStatements: false,
      \   AfterForeachMacros: false,
      \   AfterFunctionDefinitionName: false,
      \   AfterFunctionDeclarationName: false,
      \   AfterIfMacros: false,
      \   AfterNot: false,
      \   AfterOverloadedOperator: false,
      \   AfterPlacementOperator: false,
      \   AfterRequiresInClause: false,
      \   AfterRequiresInExpression: false,
      \   BeforeNonEmptyParentheses: false
      \ }}'

" clang-format always pins preprocessor directives (e.g. #pragma omp) to
" column 0; IndentPPDirectives can't change that for non-conditional
" directives. Re-indent #pragma lines to match the previous line afterward.
function! IndentPragmas()
    let l:lnum = 1
    let l:last = line('$')
    while l:lnum <= l:last
        if getline(l:lnum) =~# '^\s*#\s*pragma\>'
            let l:ref = nextnonblank(l:lnum + 1)
            if l:ref <= 0
                let l:ref = prevnonblank(l:lnum - 1)
            endif
            if l:ref > 0
                let l:indent = matchstr(getline(l:ref), '^\s*')
                call setline(l:lnum, l:indent . substitute(getline(l:lnum), '^\s*', '', ''))
            endif
        endif
        let l:lnum += 1
    endwhile
endfunction

function! ClangFormatBuffer()
    let l:view = winsaveview()
    execute '%!clang-format --style=' . shellescape(g:clang_style)
    call IndentPragmas()
    call winrestview(l:view)
endfunction

nnoremap <Leader>cf :call ClangFormatBuffer()<CR>
