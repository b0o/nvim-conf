---- b0o/vim-shot-f
local shotf_cterm = 'lightcyan'
local shotf_gui = '#7CFFE4'

vim.g.shot_f_highlight_graph = table.concat({
  'cterm=bold',
  'ctermbg=NONE',
  'ctermfg=' .. shotf_cterm,
  'gui=underline',
  'guibg=NONE',
  'guifg=' .. shotf_gui,
}, ' ')

vim.g.shot_f_highlight_blank = table.concat({
  'cterm=bold',
  'ctermbg=' .. shotf_cterm,
  'ctermfg=NONE',
  'gui=underline',
  'guibg=' .. shotf_gui,
  'guifg=NONE',
}, ' ')
