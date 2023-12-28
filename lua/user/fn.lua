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
-- selene: allow(global_usage)
_G.inspect = M.inspect

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

  local result = {
    start = { line = sline, col = scol },
    finish = { line = eline, col = ecol },
    mode = mode,
    lines = {},
  }

  local lines = vim.api.nvim_buf_get_lines(0, sline - 1, eline, 0)

  if #lines > 0 then
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
    result.lines = selection
  end

  return result
end

-- Get the visual selection as a list-like table of lines
M.get_visual_selection_list = function(mode)
  local selection = M.get_visual_selection(mode)
  local lines = selection.lines
  if #lines == 0 then
    return
  end

  local scol = selection.start.col
  local ecol = selection.finish.col

  local start_text, end_text
  if #lines == 1 then
    start_text = string.sub(lines[1], scol, ecol)
  else
    start_text = string.sub(lines[1], scol)
    end_text = string.sub(lines[#lines], 1, ecol)
  end

  local result = { start_text }
  if #lines > 2 then
    vim.list_extend(result, vim.list_slice(lines, 2, #lines - 1))
  end
  table.insert(result, end_text)

  return result
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
      local selection = M.get_visual_selection_list(mode)
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

-- Like vim.tbl_map, but fn is called with (k, v) pairs and returns (k, v) pairs
M.tbl_map_entries = function(fn, tbl)
  local res = {}
  for k, v in pairs(tbl) do
    local nk, nv = fn(k, v)
    res[nk] = nv
  end
  return res
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
    vim.cmd(prefix .. 'file ' .. page)
    require('man').read_page(page)
  end
end

M.close_float_wins = function(fts)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ok, config, bufnr
    ok, config = pcall(vim.api.nvim_win_get_config, win)
    if ok then
      ok, bufnr = pcall(vim.api.nvim_win_get_buf, win)
      if ok and config.relative ~= '' and vim.tbl_contains(fts, vim.api.nvim_buf_get_option(bufnr, 'filetype')) then
        -- for some reason, vim.api.nvim_win_close() causes issues with some plugins, but win_execute('close') works fine
        vim.fn.win_execute(win, 'close')
      end
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

-- Jump to prev/next buffer in jumplist
M.jumplist_jump_buf = function(dir)
  local jumplist, jumppos = unpack(vim.fn.getjumplist())
  local initial = math.min(jumppos + 1, #jumplist)
  local bufnr = vim.api.nvim_get_current_buf()
  local target = { bufnr = bufnr }
  local i = initial
  while i > 0 and i <= #jumplist do
    local j = jumplist[i]
    if j.bufnr ~= target.bufnr then
      target = j
      break
    end
    i = i + dir
  end
  if target.bufnr == bufnr then
    return
  end
  local dist = i - initial
  if jumppos == #jumplist then
    dist = dist - 1
  end
  local keys =
    vim.api.nvim_replace_termcodes(('%d<C-%s>'):format(math.abs(dist), dir > 0 and 'i' or 'o'), true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
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
  if package.loaded['nvim-tree'] and require('nvim-tree.view').is_visible() then
    meta.nvimTreeOpen = true
    meta.nvimTreeFocused = vim.fn.bufname(vim.fn.bufnr()) == 'NvimTree'
    vim.cmd 'NvimTreeClose'
  end

  require('treesitter-context').disable()

  vim.g.SessionMeta = vim.inspect(meta)
  require('session_manager').save_current_session()
  vim.g.SessionMeta = nil

  require('treesitter-context').enable()

  if meta.nvimTreeOpen then
    vim.cmd 'NvimTreeOpen'
    if not meta.nvimTreeFocused and vim.api.nvim_win_is_valid(meta.focused) then
      vim.api.nvim_set_current_win(meta.focused)
    end
  end
end

-- Load the session associated with the CWD
M.session_load = function()
  local cb = M.new_callback(function()
    vim.schedule(function()
      local meta = loadstring('return ' .. (vim.g.SessionMeta or '{}'))()
      vim.g.SessionMeta = nil
      require('user.tabline').restore_tabpage_titles()
      if meta.nvimTreeOpen then
        vim.cmd 'NvimTreeOpen'
      end
      if meta.nvimTreeFocused then
        vim.cmd 'NvimTreeFocus'
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

local apiutil = M.require_on_call_rec 'user.apiutil'

M.resolve_bufnr = apiutil.resolve_bufnr
M.resolve_winnr = apiutil.resolve_winnr

M.get_wins_of_type = function(wintype)
  return vim.tbl_filter(function(winid)
    return vim.fn.win_gettype(winid) == wintype
  end, vim.api.nvim_list_wins())
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

M.hex_to_rgb = function(hex)
  hex = hex:gsub('#', '')
  return {
    r = tonumber(hex:sub(1, 2), 16) / 255,
    g = tonumber(hex:sub(3, 4), 16) / 255,
    b = tonumber(hex:sub(5, 6), 16) / 255,
  }
end

M.relative_luminance = function(color)
  local r, g, b = color.r, color.g, color.b
  local function adjust(channel)
    if channel <= 0.03928 then
      return channel / 12.92
    else
      return ((channel + 0.055) / 1.055) ^ 2.4
    end
  end
  r, g, b = adjust(r), adjust(g), adjust(b)
  return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

M.contrast_color = function(bg_hex)
  local bg_color = M.hex_to_rgb(bg_hex)
  local bg_luminance = M.relative_luminance(bg_color)
  -- The W3C recommendation states that if the relative luminance
  -- is more than 0.179, the text should be black; otherwise, it should be white.
  if bg_luminance > 0.179 then
    return 'black'
  else
    return 'white'
  end
end

M.replace_visual_selection = function(str)
  local selection = M.get_visual_selection()
  if selection == nil or vim.tbl_isempty(selection) then
    return
  end
  if selection.mode == 'V' then
    vim.api.nvim_buf_set_lines(
      0,
      selection.start.line - 1,
      selection.finish.line,
      false,
      type(str) == 'table' and str or { str }
    )
    return
  end
  vim.api.nvim_buf_set_text(
    0,
    selection.start.line - 1,
    selection.start.col - 1,
    selection.finish.line - 1,
    selection.finish.col,
    type(str) == 'table' and str or { str }
  )
end

-- Function to transform string
-- preFn can return a second value, `ctx`, which will be passed to postFn as the second argument
-- M.transform_string = function(str, cmd, preFn, postFn, meta)
M.transform_string = function(opts)
  local str = opts.str
  local cmd = opts.cmd
  local preFn = opts.preFn
  local postFn = opts.postFn
  local meta = opts.meta

  local function identityFn(x, ...)
    return x
  end
  -- If preFn or postFn are not provided, default to identityFn
  preFn = preFn or identityFn
  postFn = postFn or identityFn

  -- Transform the string
  local transformed, ctx = preFn(str, meta)

  -- Pass the result to cmd and then to postFn
  local cmd_output
  if type(cmd) == 'function' then
    cmd_output = cmd(transformed, meta)
  else
    cmd_output = vim.fn.system(cmd, transformed)
  end
  return postFn(cmd_output, ctx, meta)
end

M.transform_visual_selection = function(cmd, preFn, postFn)
  -- Get visual selection, transform it, and replace it
  local selection = M.get_visual_selection()
  if selection == nil or vim.tbl_isempty(selection) then
    return
  end
  local final_output = M.transform_string {
    str = table.concat(selection.lines, '\n'),
    cmd = cmd,
    preFn = preFn,
    postFn = postFn,
    meta = { selection = selection },
  }
  M.replace_visual_selection(final_output)
end

--- @param bufnr number | nil
--- @return { char: string, size: number }
M.get_indent_info = function(bufnr)
  bufnr = bufnr or 0

  ---@diagnostic disable-next-line: redundant-parameter
  local expandtab = vim.api.nvim_buf_get_option(bufnr, 'expandtab')
  ---@diagnostic disable-next-line: redundant-parameter
  local tabstop = vim.api.nvim_buf_get_option(bufnr, 'tabstop')
  ---@diagnostic disable-next-line: redundant-parameter
  local shiftwidth = vim.api.nvim_buf_get_option(bufnr, 'shiftwidth')

  if expandtab then
    return { char = ' ', size = shiftwidth }
  else
    return { char = '	', size = tabstop }
  end
end

return M
