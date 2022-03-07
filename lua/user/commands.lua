local fn = require 'user.fn'
local command, cabbrev = fn.command, fn.cabbrev

local M = {
  cmp = {},
}

------ User Commands
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

command { 'SessionSave', require('user.fn').session_save }
command { 'SessionLoad', require('user.fn').session_load }
cabbrev('SS', 'SessionSave')
cabbrev('SL', 'SessionLoad')

command { '-count=-1', '-register', 'YankMessages', 'lua require("user.fn").yank_messages("<reg>", <count>)' }

------ Plugins
---- tpope/vim-eunuch
command { 'Cx', ':Chmod +x' }

M.cmp.copy = function(input)
  local sep = fn.get_path_separator()
  local prefix = vim.fn.expand '%:p:h' .. sep
  local files = vim.fn.glob(prefix .. input .. '*', false, true)
  files = vim.tbl_map(function(file)
    return string.sub(file, #prefix + 1) .. (vim.fn.isdirectory(file) == 1 and sep or '')
  end, files)
  table.insert(files, '..' .. sep)
  return table.concat(files, '\n')
end

command {
  '-nargs=1',
  '-bar',
  '-bang',
  "-complete=custom,v:lua.require'user.commands'.cmp.copy",
  'Copy',
  'saveas<bang> %:h/<args>',
}

------ Abbreviations
cabbrev('LI', 'lua inspect')
cabbrev('Cp', 'Copy')

return M
