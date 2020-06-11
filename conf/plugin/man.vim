""" man.vim
""" configuration for the plugin vim-utils/vim-man

" prevent /usr/share/nvim/runtime/plugin/man.vim from initializing
let g:loaded_man = 1

" disable default man.vim and vim-man mappings
let g:no_man_maps = 1
let g:vim_man_no_maps = 1

function! s:init_man()
  " open manpage tag (e.g. isatty(3)) in current buffer
  nnoremap <silent> <buffer> <C-]>       :call man#get_page_from_cword('horizontal', v:count)<CR>

  " open manpage tag in new tab
  nnoremap <silent> <buffer> <M-]>       <c-w>s<c-w>T:call man#get_page_from_cword('tab', v:count)<CR>
  nnoremap <silent> <buffer> <C-M-]>     <c-w>s<c-w>T:call man#get_page_from_cword('tab', v:count)<CR>

  " go back to previous manpage
  nnoremap <silent> <buffer> <C-t>       :call man#pop_page()<CR>
  nnoremap <silent> <buffer> <C-o>       :call man#pop_page()<CR>
  nnoremap <silent> <buffer> <M-o>       <C-o>

  " navigate to next/prev section
  nnoremap <silent> <buffer> [[ :<C-u>call man#section#move('b', 'n', v:count1)<CR>
  nnoremap <silent> <buffer> ]] :<C-u>call man#section#move('' , 'n', v:count1)<CR>
  xnoremap <silent> <buffer> [[ :<C-u>call man#section#move('b', 'v', v:count1)<CR>
  xnoremap <silent> <buffer> ]] :<C-u>call man#section#move('' , 'v', v:count1)<CR>

  " navigate to next/prev manpage tag
  nnoremap <silent> <buffer> <tab>      :call search('\(\w\+(\w\+)\)', 's')<CR>
  nnoremap <silent> <buffer> <S-tab>    :call search('\(\w\+(\w\+)\)', 'sb')<CR>

  " search from beginning of line (useful for finding command args like -h)
  nnoremap <buffer> g/ /^\s*\zs
endfunction

augroup man_maps
  autocmd!
  autocmd FileType man call s:init_man()
augroup END
