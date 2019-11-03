" Copyright (C) 2019-present Maddison Hellstrom <maddy@na.ai>
"
" Vim script based on https://github.com/arcticicestudio/lavi-vim
" Copyright (C) 2016-2019 Arctic Ice Studio <development@arcticicestudio.com>
" Copyright (C) 2016-2019 Sven Greb <development@svengreb.de>

" Project: Lavi Vim
" Repository: https://github.com/b0o/lavi
" License: MIT

let g:lavi_vim_version="0.1.0"
let g:airline#themes#lavi#palette = {}

" Normal Mode     guifg           guibg           ctermfg          ctermbg
let s:NMain   = [ g:lavi_gui[1],  g:lavi_gui[8],  g:lavi_term[1],  g:lavi_term[8]  ]
let s:NRight  = [ g:lavi_gui[1],  g:lavi_gui[9],  g:lavi_term[1],  g:lavi_term[9]  ]
let s:NMiddle = [ g:lavi_gui[5],  g:lavi_gui[3],  g:lavi_term[5],  g:lavi_term[3]  ]
let s:NWarn   = [ g:lavi_gui[1],  g:lavi_gui[13], g:lavi_term[3],  g:lavi_term[13] ]
let s:NError  = [ g:lavi_gui[0],  g:lavi_gui[11], g:lavi_term[1],  g:lavi_term[11] ]

" Insert Mode     guifg           guibg           ctermfg          ctermbg
let s:IMain   = [ g:lavi_gui[1],  g:lavi_gui[14], g:lavi_term[1],  g:lavi_term[6]  ]
let s:IRight  = [ g:lavi_gui[1],  g:lavi_gui[9],  g:lavi_term[1],  g:lavi_term[9]  ]
let s:IMiddle = [ g:lavi_gui[5],  g:lavi_gui[3],  g:lavi_term[5],  g:lavi_term[3]  ]
let s:IWarn   = [ g:lavi_gui[1],  g:lavi_gui[13], g:lavi_term[3],  g:lavi_term[13] ]
let s:IError  = [ g:lavi_gui[0],  g:lavi_gui[11], g:lavi_term[1],  g:lavi_term[11] ]

" Replace Mode    guifg           guibg           ctermfg          ctermbg
let s:RMain   = [ g:lavi_gui[1],  g:lavi_gui[14], g:lavi_term[1],  g:lavi_term[14] ]
let s:RRight  = [ g:lavi_gui[1],  g:lavi_gui[9],  g:lavi_term[1],  g:lavi_term[9]  ]
let s:RMiddle = [ g:lavi_gui[5],  g:lavi_gui[3],  g:lavi_term[5],  g:lavi_term[3]  ]
let s:RWarn   = [ g:lavi_gui[1],  g:lavi_gui[13], g:lavi_term[3],  g:lavi_term[13] ]
let s:RError  = [ g:lavi_gui[0],  g:lavi_gui[11], g:lavi_term[1],  g:lavi_term[11] ]

" Visual Mode     guifg           guibg           ctermfg          ctermbg
let s:VMain   = [ g:lavi_gui[1],  g:lavi_gui[7],  g:lavi_term[1],  g:lavi_term[7]  ]
let s:VRight  = [ g:lavi_gui[1],  g:lavi_gui[9],  g:lavi_term[1],  g:lavi_term[9]  ]
let s:VMiddle = [ g:lavi_gui[5],  g:lavi_gui[3],  g:lavi_term[5],  g:lavi_term[3]  ]
let s:VWarn   = [ g:lavi_gui[1],  g:lavi_gui[13], g:lavi_term[3],  g:lavi_term[13] ]
let s:VError  = [ g:lavi_gui[0],  g:lavi_gui[11], g:lavi_term[1],  g:lavi_term[11] ]

" Inactive         guifg           guibg           ctermfg          ctermbg
let s:IAMain   = [ g:lavi_gui[5],  g:lavi_gui[3],  g:lavi_term[5],  g:lavi_term[3]  ]
let s:IARight  = [ g:lavi_gui[5],  g:lavi_gui[3],  g:lavi_term[5],  g:lavi_term[3]  ]
let s:IAMiddle = [ g:lavi_gui[5],  g:lavi_gui[3],  g:lavi_term[5],  g:lavi_term[3]  ]
let s:IAWarn   = [ g:lavi_gui[1],  g:lavi_gui[13], g:lavi_term[3],  g:lavi_term[13] ]
let s:IAError  = [ g:lavi_gui[0],  g:lavi_gui[11], g:lavi_term[1],  g:lavi_term[11] ]

let s:accents = {}

" Accent Colors          guifg           guibg  ctermfg          ctermbg   textdecor
let s:accents.none   = [ '',             '',    '',              '',       ''       ]
let s:accents.bold   = [ '',             '',    '',              '',       'bold'   ]
let s:accents.italic = [ '',             '',    '',              '',       'italic' ]
let s:accents.blue   = [ g:lavi_gui[9],  '' ,   g:lavi_term[9],  '',       ''       ]
let s:accents.red    = [ g:lavi_gui[11], '' ,   g:lavi_term[10], '',       ''       ]
let s:accents.green  = [ g:lavi_gui[14], '' ,   g:lavi_term[14], '',       ''       ]
let s:accents.yellow = [ g:lavi_gui[13], '' ,   g:lavi_term[13], '',       ''       ]
let s:accents.orange = [ '#FFDF61',      '' ,   '',              '',       ''       ]
let s:accents.purple = [ g:lavi_gui[15], '' ,   g:lavi_term[15], '',       ''       ]

let g:airline#themes#lavi#palette.accents = s:accents

let g:airline#themes#lavi#palette.normal = airline#themes#generate_color_map(s:NMain, s:NRight, s:NMiddle)
let g:airline#themes#lavi#palette.normal.airline_warning = s:NWarn
let g:airline#themes#lavi#palette.normal.airline_error = s:NError

let g:airline#themes#lavi#palette.insert = airline#themes#generate_color_map(s:IMain, s:IRight, s:IMiddle)
let g:airline#themes#lavi#palette.insert.airline_warning = s:IWarn
let g:airline#themes#lavi#palette.insert.airline_error = s:IError

let g:airline#themes#lavi#palette.replace = airline#themes#generate_color_map(s:RMain, s:RRight, s:RMiddle)
let g:airline#themes#lavi#palette.replace.airline_warning = s:RWarn
let g:airline#themes#lavi#palette.replace.airline_error = s:RError

let g:airline#themes#lavi#palette.visual = airline#themes#generate_color_map(s:VMain, s:VRight, s:VMiddle)
let g:airline#themes#lavi#palette.visual.airline_warning = s:VWarn
let g:airline#themes#lavi#palette.visual.airline_error = s:VError

let g:airline#themes#lavi#palette.inactive = airline#themes#generate_color_map(s:IAMain, s:IARight, s:IAMiddle)
let g:airline#themes#lavi#palette.inactive.airline_warning = s:IAWarn
let g:airline#themes#lavi#palette.inactive.airline_error = s:IAError

let g:airline#themes#lavi#palette.normal.airline_term = s:NMiddle
let g:airline#themes#lavi#palette.insert.airline_term = s:IMiddle
let g:airline#themes#lavi#palette.replace.airline_term = s:RMiddle
let g:airline#themes#lavi#palette.visual.airline_term = s:VMiddle
let g:airline#themes#lavi#palette.inactive.airline_term = s:IAMiddle
