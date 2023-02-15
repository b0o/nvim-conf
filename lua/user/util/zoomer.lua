-- maximize.lua: maximize the current buffer in a fullscreen floating window
-- Author: Maddison Hellstrom - github.com/b0o
-- Place in your lua directory (preferably use a subdirectory as a namespace)
-- Usage: vim.keymap.set('n', '<leader>z', require'maximize'.toggle)

-- I use a lot of window splits, often 5 or more per tabpage. Sometimes, windows can get a bit too small to see all of the contextual information I'd like. Enter maximize.lua, a tiny module that plops your current buffer into a new full-size floating window. There are a few other plugins that do similar things, but none of them use floating windows, and as a result they have issues messing up your window layout. Because maximize.lua uses a floating window, your original window layout is untouched, and will be just as you left it as soon as you close the maximized floating window.

-- TODO: Add zoom animation

local M = {}

local state = {
  conf = {
    margin_horiz = 0,
    margin_vert = 0,
    zindex = 51,
    winblend = 0,
    on_open = nil, -- function(props) ... end
    on_close = nil, -- function(props) ... end
  },
  basewin = nil,
  floatwin = nil,
  buf = nil,
  on_open_state = nil,
}

M.reset = function()
  state.basewin = nil
  state.floatwin = nil
  state.buf = nil
  state.on_open_state = nil
end

M.setup = function(opts)
  state.conf = vim.tbl_extend('force', state.conf, opts)
end

local is_open = function()
  return state.floatwin and vim.api.nvim_win_is_valid(state.floatwin)
end

M.open = function()
  if is_open() then
    M.close()
  end

  state.basewin = vim.api.nvim_get_current_win()
  state.buf = vim.api.nvim_win_get_buf(state.basewin)

  local scrollbind = vim.api.nvim_win_get_option(state.basewin, 'scrollbind')
  local cursorbind = vim.api.nvim_win_get_option(state.basewin, 'cursorbind')
  vim.api.nvim_win_set_option(state.basewin, 'scrollbind', true)
  vim.api.nvim_win_set_option(state.basewin, 'cursorbind', true)

  state.floatwin = vim.api.nvim_open_win(state.buf, true, {
    relative = 'editor',
    zindex = 51,
    col = 0,
    row = 1,
    width = vim.o.columns,
    height = vim.o.lines - 3,
  })

  vim.api.nvim_win_set_option(state.floatwin, 'scrollbind', true)
  vim.api.nvim_win_set_option(state.floatwin, 'cursorbind', true)

  if state.conf.winblend > 0 then
    vim.api.nvim_win_set_option(state.floatwin, 'winblend', state.conf.winblend)
  end

  vim.api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(state.floatwin),
    callback = function()
      vim.api.nvim_win_set_option(state.basewin, 'scrollbind', scrollbind)
      vim.api.nvim_win_set_option(state.basewin, 'cursorbind', cursorbind)
      if type(state.conf.on_close) == 'function' then
        state.conf.on_close {
          basewin = state.basewin,
          floatwin = state.floatwin,
          buf = state.buf,
          prev_state = state.on_open_state,
        }
      end
      M.reset()
    end,
    once = true,
  })

  if type(state.conf.on_open) == 'function' then
    state.on_open_state = state.conf.on_open {
      basewin = state.basewin,
      floatwin = state.floatwin,
      buf = state.buf,
    }
  end
end

M.close = function()
  if is_open() then
    vim.api.nvim_win_close(state.floatwin, false)
  end
  M.reset()
end

M.toggle = function()
  if is_open() then
    M.close()
  else
    M.open()
  end
end

return M
