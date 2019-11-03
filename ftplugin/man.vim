" Disable default manpage mappings
let g:no_man_maps = 1

" Redefine desired mappings
nnoremap <silent> <buffer> <leader>b  :call man#show_toc()<CR>
nnoremap <silent> <buffer> <C-]>      :silent! Man<CR>
nnoremap <silent> <buffer> <C-[>      :call man#pop_tag()<CR>
nnoremap <silent> <buffer> <tab>      :call search('\(^\w\)\|\(\w\+(\w\+)\)', 's')<CR>
nnoremap <silent> <buffer> <S-tab>    :call search('\(^\w\)\|\(\w\+(\w\+)\)', 'sb')<CR>
nnoremap <silent> <buffer> <esc>      :noh<return><esc>
