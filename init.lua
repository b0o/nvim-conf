vim.loader.enable()

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

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
