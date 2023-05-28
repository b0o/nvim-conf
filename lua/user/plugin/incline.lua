---- b0o/incline.nvim
local a = vim.api
local devicons = require 'nvim-web-devicons'
local incline = require 'incline'
local colors = require 'user.colors'

local extra_colors = {
  theme_bg = '#222032',
  fg = 'white',
  fg_nc = '#A89CCF',
  bg = '#55456F',
  bg_nc = 'NONE',
}

incline.setup {
  render = function(props)
    local bufname = a.nvim_buf_get_name(props.buf)

    local buf_focused = props.buf == a.nvim_get_current_buf()

    ---@diagnostic disable-next-line: redundant-parameter
    local modified = a.nvim_buf_get_option(props.buf, 'modified')

    local fg = props.focused and extra_colors.fg or extra_colors.fg_nc
    local bg = buf_focused and extra_colors.bg or extra_colors.bg_nc

    local fname = bufname == '' and '[No name]' or vim.fn.fnamemodify(bufname, ':t')

    local icon, icon_fg
    if bufname ~= '' then
      icon, icon_fg = devicons.get_icon_color(fname)
    end
    if not icon or icon == '' then
      local icon_name
      ---@diagnostic disable-next-line: redundant-parameter
      local filetype = a.nvim_buf_get_option(props.buf, 'filetype')
      if filetype ~= '' then
        icon_name = devicons.get_icon_name_by_filetype(filetype)
      end
      if icon_name and icon_name ~= '' then
        icon, icon_fg = require('nvim-web-devicons').get_icon_color(icon_name)
      end
    end

    local has_error = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity.ERROR }) > 0

    icon = icon or ''
    icon_fg = props.focused and (icon_fg or extra_colors.fg) or extra_colors.fg_nc

    return {
      {
        ' ' .. icon .. ' ',
        guifg = buf_focused and colors.licorice or colors.deep_velvet,
        guibg = props.focused and icon_fg or (buf_focused and icon_fg or nil),
      },
      { has_error and '  ' or ' ', guifg = props.focused and colors.red or nil },
      { fname, gui = modified and 'bold,italic' or nil },
      { modified and ' * ' or ' ', guifg = extra_colors.fg },
      guibg = bg,
      guifg = fg,
    }
  end,
  window = {
    margin = { horizontal = 0, vertical = 0 },
    padding = 0,
    zindex = 51,
    placement = { horizontal = 'right', vertical = 'top' },
    winhighlight = {
      active = { Normal = 'Normal' },
      inactive = { Normal = 'Normal' },
    },
  },
  hide = {
    cursorline = 'focused_win',
    cursor_overlap = 'focused_win',
  },
}
