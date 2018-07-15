""" neosnippet.vim
" configuration for the plugin Shougo/neosnippet.vim

let g:neosnippet#enable_completed_snippet=1
" let g:neosnippet#sn

imap <C-e> <Plug>(neosnippet_expand_or_jump)
smap <C-e> <Plug>(neosnippet_expand_or_jump)
nmap <C-e> <Plug>(neosnippet_expand_target)
xmap <C-e> <Plug>(neosnippet_expand_target)

imap <C-k> <Plug>(neosnippet_expand_or_jump)

"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"


