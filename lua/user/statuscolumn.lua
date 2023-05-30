local colors = require 'user.colors'
local highlight = require 'user.util.highlight'

local M = {}

local function hw(hl, text)
  local group = highlight.register(hl)
  local cb = function(inner_text)
    return '%#' .. group .. '#' .. inner_text .. '%*'
  end
  if text == nil then
    return cb
  end
  return cb(text)
end

local fives = hw { guifg = colors.light_lavender }

local get_num = function(lnum, relnum, virtnum, statusline_winid)
  local num = lnum
  if virtnum ~= 0 then
    return ''
  end

  local focused_winid = vim.api.nvim_get_current_win()

  ---@diagnostic disable-next-line: redundant-parameter
  if not vim.api.nvim_win_get_option(statusline_winid, 'number') then
    return ''
  end

  local mode = vim.api.nvim_get_mode().mode:lower()
  if relnum ~= 0 and statusline_winid == focused_winid and (mode:find 'n' or mode:find 'v') then
    ---@diagnostic disable-next-line: redundant-parameter
    if vim.api.nvim_win_get_option(statusline_winid, 'relativenumber') then
      num = relnum
    end
    if relnum % 5 == 0 then
      num = fives(num)
    end
  end

  return num
end

M.render = function()
  return [[%s%=]] .. get_num(vim.v.lnum, vim.v.relnum, vim.v.virtnum, vim.g.statusline_winid) .. [[%=]]
end

return M
