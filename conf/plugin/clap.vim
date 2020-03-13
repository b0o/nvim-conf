""" vim-clap.vim
""" configuration for the plugin liuchengxu/vim-clap

nnoremap <silent> <localleader>C   :Clap<cr>

nnoremap <silent> <localleader>X   :call clap#floating_win#close()<cr>
nnoremap <silent> <localleader>xx  :call clap#floating_win#close()<cr>

nnoremap <silent> <localleader>B   :Clap buffers<cr>
nnoremap <silent> <localleader>bb  :Clap buffers<cr>
nnoremap <silent> <localleader>bgc :Clap bcommits<cr>
nnoremap <silent> <localleader>bu  :Clap buffers<cr>
nnoremap <silent> <localleader>bl  :Clap blines<cr>

nnoremap <silent> <localleader>cc  :Clap command<cr>
nnoremap <silent> <localleader>cmd :Clap command<cr>
nnoremap <silent> <localleader>col :Clap colors<cr>
nnoremap <silent> <localleader>ch  :Clap command_history<cr>
nnoremap <silent> <localleader>h   :Clap command_history<cr>

nnoremap <silent> <localleader>F   :Clap files<cr>
nnoremap <silent> <localleader>ff  :Clap files<cr>
nnoremap <silent> <localleader>fi  :Clap files<cr>
nnoremap <silent> <localleader>ft  :Clap filetypes<cr>

nnoremap <silent> <localleader>G   :Clap grep<cr>
nnoremap <silent> <localleader>gg  :Clap grep<cr>
nnoremap <silent> <localleader>gr  :Clap grep<cr>
nnoremap <silent> <localleader>gc  :Clap commits<cr>
nnoremap <silent> <localleader>gf  :Clap git_files<cr>
nnoremap <silent> <localleader>gd  :Clap git_diff_files<cr>

nnoremap <silent> <localleader>H   :Clap help_tags<cr>
nnoremap <silent> <localleader>hh  :Clap help_tags<cr>
nnoremap <silent> <localleader>hi  :Clap history<cr>
nnoremap <silent> <localleader>hs  :Clap search_history<cr>
nnoremap <silent> <localleader>h/  :Clap search_history<cr>
nnoremap <silent> <localleader>/   :Clap search_history<cr>

nnoremap <silent> <localleader>J   :Clap jumps<cr>
nnoremap <silent> <localleader>jj  :Clap jumps<cr>
nnoremap <silent> <localleader>ju  :Clap jumps<cr>

nnoremap <silent> <localleader>L   :Clap lines<cr>
nnoremap <silent> <localleader>li  :Clap lines<cr>
nnoremap <silent> <localleader>lo  :Clap loclist<cr>
nnoremap <silent> <localleader>ll  :Clap loclist<cr>

nnoremap <silent> <localleader>Q   :Clap quickfix<cr>
nnoremap <silent> <localleader>qq  :Clap quickfix<cr>
nnoremap <silent> <localleader>qi  :Clap quickfix<cr>
nnoremap <silent> <localleader>qf  :Clap quickfix<cr>

nnoremap <silent> <localleader>M   :Clap maps<cr>
nnoremap <silent> <localleader>mm  :Clap maps<cr>
nnoremap <silent> <localleader>mr  :Clap marks<cr>
nnoremap <silent> <localleader>mk  :Clap marks<cr>

nnoremap <silent> <localleader>P   :Clap providers<cr>
nnoremap <silent> <localleader>pp  :Clap providers<cr>
nnoremap <silent> <localleader>pr  :Clap providers<cr>

nnoremap <silent> <localleader>R   :Clap registers<cr>
nnoremap <silent> <localleader>rr  :Clap registers<cr>
nnoremap <silent> <localleader>re  :Clap registers<cr>

nnoremap <silent> <localleader>T   :Clap tags<cr>
nnoremap <silent> <localleader>tt  :Clap tags<cr>
nnoremap <silent> <localleader>ta  :Clap tags<cr>

nnoremap <silent> <localleader>W   :Clap windows<cr>
nnoremap <silent> <localleader>ww  :Clap windows<cr>
nnoremap <silent> <localleader>wi  :Clap windows<cr>
