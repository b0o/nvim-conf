local lazy = require 'user.util.lazy'
local command_util = require 'user.util.command'

local fn = lazy.require_on_call_rec 'user.fn'

local command, cabbrev = command_util.command, command_util.cabbrev

local M = {
  cmp = {},
}

------ User Commands
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

command { 'DiffOrig', 'vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis' }

command {
  '-nargs=*',
  [[-complete=help H lua require'user.fn'.help(<q-args>)]],
}
command {
  '-nargs=*',
  [[-complete=help HH enew | set buftype=help | help <args>]],
}
command {
  '-nargs=*',
  '-bar',
  "-complete=customlist,v:lua.require'man'.man_complete",
  'Man',
  [[lua require'user.fn'.man('', <q-args>)]],
}
command {
  '-nargs=*',
  '-bar',
  "-complete=customlist,v:lua.require'man'.man_complete",
  'M',
  [[ lua require'user.fn'.man('tab', <q-args>)]],
}

command { 'SessionSave', fn.session_save }
command { 'SessionLoad', fn.session_load }
cabbrev('SS', 'SessionSave')
cabbrev('SL', 'SessionLoad')

command { '-count=-1', '-register', 'YankMessages', 'lua require("user.fn").yank_messages("<reg>", <count>)' }

-- Like :only but don't close non-normal windows like quickfix, file trees, etc.
command {
  '-bang',
  'Only',
  {
    function(o)
      local curwin = vim.api.nvim_get_current_win()
      vim.tbl_map(function(w)
        if w ~= curwin then
          vim.api.nvim_win_close(w, o.bang == '!')
        end
      end, fn.tabpage_list_normal_wins())
    end,
    'bang',
  },
}

command {
  '-bang',
  'Bclean',
  {
    function(o)
      local bufs = vim
        .iter(vim.api.nvim_list_bufs())
        :filter(function(buf)
          local bo = vim.bo[buf]
          local bang = o.bang == '!'
          return bo.buftype == '' and bo.buflisted and (bang or not bo.modified) and #vim.fn.win_findbuf(buf) == 0
        end)
        :totable()
      if #bufs == 0 then
        vim.notify 'No unused buffers found'
        return
      end
      vim.notify(string.format('Deleting %d unused buffer%s', #bufs, #bufs == 1 and '' or 's'))
      vim.iter(bufs):each(function(buf)
        vim.cmd('confirm bdelete ' .. buf)
      end)
    end,
    'bang',
  },
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
magicFileCmd(fn.magic_saveas, 'XDuplicate', 'split')
magicFileCmd(fn.magic_saveas, 'VDuplicate', 'vsplit')
magicFileCmd(fn.magic_saveas, 'Vduplicate', 'vsplit')
magicFileCmd(fn.magic_newfile, 'New')
magicFileCmd(fn.magic_newfile, 'Newsplit', 'split')
magicFileCmd(fn.magic_newfile, 'XNew', 'split')
magicFileCmd(fn.magic_newfile, 'VNew', 'vsplit')
magicFileCmd(fn.magic_newfile, 'VNewsplit', 'split')

---- Search

-- Copy matches of a regex to the clipboard.
-- If bang
function write_matches_to_clipboard(regex, bang)
  local matches = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, line in ipairs(lines) do
    local match = vim.fn.matchlist(line, regex)
    if #match > 0 then
      if bang then
        table.insert(matches, match[0])
      else
        for i = 2, #match do
          table.insert(matches, match[i])
        end
      end
    end
  end
  vim.fn.setreg('+', table.concat(matches, '\n'))
  print('Copied ' .. #matches .. ' matches to clipboard')
end

-- If invoked as a preview callback, performs 'inccommand' preview by
-- highlighting regex matches in the current buffer.
local function write_matches_to_clipboard_preview(opts, preview_ns, preview_buf) end

vim.api.nvim_create_user_command('CopyMatches', function(o)
  write_matches_to_clipboard(o.args, o.bang)
end, {
  bang = true,
  nargs = 1,
  preview = write_matches_to_clipboard_preview,
})

------ Plugins
---- tpope/vim-eunuch
command { 'Cx', ':Chmod +x' }

------ Abbreviations
cabbrev('Cp', 'Copy')
cabbrev('XDu', 'Duplicate')
cabbrev('Du', 'Duplicate')
cabbrev('Vd', 'VDuplicate')
cabbrev('LI', 'lua =')

return M
