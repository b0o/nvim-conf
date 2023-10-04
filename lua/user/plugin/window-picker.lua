---- s1n7ax/nvim-window-picker

local colors = require 'user.colors'

require('window-picker').setup {
  hint = 'floating-big-letter',
  filter_rules = {
    autoselect_one = false,
    -- filter using buffer options
    bo = {
      -- if the file type is one of following, the window will be ignored
      filetype = { 'neo-tree', 'neo-tree-popup', 'notify', 'incline' },

      -- if the buffer type is one of following, the window will be ignored
      buftype = { 'terminal', 'quickfix' },
    },
  },
  -- other_win_hl_color = colors.deep_anise,
  fg_color = colors.hydrangea,
  show_prompt = false,
}
