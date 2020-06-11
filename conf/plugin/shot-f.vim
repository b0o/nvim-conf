""" shot-f.vim
" configuration for the plugin deris/shot-f.vim

let s:hi_cterm = 'lightcyan'
let s:hi_gui   = '#7CFFE4'

let g:shot_f_highlight_graph = 'ctermfg=' . s:hi_cterm . ' ctermbg=NONE cterm=bold guifg=' . s:hi_gui . ' guibg=NONE gui=underline'
let g:shot_f_highlight_blank = 'ctermfg=NONE ctermbg=' . s:hi_cterm . ' cterm=NONE guifg=NONE guibg=' . s:hi_gui . ' gui=underline'
