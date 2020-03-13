""" vim-go.vim
" configuration for the plugin fatih/vim-go

" let g:go_term_mode = 'split'
" " let g:go_fmt_command = 'gofmt'
" let g:go_fmt_command = 'golangci-lint run --fix'

let g:go_fmt_autosave = 0
let g:go_metalinter_autosave = 0
let g:go_gopls_enabled = 0

let g:go_doc_keywordprg_enabled = 0

let g:go_term_enabled = 1
let g:go_term_mode = "vsplit"
let g:go_term_height = 20
let g:go_term_close_on_exit = 1

let g:go_highlight_generate_tags = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_trailing_whitespace_error = 1
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_string_spellcheck = 1
