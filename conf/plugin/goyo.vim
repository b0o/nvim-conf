""" goyo.vim
" configuration for the plugin junegunn/goyo.vim

function! s:goyo_enter()
  call Setbackground()
endfunction

function! s:goyo_leave()
  call Setbackground()
endfunction

augroup goyo_enter_leave
  autocmd!
  autocmd User GoyoEnter nested call <SID>goyo_enter()
  autocmd User GoyoLeave nested call <SID>goyo_leave()
augroup END

nnoremap <silent> <leader>go :Goyo<CR>
