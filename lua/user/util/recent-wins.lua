---- Recent wins
-- An extension of the 'wincmd p' concept, but ignoring special windows like
-- popups, sidebars, and quickfix.
-- TODO: Keep track of more than 2 wins, fallback when a window is closed

local fn = require 'user.fn'

local M = {
  tabpages = {},
}

M.update = function()
  local tabpage = vim.api.nvim_get_current_tabpage()
  if not M.tabpages then
    M.tabpages = {}
  end
  if not M.tabpages[tabpage] then
    M.tabpages[tabpage] = {}
  end
  local tabpage_recents = M.tabpages[tabpage]
  local cur_winid = vim.api.nvim_get_current_win()
  if not fn.is_normal_win(cur_winid) then
    return
  end
  if cur_winid == tabpage_recents[1] then
    return
  end
  M.tabpages[tabpage] = {
    cur_winid,
    tabpage_recents[1] or nil,
  }
end

M.tabpage_get_recents = function(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  return M.tabpages[tabpage]
end

M.get_most_recent = function()
  local tabpage_recents = M.tabpage_get_recents()
  local winid = tabpage_recents and tabpage_recents[1]
  if not winid then
    return
  end
  if vim.api.nvim_get_current_win() == winid then
    winid = tabpage_recents[2]
  end
  return winid
end

M.focus_most_recent = function(winid)
  winid = winid or M.get_most_recent()
  if winid then
    vim.api.nvim_set_current_win(winid)
    return
  end
  vim.cmd [[wincmd p]]
end

M.flip_recents = function()
  local cur_winid = vim.api.nvim_get_current_win()
  local tabpage_recents = M.tabpage_get_recents()
  local last_winid = tabpage_recents and tabpage_recents[1]
  if not last_winid or last_winid == cur_winid then
    return
  end
  vim.api.nvim_set_current_win(tabpage_recents[2])
  M.update()
  vim.cmd [[wincmd p]]
end

return M
