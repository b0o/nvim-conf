""" auto.vim
""" autogroups and autocommands

" Enter insert mode when entering a terminal buffer
augroup termenter
  autocmd!
  autocmd BufEnter term://* call TermEnter(1)
augroup END
