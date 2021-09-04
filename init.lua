-- XXX: impatient.nvim will only be required until https://github.com/neovim/neovim/pull/15436 is merged
if not pcall(function() require('impatient') end) then
  print('failed to load impatient.nvim')
end

require 'user.settings'
require 'user.plugins'
require 'user.mappings'
require 'user.autocmds'

-- require('auto')
-- require('interface')
