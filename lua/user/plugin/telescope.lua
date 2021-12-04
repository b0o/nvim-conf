---- nvim-telescope/telescope.nvim
local telescope = require 'telescope'

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-d>'] = false,
        ['<C-u>'] = false,
        ['<M-n>'] = require('telescope.actions').cycle_history_next,
        ['<M-p>'] = require('telescope.actions').cycle_history_next,
      },
    },
  },
}

telescope.load_extension 'sessions'
telescope.load_extension 'windows'
