""" vim-orgmode.vim
" configuration for the plugin jceb/vim-orgmode

let g:org_heading_shade_leading_stars = 0

let g:org_agenda_files = [$ORGDIR . '/index.org']
let g:org_todo_keywords = ['TODO', 'UNREAD', 'RESEARCH', 'INPROGRESS', 'RESEARCHING', 'WAITING', '|', 'DONE', 'READ', 'RESEARCHED', 'DELEGATED']
let g:org_aggressive_conceal = 1

function! s:orgmode_setup()
  set nowrap
  call ConcealSetup()
endfunction

augroup orgmode
  autocmd!
  autocmd FileType org call s:orgmode_setup()
augroup END
