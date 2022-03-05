---- user.fn: General utility functions
local M = {
  callbacks = {},
  autoresize = false,
  quiet = false,
  captured = {},
}

function M.print(...)
  if M.quiet then
    for _, l in ipairs { ... } do
      table.insert(M.captured, l)
    end
    return
  end
  _G.print(...)
end

function M.silent(f, ...)
  local q = M.quiet
  M.quiet = true
  local res = { f(...) }
  M.quiet = q
  return unpack(res)
end

function M.capture(f, ...)
  M.captured = {}
  local res = { M.silent(f, ...) }
  return M.captured, unpack(res)
end

local print = M.print

-- Register a global anonymous callback
-- Returns an id that can be passed to fn.callback() to call the function
function M.newCallback(fn)
  table.insert(M.callbacks, fn)
  return #M.callbacks
end

-- Call the callback associated with 'id'
function M.callback(id, ...)
  return M.callbacks[id](...)
end

-- print + vim.inspect
function M.inspect(...)
  for _, v in ipairs { ... } do
    print(vim.inspect(v, { depth = math.huge }))
  end
end

-- Make inspect global for convenience
_G.inspect = M.inspect

-- Register a vim command
function M.command(t)
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
      local cb = M.newCallback(e)
      e = ([[lua require'user.fn'.callback(%d, {%s})]]):format(cb, table.concat(replacements, ','))
    end
    table.insert(c, e)
  end
  vim.cmd('command!' .. table.concat(c, ' '))
end

-- Register a command-line abbreviation
function M.cabbrev(a, c)
  vim.cmd(('cabbrev %s %s'):format(a, c))
end

-- Get the visual selection as a list-like table of lines
function M.getVisualSelection(mode)
  if mode == nil then
    local modeInfo = vim.api.nvim_get_mode()
    mode = modeInfo.mode
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

  local startText, endText
  if #lines == 1 then
    startText = string.sub(lines[1], scol, ecol)
  else
    startText = string.sub(lines[1], scol)
    endText = string.sub(lines[#lines], 1, ecol)
  end

  local selection = { startText }
  if #lines > 2 then
    vim.list_extend(selection, vim.list_slice(lines, 2, #lines - 1))
  end
  table.insert(selection, endText)

  return selection
end

-- Execute the visual selection or cursor line as a sequence of lua expressions
function M.luarun()
  local modeInfo = vim.api.nvim_get_mode()
  if modeInfo.blocking then
    return
  end
  local mode = modeInfo.mode

  local text
  if mode == 'n' then
    text = vim.api.nvim_get_current_line()
  elseif mode == 'v' or mode == 'V' or mode == 'CTRL-V' or mode == '\22' then
    local selection = M.getVisualSelection(mode)
    text = table.concat(selection, '\n')
  else
    return
  end

  local loadok, expr = pcall(loadstring, 'return ' .. text)
  if loadok and expr then
    local msg = 'luarun (expr)'
    local evalok, evalResult = pcall(expr)
    if not evalok then
      error(msg .. ' (failed): ' .. evalResult)
    end
    print(msg .. ': ' .. text)
    print(vim.inspect(evalResult))
    return
  end

  local lines = vim.split(text, '\n')
  lines[#lines] = 'return ' .. lines[#lines]

  local blockexpr
  loadok, blockexpr = pcall(loadstring, table.concat(lines, '\n'))
  if loadok and blockexpr then
    local msg = 'luarun (block-expr)'
    local evalok, blockexprResult = pcall(blockexpr)
    if not evalok then
      error(msg .. ' (failed): ' .. blockexprResult)
    end
    print(msg .. ': ' .. text)
    print(vim.inspect(blockexprResult))
    return
  end

  local block, errmsg
  loadok, block, errmsg = pcall(loadstring, text)
  if not loadok then
    error(errmsg)
  end

  local msg = 'luarun (block)'
  local blockok, blockResult = pcall(block)
  if not blockok then
    error(msg .. ' failed: ' .. blockResult)
  end

  print(msg .. ': ' .. text)
  print(vim.inspect(blockResult))
end

-- Gets all of the Lua runtime paths
function M.getRuntimePath()
  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')
  return runtime_path
end

-- bind a function to some arguments and return a new function (the thunk) that
-- can be called later.
-- Useful for setting up callbacks without anonymous functions.
function M.thunk(fn, ...)
  local bound = { ... }
  return function(...)
    return fn(unpack(vim.list_extend(vim.list_extend({}, bound), { ... })))
  end
end

-- Like thunk(), but arguments passed to the thunk are ignored.
function M.ithunk(fn, ...)
  local bound = { ... }
  return function()
    return fn(unpack(bound))
  end
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
function M.man(dest, ...)
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
function M.closeFloatWins()
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
function M.help(...)
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
function M.sessionSave()
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
function M.sessionLoad()
  local cb = M.newCallback(function()
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

function M.setWinfix(set, ...)
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
    print(table.concat(msg, ', '))
  end
end

function M.toggleWinfix(...)
  M.setWinfix('toggle', ...)
end

function M.resizeWin(dir, dist)
  dist = dist or ''
  vim.cmd(dist .. 'wincmd ' .. dir)
  M.setWinfix(true, (dir == '<' or dir == '>') and 'width' or 'height')
end

---- Autoresize

function M.autoresizeDisable()
  local msg = M.capture(M.setWinfix, true, 'width', 'height')
  table.insert(msg, 'autoresize disable')
  print(table.concat(msg, ', '))
  vim.cmd [[
    augroup autoresize
      au!
    augroup END
    augroup! autoresize
  ]]
  M.autoresize = false
end

function M.autoresizeEnable()
  local msg = M.capture(M.setWinfix, false, 'width', 'height')
  table.insert(msg, 'autoresize enable')
  print(table.concat(msg, ', '))
  vim.cmd [[
    augroup autoresize
      au!
      au VimResized * wincmd =
    augroup END
  ]]
  vim.cmd 'wincmd ='
  M.autoresize = true
end

function M.autoresizeToggle()
  if M.autoresize then
    M.autoresizeEnable()
  else
    M.autoresizeDisable()
  end
end

-- Convert a number to a utf8 string
function M.utf8(decimal)
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
function M.utf8keys(keys)
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
function M.template(tmpl, data)
  local res = tmpl
  for k, v in pairs(data) do
    res = res:gsub('${' .. k .. '}', v)
  end
  return res
end

-- lazyTable returns a placeholder table and defers callback cb until someone
-- tries to access or iterate the table in some way, at which point cb will be
-- called and its result becomes the value of the table.
--
-- To work, requires LuaJIT compiled with -DLUAJIT_ENABLE_LUA52COMPAT.
-- If not, the result of the callback will be returned immediately.
-- See: https://luajit.org/extensions.html
function M.lazyTable(cb)
  -- Check if Lua 5.2 compatability is available by testing whether goto is a
  -- valid identifier name, which is not the case in 5.2.
  if loadstring 'local goto = true' ~= nil then
    return cb()
  end
  local t = { data = nil }
  local init = function()
    if t.data == nil then
      t.data = cb()
      assert(type(t.data) == 'table', 'lazy_config: expected callback to return value of type table')
    end
  end
  t.__len = function()
    init()
    return #t.data
  end
  t.__index = function(_, key)
    init()
    return t.data[key]
  end
  t.__pairs = function()
    init()
    return pairs(t.data)
  end
  t.__ipairs = function()
    init()
    return ipairs(t.data)
  end
  return setmetatable({}, t)
end

------- lazy
--- via https://github.com/tjdevries/lazy.nvim

---- Require on index.
-- Will only require the module after the first index of a module.
-- Only works for modules that export a table.
M.require_on_index = function(require_path)
  return setmetatable({}, {
    __index = function(_, key)
      return require(require_path)[key]
    end,

    __newindex = function(_, key, value)
      require(require_path)[key] = value
    end,
  })
end

---- Requires only when you call the _module_ itself.
-- If you want to require an exported value from the module,
-- see instead |lazy.require_on_exported_call()|
M.require_on_module_call = function(require_path)
  return setmetatable({}, {
    __call = function(_, ...)
      return require(require_path)(...)
    end,
  })
end

---- Require when an exported method is called.
-- Creates a new function. Cannot be used to compare functions,
-- set new values, etc. Only useful for waiting to do the require until you actually
-- call the code.
--
--   -- This is not loaded yet
--   local lazy_mod = lazy.require_on_exported_call('my_module')
--   local lazy_func = lazy_mod.exported_func
--
--   -- ... some time later
--   lazy_func(42)  -- <- Only loads the module now
M.require_on_exported_call = function(require_path)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...)
        return require(require_path)[k](...)
      end
    end,
  })
end

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

M.filetypeCommand = function(ft, ifMatch, ifNotMatch)
  return function()
    if vim.bo.filetype == ft then
      ifMatch()
    else
      if type(ifNotMatch) == 'function' then
        ifNotMatch()
      end
    end
  end
end

M.getLatestMessages = function(count)
  local messages = vim.fn.execute 'messages'
  local lines = vim.split(messages, '\n')
  lines = vim.tbl_filter(function(line)
    return line ~= ''
  end, lines)
  count = count and tonumber(count) or nil
  count = (count ~= nil and count >= 0) and count - 1 or #lines
  return table.concat(vim.list_slice(lines, #lines - count), '\n')
end

M.yankMessages = function(register, count)
  register = (register and register ~= '') and register or '+'
  vim.fn.setreg(register, M.getLatestMessages(count), 'l')
end

M.getPathSeparator = function()
  if vim.fn.exists '+shellslash' == 1 and vim.o.shellslash then
    return [[\]]
  end
  return '/'
end

return M
