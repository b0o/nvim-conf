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

-- local gitsigns = require 'gitsigns'
--
-- local M = {}
--
-- local function hw(group, text)
--   return '%#' .. group .. '#' .. text .. '%*'
-- end
--
--
-- -- Example result:
-- -- { {
-- --     added = {
-- --       count = 6,
-- --       lines = { "// foo", "et pool: any | undefined;", "// bar", "// qux", "// lol", "// wut" },
-- --       start = 18
-- --     },
-- --     head = "@@ -18,1 +18,6 @@",
-- --     lines = { "-let pool: any | undefined;", "+// foo", "+et pool: any | undefined;", "+// bar", "+// qux", "+// lol", "+// wut" },
-- --     removed = {
-- --       count = 1,
-- --       lines = { "let pool: any | undefined;" },
-- --       start = 18
-- --     },
-- --     type = "change"
-- --   } }
-- local get_hunks = gitsigns.get_hunks
--
-- M.state = {
--   winid = nil,
--   bufnr = nil,
--   lnum = nil,
--
--   -- gitsigns
--   hunks = {},
--
--   -- bufnr -> { [lnum]: { col, col, .. } }
--   cache = {},
-- }
--
-- M.render = function(winid, bufnr, lnum)
--   _ = { winid, lnum }
--   local res = {
--     git = ' ',
--     num = lnum,
--   }
--   local hunks = M.state.hunks[bufnr]
--   if hunks then
--     for _, hunk in ipairs(hunks) do
--       if lnum >= hunk.added.start and lnum <= hunk.added.start + hunk.added.count then
--         res.git = hw('GitSignsAdd', '│')
--       end
--       if lnum >= hunk.removed.start and lnum <= hunk.removed.start + hunk.removed.count then
--         res.git = hw('GitSignsDelete', '│')
--       end
--     end
--   end
--   return res.num .. ' ' .. res.git
-- end
--
-- M.update = function()
--   if vim.g.statusline_winid == M.state.winid then
--     return M.state.cache[M.state.bufnr][vim.v.lnum]
--   end
--
--   M.state.winid = vim.g.statusline_winid
--   M.state.bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
--   M.state.lnum = nil
--   M.state.hunks[M.state.bufnr] = get_hunks(M.state.bufnr)
--   M.state.cache[M.state.bufnr] = {}
--
--   -- loop over all lines in the buffer and calculate the statusline, then cache it
--   for lnum = 1, vim.api.nvim_buf_line_count(M.state.bufnr) do
--     M.state.cache[M.state.bufnr][lnum] = M.render(M.state.winid, M.state.bufnr, lnum)
--   end
--
--   -- finally, return the statusline for the current line
--   return M.state.cache[M.state.bufnr][vim.v.lnum]
-- end
--
-- return M
