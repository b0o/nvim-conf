---- folke/trouble.nvim
local fn = require 'user.fn'
local trouble = require 'trouble'
local tconf = require 'trouble.config'

trouble.setup {
  auto_open = true,
  auto_close = true,
  auto_preview = false,
  use_diagnostic_signs = true,
}

local state = {}

-- Prevent Trouble.nvim from automatically opening/closing during Insert mode
local function disable_auto_open_close()
  if not fn.is_normal_win(0) then
    return
  end
  local troubleOpts = tconf.options
  state.auto_open_close = {
    auto_open = troubleOpts.auto_open,
    auto_close = troubleOpts.auto_close,
  }
  troubleOpts.auto_open = false
  troubleOpts.auto_close = false
end

local function restore_auto_open_close()
  if not state.auto_open_close or not fn.is_normal_win(0) then
    return
  end
  local troubleOpts = tconf.options
  troubleOpts.auto_open = state.auto_open_close.auto_open
  troubleOpts.auto_close = state.auto_open_close.auto_close
  state.auto_open_close = nil
  trouble.refresh { auto = true, provider = 'diagnostics' }
end

local augid = vim.api.nvim_create_augroup('user_trouble', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', { group = augid, callback = disable_auto_open_close })
vim.api.nvim_create_autocmd('InsertLeave', { group = augid, callback = restore_auto_open_close })

trouble.refresh { auto = true, provider = 'diagnostics' }
