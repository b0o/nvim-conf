""" ultisnips.vim
" configuration for the plugin SirVer/ultisnips

let g:UltiSnipsExpandTrigger       = '<M-Tab>'
let g:UltiSnipsJumpForwardTrigger  = '<M-Tab>'
let g:UltiSnipsJumpBackwardTrigger = '<F35>' " map <M-S-Tab> to \x1b[23;5~ (F35) in your terminal emulator

let g:UltiSnipsEditSplit = 'horizontal'

map <silent> <leader>Sn :UltiSnipsEdit<cr>
