""" auto.vim
" autogroups and autocommands

" Ensure the title is set immediately on load instead of whenever a file is
" loaded/changed/written
augroup vimenter_settitle
  autocmd!
  autocmd VimEnter * set title
augroup END

" Enter insert mode when entering a terminal buffer
augroup term
  autocmd!
  autocmd BufEnter term://* call TermEnter(1)
  autocmd TermClose       * call CloseBufWins(expand('<abuf>'))
augroup END
