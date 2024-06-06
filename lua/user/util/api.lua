-- Helpers and utilities for vim.api
local api = vim.api

local M = {}

function M.resolve_bufnr(bufnr)
  return bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()
end

function M.resolve_winnr(winnr)
  return winnr ~= 0 and winnr or vim.api.nvim_get_current_win()
end

function M.resolve_tabnr(tabnr)
  return tabnr ~= 0 and tabnr or vim.api.nvim_get_current_tabpage()
end

function M.win_get_buf_option(win, name)
  win = M.resolve_winnr(win)
  local buf = api.nvim_win_get_buf(win)
  return vim.bo[buf][name]
end

function M.win_get_buf_var(win, name)
  win = M.resolve_winnr(win)
  local buf = api.nvim_win_get_buf(win)
  return api.nvim_buf_get_var(buf, name)
end

function M.win_is_modified(win)
  win = M.resolve_winnr(win)
  return M.win_get_buf_option(win, 'modified')
end

function M.win_is_floating(win)
  win = M.resolve_winnr(win)
  local cfg = vim.api.nvim_win_get_config(win)
  return cfg and cfg.relative and cfg.relative ~= ''
end

function M.tabpage_is_modified(tabpage)
  tabpage = M.resolve_tabnr(tabpage)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if M.win_is_modified(win) then
      return true
    end
  end
  return false
end

function M.tabpage_list_bufs(tabpage)
  tabpage = M.resolve_tabnr(tabpage)
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
  tabpage = M.resolve_tabnr(tabpage)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if M.win_get_buf_option(win, 'buftype') == 'quickfix' then
      return win
    end
  end
end

function M.tabpage_list_modified_bufs(tabpage)
  tabpage = M.resolve_tabnr(tabpage)
  return vim.tbl_filter(function(buf)
    return vim.bo[buf].modified
  end, M.tabpage_list_bufs(tabpage))
end

function M.buf_is_empty(b)
  b = M.resolve_bufnr(b)
  local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
  return #lines == 1 and lines[1] == ''
end

function M.buf_get_wins(b)
  b = M.resolve_bufnr(b)
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == b then
      table.insert(wins, win)
    end
  end
  return wins
end

return M
