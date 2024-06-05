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
    only_cached = true,
  }
  if not workspace_info then
    return ''
  end
  if workspace_info.focused then
    local display = workspace_info.focused.name or workspace_info.focused.relative_path
    if display then
      return '󰏗 ' .. display
    end
    return ''
  end
  if workspace_info.root then
    return workspace_info.root.name or ''
  end
  return ''
end

local theme = ({
  lavi = lavi_theme,
  tokyonight = 'tokyonight',
})[vim.env.COLORSCHEME] or lavi_theme

if type(theme) == 'string' then
  theme = require('lualine.themes.' .. theme)
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = theme,
    component_separators = { left = '', right = '' },
    section_separators = { left = ' ', right = ' ' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    refresh = {
      statusline = 1000,
    },
  },
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(str)
          return str:sub(1, 1)
        end,
      },
    },
    lualine_b = {
      'branch',
      pnpm_workspace,
      'diff',
      'diagnostics',
    },
    lualine_c = {
      'aerial',
    },
    lualine_x = {
      {
        'tabs',
        tab_max_length = 40,
        max_length = vim.o.columns / 4,
        mode = 1,
        show_modified_status = false,
        tabs_color = {
          active = theme.normal.a,
          inactive = theme.inactive.c,
        },
        section_separators = {
          left = '',
          right = '',
        },
        padding = 1,
        fmt = function(_, context)
          local tabpage = context.tabId
          local buf = require('user.util.tabs').get_most_recent_buf(tabpage)
          local mod = vim
            .iter(vim.api.nvim_tabpage_list_wins(tabpage))
            :map(function(winnr)
              return vim.api.nvim_win_get_buf(winnr)
            end)
            :any(function(bufnr)
              return vim.bo[bufnr].modified
            end)
          local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
          return vim
            .iter({
              context.tabnr,
              ' ',
              name,
              mod and ' *',
            })
            :filter(function(v)
              return v and v ~= ''
            end)
            :join ''
        end,
      },
      '%S', -- showcmd, requires showcmdloc=statusline
      'filetype',
      'progress',
    },
    lualine_y = { 'overseer' },
    lualine_z = { 'location' },
  },
}

local Debounce = require 'user.util.debounce'
local lualine_nvim_opts = require 'lualine.utils.nvim_opts'
local base_set = lualine_nvim_opts.set

local tpipeline_update = Debounce(function()
  vim.cmd 'silent! call tpipeline#update()'
end, {
  threshold = 20,
})

lualine_nvim_opts.set = function(name, val, scope)
  if vim.env.TMUX ~= nil and name == 'statusline' then
    if scope and scope.window == vim.api.nvim_get_current_win() then
      vim.g.tpipeline_statusline = val
      tpipeline_update()
    end
    return
  end
  return base_set(name, val, scope)
end
