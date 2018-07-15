" Redefine manpage mappings which were disabled in init.vim with g:no_man_maps
nnoremap <silent> <buffer> gO         :call man#show_toc()<CR>
nnoremap <silent> <buffer> <C-]>      :silent! Man<CR>
nnoremap <silent> <buffer> <C-[>      :call man#pop_tag()<CR>
nnoremap <silent> <buffer> <tab>      :call search('\w\+(\w\+)', 's')<CR>
nnoremap <silent> <buffer> <S-tab>    :call search('\w\+(\w\+)', 'sb')<CR>
