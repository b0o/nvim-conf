""" language-client.vim
""" configuration for the plugin autozimu/LanguageClient-neovim

let s:bash_cmd = [
  \ 'bash-language-server',
  \ 'start',
  \ ]

let s:cquery_cmd = ['cquery',
  \  '--init={'
  \  . '"cacheDirectory": "' . expand($HOME) . '/.cache/cquery"'
  \  . ','
  \  . '"completion": {'
  \  .   '"filterAndSort": false'
  \  . '}'
  \  .
  \  '}' ]
" \  '--log-file=~/.local/share/cquery/cquery.log',

let s:clangd_cmd = ['clangd']

let s:ccls_cmd = ['ccls']

let s:js_ts_cmd = [
  \ 'javascript-typescript-stdio',
  \ ]
" \  '--logfile', '~/.local/share/javascript_typescript_langserver/langserver.log',

let s:hie_cmd = [
  \  'hie-wrapper',
  \ ]
" \ '--logfile', '~/.local/share/haskell-ide-engine/hie-wrapper_lcn.log',

let s:go_cmd = [
  \  'go-langserver',
  \  '-gocodecompletion',
  \ ]
" \ '-usebinarypkgcache=0',
" \ '-logfile', '~/.local/share/go-langserver/go-langserver.log',

let s:bingo_cmd = [
  \   'bingo',
  \   '-enable-global-cache',
  \ ]

let s:gopls_cmd = [
  \   'gopls',
  \   '-logfile', '~/.local/share/gopls.log',
  \   'serve',
  \ ]

let s:ocaml_cmd = [
  \   'ocaml-language-server',
  \   '--stdio',
  \ ]

let s:pyls_cmd = [
  \   'pyls',
  \ ]

let s:vim_cmd = [
  \   'vim-language-server',
  \   '--stdio',
  \ ]

let s:docker_cmd = [
  \   'docker-langserver',
  \   '--stdio',
  \ ]

" LanguageClient-neovim
let g:LanguageClient_serverCommands = {
  \   'bash':           s:bash_cmd,
  \   'sh':             s:bash_cmd,
  \
  \   'c':              s:ccls_cmd,
  \   'cpp':            s:ccls_cmd,
  \   'cuda':           s:ccls_cmd,
  \   'objc':           s:ccls_cmd,
  \
  \   'dockerfile':     s:docker_cmd,
  \
  \   'go':             s:gopls_cmd,
  \
  \   'haskell':        s:hie_cmd,
  \
  \   'ocaml':          s:ocaml_cmd,
  \   'reason':         s:ocaml_cmd,
  \
  \   'javascript.jsx': s:js_ts_cmd,
  \   'typescript':     s:js_ts_cmd,
  \
  \   'python':         s:pyls_cmd,
  \
  \   'vim':            s:vim_cmd,
  \ }
" \   'c':              s:cquery_cmd,
" \   'javascript':     s:js_ts_cmd,
" \   'go':             s:gopls_cmd,
" \   'go':             s:go_cmd,

" Let ALE handle linting
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_diagnosticsList = 'Disabled'

" Fix for https://github.com/autozimu/LanguageClient-neovim/issues/379
let g:LanguageClient_hasSnippetSupport = 0

let g:LanguageClient_settingsPath = $cfgd . '/languageclient.json'

let g:LanguageClient_windowLogMessageLevel = 'Error'

" LC Settings
let g:LanguageClient_autoStart = 1
let g:LanguageClient_hoverPreview = 'Always'
let g:LanguageClient_useFloatingHover = 1
let g:LanguageClient_completionPreferTextEdit = 0

let g:LanguageClient_trace = 'off'  " 'off' | 'messages' | 'verbose'
let g:LanguageClient_loggingLevel = 'Info' " 'Debug' | 'Info' | 'Warn' | 'Error'
let g:LanguageClient_windowLogMessageLevel = 'Error' " 'Debug' | 'Info' | 'Warn' | 'Error'
let g:LanguageClient_loggingFile = stdpath('cache') . '/language-client.log'
