-- Important: Put this in your config directory at lua/nvim-tree/renderer/decorator/bookmarks.lua
--
-- HACK: Although this file is named bookmarks.lua, it is actually a decorator
-- for the quickfix list. Because nvim-tree does not provide a way to add a custom decorator,
-- we are overriding the built-in bookmarks decorator with our own quickfix list decorator.
-- If you don't want to override the bookmarks.lua decorator, you can override a different one.

local HL_POSITION = require('nvim-tree.enum').HL_POSITION
local ICON_PLACEMENT = require('nvim-tree.enum').ICON_PLACEMENT

local Decorator = require 'nvim-tree.renderer.decorator'

---@class DecoratorQuickfix: Decorator
---@field icon HighlightedString|nil
local DecoratorQuickfix = Decorator:new()

local autgroup = vim.api.nvim_create_augroup('nvim-tree-decorator-quickfix', { clear = true })

---@return DecoratorQuickfix
function DecoratorQuickfix:new()
  local o = Decorator.new(self, {
    enabled = true,
    hl_pos = HL_POSITION.all,
    icon_placement = ICON_PLACEMENT.signcolumn,
  })
  ---@cast o DecoratorQuickfix
  if not o.enabled then
    return o
  end
  o.icon = {
    str = '',
    hl = { 'QuickFixLine' },
  }
  o:define_sign(o.icon)

  vim.api.nvim_create_autocmd('QuickfixCmdPost', {
    group = autgroup,
    callback = function()
      require('nvim-tree.renderer').draw()
    end,
  })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    group = autgroup,
    callback = function(evt)
      vim.api.nvim_create_autocmd('TextChanged', {
        buffer = evt.buf,
        group = autgroup,
        callback = function()
          require('nvim-tree.renderer').draw()
        end,
      })
    end,
  })

  return o
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
function DecoratorQuickfix:calculate_icons(node)
  if not self.enabled or not is_qf_item(node) then
    return nil
  end
  return { self.icon }
end

---Modified highlight: modified.enable, renderer.highlight_modified and node is modified
---@param node Node
---@return string|nil group
function DecoratorQuickfix:calculate_highlight(node)
  if not self.enabled or self.hl_pos == HL_POSITION.none or not is_qf_item(node) then
    return nil
  end
  return 'QuickFixLine'
end

return DecoratorQuickfix
