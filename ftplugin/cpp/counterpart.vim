""" ftplugin/cpp/counterpart.vim
"" Counterparts (e.g. header for implementation)

" Open counterpart in current buffer
nnoremap <silent> <leader>cpp :call cpp#counterpart#edit(expand('%'))<cr>

" Open counterpart in new tab
nnoremap <silent> <leader>cP :call cpp#counterpart#edit(expand('%'), "tabedit")<cr>

" Open counterpart in new horizontal split
nnoremap <silent> <leader>cps :call cpp#counterpart#edit(expand('%'), "split")<cr>

" Open counterpart in new vertical split
nnoremap <silent> <leader>cpv :call cpp#counterpart#edit(expand('%'), "vsplit")<cr>

" Open counterpart in new vim instances
nnoremap <silent> <leader>cpn :call cpp#counterpart#edit(expand('%:p'), "LaunchVimInstance")<cr>
