---- nvim-neotest/neotest
require('neotest').setup {
  adapters = {
    require 'neotest-vitest',
  },
  quickfix = {
    enabled = false,
    open = false,
  },
  summary = {
    open = [[botright vsplit +set\ nowrap | vertical resize 50]],
  },
  icons = {
    running_animated = {
      '⠋',
      '⠙',
      '⠹',
      '⠸',
      '⠼',
      '⠴',
      '⠦',
      '⠧',
      '⠇',
      '⠏',
    },
  },
}
