""" neosnippet.vim
" configuration for the plugin Shougo/neosnippet.vim

let g:neosnippet#enable_completed_snippet=1

imap <C-e> <Plug>(neosnippet_expand_or_jump)
smap <C-e> <Plug>(neosnippet_expand_or_jump)
nmap <C-e> <Plug>(neosnippet_expand_target)
xmap <C-e> <Plug>(neosnippet_expand_target)

imap <expr><TAB>
\ pumvisible() ? "\<C-n>" :
\ neosnippet#expandable_or_jumpable() ?
\    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

imap <expr><CR>
\ (pumvisible() && neosnippet#expandable()) ? "\<Plug>(neosnippet_expand_or_jump)" : "\<CR>"

smap <expr><TAB>
\ (neosnippet#expandable_or_jumpable()) ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
