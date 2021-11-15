local feline = require 'feline'
local lsp = require 'feline.providers.lsp'
local vi_mode_utils = require 'feline.providers.vi_mode'
local defaults = require 'feline.defaults'

require 'user.statusline.lsp'
require 'user.statusline.dap'

local g = vim.g
local fn = vim.fn

local colors_gui = g.colors_gui or {}

local colors = {
  bg = colors_gui['0'] or defaults.bg,
  black = colors_gui['1'] or defaults.black,
  skyblue = colors_gui['7'] or defaults.skyblue,
  cyan = colors_gui['8'] or defaults.cyan,
  fg = colors_gui['4'] or defaults.fg,
  green = colors_gui['14'] or defaults.green,
  oceanblue = colors_gui['9'] or defaults.oceanblue,
  magenta = colors_gui['15'] or defaults.magenta,
  orange = colors_gui['17'] or defaults.orange,
  red = colors_gui['12'] or defaults.red,
  violet = colors_gui['10'] or defaults.violet,
  white = colors_gui['5'] or defaults.white,
  yellow = colors_gui['13'] or defaults.yellow,

  butter = '#fffacf',
  milk = '#fdf6e3',
  cream = '#e6dac3',
  cashew = '#CEB999',
  almond = '#a6875a',
  cocoa = '#3b290e',

  licorice = '#483270',
  lavender = '#d7b0ff',
  velvet = '#d7cfe6',
  anise = '#C5A7FF',
  hydrangea = '#ca7fff',
  blush = '#F6D7FF',
  powder = '#e9d9ee',

  evergreen = '#9fdfb4',

  snow = '#e4fffe',
  ice = '#a4e2e0',
  mint = '#a2e0ca',

  nectar = '#f0f070',
  cayenne = '#ff7a75',
  yam = '#e86f54',
  pumpkin = '#ff9969',
  rose = '#b32e29',

  grey2 = '#222222',
  grey5 = '#777777',
  grey6 = '#aaaaaa',
  grey7 = '#cccccc',
  grey8 = '#dddddd',

  deep_lavender = '#705987',
}

local separators = {
  vertical_bar = '┃',
  vertical_bar_thin = '│',
  left = '',
  right = '',
  block = '█',
  left_filled = '',
  right_filled = '',
  slant_left = '',
  slant_left_thin = '',
  slant_right = '',
  slant_right_thin = '',
  slant_left_2 = '',
  slant_left_2_thin = '',
  slant_right_2 = '',
  slant_right_2_thin = '',
  left_rounded = '',
  left_rounded_thin = '',
  right_rounded = '',
  right_rounded_thin = '',
  circle = '●',
}

local vi_mode_colors = {
  ['NORMAL'] = colors.green,
  ['OP'] = colors.green,
  ['INSERT'] = colors.red,
  ['VISUAL'] = colors.skyblue,
  ['LINES'] = colors.skyblue,
  ['BLOCK'] = colors.skyblue,
  ['REPLACE'] = colors.violet,
  ['V-REPLACE'] = colors.violet,
  ['ENTER'] = colors.cyan,
  ['MORE'] = colors.cyan,
  ['SELECT'] = colors.orange,
  ['COMMAND'] = colors.green,
  ['SHELL'] = colors.green,
  ['TERM'] = colors.green,
  ['NONE'] = colors.yellow,
}

local config = {
  preset = 'default',

  colors = colors,
  separators = separators,

  vi_mode_colors = vi_mode_colors,

  force_inactive = {
    filetypes = {
      'NvimTree',
      'packer',
      'startify',
      'fugitive',
      'fugitiveblame',
      'qf',
    },
    buftypes = {
      'terminal',
    },
    bufnames = {},
  },

  components = {
    active = {},
    inactive = {},
  },

  custom_providers = require('user.statusline.providers').providers,
}

config.components.active[1] = {
  {
    provider = '▊ ',
    hl = { fg = 'skyblue' },
  },
  {
    provider = 'vi_mode',
    hl = function()
      return {
        name = vi_mode_utils.get_mode_highlight_name(),
        fg = vi_mode_utils.get_mode_color(),
        style = 'bold',
      }
    end,
    right_sep = ' ',
  },
  --   {
  --     provider = require'mapx'.getMode,
  --     hl = { fg = white, style = 'bold' },
  --     left_sep = ' ',
  --     right_sep = ' ',
  --   },
  {
    provider = 'file_info',
    hl = {
      fg = 'white',
      bg = 'violet',
      style = 'bold',
    },
    left_sep = {
      ' ',
      'slant_left_2',
      { str = ' ', hl = { bg = 'violet', fg = 'NONE' } },
    },
    right_sep = { 'slant_right_2', ' ' },
  },
  {
    provider = 'file_size',
    enabled = function()
      return fn.getfsize(fn.expand '%:p') > 0
    end,
    right_sep = {
      ' ',
      { str = 'slant_left_2_thin', hl = { fg = 'fg', bg = 'bg' } },
    },
  },
  {
    provider = 'position',
    left_sep = ' ',
    right_sep = {
      ' ',
      { str = 'slant_right_2_thin', hl = { fg = 'fg', bg = 'bg' } },
    },
  },
  {
    provider = 'diagnostic_errors',
    enabled = function()
      return lsp.diagnostics_exist 'Error'
    end,
    hl = { fg = 'red' },
  },
  {
    provider = 'diagnostic_warnings',
    enabled = function()
      return lsp.diagnostics_exist 'Warning'
    end,
    hl = { fg = 'yellow' },
  },
  {
    provider = 'diagnostic_hints',
    enabled = function()
      return lsp.diagnostics_exist 'Hint'
    end,
    hl = { fg = 'cyan' },
  },
  {
    provider = 'diagnostic_info',
    enabled = function()
      return lsp.diagnostics_exist 'Information'
    end,
    hl = { fg = 'skyblue' },
  },
}

config.components.active[2] = {
  {
    provider = 'lsp_progress',
    hl = { fg = 'blush', bold = false },
  },
}

config.components.active[3] = {
  {
    provider = 'dap_clients',
    hl = { fg = 'green' },
    right_sep = ' ',
  },
  {
    provider = 'lsp_clients_running',
    hl = { fg = 'green' },
    right_sep = ' ',
  },
  {
    provider = 'lsp_clients_starting',
    hl = { fg = 'skyblue' },
    right_sep = ' ',
  },
  {
    provider = 'lsp_clients_exited_ok',
    hl = { fg = 'grey6' },
    right_sep = ' ',
  },
  {
    provider = 'lsp_clients_exited_err',
    hl = { fg = 'red' },
    right_sep = ' ',
  },
  {
    provider = 'git_branch',
    hl = {
      fg = 'white',
      style = 'bold',
    },
    right_sep = ' ',
    left_sep = ' ',
  },
  {
    provider = 'git_diff_added',
    hl = {
      fg = 'green',
    },
  },
  {
    provider = 'git_diff_changed',
    hl = {
      fg = 'orange',
    },
  },
  {
    provider = 'git_diff_removed',
    hl = {
      fg = 'red',
    },
    right_sep = ' ',
  },
  {
    provider = 'line_percentage',
    hl = {
      style = 'bold',
    },
    left_sep = ' ',
    right_sep = ' ',
  },
  {
    provider = 'scroll_bar',
    hl = {
      fg = 'skyblue',
      style = 'bold',
    },
  },
}

config.components.inactive[1] = {
  {
    provider = '▊   ',
    hl = {
      fg = 'deep_lavender',
    },
  },
  {
    provider = 'file_info',
    hl = {
      fg = 'white',
      bg = 'deep_lavender',
    },
    left_sep = {
      ' ',
      'slant_left_2',
      { str = ' ', hl = { bg = 'deep_lavender', fg = 'NONE' } },
    },
    right_sep = { 'slant_right_2', ' ' },
  },
}

feline.setup(config)
