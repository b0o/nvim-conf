-- Helpers and utilities for vim.api
local api = vim.api

local M = {}

function M.win_get_buf_option(win, name)
  local buf = api.nvim_win_get_buf(win)
  return api.nvim_buf_get_option(buf, name)
end

function M.win_get_buf_var(win, name)
  local buf = api.nvim_win_get_buf(win)
  return api.nvim_buf_get_var(buf, name)
end

function M.win_is_modified(win)
  return M.win_get_buf_option(win, 'modified')
end

function M.tabpage_is_modified(tabpage)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if M.win_is_modified(win) then
      return true
    end
  end
  return false
end

function M.tabpage_list_bufs(tabpage)
  local bufs = {}
  return vim.tbl_filter(
    function(b)
      return b
    end,
    vim.tbl_map(function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      if bufs[buf] ~= nil then
        return false
      end
      bufs[buf] = true
      return buf
    end, vim.api.nvim_tabpage_list_wins(tabpage))
  )
end

function M.tabpage_get_quickfix_win(tabpage)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if M.win_get_buf_option(win, 'buftype') == 'quickfix' then
      return win
    end
  end
end

function M.tabpage_list_modified_bufs(tabpage)
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_get_option(buf, 'modified')
  end, M.tabpage_list_bufs(tabpage))
end

function M.buf_is_empty(b)
  local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
  return #lines == 1 and lines[1] == ''
end

return M
