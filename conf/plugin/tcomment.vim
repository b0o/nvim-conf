""" tcomment.vim
" configuration for the plugin tomtom/tcomment_vim

" TComment
" call tcomment#DefineType('go', g:tcommentBlockC)
call tcomment#type#Define('go', tcomment#GetLineC('// %s'))
call tcomment#type#Define('go_block', g:tcomment#block_fmt_c)
call tcomment#type#Define('go_inline', g:tcomment#inline_fmt_c)

