---- user.fn: General utility functions
local M = {
  callbacks = {},
  quiet = false,
  captured = {},
}

M.notify = function(...)
  if M.quiet then
    for _, l in ipairs { ... } do
      table.insert(M.captured, l)
    end
    return
  end
  vim.notify(...)
end
local notify = M.notify

M.silent = function(f, ...)
  local q = M.quiet
  M.quiet = true
  local res = { f(...) }
  M.quiet = q
  return unpack(res)
end

M.capture = function(f, ...)
  M.captured = {}
  local res = { M.silent(f, ...) }
  return M.captured, unpack(res)
end

-- Register a global anonymous callback
-- Returns an id that can be passed to fn.callback() to call the function
M.new_callback = function(fn)
  table.insert(M.callbacks, fn)
  return #M.callbacks
end

-- Call the callback associated with 'id'
M.callback = function(id, ...)
  return M.callbacks[id](...)
end

-- print + vim.inspect
M.inspect = function(...)
  for _, v in ipairs { ... } do
    print(vim.inspect(v, { depth = math.huge }))
  end
end

-- Make inspect global for convenience
_G.inspect = M.inspect

-- Register a vim command
M.command = function(t)
  local c = {}
  for _, e in ipairs(t) do
    if type(e) == 'function' or type(e) == 'table' then
      local replacements = {}
      if type(e) == 'table' then
        local et = e
        e = table.remove(e, 1)
        for _, r in ipairs(et) do
          local rep = ({
            args = '{ <f-args> }',
            line1 = '<line1>',
            line2 = '<line2>',
            range = '<range>',
            count = '<count>',
            bang = '<q-bang>',
            mods = '<q-mods>',
            reg = '<q-reg>',
          })[r]
          if rep then
            table.insert(replacements, ('%s = %s'):format(r, rep))
          end
        end
      end
      local cb = M.new_callback(e)
      e = ([[lua require'user.fn'.callback(%d, {%s})]]):format(cb, table.concat(replacements, ','))
    end
    table.insert(c, e)
  end
  vim.cmd('command!' .. table.concat(c, ' '))
end

-- Register a command-line abbreviation
M.cabbrev = function(a, c)
  vim.cmd(('cabbrev %s %s'):format(a, c))
end

-- Get the visual selection as a list-like table of lines
M.get_visual_selection = function(mode)
  if mode == nil then
    local mode_info = vim.api.nvim_get_mode()
    mode = mode_info.mode
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local cline, ccol = cursor[1], cursor[2]
  local vline, vcol = vim.fn.line 'v', vim.fn.col 'v'

  local sline, scol
  local eline, ecol
  if cline == vline then
    if ccol <= vcol then
      sline, scol = cline, ccol
      eline, ecol = vline, vcol
      scol = scol + 1
    else
      sline, scol = vline, vcol
      eline, ecol = cline, ccol
      ecol = ecol + 1
    end
  elseif cline < vline then
    sline, scol = cline, ccol
    eline, ecol = vline, vcol
    scol = scol + 1
  else
    sline, scol = vline, vcol
    eline, ecol = cline, ccol
    ecol = ecol + 1
  end

  if mode == 'V' or mode == 'CTRL-V' or mode == '\22' then
    scol = 1
    ecol = nil
  end

  local lines = vim.api.nvim_buf_get_lines(0, sline - 1, eline, 0)
  if #lines == 0 then
    return
  end

  local start_text, end_text
  if #lines == 1 then
    start_text = string.sub(lines[1], scol, ecol)
  else
    start_text = string.sub(lines[1], scol)
    end_text = string.sub(lines[#lines], 1, ecol)
  end

  local selection = { start_text }
  if #lines > 2 then
    vim.list_extend(selection, vim.list_slice(lines, 2, #lines - 1))
  end
  table.insert(selection, end_text)

  return selection
end

-- Execute the visual selection or cursor line as a sequence of lua expressions
M.luarun = function(file)
  local mode_info = vim.api.nvim_get_mode()
  if mode_info.blocking then
    return
  end
  local mode = mode_info.mode

  local text
  if file then
    text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
  else
    if mode == 'n' then
      text = vim.api.nvim_get_current_line()
    elseif mode == 'v' or mode == 'V' or mode == 'CTRL-V' or mode == '\22' then
      local selection = M.get_visual_selection(mode)
      text = table.concat(selection, '\n')
    else
      return
    end
  end

  local loadok, expr = pcall(loadstring, 'return ' .. text)
  if loadok and expr then
    local msg = 'luarun (expr)'
    local evalok, eval_result = pcall(expr)
    if not evalok then
      error(msg .. ' (failed): ' .. eval_result)
    end
    print(msg .. ': ' .. text)
    print(vim.inspect(eval_result))
    return
  end

  local lines = vim.split(text, '\n')
  lines[#lines] = 'return ' .. lines[#lines]

  local blockexpr
  loadok, blockexpr = pcall(loadstring, table.concat(lines, '\n'))
  if loadok and blockexpr then
    local msg = 'luarun (block-expr)'
    local evalok, blockexpr_result = pcall(blockexpr)
    if not evalok then
      error(msg .. ' (failed): ' .. blockexpr_result)
    end
    print(msg .. ': ' .. text)
    print(vim.inspect(blockexpr_result))
    return
  end

  local block, errmsg
  loadok, block, errmsg = pcall(loadstring, text)
  if not loadok then
    error(errmsg)
  end

  local msg = 'luarun (block)'
  local blockok, block_result = pcall(block)
  if not blockok then
    error(msg .. ' failed: ' .. block_result)
  end

  print(msg .. ': ' .. text)
  print(vim.inspect(block_result))
end

-- Gets all of the Lua runtime paths
M.get_runtime_path = function()
  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')
  return runtime_path
end

-- bind a function to some arguments and return a new function (the thunk) that
-- can be called later.
-- Useful for setting up callbacks without anonymous functions.
M.thunk = function(fn, ...)
  local bound = { ... }
  return function(...)
    return fn(unpack(vim.list_extend(vim.list_extend({}, bound), { ... })))
  end
end

-- Like thunk(), but arguments passed to the thunk are ignored.
M.ithunk = function(fn, ...)
  local bound = { ... }
  return function()
    return fn(unpack(bound))
  end
end

M.tbl_reduce = function(tbl, fn, acc)
  for k, v in pairs(tbl) do
    acc = fn(acc, v, k)
  end
  return acc
end

-- Like vim.tbl_keys, but also includes all list-like elements
M.tbl_listkeys = function(tbl)
  return M.tbl_reduce(tbl, function(acc, v, k)
    if type(k) == 'number' then
      table.insert(acc, v)
    else
      table.insert(acc, k)
    end
    return acc
  end, {})
end

-- Like vim.tbl_values, but also includes all list-like elements
M.tbl_listvalues = function(tbl)
  return M.tbl_reduce(tbl, function(acc, v)
    table.insert(acc, v)
    return acc
  end, {})
end

-- Open one or more man pages
-- Accepts a string representing how to open the man pages, one of:
--   - ''        - current window
--   - 'split'   - new horizontal split
--   - 'vsplit'  - new vertical split
--   - 'tab'     - new tab
-- Varargs should be strings of the format
--   <manpage>
-- or
--   <section> <manpage>
M.man = function(dest, ...)
  if dest == 'tab' then
    dest = 'tabnew'
  end
  if dest ~= '' then
    dest = dest .. ' | '
  end
  for _, page in ipairs { ... } do
    if vim.regex('^\\d\\+p\\? \\w\\+$'):match_str(page) ~= nil then
      local s = vim.split(page, ' ')
      page = ('%s(%s)'):format(s[2], s[1])
    end
    local prefix = dest
    if vim.fn.bufname(0) == '' and vim.fn.line '$' == 1 and vim.fn.getline(1) == '' then
      prefix = ''
    end
    vim.cmd(prefix .. 'file ' .. page .. ' | call man#read_page("' .. page .. '")')
  end
end

-- https://www.reddit.com/r/neovim/comments/nrz9hp/can_i_close_all_floating_windows_without_closing/h0lg5m1/
M.close_float_wins = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_win_close(win, false)
    end
  end
end

-- Open a Help topic
--  - If a blank buffer is focused, open it there
--  - Otherwise, open in a new tab
M.help = function(...)
  for _, topic in ipairs { ... } do
    if vim.fn.bufname() == '' and vim.api.nvim_buf_line_count(0) == 1 and vim.fn.getline(1) == '' then
      local win = vim.api.nvim_get_current_win()
      vim.cmd 'help'
      vim.api.nvim_win_close(win, false)
    else
      vim.cmd('tab help ' .. topic)
    end
  end
end

---- Shatur/neovim-session-manager
-- Wrapper functions which persist and load additional state with the session,
-- such as whether nvim-tree is open.
M.session_save = function()
  local meta = {
    focused = vim.api.nvim_get_current_win(),
    nvimTreeOpen = false,
    nvimTreeFocused = false,
  }

  if require('nvim-tree.view').is_visible() then
    meta.nvimTreeOpen = true
    meta.nvimTreeFocused = vim.fn.bufname(vim.fn.bufnr()) == 'NvimTree'
    require('nvim-tree.view').close()
  end

  require('treesitter-context').disable()

  vim.g.SessionMeta = vim.inspect(meta)
  require('session_manager').save_current_session()
  vim.g.SessionMeta = nil

  require('treesitter-context').enable()

  if meta.nvimTreeOpen then
    require('nvim-tree').open()
    if not meta.nvimTreeFocused and vim.api.nvim_win_is_valid(meta.focused) then
      vim.api.nvim_set_current_win(meta.focused)
    end
  end
end

-- Load the session associated with the CWD
M.session_load = function()
  local cb = M.new_callback(function()
    local meta = loadstring('return ' .. (vim.g.SessionMeta or '{}'))()
    vim.g.SessionMeta = nil

    vim.schedule(function()
      require('user.tabline').restore_tabpage_titles()
      if meta.nvimTreeOpen then
        require('nvim-tree').open()
      end
      if meta.nvimTreeFocused then
        require('nvim-tree').focus()
      elseif meta.focused and vim.api.nvim_win_is_valid(meta.focused) then
        vim.api.nvim_set_current_win(meta.focused)
      end
      require('treesitter-context').enable()
    end)
  end)

  vim.cmd(([[
    autocmd! SessionLoadPost * ++once lua require('user.fn').callback(%s)
  ]]):format(cb))

  require('treesitter-context').disable()
  require('session_manager').load_current_dir_session(false)
end

M.set_winfix = function(set, ...)
  local dirs = { ... }
  local msg = {}
  for _, dir in ipairs(dirs) do
    local fix = 'winfix' .. dir
    if set == 'toggle' then
      set = not vim.o[fix]
    end
    if vim.o[fix] ~= set then
      vim.o[fix] = set
      table.insert(msg, fix .. ' ' .. (vim.o[fix] and 'enable' or 'disable'))
    end
  end
  if #msg > 0 then
    notify(table.concat(msg, ', '))
  end
end

M.toggle_winfix = function(...)
  M.set_winfix('toggle', ...)
end

M.resize_win = function(dir, dist)
  dist = dist or ''
  vim.cmd(dist .. 'wincmd ' .. dir)
  M.set_winfix(true, (dir == '<' or dir == '>') and 'width' or 'height')
end

---- UTF-8
-- Convert a number to a utf8 string
M.utf8 = function(decimal)
  if type(decimal) == 'string' then
    decimal = vim.fn.char2nr(decimal)
  end
  if decimal < 128 then
    return string.char(decimal)
  end
  local charbytes = {}
  for bytes, vals in ipairs { { 0x7FF, 192 }, { 0xFFFF, 224 }, { 0x1FFFFF, 240 } } do
    if decimal <= vals[1] then
      for b = bytes + 1, 2, -1 do
        local mod = decimal % 64
        decimal = (decimal - mod) / 64
        charbytes[b] = string.char(128 + mod)
      end
      charbytes[1] = string.char(vals[2] + decimal)
      break
    end
  end
  return table.concat(charbytes)
end

-- For each { k = v } in keys, return a table that when indexed by any k' such
-- that tolower(k') == tolower(k) returns utf8(v)
M.utf8keys = function(keys)
  local _keys = {}
  for k, v in pairs(keys) do
    _keys[string.lower(k)] = M.utf8(v)
  end
  return setmetatable(_keys, {
    __index = function(self, k)
      return rawget(self, string.lower(k))
    end,
    __call = function(self, k)
      return self[k]
    end,
  })
end

-- Replace occurrences of ${k} with v in tmpl for each { k = v } in data
M.template = function(tmpl, data)
  local fn = function(_data)
    local res = tmpl
    for k, v in pairs(_data) do
      res = res:gsub('${' .. k .. '}', v)
    end
    return res
  end
  if data then
    return fn(data)
  end
  return fn
end

M.tmpl_cmd = function(...)
  return vim.cmd(M.template(...))
end

M.tmpl_hi = function(tmpl, colors)
  colors = colors or require 'user.colors'
  return M.tmpl_cmd(tmpl, colors)
end

------- lazy
-- TODO: remove this from user.fn, callers should load user.util.lazy directly
local lazy = require 'user.util.lazy'

M.lazy_table = lazy.table
M.on_call_rec = lazy.on_call_rec
M.require_on_index = lazy.require_on_index
M.require_on_module_call = lazy.require_on_module_call
M.require_on_exported_call = lazy.require_on_exported_call
M.require_on_call_rec = lazy.require_on_call_rec

---- memoization

-- memotable gets an index from target and caches the result, returning the
-- cached version on future lookups.
--
-- Setting an index on memotable passes the value through to target and
-- updates the cache.
--
-- This only makes sense for targets who themselves have metatables that do
-- work on __index; if target is a plain table, this is unnecessary overhead.
M.memotable = function(target)
  return setmetatable({}, {
    __index = function(self, k)
      local v = target[k]
      rawset(self, k, v)
      return v
    end,
    __newindex = function(self, k, v)
      rawset(self, k, v)
      target[k] = v
    end,
  })
end

-- TODO
-- M.memofn = function(fn)
--   local mt = M.memotable({}, {
--     __index = function(k, v)
--       -- ...
--     end
--   })
--   return setmetatable({}, {
--     __call = function(_, arg1, ...)
--       return mt[arg1](...)
--     end
--   })
-- end

M.filetype_command = function(ft, if_match, if_not_match)
  return function()
    if vim.bo.filetype == ft then
      if_match()
    else
      if type(if_not_match) == 'function' then
        if_not_match()
      end
    end
  end
end

M.get_latest_messages = function(count)
  local messages = vim.fn.execute 'messages'
  local lines = vim.split(messages, '\n')
  lines = vim.tbl_filter(function(line)
    return line ~= ''
  end, lines)
  count = count and tonumber(count) or nil
  count = (count ~= nil and count >= 0) and count - 1 or #lines
  return table.concat(vim.list_slice(lines, #lines - count), '\n')
end

M.yank_messages = function(register, count)
  register = (register and register ~= '') and register or '+'
  vim.fn.setreg(register, M.get_latest_messages(count), 'l')
end

M.get_path_separator = function()
  if vim.fn.exists '+shellslash' == 1 and vim.o.shellslash then
    return [[\]]
  end
  return '/'
end

M.resolve_bufnr = function(bufnr)
  return bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()
end

M.resolve_winnr = function(winnr)
  return winnr ~= 0 and winnr or vim.api.nvim_get_current_win()
end

M.get_wins_of_type = function(wintype)
  return vim.tbl_filter(function(winid)
    return vim.fn.win_gettype(winid) == wintype
  end, vim.api.nvim_list_wins())
end

M.get_qfwin = function()
  return M.get_wins_of_type('quickfix')[1]
end

M.is_normal_win = function(winid)
  if vim.fn.win_gettype(winid) ~= '' then
    return false
  end
  local bufid = vim.api.nvim_win_get_buf(winid)
  if vim.api.nvim_buf_get_option(bufid, 'buftype') ~= '' then
    return false
  end
  if vim.tbl_contains({ 'NvimTree', 'Trouble', 'aerial' }, vim.api.nvim_buf_get_option(bufid, 'filetype')) then
    return false
  end
  return true
end

M.tabpage_list_normal_wins = function(tabpage)
  local wins = vim.api.nvim_tabpage_list_wins(tabpage or 0)
  return vim.tbl_filter(M.is_normal_win, wins)
end

---- Magic file functions
-- Get a magic file path based on the current buffer path and new_name.
-- Behaves kinda like paths in tpope/vim-eunuch.
M.magic_file_path = function(winnr, new_name, add_ext)
  assert(new_name ~= '', 'magic_file_path: no name specified')
  winnr = M.resolve_winnr(winnr)
  add_ext = add_ext ~= nil and add_ext or false

  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local file_name = vim.fn.fnamemodify(file_path, ':t')
  local path_is_absolute = new_name:match '^/'

  local dest_path
  if path_is_absolute then
    if vim.fn.isdirectory(new_name) then
      dest_path = new_name .. '/' .. file_name
    else
      dest_path = new_name
    end
  else
    local dest_dir
    if vim.api.nvim_buf_get_option(bufnr, 'buftype') == '' then
      dest_dir = vim.fn.fnamemodify(file_path, ':p:h')
    else
      dest_dir = vim.fn.getcwd(winnr)
    end
    dest_path = dest_dir .. '/' .. new_name
  end

  if add_ext and vim.fn.fnamemodify(dest_path, ':e') == '' then
    local ext = vim.fn.fnamemodify(file_name, ':e')
    if ext ~= '' then
      dest_path = dest_path .. '.' .. ext
    end
  end

  return vim.fn.resolve(dest_path)
end

-- Create and edit a new file with a magic path
M.magic_newfile = function(winnr, new_name, force, edit_cmd, add_ext, lines)
  assert(new_name ~= '', 'saveas: no name specified')
  winnr = M.resolve_winnr(winnr)
  lines = lines or {}
  force = force ~= nil and force or false
  edit_cmd = edit_cmd or 'edit!'

  if add_ext and new_name:match '[.]$' then
    add_ext = false
    new_name = new_name:sub(1, #new_name - 1)
  end

  local dest_path = M.magic_file_path(winnr, new_name, add_ext)

  assert(force or vim.fn.filereadable(dest_path) == 0, 'File exists: ' .. dest_path)
  local ok, msg = pcall(vim.fn.writefile, lines, dest_path, '')
  assert(ok == true, 'newfile: write failed: ' .. msg)

  vim.cmd(([[%s %s]]):format(edit_cmd, dest_path))
end

-- Saveas and edit a new file with a magic path
M.magic_saveas = function(winnr, new_name, force, edit_cmd, add_ext)
  winnr = M.resolve_winnr(winnr)
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return M.magic_newfile(winnr, new_name, force, edit_cmd or 'edit!', add_ext, lines)
end

---- Packer
M.get_plugins_conf_path = function()
  return vim.fn.stdpath 'config' .. '/lua/user/plugins.lua'
end

M.packer_compile = function()
  local plugins_conf_path = M.get_plugins_conf_path()
  dofile(plugins_conf_path)
  require('packer').compile(plugins_conf_path)
end

return M
