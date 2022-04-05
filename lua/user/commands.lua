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

command { 'DiffOrig', 'vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis' }

command { '-nargs=*', [[-complete=help H lua require'user.fn'.help(<q-args>)]] }
command { '-nargs=*', '-bar', '-complete=customlist,man#complete', 'Man', [[lua require'user.fn'.man('', <q-args>)]] }
command {
  '-nargs=*',
  '-bar',
  '-complete=customlist,man#complete',
  'M',
  [[ lua require'user.fn'.man('tab', <q-args>)]],
}

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

-- Like :only but don't close non-normal windows like quickfix, file trees, etc.
command {
  '-bang',
  'Only',
  function(o)
    local curwin = vim.api.nvim_get_current_win()
    vim.tbl_map(function(w)
      if w ~= curwin then
        vim.api.nvim_win_close(w, o.bang == '!')
      end
    end, require('user.fn').tabpage_list_normal_wins())
  end,
}

---- Magic file commands
-- More commands with similar behavior to Eunuch

-- Complete magic file paths
M.cmp.copy = function(input)
  vim.g.lastinput = input
  if input:match '^[%%#]' or input:match '^%b<>' then
    if input == '%' then
      input = '%:t'
    elseif input == '%%' then
      input = '%'
    end
    return { vim.fn.expand(input) }
  end
  local sep = fn.get_path_separator()
  local prefix = vim.fn.expand '%:p:h' .. sep
  local files = vim.fn.glob(prefix .. input .. '*', false, true)
  files = vim.tbl_map(function(file)
    return string.sub(file, #prefix + 1) .. (vim.fn.isdirectory(file) == 1 and sep or '')
  end, files)
  if #files > 0 then
    table.insert(files, '..' .. sep)
  end
  return files
end

local function magicFileCmd(func, name, edit_cmd)
  command {
    '-nargs=1',
    '-bar',
    '-bang',
    "-complete=customlist,v:lua.require'user.commands'.cmp.copy",
    name,
    {
      function(o)
        func(0, o.args[1], o.bang == '!', edit_cmd, true)
      end,
      'args',
      'bang',
    },
  }
end

magicFileCmd(fn.magic_saveas, 'Copy')
magicFileCmd(fn.magic_saveas, 'Duplicate', 'split')
magicFileCmd(fn.magic_saveas, 'VDuplicate', 'vsplit')
magicFileCmd(fn.magic_saveas, 'Vduplicate', 'vsplit')
magicFileCmd(fn.magic_newfile, 'New')
magicFileCmd(fn.magic_newfile, 'Newsplit', 'split')
magicFileCmd(fn.magic_newfile, 'XNew', 'split')
magicFileCmd(fn.magic_newfile, 'VNew', 'vsplit')
magicFileCmd(fn.magic_newfile, 'VNewsplit', 'split')

------ Plugins
---- tpope/vim-eunuch
command { 'Cx', ':Chmod +x' }

------ Abbreviations
cabbrev('Cp', 'Copy')
cabbrev('Du', 'Duplicate')
cabbrev('Vd', 'VDuplicate')
cabbrev('LI', 'lua inspect')
cabbrev('PS', 'PackerSync')

return M
