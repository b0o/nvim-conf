---- stevearc/aerial.nvim
local fn = require 'user.fn'

local update_delay = 500

require('aerial').setup {
  backends = { 'lsp', 'treesitter', 'markdown' },
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
    update_when_errors = true,
    diagnostics_trigger_update = true,
    update_delay = update_delay,
  },
  treesitter = {
    update_delay = update_delay,
  },
  markdown = {
    update_delay = update_delay,
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
