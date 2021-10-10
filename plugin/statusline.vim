hi! def link User1 CursorLine
hi! def link User2 Statusline
hi! def link User3 DiffAdd
hi! def link User4 DiffText
hi! def link User5 DiffDelete
hi! def link User6 Visual
hi! def link User7 DiffChange
hi! def link User8 WarningMsg
hi! def link User9 ErrorMsg

if has('nvim')
    set statusline=%{%v:lua.require'statusline'.SetStatusline()%}
    augroup statusline
        autocmd!
        autocmd VimResized * redrawstatus
    augroup END
endif
