-- XXX: impatient.nvim will only be required until https://github.com/neovim/neovim/pull/15436 is merged
if not pcall(require, 'impatient') then
  print 'failed to load impatient.nvim'
end

require 'user.settings'
require 'user.fn'
require 'user.plugins'
require 'user.plugins.plugins'
require 'user.mappings'
require 'user.autocmds'
require 'user.statusline'
require 'user.lsp'
require 'user.completion'
require 'user.treesitter'
