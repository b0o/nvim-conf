""" vim-clap.vim
""" configuration for the plugin liuchengxu/vim-clap

let g:clap_layout = { 'relative': 'editor' }

let g:clap_popup_border = 'nil'
let g:clap_search_box_border_style = 'nil'

let g:clap_insert_mode_only = 1
let g:clap_open_action = {}
let g:clap_open_action['F12']    = 'tab split' " map <C-Cr> to ^[[24~ (F12) in your terminal emulator
let g:clap_open_action['ctrl-t'] = 'tab split'
let g:clap_open_action['ctrl-x'] = 'split'
let g:clap_open_action['ctrl-s'] = 'split'
let g:clap_open_action['ctrl-v'] = 'vsplit'

function! s:clap_user_maps()
  imap <silent> <buffer> <nowait> <c-n> <c-j>
  imap <silent> <buffer> <nowait> <c-p> <c-k>
endfunction

augroup clap_user_maps
  autocmd!
  autocmd User ClapOnEnter call <sid>clap_user_maps()
augroup END
