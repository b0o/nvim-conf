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

M.update = function()
  local num = vim.v.lnum
  if vim.v.virtnum ~= 0 then
    num = ''
  else
    local focused_winid = vim.api.nvim_get_current_win()
    local winid = vim.g.statusline_winid
    local mode = vim.api.nvim_get_mode().mode:lower()
    if vim.v.relnum ~= 0 and winid == focused_winid and (mode:find 'n' or mode:find 'v') then
      num = vim.v.relnum
      if num % 5 == 0 then
        num = fives(num)
      end
    end
  end
  return [[%s%=]] .. num .. [[%=]]
end

return M
