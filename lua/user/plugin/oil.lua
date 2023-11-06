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
  },
}
