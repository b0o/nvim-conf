local M = {}

M.start = function()
  local c = require 'supermaven-nvim.completion_preview'
  local xk = require('user.keys').xk

  require('supermaven-nvim').setup {
    disable_keymaps = true,
  }

  vim.keymap.set('i', xk [[<C-\>]], c.on_accept_suggestion, { silent = true })
  vim.keymap.set('i', [[<M-\>]], c.on_accept_suggestion_word, { silent = true })
end

M.stop = function()
  local xk = require('user.keys').xk

  vim.keymap.del('i', xk [[<C-\>]])
  vim.keymap.del('i', [[<M-\>]])

  require('supermaven-nvim.api').stop()
end

return M
