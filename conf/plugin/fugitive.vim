""" vim-fugitive.vim
" configuration for the plugin tpope/vim-fugitive

noremap <leader>gA  :Git add --all<cr>
noremap <leader>gaa :Git add --all<cr>
noremap <leader>gC  :Gcommit --verbose<cr>
noremap <leader>gcc :Gcommit --verbose<cr>
noremap <leader>gca :Gcommit --verbose --all<cr>
noremap <leader>gL  :Glog<cr>
noremap <leader>gll :Glog<cr>
noremap <leader>gpa :Gpush --all<cr>
noremap <leader>gpp :Gpush<cr>
noremap <leader>gpl :Gpull<cr>
noremap <leader>gS  :Gstatus<cr>
noremap <leader>gss :Gstatus<cr>

noremap <leader>GG  :Git<space>
noremap <leader>GA  :Git add<space>
noremap <leader>GC  :Gcommit<space>
noremap <leader>GF  :Gfetch<space>
noremap <leader>GL  :Glog<space>
noremap <leader>GPP :Gpush<space>
noremap <leader>GPL :Gpull<space>
noremap <leader>GS  :Gstatus<space>
