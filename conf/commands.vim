""" commands.vim
""" command definitions

" Open a term split which starts in insert mode
command! -count -nargs=* Term  call OpenTerm(<q-args>, <count>, 1)

" Open a term split which starts in normal mode
command! -count -nargs=* NTerm call OpenTerm(<q-args>, <count>, 0)

" Open a help page in a new tab
command! -nargs=* -complete=help H call s:helpTab(<q-args>)
