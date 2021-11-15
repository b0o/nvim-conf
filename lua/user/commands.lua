local fn = require 'user.fn'
local command, cabbrev = fn.command, fn.cabbrev
-- local mapx = require'mapx'
--
-- mapx.cmd('Put', "pu=execute('<args>')", {'-nargs=+', '-complete=command' }
-- mapx.cmd( {
--   '-nargs=+',
--   '-complete=command',
--   'Put',
--   {
--     function(o)
--       local l = vim.api.nvim_win_get_cursor(0)[1]
--       local res = vim.split(vim.fn.trim(vim.fn.execute(table.concat(o.args, ' '))), '\n')
--       vim.api.nvim_buf_set_lines(0, l, l, false, res)
--     end,
--     'args',
--   },
-- }
--
-- mapx.cmd( { 'PluginClean', 'call user#fn#pluginClean()' }
-- mapx.cmd( { 'PluginInstall', 'call user#fn#pluginInstall()' }
-- mapx.cmd( { 'PluginUpdate', 'call user#fn#pluginUpdate()' }
-- mapx.cmd( { 'PluginClean', 'call user#fn#pluginClean()' }
-- mapx.cmd( { 'PluginInstall', 'call user#fn#pluginInstall()' }
-- mapx.cmd( { 'PluginUpdate', 'call user#fn#pluginUpdate()' }
--
-- mapx.cmd( { '-bang', '-count', '-nargs=*', 'Term', 'call user#fn#openTerm(<q-args>, <count>, 1, <bang>0)' }
-- mapx.cmd( { '-bang', '-count', '-nargs=*', 'Nterm', 'call user#fn#openTerm(<q-args>, <count>, 0, <bang>0)' }
-- mapx.cmd( { '-bang', '-count', '-nargs=*', 'Vterm', 'call user#fn#openTerm(<q-args>, <count>, 0, <bang>0)' }
-- mapx.cmd( { '-bang', '-count', '-nargs=*', 'Vnterm', 'call user#fn#openTerm(<q-args>, <count>, 0, <bang>0)' }
--
-- mapx.cmd( { 'Format', vim.lsp.buf.formatting }
--
-- mapx.cmd( { '-nargs=*', [[-complete=help H lua require'user.fn'.help(<q-args>)]] }
-- mapx.cmd( { '-nargs=*', '-bar', '-complete=customlist,man#complete', 'Man', [[lua require'user.fn'.man('', <q-args>)]] }
-- mapx.cmd( {
--   '-nargs=*',
--   '-bar',
--   '-complete=customlist,man#complete',
--   'M',
--   [[ lua require'user.fn'.man('tab', <q-args>)]],
-- }
-- -- mapx.cmd( { -nargs=* -complete=help H call user#fn#tabcmd('tab help %s', 'help %s | only', <q-args>) }
--
-- mapx.cmd( { 'CloseWin', 'call user#fn#closeWin()' }
-- mapx.cmd( { 'ReloadConfig', 'call user#fn#reloadConfig()' }
--
-- mapx.cmd( { '-bang', '-nargs=?', 'ReloadConfigFile', 'call user#fn#reloadConfigFile(<bang>0, <q-args>)' }
-- mapx.cmd( {
--   '-bang',
--   '-nargs=?',
--   '-range=%',
--   'CopyMatches',
--   'call user#fn#copyMatches(<bang>0, <line1>, <line2>, <q-args>, 0)',
-- }
-- mapx.cmd( {
--   '-bang',
--   '-nargs=?',
--   '-range=%',
--   'CopyLines',
--   'call user#fn#copyMatches(<bang>0, <line1>, <line2>, <q-args>, 1)',
-- }
--
-- mapx.cmd( { '-count', '-nargs=*', 'LaunchVimInstance', 'call user#fn#launchVimInstance(<q-args>)' }
--
-- mapx.cmd( { 'SessionSave', require('user.fn').sessionSave }
-- mapx.cmd( { 'SessionLoad', require('user.fn').sessionLoad }
-- cabbrev('SS', 'SessionSave')
-- cabbrev('SL', 'SessionLoad')
--
-- ------ Plugins
-- ---- tpope/vim-eunuch
-- mapx.cmd( { 'Cx', ':Chmod +x' }

command { '-nargs=+', '-complete=command', 'Put', "pu=execute('<args>')" }
command {
  '-nargs=+',
  '-complete=command',
  'Put',
  {
    function(o)
      local l = vim.api.nvim_win_get_cursor(0)[1]
      local res = vim.split(vim.fn.trim(vim.fn.execute(table.concat(o.args, ' '))), '\n')
      vim.api.nvim_buf_set_lines(0, l, l, false, res)
    end,
    'args',
  },
}

command { 'PluginClean', 'call user#fn#pluginClean()' }
command { 'PluginInstall', 'call user#fn#pluginInstall()' }
command { 'PluginUpdate', 'call user#fn#pluginUpdate()' }
command { 'PluginClean', 'call user#fn#pluginClean()' }
command { 'PluginInstall', 'call user#fn#pluginInstall()' }
command { 'PluginUpdate', 'call user#fn#pluginUpdate()' }

command { '-bang', '-count', '-nargs=*', 'Term', 'call user#fn#openTerm(<q-args>, <count>, 1, <bang>0)' }
command { '-bang', '-count', '-nargs=*', 'Nterm', 'call user#fn#openTerm(<q-args>, <count>, 0, <bang>0)' }
command { '-bang', '-count', '-nargs=*', 'Vterm', 'call user#fn#openTerm(<q-args>, <count>, 0, <bang>0)' }
command { '-bang', '-count', '-nargs=*', 'Vnterm', 'call user#fn#openTerm(<q-args>, <count>, 0, <bang>0)' }

command { 'Format', vim.lsp.buf.formatting }

command { '-nargs=*', [[-complete=help H lua require'user.fn'.help(<q-args>)]] }
command { '-nargs=*', '-bar', '-complete=customlist,man#complete', 'Man', [[lua require'user.fn'.man('', <q-args>)]] }
command {
  '-nargs=*',
  '-bar',
  '-complete=customlist,man#complete',
  'M',
  [[ lua require'user.fn'.man('tab', <q-args>)]],
}
-- command { -nargs=* -complete=help H call user#fn#tabcmd('tab help %s', 'help %s | only', <q-args>) }

command { 'CloseWin', 'call user#fn#closeWin()' }
command { 'ReloadConfig', 'call user#fn#reloadConfig()' }

command { '-bang', '-nargs=?', 'ReloadConfigFile', 'call user#fn#reloadConfigFile(<bang>0, <q-args>)' }
command {
  '-bang',
  '-nargs=?',
  '-range=%',
  'CopyMatches',
  'call user#fn#copyMatches(<bang>0, <line1>, <line2>, <q-args>, 0)',
}
command {
  '-bang',
  '-nargs=?',
  '-range=%',
  'CopyLines',
  'call user#fn#copyMatches(<bang>0, <line1>, <line2>, <q-args>, 1)',
}

command { '-count', '-nargs=*', 'LaunchVimInstance', 'call user#fn#launchVimInstance(<q-args>)' }

command { 'SessionSave', require('user.fn').sessionSave }
command { 'SessionLoad', require('user.fn').sessionLoad }
cabbrev('SS', 'SessionSave')
cabbrev('SL', 'SessionLoad')

------ Plugins
---- tpope/vim-eunuch
command { 'Cx', ':Chmod +x' }