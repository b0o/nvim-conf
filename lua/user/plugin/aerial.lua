---- stevearc/aerial.nvim
require('aerial').setup {
  backends = { 'treesitter', 'lsp', 'markdown', 'man' },
  attach_mode = 'global',
  disable_max_lines = 5000,
  filter_kind = {
    'Class',
    'Constructor',
    'Enum',
    'Function',
    'Interface',
    'Module',
    'Method',
    'Struct',
    'Type',
  },
  highlight_on_hover = true,
  ignore = { filetypes = { 'gomod' } },
  layout = {
    min_width = 30,
    default_direction = 'right',
    placement = 'edge',
  },
  update_events = 'TextChanged,InsertLeave',
  lsp = {
    update_when_errors = true,
    -- diagnostics_trigger_update = false,
    update_delay = 500,
  },
  treesitter = {
    update_delay = 500,
  },
  markdown = {
    update_delay = 500,
  },
  keymaps = {
    ['?'] = false,
  },
}
