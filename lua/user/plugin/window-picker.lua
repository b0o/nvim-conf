---- s1n7ax/nvim-window-picker

local colors = require 'user.colors'

require('window-picker').setup {
  autoselect_one = true,
  include_current = false,
  filter_rules = {
    -- filter using buffer options
    bo = {
      -- if the file type is one of following, the window will be ignored
      filetype = { 'neo-tree', 'neo-tree-popup', 'notify', 'incline' },

      -- if the buffer type is one of following, the window will be ignored
      buftype = { 'terminal', 'quickfix' },
    },
  },
  other_win_hl_color = colors.deep_anise,
  fg_color = colors.hydrangea,
}
