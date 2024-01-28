---- b0o/incline.nvim
local a = vim.api
local incline = require 'incline'
local Path = require 'plenary.path'
local devicons = require 'nvim-web-devicons'

local colors = require 'user.colors'
local helpers = require 'incline.helpers'
local lsp_status = require 'user.statusline.lsp'
local pnpm = require 'user.util.pnpm'

local extra_colors = {
  theme_bg = '#222032',
  fg = '#FFFFFF',
  fg_dim = '#ded4fd',
  fg_nc = '#A89CCF',
  bg = '#55456F',
  bg_nc = 'NONE',
}

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
  return string.sub(Path:new(path):absolute(), #Path:new(base):absolute() + 2)
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
  local result = {
    #head > 0 and Path.new(unpack(head)):shorten(short_len, {}) or nil,
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
  if #buf_cache.staged_diffs > 0 then
    table.insert(res, { '+ ', group = 'GitSignsAdd' })
  end
  if #buf_cache.hunks > 0 then
    table.insert(res, { 'ϟ ', group = 'GitSignsChange' })
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

incline.setup {
  render = function(props)
    local bufname = a.nvim_buf_get_name(props.buf)

    local buf_focused = props.buf == a.nvim_get_current_buf()

    ---@diagnostic disable-next-line: redundant-parameter
    local modified = a.nvim_buf_get_option(props.buf, 'modified')

    local fg = props.focused and extra_colors.fg or extra_colors.fg_nc
    local bg = buf_focused and extra_colors.bg or extra_colors.bg_nc

    ---@diagnostic disable-next-line: redundant-parameter
    local filetype = a.nvim_buf_get_option(props.buf, 'filetype')

    local pnpm_workspace = get_pnpm_workspace(bufname)

    local fname, icon, icon_bg
    if bufname == '' then
      fname = '[No name]'
    else
      icon, icon_bg = devicons.get_icon_color(bufname)
      if pnpm_workspace then
        fname = shorten_path_styled(relativize_path(bufname, pnpm_workspace.path), {
          relative = false,
          short_len = 1,
          tail_count = 2,
          head_max = 3,
          head_style = { guifg = extra_colors.fg_nc },
          tail_style = { guifg = extra_colors.fg },
        })
      else
        fname = shorten_path_styled(bufname, {
          short_len = 1,
          tail_count = 2,
          head_max = 4,
          head_style = { guifg = extra_colors.fg_nc },
          tail_style = { guifg = extra_colors.fg },
        })
      end
    end

    if not icon or icon == '' then
      local icon_name
      if filetype ~= '' then
        icon_name = devicons.get_icon_name_by_filetype(filetype)
      end
      if icon_name and icon_name ~= '' then
        icon, icon_bg = require('nvim-web-devicons').get_icon_color(icon_name)
      end
    end

    local diag_disabled = vim.diagnostic.is_disabled(props.buf)
    local has_error = not diag_disabled
      and #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity.ERROR }) > 0

    icon = icon or ''
    icon_bg = props.focused and (icon_bg or extra_colors.fg) or extra_colors.fg_nc
    local icon_fg = helpers.contrast_color(icon_bg, {
      dark = colors.bg_dark,
      light = colors.fg,
    })

    local extra = {}

    local lsp = props.focused
        and {
          { lsp_clients_running(props.buf), guifg = colors.green },
          { lsp_clients_starting(props.buf), guifg = colors.skyblue },
          { lsp_clients_exited_ok(props.buf), guifg = colors.grey6 },
          { lsp_clients_exited_err(props.buf), guifg = colors.red },
        }
      or ''

    return {
      extra,
      {
        {
          ' ',
          icon,
          ' ',
          guifg = buf_focused and icon_fg or colors.deep_velvet,
          guibg = props.focused and icon_bg or (buf_focused and icon_bg or nil),
        },
        { diag_disabled and ' 󱒼 ' or '', guifg = buf_focused and colors.deep_velvet or colors.deep_anise },
        { has_error and '  ' or ' ', guifg = colors.red },
        lsp,
        {
          pnpm_workspace and {
            pnpm_workspace.name,
            ' ',
            guifg = props.focused and extra_colors.fg_dim or extra_colors.fg_nc,
          } or '',
        },
        { fname, guifg = props.focused and fg or extra_colors.fg_dim, gui = modified and 'bold,italic' or nil },
        { modified and ' * ' or ' ', guifg = extra_colors.fg },
        git_status(props),
        guibg = bg,
        guifg = fg,
      },
    }
  end,
  window = {
    margin = { horizontal = 0, vertical = 0 },
    padding = 0,
    zindex = 49,
    placement = { horizontal = 'right', vertical = 'top' },
    winhighlight = {
      active = { Normal = 'Normal' },
      inactive = { Normal = 'Normal' },
    },
  },
  hide = {
    cursorline = 'focused_win',
  },
}

return M
