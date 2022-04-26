-- XXX: impatient.nvim will only be required until https://github.com/neovim/neovim/pull/15436 is merged
if not pcall(require, 'impatient') then
  -- if unable to load impatient.nvim, try loading user.packer to see if
  -- packer needs to be installed
  if not pcall(require, 'user.packer') then
    print 'failed to load impatient.nvim and user.packer'
    return
  end
end

require 'user.settings'
require 'user.statusline'
require 'user.lsp'
require 'user.commands'

vim.defer_fn(function()
  require 'user.autocmds'
  require 'user.mappings'
  require 'user.plugins'
  require 'user.plugin'
  require 'user.completion'
  require 'user.treesitter'
  require 'user.quickfix'
end, 0)
