---- epwalsh/obsidian.nvim
local private = require 'user.private'

vim.o.conceallevel = 1

require('obsidian').setup {
  workspaces = {
    private.obsidian_vault,
  },
  completion = {
    nvim_cmp = true,
    min_chars = 1,
  },
  templates = {
    subdir = 'Meta/Templates',
    date_format = '%Y-%m-%d',
    time_format = '%H:%M',
    substitutions = {},
  },
  daily_notes = {
    folder = 'Journal',
    date_format = '%Y/%Y-%m/%Y-%m-%d',
    template = 'JournalNvim.md',
  },
}

vim.cmd.delcommand 'Rename'
vim.cmd.cabbrev { 'Rename', 'ObsidianRename' }

require('user.mappings').obsidian_on_attach()
