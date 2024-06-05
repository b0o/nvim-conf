---- b0o/incline.nvim
local a = vim.api
local incline = require 'incline'
local Path = require 'plenary.path'
local devicons = require 'nvim-web-devicons'

local colors = require 'user.colors'
local helpers = require 'incline.helpers'
local lsp_status = require 'user.statusline.lsp'
local pnpm = require 'user.util.pnpm'

local extra_colors = {}
if vim.g.colors_name == 'lavi' then
  local lavi = require 'lavi.palette'
  extra_colors = {
    theme_bg = lavi.bg_dark.hex,
    fg = lavi.white.hex,
    fg_dim = lavi.fg_dim.hex,
    fg_nc = lavi.fg_nc.hex,
    bg = lavi.bg_med.hex,
    bg_nc = lavi.bg_dark.hex,
  }
elseif vim.g.colors_name == 'tokyonight' then
  local tokyonight = require 'tokyonight.colors'
  extra_colors = {
    theme_bg = tokyonight.default.bg_dark,
    fg = tokyonight.default.fg,
    fg_dim = tokyonight.default.fg_dark,
    fg_nc = tokyonight.default.fg_gutter,
    bg = tokyonight.default.bg,
    bg_nc = tokyonight.default.bg_dark,
  }
else
  extra_colors = {
    theme_bg = '#222032',
    fg = '#FFFFFF',
    fg_dim = '#ded4fd',
    fg_nc = '#A89CCF',
    bg = '#55456F',
    bg_nc = 'NONE',
  }
end

local M = {}

local function status_lsp_client(status)
  local icon = ''
  return function(bufnr)
    local count = lsp_status.status_clients_count(status, bufnr)
    if count == 0 then
      return ''
    end
    if count == 1 then
      return { icon, ' ' }
    end
    return { count, ' ', icon, ' ' }
  end
end

local lsp_clients_running = status_lsp_client 'running'
local lsp_clients_starting = status_lsp_client 'starting'
local lsp_clients_exited_ok = status_lsp_client 'exited_ok'
local lsp_clients_exited_err = status_lsp_client 'exited_err'

local function relativize_path(path, base)
  local abs_base = Path:new(base):absolute()
  local abs_path = Path:new(path):absolute()
  if string.sub(abs_path, 1, #abs_base) ~= abs_base then
    return path
  end
  return string.sub(abs_path, #abs_base + 2)
end

--- Given a path, return a shortened version of it.
--- @param path string an absolute or relative path
--- @param opts table
--- @return string | table
---
--- The tail of the path (the last n components, where n is the value of
--- opts.tail_count) is kept unshortened.
---
--- Each component in the head of the path (the first components up to the tail)
--- is shortened to opts.short_len characters.
---
--- If opts.head_max is non-zero, the number of components in the head
--- is limited to opts.head_max. Excess components are trimmed from left to right.
--- If opts.head_max is zero, all components are kept.
---
--- opts is a table with the following keys:
---   short_len: int - the number of chars to shorten each head component to (default: 1)
---   tail_count: int - the number of tail components to keep unshortened (default: 2)
---   head_max: int - the max number of components to keep, including the tail
---     components. If 0, keep all components. Excess components are
---     trimmed starting from the head. (default: 0)
---   relative: bool - if true, make the path relative to the current working
---     directory (default: true)
---   return_table: bool - if true, return a table of { head, tail } instead
---     of a string (default: false)
---
--- Example: get_short_path_fancy('foo/bar/qux/baz.txt', {
---   short_len = 1,
---   tail_count = 2,
---   head_max = 0,
--- }) -> 'f/b/qux/baz.txt'
---
--- Example: get_short_path_fancy('foo/bar/qux/baz.txt', {
---   short_len = 2,
---   tail_count = 2,
---   head_max = 1,
--- }) -> 'ba/baz.txt'
---
local function shorten_path(path, opts)
  opts = opts or {}
  local short_len = opts.short_len or 1
  local tail_count = opts.tail_count or 2
  local head_max = opts.head_max or 0
  local relative = opts.relative == nil or opts.relative
  local return_table = opts.return_table or false
  if relative then
    path = relativize_path(path, vim.uv.cwd())
  end
  local components = vim.split(path, Path.path.sep)
  if #components == 1 then
    if return_table then
      return { nil, path }
    end
    return path
  end
  local tail = { unpack(components, #components - tail_count + 1) }
  local head = { unpack(components, 1, #components - tail_count) }
  if head_max > 0 and #head > head_max then
    head = { unpack(head, #head - head_max + 1) }
  end
  local head_short = #head > 0 and Path.new(unpack(head)):shorten(short_len, {}) or nil
  if head_short == '/' then
    head_short = ''
  end
  local result = {
    head_short,
    table.concat(tail, Path.path.sep),
  }
  if return_table then
    return result
  end
  return table.concat(result, Path.path.sep)
end

--- Given a path, return a shortened version of it, with additional styling.
--- @param path string an absolute or relative path
--- @param opts table see below
--- @return table
---
--- The arguments are the same as for shorten_path, with the following additional options:
---   head_style: table - a table of highlight groups to apply to the head (see
---      :help incline-render) (default: nil)
---   tail_style: table - a table of highlight groups to apply to the tail (default: nil)
---
--- Example: get_short_path_fancy('foo/bar/qux/baz.txt', {
---   short_len = 1,
---   tail_count = 2,
---   head_max = 0,
---   head_style = { guibg = '#555555' },
--- }) -> { 'f/b/', guibg = '#555555' }, { 'qux/baz.txt' }
---
local function shorten_path_styled(path, opts)
  opts = opts or {}
  local head_style = opts.head_style or {}
  local tail_style = opts.tail_style or {}
  local result = shorten_path(
    path,
    vim.tbl_extend('force', opts, {
      return_table = true,
    })
  )
  return {
    result[1] and vim.list_extend(head_style, { result[1], '/' }) or '',
    vim.list_extend(tail_style, { result[2] }),
  }
end

local function git_status(props)
  if not package.loaded['gitsigns'] then
    return
  end
  local gitsigns_cache = require('gitsigns.cache').cache
  local buf_cache = gitsigns_cache[props.buf]
  if not buf_cache then
    return
  end
  local res = {}
  if buf_cache.staged_diffs and #buf_cache.staged_diffs > 0 then
    table.insert(res, { ' + ', group = 'GitSignsAdd' })
  end
  if buf_cache.hunks and #buf_cache.hunks > 0 then
    table.insert(res, { ' ϟ ', group = 'GitSignsChange' })
  end
  return res
end

---@type Map<string, boolean> @root path -> true|nil
local scheduled_pnpm_callbacks = {}

local function get_pnpm_workspace(bufname)
  if bufname == '' then
    return
  end
  local ws = pnpm.get_workspace_info {
    focused_path = bufname,
    only_cached = true,
  }
  if ws and ws.focused and ws.focused.name then
    return ws.focused
  end
  -- ws == nil indicates that the root dir has not been cached yet
  -- ws == false indicates that the root dir was not found
  if ws == false then
    -- if the root dir was not found, then the focused path is not in a workspace
    return
  end
  -- if the root dir has not been cached yet, then the focused path may be in a workspace
  -- schedule an async call to populate the cache so that the next render will pick it up
  local root = pnpm.get_pnpm_root_path(Path:new(bufname))
  if not root or scheduled_pnpm_callbacks[root:absolute()] then
    return
  end
  scheduled_pnpm_callbacks[root:absolute()] = true
  pnpm.get_workspace_package_paths(root, {
    callback = function()
      pnpm.get_workspace_info()
    end,
  })
end

local state = {
  focused_workspace = nil,
}

local wrap_status = function(bg, buf_focused, props, icon, status)
  return {
    {
      {
        '',
        guifg = props.focused and icon.bg or bg,
        guibg = props.focused and extra_colors.theme_bg or extra_colors.bg_nc,
      },
      {
        icon.icon,
        ' ',
        guifg = buf_focused and icon.fg or colors.deep_velvet,
        guibg = props.focused and icon.bg or bg,
      },
      status,
      {
        '',
        guifg = bg,
        guibg = props.focused and extra_colors.theme_bg or extra_colors.bg_nc,
      },
    },
  }
end

local dap_status = function()
  local dap = require 'dap'
  local session = dap.session()
  if not session then
    return 'Inactive'
  end
  return dap.status()
end

local get_icon = function(props)
  local bufname = a.nvim_buf_get_name(props.buf)
  local buf_focused = props.buf == a.nvim_get_current_buf()
  local ft = vim.bo[props.buf].filetype
  local icon, accent_color
  if bufname ~= '' then
    icon, accent_color = devicons.get_icon_color(bufname)
  end
  if not icon or icon == '' then
    local icon_name
    if ft ~= '' then
      icon_name = devicons.get_icon_name_by_filetype(ft)
    end
    if icon_name and icon_name ~= '' then
      icon, accent_color = require('nvim-web-devicons').get_icon_color(icon_name)
    end
  end
  icon = icon or ''
  accent_color = accent_color or extra_colors.fg
  if not props.focused and buf_focused then
    return {
      icon = icon,
      fg = accent_color,
    }
  end
  local contrast_color = helpers.contrast_color(accent_color, {
    dark = colors.bg_dark,
    light = colors.fg,
  })
  return {
    icon = icon,
    fg = contrast_color,
    bg = props.focused and accent_color or extra_colors.bg_nc,
  }
end

local get_file_info = function(props)
  local bufname = a.nvim_buf_get_name(props.buf)
  if bufname == '' then
    return { fname = '[No Name]' }
  end
  local pnpm_workspace = get_pnpm_workspace(bufname)
  if pnpm_workspace then
    if props.focused then
      state.focused_workspace = pnpm_workspace.name
    end
    local fname = shorten_path_styled(relativize_path(bufname, pnpm_workspace.path), {
      relative = false,
      short_len = 1,
      tail_count = 2,
      head_max = 3,
      head_style = { guifg = extra_colors.fg_nc },
      tail_style = { guifg = extra_colors.fg },
    })
    return {
      fname = fname,
      pnpm_workspace = pnpm_workspace,
    }
  end
  local fname = shorten_path_styled(bufname, {
    short_len = 1,
    tail_count = 2,
    head_max = 4,
    head_style = { guifg = extra_colors.fg_nc },
    tail_style = { guifg = extra_colors.fg },
  })
  return { fname = fname }
end

local get_lsp = function(props)
  if not props.focused then
    return ''
  end
  return {
    { lsp_clients_running(props.buf), guifg = colors.green },
    { lsp_clients_starting(props.buf), guifg = colors.skyblue },
    { lsp_clients_exited_ok(props.buf), guifg = colors.grey6 },
    { lsp_clients_exited_err(props.buf), guifg = colors.red },
  }
end

local get_pnpm_info = function(file_info)
  return {
    file_info.pnpm_workspace
        and {
          file_info.pnpm_workspace.name,
          ' ',
          guifg = file_info.pnpm_workspace.name == state.focused_workspace and extra_colors.fg_dim
            or extra_colors.fg_nc,
        }
      or '',
  }
end

incline.setup {
  render = function(props)
    local ft = vim.bo[props.buf].filetype

    local buf_focused = props.buf == a.nvim_get_current_buf()
    local modified = vim.bo[props.buf].modified

    local fg = props.focused and extra_colors.fg or extra_colors.fg_nc
    local bg = buf_focused and extra_colors.bg or extra_colors.bg_nc

    if ft == 'dap-repl' then
      local icon = {
        bg = 'red',
        fg = 'white',
        icon = '',
      }
      return {
        wrap_status(bg, buf_focused, props, icon, {
          ' ',
          dap_status(),
          guibg = bg,
          guifg = fg,
        }),
      }
    end

    local file_info = get_file_info(props)

    local diag_disabled = not vim.diagnostic.is_enabled { bufnr = props.buf }

    local has_error = not diag_disabled
      and #vim.diagnostic.get(props.buf, {
        severity = vim.diagnostic.severity.ERROR,
      }) > 0

    local lsp = get_lsp(props)
    local icon = get_icon(props)

    local status = {
      { diag_disabled and ' 󱒼 ' or '', guifg = buf_focused and colors.deep_velvet or colors.deep_anise },
      { has_error and '  ' or ' ', guifg = colors.red },
      lsp,
      get_pnpm_info(file_info),
      {
        file_info.fname,
        guifg = props.focused and fg or extra_colors.fg_dim,
        gui = modified and 'bold,italic' or nil,
      },
      { modified and ' *' or '', guifg = extra_colors.fg },
      git_status(props),
      guibg = bg,
      guifg = fg,
    }

    return wrap_status(bg, buf_focused, props, icon, status)
  end,

  debounce_threshold = { rising = 20, falling = 150 },
  window = {
    margin = { horizontal = 0, vertical = 0 },
    placement = { horizontal = 'right', vertical = 'top' },
    overlap = {
      tabline = false,
      winbar = true,
      borders = true,
      statusline = true,
    },
    padding = 0,
    zindex = 49,
    winhighlight = {
      active = { Normal = 'Normal' },
      inactive = { Normal = 'Normal' },
    },
  },
  hide = {
    cursorline = 'focused_win',
  },
  ignore = {
    unlisted_buffers = false,
    buftypes = function(bufnr, buftype)
      return not (buftype == '' or vim.bo[bufnr].filetype == 'dap-repl')
    end,
  },
}

return M
