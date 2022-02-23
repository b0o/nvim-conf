local feline = require 'feline'
local lsp = require 'feline.providers.lsp'
local vi_mode_utils = require 'feline.providers.vi_mode'

local colors = require 'user.colors'
local file_info = require 'user.statusline.file_info'

require 'user.statusline.lsp'
require 'user.statusline.dap'


local fn = vim.fn

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
  moon = '',
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

  theme = colors,
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
    provider = {
      name = 'user_file_info',
      opts = {
        active = true,
      },
    },
    hl = file_info.hl({
        fg = 'white',
        bg = colors.deep_licorice,
    }),
    left_sep = {
      ' ',
      'slant_left_2',
      { str = ' ', hl = { bg = colors.deep_licorice, fg = 'NONE' } },
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
      return lsp.diagnostics_exist(vim.diagnostic.severity.ERROR)
    end,
    hl = { fg = 'red' },
  },
  {
    provider = 'diagnostic_warnings',
    enabled = function()
      return lsp.diagnostics_exist(vim.diagnostic.severity.WARN)
    end,
    hl = { fg = 'yellow' },
  },
  {
    provider = 'diagnostic_hints',
    enabled = function()
      return lsp.diagnostics_exist(vim.diagnostic.severity.HINT)
    end,
    hl = { fg = 'cyan' },
  },
  {
    provider = 'diagnostic_info',
    enabled = function()
      return lsp.diagnostics_exist(vim.diagnostic.severity.INFO)
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
    provider = {
      name = 'user_file_info',
      opts = {
        active = false,
      },
    },
    hl = file_info.hl({
        fg = 'white',
        bg = 'deep_lavender',
    }),
    -- hl = function()
    --   return {
    --     fg = 'white',
    --     bg = 'deep_lavender',
    --     style = vim.api.nvim_buf_get_option(0, 'modified') and 'italic' or 'bold',
    --   }
    -- end,
    left_sep = {
      ' ',
      'slant_left_2',
      { str = ' ', hl = { bg = 'deep_lavender', fg = 'NONE' } },
    },
    right_sep = { 'slant_right_2', ' ' },
  },
}

feline.setup(config)
