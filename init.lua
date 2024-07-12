vim.loader.enable()

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require 'user.util.polyfill' -- TODO: Remove once all plugins have migrated away from deprecated APIs

local lazyutil = require 'user.util.lazy'
_G.lazy_require = lazyutil.require
_G.very_lazy = lazyutil.very_lazy

require 'user.settings'
require 'user.commands'

require('lazy').setup({
  import = 'user.plugins',
}, {
  defaults = { lazy = true },
  ui = { border = 'rounded' },
  dev = {
    path = vim.env.GIT_PROJECTS_DIR .. '/nvim',
    fallback = true,
  },
  change_detection = {
    enabled = false,
  },
})

very_lazy(function()
  require 'user.mappings'
  require 'user.autocmds'
  require('user.fn').silent(require('user.util.auto-resize').enable)
end)
