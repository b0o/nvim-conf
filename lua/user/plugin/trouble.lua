---- folke/trouble.nvim
local M = {}
require('trouble').setup {
  auto_open = true,
  auto_close = true,
}

-- Prevent Trouble.nvim from automatically opening/closing during Insert mode
local state

function M.disableAutoOpenClose()
  local troubleOpts = require('trouble.config').options
  state = {
    auto_open = troubleOpts.auto_open,
    auto_close = troubleOpts.auto_close,
  }
  troubleOpts.auto_open = false
  troubleOpts.auto_close = false
end

function M.restoreAutoOpenClose()
  if state == nil then
    return
  end
  local troubleOpts = require('trouble.config').options
  troubleOpts.auto_open = state.auto_open
  troubleOpts.auto_close = state.auto_close
  state = nil
  require('trouble').refresh { auto = true, provider = 'diagnostics' }
end

vim.cmd [[
  augroup user_trouble
    autocmd!
    autocmd InsertEnter * lua require'user.plugin.trouble'.disableAutoOpenClose()
    autocmd InsertLeave * lua require'user.plugin.trouble'.restoreAutoOpenClose()
  augroup END
]]

return M
