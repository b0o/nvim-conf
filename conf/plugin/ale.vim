""" ale.vim
""" configuration for the plugin w0rp/ale

let g:ale_linters = {
      \   'haskell'   : ['hie'],
      \   'c':          ['cquery'],
      \   'cpp':        ['cquery'],
      \   'javascript': ['eslint'],
      \}

let g:ale_fixers = {
      \   'javascript': ['eslint'],
      \   'bash':       ['shfmt'],
      \   'sh':         ['shfmt'],
      \   'c':          ['clang-format'],
      \   'cpp':        ['clang-format'],
      \   'ocaml':      ['ocamlformat'],
      \}

let g:ale_sign_error = '✖'
let g:ale_sign_warning = ''
let g:ale_sign_info = 'ℹ'
let g:ale_sign_style_error = '✖'
let g:ale_sign_style_warning = ''

let g:ale_echo_cursor = 1
let g:ale_cursor_detail = 0
let g:ale_fix_on_save = 1

let g:ale_haskell_hie_executable = 'hie-wrapper-ale'

let g:ale_javascript_eslint_executable = 'eslint_d'
let g:ale_javascript_eslint_use_global = 1
let g:ale_javascript_prettier_eslint_use_global = 1

" shfmt options:
"  -i 2: use two spaces as indentation
"  -kp:  keep column alignment paddings
"  -bn:  binary ops like && and | may start a line
"  -sr:  redirect operators will be followed by a space
let g:ale_sh_shfmt_options = "-i 2 -kp -bn -sr"
