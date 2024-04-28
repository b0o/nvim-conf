local overseer = require 'overseer'

overseer.setup {
  strategy = {
    'jobstart',
    preserve_output = true,
    use_terminal = true,
  },
  component_aliases = {
    default = {
      { 'display_duration', detail_level = 2 },
      'on_output_summarize',
      'on_exit_set_status',
      'on_complete_notify',
      -- "on_complete_dispose", -- disabled to keep tasks until manually disposed
    },
  },
  task_list = {
    direction = 'bottom',
    max_width = { 180, 0.4 },
    min_width = { 40, 0.1 },
    max_height = { 40, 0.5 },
    min_height = { 15, 0.2 },
    bindings = {
      ['<C-s>'] = false,
      ['<C-x>'] = 'OpenSplit',
      ['<C-r>'] = '<CMD>OverseerQuickAction restart<CR>',
      ['<C-d>'] = '<CMD>OverseerQuickAction dispose<CR>',
    },
  },
}
