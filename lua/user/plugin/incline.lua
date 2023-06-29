---- b0o/incline.nvim
local a = vim.api
local devicons = require 'nvim-web-devicons'
local incline = require 'incline'
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
      local Path = require 'plenary.path'
      local sep = Path.path.sep
      local rel = vim.fn.fnamemodify(bufname, ':.')
      local components = vim.split(rel, sep)
      if #components > 2 then
        local head = { unpack(components, 1, #components - 2) }
        local lastTwo = { components[#components - 1], components[#components] }
        local shortHead = Path.new(unpack(head)):shorten(1, {})
        fname = {
          { shortHead, sep, guifg = extra_colors.fg_nc },
          { table.concat(lastTwo, sep), guifg = extra_colors.fg },
        }
      else
        fname = rel
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
