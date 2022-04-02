local colors = require 'user.colors'
local fn = require 'user.fn'
local apiutil = require 'user.apiutil'

local Input = fn.require_on_module_call 'nui.input'
local Path = fn.require_on_exported_call 'plenary.path'

local M = {
  state = {
    titles = {},
    prev_win = {},
    style = vim.g.tabpage_titlestyle or 'long',
  },
  ignore = {
    unlisted_buffers = true,
    unnamed_buffers = true,
    filetypes = {},
    buftypes = 'special',
    wintypes = 'special',
  },
}

local buf_name_transformers = setmetatable({
  __default = function(buf)
    local p = buf.name
    if vim.startswith(p, '/') then
      p = Path.new(p):make_relative()
      local home = vim.env['HOME']
      if vim.startswith(p, home) then
        p = '~' .. string.sub(p, #home + 1)
      end
      p = Path.new(p):shorten(1, { -1, 1 })
    end
    return p
  end,

  help = function(buf)
    local l = vim.split(buf.name, '/')
    return l[#l]
  end,
}, {
  __index = function(self, ft)
    local v = rawget(self, ft)
    return v ~= nil and v or rawget(self, '__default')
  end,
})

function M.tabpage_set_title(...) -- ([t, ]title)
  local args = { ... }
  local t = #args == 2 and args[1] or 0
  local title = #args == 2 and args[2] or args[1]

  if t == 0 then
    t = vim.api.nvim_get_current_tabpage()
  end
  if not vim.api.nvim_tabpage_is_valid(t) then
    return
  end

  vim.api.nvim_tabpage_set_var(t, 'title', title)

  M.state.titles[tostring(t)] = title
  vim.g.TabpageTitles = vim.inspect(M.state.titles)

  vim.cmd 'redrawtabline'
end

function M.tabpage_get_title(t)
  local ok, title = pcall(vim.api.nvim_tabpage_get_var, t, 'title')
  return ok and title or nil
end

function M.restore_tabpage_titles()
  local tt = loadstring('return ' .. (vim.g.TabpageTitles or '{}'))()
  for ts, title in pairs(tt) do
    M.tabpage_set_title(tonumber(ts), title)
  end
end

function M.tabpage_set_titlestyle(s)
  M.state.style = s or (M.state.style == 'long' and 'short' or 'long')
  vim.cmd 'redrawtabline'
end

function M.tabpage_toggle_titlestyle()
  return M.tabpage_set_titlestyle()
end

-- highlight wrap
local function hw(...)
  return '%#' .. table.concat({ ... }, '') .. '#'
end

local function sanitize(s)
  return string.gsub(s, '[%%#]', '')
end

local function is_ignored_filetype(ft)
  return M.ignore.filetypes and vim.tbl_contains(M.ignore.filetypes, ft)
end

local function is_ignored_buf(bufnr, ft)
  bufnr = bufnr or 0
  if M.ignore.unlisted_buffers and not vim.api.nvim_buf_get_option(bufnr, 'buflisted') then
    return true
  end
  if M.ignore.unnamed_buffers and vim.api.nvim_buf_get_name(bufnr) == '' then
    return true
  end
  if M.ignore.buftypes then
    local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
    if M.ignore.buftypes == 'special' and buftype ~= '' then
      return true
    elseif type(M.ignore.buftypes) == 'table' then
      if vim.tbl_contains(M.ignore.buftypes, buftype) then
        return true
      end
    elseif type(M.ignore.buftypes) == 'function' then
      if M.ignore.buftypes(bufnr, buftype) then
        return true
      end
    end
  end
  if M.ignore.filetypes then
    ft = ft or vim.api.nvim_buf_get_option(bufnr, 'filetype')
    if is_ignored_filetype(ft) then
      return true
    end
  end
  return false
end

local function is_ignored(winid, bufnr, ft)
  winid = winid or 0
  bufnr = bufnr or vim.api.nvim_win_get_buf(winid)
  if is_ignored_buf(bufnr, ft) then
    return true
  end
  if M.ignore.wintypes then
    local wintype = vim.fn.win_gettype(winid)
    if M.ignore.wintypes == 'special' and wintype ~= '' then
      return true
    elseif type(M.ignore.wintypes) == 'table' then
      if vim.tbl_contains(M.ignore.wintypes, wintype) then
        return true
      end
    end
  end
  return false
end

function M.titlestring(t, sel)
  local tabpage = t or vim.api.nvim_get_current_tabpage()
  local cur_win = vim.api.nvim_tabpage_get_win(tabpage)

  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  local cur_buf_ft = vim.api.nvim_buf_get_option(cur_buf, 'filetype')

  local hl = 'TabLine' .. (sel and 'Sel' or '')
  local hl_name = hw(hl)
  local hl_count = hw(hl)

  if t ~= nil then
    if
      is_ignored(cur_win, cur_buf, cur_buf_ft)
      and M.state.prev_win[tabpage] ~= nil
      and vim.api.nvim_win_is_valid(M.state.prev_win[tabpage])
    then
      cur_win = M.state.prev_win[tabpage]
      cur_buf = vim.api.nvim_win_get_buf(cur_win)
      cur_buf_ft = vim.api.nvim_buf_get_option(cur_buf, 'filetype')
    end
    M.state.prev_win[tabpage] = cur_win

    local mod_bufs = apiutil.tabpage_list_modified_bufs(tabpage)
    local min_mod = 0
    if vim.tbl_contains(mod_bufs, cur_buf) then
      hl_name = hw(hl, 'Mod')
      min_mod = 1
    end
    if #mod_bufs > min_mod then
      hl_count = hw(hl, 'Mod')
    end
  end

  local buf_listed = vim.api.nvim_buf_get_option(cur_buf, 'buflisted')
  local buf_name = buf_listed and vim.api.nvim_buf_get_name(cur_buf) or vim.fn.bufname(cur_buf)

  buf_name = buf_name_transformers[cur_buf_ft] {
    id = cur_buf,
    ft = cur_buf_ft,
    win = cur_win,
    name = buf_name,
    listed = buf_listed,
  }

  local bufs = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_get_option(b, 'buflisted')
      and (vim.api.nvim_buf_get_name(b) ~= '' or not apiutil.buf_is_empty(b))
  end, apiutil.tabpage_list_bufs(tabpage))

  local ts = ''
  ts = ts .. hl_name
  ts = ts .. (buf_name ~= '' and sanitize(buf_name) or 'unnamed')
  ts = ts .. hl_count
  ts = ts .. (#bufs > 1 and (' +' .. (#bufs - 1)) or '')
  ts = ts .. hw(hl)
  return ts
end

local function tabline()
  local tabpages = vim.api.nvim_list_tabpages()
  local current_tabpage = vim.api.nvim_get_current_tabpage()
  local s = ''
  for i, t in ipairs(tabpages) do
    local hl = 'TabLine'
    if t == current_tabpage then
      hl = 'TabLineSel'
    end
    s = s .. hw(hl)
    s = s .. '%' .. t .. 'T'
    s = s .. hw(hl, 'Sep') .. ''
    s = s .. hw(hl, 'Nr') .. ' '
    s = s .. (apiutil.tabpage_is_modified(t) and '' or '')
    s = s .. ' ' .. i
    s = s .. hw(hl) .. ' '
    local title = M.tabpage_get_title(t)
    if title ~= nil then
      s = s .. hw(hl, 'Title') .. sanitize(title)
      s = s .. hw(hl) .. ' '
    end
    if title == nil or M.state.style == 'long' then
      s = s .. M.titlestring(t, t == current_tabpage)
    end
    s = s .. ' '
    s = s .. hw(hl, 'Sep') .. ''
    s = s .. hw 'TabLineFill' .. ' '
  end
  s = s .. '%#TabLineFill#%T'
  return s
end

function M.tabline()
  local ok, res = pcall(tabline)
  if ok then
    return res
  end
  return ''
end

fn.tmpl_cmd(
  [[
    hi TabLineFill               ctermbg=0                           guibg=${base_bg}

    hi TabLine                   ctermbg=0 guifg=${tab_fg}           guibg=${tab_bg}
    hi TabLineSel      ctermfg=6 ctermbg=8 guifg=${tab_sel_fg}       guibg=${tab_sel_bg}

    hi TabLineMod                ctermbg=0 guifg=${tab_fg}           guibg=${tab_bg}     cterm=italic gui=italic
    hi TabLineSelMod   ctermfg=6 ctermbg=8 guifg=${tab_sel_fg}       guibg=${tab_sel_bg} cterm=italic gui=italic

    hi TabLineSep                ctermbg=0 guifg=${tab_bg}           guibg=${base_bg}
    hi TabLineSelSep   ctermfg=6 ctermbg=8 guifg=${tab_sel_bg}       guibg=${base_bg}

    hi TabLineNr                 ctermbg=0 guifg=${tab_nr_fg}        guibg=${tab_bg}
    hi TabLineSelNr              ctermbg=8 guifg=${tab_sel_nr_fg}    guibg=${tab_sel_bg}

    hi TabLineTitle              ctermbg=0 guifg=${tab_title_fg}     guibg=${tab_bg}     cterm=bold   gui=bold
    hi TabLineSelTitle ctermfg=6 ctermbg=8 guifg=${tab_sel_title_fg} guibg=${tab_sel_bg} cterm=bold   gui=bold
  ]],
  {
    base_bg = colors.deep_anise,
    tab_bg = colors.deep_velvet,
    tab_fg = colors.white,
    tab_nr_fg = colors.white,
    tab_title_fg = colors.white,
    tab_sel_bg = colors.deep_licorice,
    tab_sel_fg = colors.powder,
    tab_sel_nr_fg = colors.hydrangea,
    tab_sel_title_fg = colors.white,
  }
)

function M.do_rename_tab()
  local input = Input({
    position = {
      row = '50%',
      col = '50%',
    },
    size = {
      width = '60%',
      height = 2,
    },
    relative = 'editor',
    border = {
      highlight = 'FloatBorder',
      style = 'rounded',
      padding = { 1, 3 },
      text = {
        top = 'Tab Title',
        top_align = 'left',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal',
      signcolumn = 'no',
    },
    buf_options = {
      buflisted = false,
      filetype = 'Nui',
    },
  }, {
    prompt = 'Title: ',
    default_value = vim.t.title or '',
    on_submit = function(title)
      M.tabpage_set_title(title)
    end,
  })
  input:mount()
  input:map('i', '<Esc>', input.input_props.on_close, { noremap = true })
  input:map('n', '<Esc>', input.input_props.on_close, { noremap = true })
end

return M
