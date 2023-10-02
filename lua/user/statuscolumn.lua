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

-- local fives = hw { guifg = colors.bg }
local inactive = hw { guifg = colors.inactive_bg }

local get_num = function(lnum, relnum, virtnum, statusline_winid)
  local num = lnum
  if virtnum ~= 0 then
    return ''
  end

  ---@diagnostic disable-next-line: redundant-parameter
  if not vim.api.nvim_win_get_option(statusline_winid, 'number') then
    return ''
  end

  if statusline_winid ~= vim.api.nvim_get_current_win() then
    if relnum ~= 0 then
      num = inactive(num)
    end
    return num
  end

  local mode = vim.api.nvim_get_mode().mode:lower()
  if relnum ~= 0 then
    if mode:find 'n' or mode:find 'v' then
      ---@diagnostic disable-next-line: redundant-parameter
      if vim.api.nvim_win_get_option(statusline_winid, 'relativenumber') then
        num = relnum
      end
      -- num = relnum % 5 == 0 and fives(num) or inactive(num)
      num = inactive(num)
    else
      num = inactive(num)
    end
  end

  return num
end

M.render = function()
  return [[%s%=]] .. get_num(vim.v.lnum, vim.v.relnum, vim.v.virtnum, vim.g.statusline_winid) .. [[%= ]]
end

return M
