---- Auto-resize
local fn = require 'user.fn'

local M = { enabled = false }

M.disable = function()
  local msg = fn.capture(fn.set_winfix, true, 'width', 'height')
  table.insert(msg, 'auto-resize disable')
  fn.notify(table.concat(msg, ', '))
  vim.cmd [[
    augroup auto_resize
      au!
    augroup END
    augroup! auto_resize
  ]]
  M.enabled = false
end

M.trigger = function()
  if M.enabled then
    vim.cmd 'wincmd ='
  end
end

M.enable = function()
  local msg = fn.capture(fn.set_winfix, false, 'width', 'height')
  table.insert(msg, 'auto-resize enable')
  fn.notify(table.concat(msg, ', '))
  vim.cmd [[
    augroup auto_resize
      au!
      au VimResized,WinNew,WinClosed * wincmd =
    augroup END
  ]]
  vim.cmd 'wincmd ='
  M.enabled = true
end

M.toggle = function()
  if M.enabled then
    M.enable()
  else
    M.disable()
  end
end

return M
