local M = {}

local state = { winid = nil }

local is_open = function()
  return state.winid and vim.api.nvim_win_is_valid(state.winid)
end

M.open = function()
  if is_open() then
    M.close()
  end
  local basewinid = vim.api.nvim_get_current_win()
  local basewinsb = vim.api.nvim_win_get_option(basewinid, 'scrollbind')
  local basewincb = vim.api.nvim_win_get_option(basewinid, 'scrollbind')
  vim.api.nvim_win_set_option(basewinid, 'scrollbind', true)
  vim.api.nvim_win_set_option(basewinid, 'cursorbind', true)
  state.winid = vim.api.nvim_open_win(0, true, {
    relative = 'editor',
    zindex = 100,
    col = 0,
    row = 1,
    width = vim.o.columns,
    height = vim.o.lines - 3,
  })
  vim.api.nvim_win_set_option(state.winid, 'scrollbind', true)
  vim.api.nvim_win_set_option(state.winid, 'cursorbind', true)
  vim.api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(state.winid),
    callback = function()
      vim.api.nvim_win_set_option(basewinid, 'scrollbind', basewinsb)
      vim.api.nvim_win_set_option(basewinid, 'cursorbind', basewincb)
    end,
    once = true,
  })
end

M.close = function()
  if is_open() then
    vim.api.nvim_win_close(state.winid, false)
    state.winid = nil
  end
end

M.toggle = function()
  if is_open() then
    M.close()
  else
    M.open()
  end
end

return M
