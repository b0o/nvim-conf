---- b0o/incline.nvim
local a = vim.api
local incline = require 'incline'
local Path = require 'plenary.path'
local devicons = require 'nvim-web-devicons'

local colors = require 'user.colors'
local fn = require 'user.fn'

local extra_colors = {
  theme_bg = '#222032',
  fg = 'white',
  fg_nc = '#A89CCF',
  bg = '#55456F',
  bg_nc = 'NONE',
}

local M = {}

local react_use_directive_query_str = [[
  (program
    ((expression_statement (string (string_fragment) @directive))
        (#any-of? @directive "use client" "use server")))
]]

-- lang -> query
--- @type table<string, Query>
local react_use_directive_query = {}

-- bufnr -> {directive: string, timestamp: number}
--- @type table<number, {directive: string, timestamp: number}>
local get_react_use_directive_cache = {}

--- @param bufnr number
--- @return "use client" | "use server" | nil
local function get_react_use_directive(bufnr)
  local cached = get_react_use_directive_cache[bufnr]
  if cached and cached.timestamp > vim.uv.now() - 1000 then
    return cached.directive
  end
  local parser = vim.treesitter.get_parser(bufnr)
  local root = parser:parse()[1]:root()
  local lang = parser:lang()
  local query = react_use_directive_query[lang]
  if not query then
    local ok, maybe_query = pcall(vim.treesitter.query.parse, lang, react_use_directive_query_str)
    if not ok then
      return
    end
    query = maybe_query
    react_use_directive_query[lang] = query
  end
  ---@diagnostic disable-next-line: missing-parameter
  for _, node in query:iter_captures(root, bufnr) do
    local directive = vim.treesitter.get_node_text(node, bufnr)
    get_react_use_directive_cache[bufnr] = {
      directive = directive,
      -- add random jitter to avoid cache stampede
      timestamp = vim.uv.now() + math.random(0, 1000),
    }
    return directive
  end
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
    path = vim.fn.fnamemodify(path, ':.')
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

local function git_status(bufname)
  if bufname == '' then
    return
  end
  local nvim_tree_git = require 'nvim-tree.git'
  if not nvim_tree_git then
    return
  end
  local cwd = vim.fn.getcwd()
  local proj = nvim_tree_git.get_project(cwd)
  if not proj then
    proj = nvim_tree_git.load_project_status(cwd)
  end
  local file_status = proj.files[bufname]
  if not file_status then
    return
  end
  local icons = require('nvim-tree.renderer.components.git').git_icons[file_status]
  if not icons then
    return
  end
  local res = {}
  for _, icon in ipairs(icons) do
    table.insert(res, { icon.str, ' ', group = icon.hl })
  end
  return res
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

    local fname, icon, icon_bg
    if bufname == '' then
      fname = '[No name]'
    else
      icon, icon_bg = devicons.get_icon_color(bufname)
      fname = shorten_path_styled(bufname, {
        short_len = 1,
        tail_count = 2,
        head_max = 4,
        head_style = { guifg = extra_colors.fg_nc },
        tail_style = { guifg = extra_colors.fg },
      })
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

    local has_error = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity.ERROR }) > 0

    icon = icon or ''
    icon_bg = props.focused and (icon_bg or extra_colors.fg) or extra_colors.fg_nc
    local icon_fg = fn.contrast_color(icon_bg)

    local extra = {}

    if filetype == 'javascriptreact' or filetype == 'typescriptreact' then
      local client_or_server = get_react_use_directive(props.buf)
      if client_or_server then
        local use_directive_icon = ({
          ['use server'] = ' 󰬀󰫲󰫿󱂌󰫲󰫿 ', -- "server" written with nerd font icons
          ['use client'] = ' 󰫰󱎦󱂈󰫲󰫻󰬁 ', -- "client" written with nerd font icons
        })[client_or_server]
        table.insert(extra, { use_directive_icon, guifg = fg })
      end
    end

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
        { has_error and '  ' or ' ', guifg = props.focused and colors.red or nil },
        { fname, gui = modified and 'bold,italic' or nil },
        { modified and ' * ' or ' ', guifg = extra_colors.fg },
        git_status(bufname),
        guibg = bg,
        guifg = fg,
      },
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
  },
}

return M
