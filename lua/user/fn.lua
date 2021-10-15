local M = {}

function M.inspect(...)
  for _, v in ipairs { ... } do
    print(vim.inspect(v))
  end
end

-- Make inspect global for convenience
_G.inspect = M.inspect

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
  for _, topic in ipairs({...}) do
    if vim.fn.bufname() == '' and vim.api.nvim_buf_line_count(0) == 1 and vim.fn.getline(1) == '' then
      local win = vim.api.nvim_get_current_win()
      vim.cmd('help')
      vim.api.nvim_win_close(win, false)
    else
      vim.cmd('tab help ' .. topic)
    end
  end
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
  if loadstring('local goto = true') ~= nil then
    return cb()
  end
  local t = { data = nil }
  local init = function()
    if t.data == nil then
      t.data = cb()
      assert(type(t.data) == "table", "lazy_config: expected callback to return value of type table")
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

return M
