""" vim-orgmode.vim
" configuration for the plugin jceb/vim-orgmode

let g:org_heading_shade_leading_stars = 0

let g:org_agenda_files = [$ORGDIR . '/index.org']
let g:org_todo_keywords = [
  \   [ 'TODO(t)', 'INPROGRESS(T)', '|', 'DONE(d)' ],
  \   [ 'UNREAD(u)', 'READING(U)', '|', 'READ(D)' ],
  \   [ 'RESEARCH(r)', 'RESEARCHING(R)', '|', 'RESEARCHED(e)' ],
  \   [ 'REPORT(b)', 'BUG(B)', '|', 'FIXED(f)' ],
  \ ]

  " \ ['TODO', 'UNREAD', 'RESEARCH', 'INPROGRESS', 'RESEARCHING', 'WAITING', '|', 'DONE', 'READ', 'RESEARCHED', 'DELEGATED']

" BUG: breaks headings of depth >= 4; see https://github.com/jceb/vim-orgmode/issues/350
" let g:org_aggressive_conceal = 1

hi OrgHeading1 ctermfg=blue guifg=#98F6E5 gui=bold
hi OrgHeading2 ctermfg=blue guifg=#73E2D4 gui=bold
hi OrgHeading3 ctermfg=blue guifg=#A2E0D7 gui=bold
hi OrgHeading4 ctermfg=blue guifg=#A3E2DA
hi OrgHeading5 ctermfg=blue guifg=#D9EEE2

let g:org_heading_highlight_colors = [
  \   'OrgHeading1',
  \   'OrgHeading2',
  \   'OrgHeading3',
  \   'OrgHeading4',
  \   'OrgHeading5',
  \   'OrgHeading5',
  \   'OrgHeading5',
  \   'OrgHeading5',
  \   'OrgHeading5',
  \ ]

function! s:orgmode_setup()
  set nowrap
  call ConcealSetup()
endfunction

augroup orgmode
  autocmd!
  autocmd FileType org call s:orgmode_setup()
augroup END
