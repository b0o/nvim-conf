command! -nargs=+ -complete=command Put pu=execute(\"<args>\")

command! PluginClean call user#fn#pluginClean()
command! PluginInstall call user#fn#pluginInstall()
command! PluginUpdate call user#fn#pluginUpdate()
command! PluginClean call user#fn#pluginClean()
command! PluginInstall call user#fn#pluginInstall()
command! PluginUpdate call user#fn#pluginUpdate()

command! -bang -count -nargs=* Term  call user#fn#openTerm(<q-args>, <count>, 1, <bang>0)
command! -bang -count -nargs=* Nterm call user#fn#openTerm(<q-args>, <count>, 0, <bang>0)
command! -bang -count -nargs=* Vterm call user#fn#openTerm(<q-args>, <count>, 0, <bang>0)
command! -bang -count -nargs=* Vnterm call user#fn#openTerm(<q-args>, <count>, 0, <bang>0)

command! -nargs=* -complete=help H lua require'user.fn'.help(<q-args>)
" command! -nargs=* -complete=help H call user#fn#tabcmd('tab help %s', 'help %s | only', <q-args>)
command! -nargs=* -bar -complete=customlist,man#complete Man lua require'user.fn'.man('', <q-args>)
command! -nargs=* -bar -complete=customlist,man#complete M lua require'user.fn'.man('tab', <q-args>)

command! CloseWin call user#fn#closeWin()
command! ReloadConfig call user#fn#reloadConfig()
command! -bang -nargs=? ReloadConfigFile call user#fn#reloadConfigFile(<bang>0, <q-args>)

command! -bang -nargs=? -range=% CopyMatches call user#fn#copyMatches(<bang>0, <line1>, <line2>, <q-args>, 0)
command! -bang -nargs=? -range=% CopyLines call user#fn#copyMatches(<bang>0, <line1>, <line2>, <q-args>, 1)

command! -count -nargs=* LaunchVimInstance  call user#fn#launchVimInstance(<q-args>)

"""""" Plugins
"" tpope/vim-eunuch
command! Cx :Chmod +x

"" neovim/nvim-lspconfig
command! Format execute 'lua vim.lsp.buf.formatting()'
