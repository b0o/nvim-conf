---- Recent wins
-- An extension of the 'wincmd p' concept, but ignoring special windows like
-- popups, sidebars, and quickfix.
-- TODO: Keep track of more than 2 wins, fallback when a window is closed

local fn = require 'user.fn'

local M = {
  tabpages = {},
  tabpages_any = {},
}

M.update = function()
  local tabpage = vim.api.nvim_get_current_tabpage()
  if not M.tabpages then
    M.tabpages = {}
  end
  if not M.tabpages[tabpage] then
    M.tabpages[tabpage] = {}
  end
  if not M.tabpages_any[tabpage] then
    M.tabpages_any[tabpage] = {}
  end
  local tabpage_recents = M.tabpages[tabpage]
  local tabpage_recents_any = M.tabpages_any[tabpage]
  local cur_winid = vim.api.nvim_get_current_win()
  if cur_winid ~= tabpage_recents_any[1] then
    M.tabpages_any[tabpage] = {
      cur_winid,
      tabpage_recents_any[1] or nil,
    }
  end
  if not fn.is_normal_win(cur_winid) then
    return
  end
  if cur_winid ~= tabpage_recents[1] then
    M.tabpages[tabpage] = {
      cur_winid,
      tabpage_recents[1] or nil,
    }
  end
end

M.tabpage_get_recents = function(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  return M.tabpages[tabpage]
end

M.tabpage_get_recents_any = function(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  return M.tabpages_any[tabpage]
end

M.tabpage_get_recents_smart = function(tabpage)
  for _, tp in ipairs { tabpage, M.tabpage_get_recents, M.tabpage_get_recents_any } do
    local recents
    if tp then
      if type(tp) == 'function' then
        recents = tp()
      else
        recents = M.tabpages[tp]
      end
    end
    if recents then
      return recents
    end
  end
end

M.get_most_recent = function(tabpage_recents)
  tabpage_recents = tabpage_recents or M.tabpage_get_recents()
  local winid = tabpage_recents and tabpage_recents[1]
  if not winid then
    return
  end
  if vim.api.nvim_get_current_win() == winid then
    winid = tabpage_recents[2]
  end
  return winid
end

M.get_most_recent_any = function()
  return M.get_most_recent(M.tabpage_get_recents_any())
end

M.get_most_recent_smart = function()
  local tabpage_recents = M.tabpage_get_recents_any()
  if not vim.api.nvim_win_is_valid(tabpage_recents[1] or -1) then
    tabpage_recents = M.tabpage_get_recents()
  end
  return M.get_most_recent(tabpage_recents)
end

M.focus_most_recent = function(winid)
  winid = winid or M.get_most_recent()
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
    return
  end
  vim.cmd [[wincmd p]]
end

M.focus_most_recent_any = function()
  return M.focus_most_recent(M.get_most_recent())
end

M.focus_most_recent_smart = function()
  return M.focus_most_recent(M.get_most_recent_smart())
end

M.flip_recents = function(tabpage_recents)
  tabpage_recents = tabpage_recents or M.tabpage_get_recents()
  local cur_winid = vim.api.nvim_get_current_win()
  local last_winid = tabpage_recents and tabpage_recents[1]
  if not last_winid or last_winid == cur_winid then
    return
  end
  vim.api.nvim_set_current_win(tabpage_recents[2])
  M.update()
  vim.cmd [[wincmd p]]
end

M.flip_recents_any = function()
  return M.flip_recents(M.tabpage_get_recents_any())
end

M.flip_recents_smart = function()
  return M.flip_recents(M.tabpage_get_recents_smart())
end

return M
