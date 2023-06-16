---- rcarriga/neotest
require('neotest').setup {
  adapters = {
    require 'neotest-vitest',
  },
  quickfix = {
    enabled = false,
    open = false,
  },
}
