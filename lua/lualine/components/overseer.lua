-- Based on https://github.com/stevearc/overseer.nvim/blob/68a2d344cea4a2e11acfb5690dc8ecd1a1ec0ce0/lua/lualine/components/overseer.lua
-- Modified to not trigger lazy.nvim to load overseer until it's actually used.
local require_on_call_rec = require('user.util.lazy').require_on_call_rec

local M = require('lualine.component'):extend()

local task_list = require_on_call_rec 'overseer.task_list'
local util = require_on_call_rec 'overseer.util'
local utils = require_on_call_rec 'lualine.utils.utils'

local STATUS = {
  'FAILURE',
  'CANCELED',
  'SUCCESS',
  'RUNNING',
}

function M:init(options)
  M.super.init(self, options)
  self.options.label = self.options.label or ''
  if self.options.colored == nil then
    self.options.colored = true
  end
  self.symbols = {
    ['FAILURE'] = '󰅚',
    ['CANCELED'] = '',
    ['SUCCESS'] = '󰄴',
    ['RUNNING'] = '󰑮',
  }
end

function M:update_colors()
  self.highlight_groups = {}
  for _, status in ipairs(STATUS) do
    local hl = string.format('Overseer%s', status)
    local color = { fg = utils.extract_color_from_hllist('fg', { hl }) }
    self.highlight_groups[status] = self:create_hl(color, status)
  end
end

function M:update_status()
  if not package.loaded['overseer'] then
    return ''
  end
  if self.options.colored and not self.highlight_groups then
    self:update_colors()
  end
  local tasks = task_list.list_tasks(self.options)
  local tasks_by_status = util.tbl_group_by(tasks, 'status')
  local pieces = {}
  if self.options.label ~= '' then
    table.insert(pieces, self.options.label)
  end
  for _, status in ipairs(STATUS) do
    local status_tasks = tasks_by_status[status]
    if self.symbols[status] and status_tasks then
      if self.options.colored then
        local hl_start = self:format_hl(self.highlight_groups[status])
        table.insert(pieces, string.format(' %s%s %s', hl_start, self.symbols[status], #status_tasks))
      else
        table.insert(pieces, string.format(' %s %s', self.symbols[status], #status_tasks))
      end
    end
  end
  if #pieces > 0 then
    return table.concat(pieces, ' ')
  end
end

return M
