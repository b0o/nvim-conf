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
      'Trouble',
      'aerial',
      'fugitive',
      'fugitiveblame',
      'packer',
      'qf',
      'startify',
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

local vi_mode_hl = function(hl)
  return function()
    local hl = hl
    if hl then
      hl = vim.deepcopy(hl)
    else
      hl = { fg = true }
    end
    if hl.fg == true then
      hl.fg = vi_mode_utils.get_mode_color()
    end
    if hl.bg == true then
      hl.bg = vi_mode_utils.get_mode_color()
    end
    if hl.name == true then
      hl.name = vi_mode_utils.get_mode_highlight_name()
    end
    return hl
  end
end

config.components.active[1] = {
  {
    provider = separators.block .. separators.slant_right .. ' ',
    hl = vi_mode_hl(),
  },
  {
    provider = 'vi_mode',
    hl = vi_mode_hl { fg = true, name = true, style = 'bold' },
  },
  {
    provider = {
      name = 'user_file_info',
      opts = {
        active = true,
        filetypes_hide_name = config.force_inactive.filetypes,
      },
    },
    hl = file_info.hl {
      fg = 'white',
      bg = colors.deep_licorice,
    },
    left_sep = {
      { str = 'slant_left_2', hl = { fg = colors.deep_licorice } },
      { str = ' ', hl = { bg = colors.deep_licorice } },
    },
    right_sep = {
      { str = 'slant_right_2', hl = { fg = colors.deep_licorice } },
    },
  },
  {
    provider = 'file_size',
    enabled = function()
      return fn.getfsize(fn.expand '%:p') > 0
    end,
    left_sep = ' ',
    right_sep = {
      { str = ' ' },
      { str = 'slant_left_2_thin', hl = { fg = 'fg' } },
    },
  },
  {
    provider = 'position',
    left_sep = ' ',
    right_sep = {
      { str = ' ' },
      { str = 'slant_right_2_thin', hl = { fg = 'fg' } },
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
    hl = { fg = 'mistyrose', bold = false },
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
    right_sep = ' ',
    left_sep = ' ',
  },
  {
    provider = 'scroll_bar',
    hl = {
      fg = 'skyblue',
      style = 'bold',
    },
  },
  {
    provider = ' ' .. separators.slant_left .. separators.block,
    hl = vi_mode_hl(),
  },
}

local hl_if_focused = function(hl_if_true, hl_if_false)
  return function(...)
    local cw = vim.api.nvim_get_current_win()
    local acw = tonumber(vim.g.actual_curwin)
    local hl = cw == acw and hl_if_true or hl_if_false
    if type(hl) == 'function' then
      return hl(...)
    end
    return hl
  end
end

config.components.inactive[1] = {
  {
    provider = separators.block .. separators.slant_right .. '  ',
    hl = hl_if_focused(
      vi_mode_hl {
        fg = true,
        bg = colors.active_bg,
      },
      { fg = 'deep_lavender' }
    ),
  },
  {
    provider = {
      name = 'user_file_info',
      opts = {
        active = false,
        filetypes_hide_name = config.force_inactive.filetypes,
      },
    },
    hl = file_info.hl {
      fg = 'white',
      bg = 'deep_lavender',
    },
    left_sep = {
      {
        str = ' ' .. separators.slant_left_2,
        hl = hl_if_focused {
          bg = colors.active_bg,
          fg = 'deep_lavender',
        },
      },
      { str = ' ', hl = { bg = 'deep_lavender', fg = 'NONE' } },
    },
    right_sep = {
      {
        str = separators.slant_right_2 .. ' ',
        hl = hl_if_focused {
          bg = colors.active_bg,
          fg = 'deep_lavender',
        },
      },
    },
  },
}
config.components.inactive[2] = {
  {
    provider = ' ',
    hl = hl_if_focused {
      bg = colors.active_bg,
    },
  },
}

config.components.inactive[3] = {
  {
    provider = ' ' .. separators.slant_left .. separators.block,
    hl = hl_if_focused(
      vi_mode_hl {
        fg = true,
        bg = colors.active_bg,
      },
      {
        fg = 'deep_lavender',
      }
    ),
  },
}

-- Give active components a different default background color
local active_hl = function(hl)
  if hl and (not hl.bg or hl.bg == 'bg') then
    hl.bg = colors.active_bg
  end
  return hl
end
for _, component in ipairs(config.components.active) do
  for _, val in ipairs(component) do
    if not val.hl or type(val.hl) == 'table' then
      val.hl = active_hl(val.hl or {})
    elseif type(val.hl) == 'function' then
      local orig_hl = val.hl
      val.hl = function(...)
        return active_hl(orig_hl(...))
      end
    end
    for _, sep_kind in ipairs { 'left_sep', 'right_sep' } do
      local seps = val[sep_kind]
      if type(seps) == 'string' then
        seps = { str = seps }
        val[sep_kind] = seps
      end
      if type(seps) == 'table' then
        if seps.str or seps.hl then
          seps = { seps }
        end
        for i, sep in ipairs(seps) do
          if type(sep) == 'string' then
            sep = { str = sep }
            seps[i] = sep
          end
          if type(sep) == 'table' and (not sep.hl or type(sep.hl) == 'table') then
            sep.hl = active_hl(sep.hl or {})
          end
        end
      end
    end
  end
end

feline.setup(config)
