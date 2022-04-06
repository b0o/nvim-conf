---- stevearc/aerial.nvim
local fn = require 'user.fn'

-- SEE: https://github.com/stevearc/aerial.nvim/issues/78
require('aerial').setup {
  backends = {
    _ = { 'lsp', 'treesitter', 'markdown' },
    rescript = { 'treesitter' },
  },
  close_behavior = 'global',
  default_direction = 'right',
  disable_max_lines = 3000,
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
  min_width = 30,
  placement_editor_edge = true,
  update_events = 'TextChanged,InsertLeave',
  lsp = {
    diagnostics_trigger_update = false,
    update_when_errors = false,
  },
}

local treesitter_langs = require 'aerial.backends.treesitter.language_kind_map'

-- SEE: queries/rescript/aerial.scm
treesitter_langs.rescript = {
  ['function'] = 'Function',
  module_declaration = 'Module',
  type_declaration = 'Type',
  type_annotation = 'Interface',
  external_declaration = 'Interface',
}

fn.tmpl_hi [[
  hi AerialLine    guibg=${lavender}
  hi AerialLineNC  guibg=${deep_anise}
]]
