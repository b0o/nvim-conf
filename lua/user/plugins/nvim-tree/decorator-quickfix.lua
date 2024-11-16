local UserDecorator = require 'nvim-tree.renderer.decorator.user'

---A string with one or more highlight groups applied to it
---@class (exact) HighlightedString
---@field str string
---@field hl string[] highlight groups applied in order

---Quickfix decorator
---@class (exact) DecoratorQuickfix: UserDecorator
---@field private qf_icon HighlightedString
local DecoratorQuickfix = UserDecorator:extend()

local augroup = vim.api.nvim_create_augroup('nvim-tree-decorator-quickfix', { clear = true })

local autocmds_setup = false
local function setup_autocmds()
  if autocmds_setup then
    return
  end
  autocmds_setup = true
  vim.api.nvim_create_autocmd('QuickfixCmdPost', {
    group = augroup,
    callback = function()
      require('nvim-tree.api').tree.reload()
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    group = augroup,
    callback = function(evt)
      vim.api.nvim_create_autocmd('TextChanged', {
        buffer = evt.buf,
        group = augroup,
        callback = function()
          require('nvim-tree.api').tree.reload()
        end,
      })
    end,
  })
end

function DecoratorQuickfix:new()
  DecoratorQuickfix.super.new(self, {
    enabled = true,
    hl_pos = 'name',
    icon_placement = 'signcolumn',
  })
  self.qf_icon = { str = '', hl = { 'QuickFixLine' } }
  self:define_sign(self.qf_icon)
  setup_autocmds()
end

---@param node Node
local function is_qf_item(node)
  if node.name == '..' or node.type == 'directory' then
    return false
  end
  local bufnr = vim.fn.bufnr(node.absolute_path)
  return bufnr ~= -1 and vim.iter(vim.fn.getqflist()):any(function(qf)
    return qf.bufnr == bufnr
  end)
end

---@param node Node
---@return HighlightedString[]|nil icons
---@diagnostic disable-next-line: duplicate-set-field
function DecoratorQuickfix:calculate_icons(node)
  if is_qf_item(node) then
    return { self.qf_icon }
  end
  return nil
end

---@param node Node
---@return string|nil group
---@diagnostic disable-next-line: duplicate-set-field
function DecoratorQuickfix:calculate_highlight(node)
  if is_qf_item(node) then
    return 'QuickFixLine'
  end
  return nil
end

return DecoratorQuickfix
