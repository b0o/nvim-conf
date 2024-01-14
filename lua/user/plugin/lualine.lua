local lavi = require 'lavi.palette'

local b = { bg = lavi.bg_bright.hex, fg = lavi.bg.lighten(80).hex }
local c = { bg = lavi.bg.hex, fg = lavi.bg.lighten(70).hex }

local lavi_theme = {
  normal = { a = { bg = lavi.bg_bright.lighten(30).hex, fg = lavi.white_bright.hex, gui = 'bold' }, b = b, c = c },
  insert = { a = { bg = lavi.violet.hex, fg = lavi.white_bright.hex, gui = 'bold' }, b = b, c = c },
  visual = { a = { bg = lavi.pumpkin.hex, fg = lavi.white_bright.hex, gui = 'bold' }, b = b, c = c },
  replace = { a = { bg = lavi.red_bright.hex, fg = lavi.white_bright.hex, gui = 'bold' }, b = b, c = c },
  command = { a = { bg = lavi.blue.hex, fg = lavi.white_bright.hex, gui = 'bold' }, b = b, c = c },
  inactive = { a = { bg = lavi.bg.hex, fg = lavi.white_bright.hex, gui = 'bold' }, b = b, c = c },
}

local function pnpm_workspace()
  local focused_path = vim.api.nvim_buf_get_name(0)
  if focused_path == '' then
    return ''
  end
  local workspace_info = require('user.util.pnpm').get_workspace_info {
    focused_path = focused_path,
  }
  if not workspace_info then
    return ''
  end
  if workspace_info.focused then
    return workspace_info.focused.name or workspace_info.focused.relative_path or ''
  end
  if workspace_info.root then
    return workspace_info.root.name or ''
  end
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = lavi_theme,
    component_separators = { left = '', right = '' },
    section_separators = { left = ' ', right = ' ' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = true,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { {
      'mode',
      fmt = function(str)
        return str:sub(1, 1)
      end,
    } },
    lualine_b = {
      'branch',
      pnpm_workspace,
      'diff',
      'diagnostics',
    },
    lualine_c = {
      { 'filename', path = 1, symbols = { modified = '*' } },
    },
    lualine_x = { 'filetype', 'progress' },
    lualine_y = { 'overseer' },
    lualine_z = { 'location' },
  },
  extensions = {
    'aerial',
    'lazy',
    'man',
    'neo-tree',
    'nvim-tree',
    'oil',
    'overseer',
    'quickfix',
    'toggleterm',
    'trouble',
  },
}
