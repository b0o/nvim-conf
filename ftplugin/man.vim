" Disable default manpage mappings
let g:no_man_maps = 1

function! s:man_maps()
  echom "man_maps"
  " Redefine desired mappings
  nnoremap <silent> <buffer> <leader>b  :call man#show_toc()<CR>
  nnoremap <silent> <buffer> <C-]>      :silent! Man<CR>
  nnoremap <silent> <buffer> <C-[>      :call man#pop_tag()<CR>
  nnoremap <silent> <buffer> <tab>      :call search('\(^\w\)\|\(\w\+(\w\+)\)', 's')<CR>
  nnoremap <silent> <buffer> <S-tab>    :call search('\(^\w\)\|\(\w\+(\w\+)\)', 'sb')<CR>
  nnoremap <silent> <buffer> <esc>      :noh<return><esc>
endfunction

augroup man_maps
  autocmd!
  autocmd BufReadPost * echom "foo" | if &ft == "man" | call s:man_maps() | endif
augroup END
