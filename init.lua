vim.loader.enable()

require 'user.settings'
require 'user.plugins'

vim.defer_fn(function()
  require 'user.commands'
  require 'user.lsp'
  require 'user.statusline'
  require 'user.completion'
  require 'user.autocmds'
  require 'user.mappings'
  require 'user.plugin'
  require 'user.treesitter'
  require 'user.quickfix'
  vim.cmd [[doautocmd User ConfigLoaded]]
end, 0)
