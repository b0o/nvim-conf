local overseer = require 'overseer'

overseer.setup {
  strategy = {
    'jobstart',
    preserve_output = true,
    use_terminal = true,
  },
  task_list = {
    direction = 'bottom',
    max_height = { 30, 0.3 },
    min_height = { 15, 0.2 },
    bindings = {
      ['<C-s>'] = false,
      ['<C-x>'] = 'OpenSplit',
    },
  },
}
