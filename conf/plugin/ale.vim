""" ale.vim
""" configuration for the plugin w0rp/ale

let g:ale_linters = {
      \   'haskell'   : ['ghc', 'ghc-mod'],
      \   'c':          ['cquery'],
      \   'cpp':        ['cquery'],
      \}

let g:ale_fixers = {
      \   'javascript': ['eslint'],
      \   'bash':       ['shfmt'],
      \   'sh':         ['shfmt'],
      \   'c':          ['clang-format'],
      \   'cpp':        ['clang-format'],
      \}

let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'
let g:ale_sign_info = 'ℹ'
let g:ale_sign_style_error = '✖'
let g:ale_sign_style_warning = '⚠'

let g:ale_echo_cursor = 1

let g:ale_fix_on_save = 1

let g:ale_javascript_eslint_executable = 'eslint_d'
let g:ale_javascript_eslint_use_global = 1
let g:ale_javascript_prettier_eslint_use_global = 1
