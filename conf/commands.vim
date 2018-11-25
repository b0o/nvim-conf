""" commands.vim
""" command definitions

"" Dein helpers
command! PluginClean call PluginClean()
command! PluginInstall call PluginInstall()
command! PluginUpdate call PluginUpdate()

" Open a term split which starts in insert mode
command! -count -nargs=* Term  call OpenTerm(<q-args>, <count>, 1)

" Open a term split which starts in normal mode
command! -count -nargs=* NTerm call OpenTerm(<q-args>, <count>, 0)

" Open a help page in a new tab
command! -nargs=* -complete=help H call HelpTab(<q-args>)

"" CopyMatches
command! -bang -nargs=? -range=% CopyMatches call CopyMatches(<bang>0, <line1>, <line2>, <q-args>, 0)
command! -bang -nargs=? -range=% CopyLines call CopyMatches(<bang>0, <line1>, <line2>, <q-args>, 1)

" LaunchVimInstance
command! -count -nargs=* LaunchVimInstance  call LaunchVimInstance(<q-args>)
