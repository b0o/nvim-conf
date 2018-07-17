""" denite.vim
" configuration for the plugin shuogo/denite.vim

call denite#custom#map(
  \ 'insert',
  \ '<C-n>',
  \ '<denite:move_to_next_line>',
  \ 'noremap'
  \)
call denite#custom#map(
  \ 'insert',
  \ '<C-p>',
  \ '<denite:move_to_previous_line>',
  \ 'noremap'
  \)
call denite#custom#map(
  \ 'insert',
  \ '<Tab>',
  \ '<denite:move_to_next_line>',
  \ 'noremap'
  \)
call denite#custom#map(
  \ 'insert',
  \ '<S-Tab>',
  \ '<denite:move_to_previous_line>',
  \ 'noremap'
  \)
call denite#custom#map(
  \ 'insert',
  \ '<S-Tab>',
  \ '<denite:move_to_previous_line>',
  \ 'noremap'
  \)
call denite#custom#map(
  \ '_',
  \ '<M-CR>',
  \ '<denite:choose_action>',
  \ 'noremap'
  \)
