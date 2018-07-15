""" language-client.vim
""" configuration for the plugin autozimu/LanguageClient-neovim

" LanguageClient-neovim
let g:LanguageClient_serverCommands = {
    \     'cpp': ['cquery',
    \             '--log-file=~/.local/share/cquery/cquery.log',
    \             '--init={"cacheDirectory": "' . expand($HOME) . '/.cache/cquery"}' ],
    \ }
