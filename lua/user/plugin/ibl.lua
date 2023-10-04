---- lukas-reineke/indent-blankline.nvim
local fn = require 'user.fn'
require('ibl').setup {
  indent = {
    char = '│',
  },
  scope = {
    show_start = false,
  },
}

fn.tmpl_hi [[
  hi link IblWhitespace Comment
  hi IblIndent guifg=${mid_velvet} gui=nocombine
]]
