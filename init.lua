-- XXX: impatient.nvim will only be required until https://github.com/neovim/neovim/pull/15436 is merged
if not pcall(require, 'impatient') then
  -- if unable to load impatient.nvim, try loading user.packer to see if
  -- packer needs to be installed
  local ok, user_packer = pcall(require, 'user.packer')
  if not ok then
    print 'failed to load impatient.nvim and user.packer'
    return
  end
  print 'Bootstrapping configuration...'
  user_packer.install_or_sync()
  return
end

require 'user.settings'

vim.defer_fn(function()
  require 'user.commands'
  require 'user.lsp'
  require 'user.statusline'
  require 'user.completion'
  require 'user.autocmds'
  require 'user.mappings'
  require 'user.plugins'
  require 'user.plugin'
  require 'user.treesitter'
  require 'user.quickfix'
end, 0)
