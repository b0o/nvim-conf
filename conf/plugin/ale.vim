""" ale.vim
""" configuration for the plugin w0rp/ale
scriptencoding utf-8

""" Haskell
let g:ale_haskell_hie_executable = 'hie-wrapper-ale'

""" JavaScript
let g:ale_javascript_eslint_executable = 'eslint_d'
let g:ale_javascript_eslint_use_global = 1
let g:ale_javascript_prettier_eslint_use_global = 1

""" Shell/Bash
" shfmt options:
"  -i 2: use two spaces as indentation
"  -kp:  keep column alignment paddings
"  -bn:  binary ops like && and | may start a line
"  -sr:  redirect operators will be followed by a space
let g:ale_sh_shfmt_options = '-i 2 -kp -bn -sr'

""" Golang
" revive
call ale#linter#Define('go', {
  \   'name': 'revive',
  \   'output_stream': 'both',
  \   'executable': 'revive',
  \   'read_buffer': 0,
  \   'command': 'revive %t',
  \   'callback': 'ale#handlers#unix#HandleAsWarning',
  \ })

" golangci-lint
call ale#Set('go_golangci_lint_options', '')
call ale#Set('go_golangci_lint_executable', 'golangci-lint')
call ale#Set('go_golangci_lint_package', 0)

" golangci-lint fixer
" TODO
" function! ALE_Golangci_lint_fix(buffer) abort
"     let l:executable = ale#Var(a:buffer, 'go_golangci_lint_executable')
"     let l:options = ale#Var(a:buffer, 'go_golangci_lint_options')
"     let l:env = ale#go#EnvString(a:buffer)
"     return {
"       \  'command': l:env . ale#Escape(l:executable)
"       \             . ' run --fix'
"       \             . (empty(l:options) ? '' : ' ' . l:options)
"       \             . ' %t',
"       \  'read_temporary_file': 1,
"       \}
" endfunction

" call ale#fix#registry#Add("golangci-lint", "ALE_Golangci_lint_fix", ["go"], "Fix Go files with golangci-lint")

" \   'go':         ['revive'],
" \   'go':         ['golangci-lint'],

""" ALE configuration
let g:ale_linters = {
  \   'go':         ['gopls', 'golangci-lint', 'revive'],
  \   'haskell':    ['hie'],
  \   'c':          ['ccls'],
  \   'cpp':        ['ccls'],
  \   'cuda':       ['ccls'],
  \   'objc':       ['ccls'],
  \   'javascript': ['eslint'],
  \   'python':     ['bandit', 'prospector', 'vulture'],
  \ }

let g:ale_fixers = {
  \   'go':         ['golangci-lint'],
  \   'javascript': ['eslint'],
  \   'bash':       ['shfmt'],
  \   'zsh':        ['shfmt'],
  \   'sh':         ['shfmt'],
  \   'c':          ['clang-format'],
  \   'cpp':        ['clang-format'],
  \   'ocaml':      ['ocamlformat'],
  \   'python':     ['yapf', 'isort'],
  \   'yaml':       ['prettier'],
  \ }

let g:ale_sign_error = '✖'
let g:ale_sign_warning = ''
let g:ale_sign_info = 'ℹ'
let g:ale_sign_style_error = '✖'
let g:ale_sign_style_warning = ''

let g:ale_echo_cursor = 1
let g:ale_cursor_detail = 0
let g:ale_fix_on_save = 1
