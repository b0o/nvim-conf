---- stevearc/oil.nvim
local oil = require 'oil'

oil.setup {
  view_options = {
    show_hidden = true,
  },
  float = {
    padding = 2,
    max_width = 100,
    max_height = 40,
    override = function(conf)
      return vim.tbl_deep_extend('force', conf, {
        zindex = 80,
      })
    end,
  },
  skip_confirm_for_simple_edits = true,
  keymaps = {
    ['<M-u>'] = 'actions.parent',
    ['<M-i>'] = 'actions.select',
    ['<C-v>'] = 'actions.select_vsplit',
    ['<C-x>'] = 'actions.select_split',
  },
}
