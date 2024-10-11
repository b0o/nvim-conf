-- Important: Put this in your config directory at lua/nvim-tree/renderer/decorator/bookmarks.lua
--
-- HACK: Although this file is named bookmarks.lua, it is actually a decorator
-- for the quickfix list. Because nvim-tree does not provide a way to add a custom decorator,
-- we are overriding the built-in bookmarks decorator with our own quickfix list decorator.
-- If you don't want to override the bookmarks.lua decorator, you can override a different one.
-- TODO: Upgrade to official nvim-tree decorator API once it's released:
-- https://github.com/nvim-tree/nvim-tree.lua/issues/2948

local HL_POSITION = require('nvim-tree.enum').HL_POSITION
local ICON_PLACEMENT = require('nvim-tree.enum').ICON_PLACEMENT

local Decorator = require 'nvim-tree.renderer.decorator'

---@class (exact) DecoratorQuickfix: Decorator
---@field icon HighlightedString?
local DecoratorQuickfix = Decorator:new()

local augroup = vim.api.nvim_create_augroup('nvim-tree-decorator-quickfix', { clear = true })

---@param opts table
---@param explorer Explorer
---@return DecoratorQuickfix
function DecoratorQuickfix:create(opts, explorer)
  local o = Decorator.new(self, {
    explorer = explorer,
    enabled = true,
    hl_pos = HL_POSITION[opts.renderer.highlight_bookmarks] or HL_POSITION.none,
    icon_placement = ICON_PLACEMENT[opts.renderer.icons.bookmarks_placement] or ICON_PLACEMENT.none,
  })
  o = self:new(o) --[[@as DecoratorQuickfix]]
  o.icon = {
    str = '',
    hl = { 'QuickFixLine' },
  }
  o:define_sign(o.icon)
  vim.api.nvim_create_autocmd('QuickfixCmdPost', {
    group = augroup,
    callback = function()
      explorer.renderer:draw()
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
          explorer.renderer:draw()
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
  if is_qf_item(node) then
    return { self.icon }
  end
end

---@param node Node
---@return string|nil group
function DecoratorQuickfix:calculate_highlight(node)
  if is_qf_item(node) then
    return 'QuickFixLine'
  end
end

return DecoratorQuickfix
