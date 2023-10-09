local M = {}

local fn = require 'user.fn'

-- bind a function to some arguments and return a new function that
-- can be called later.
-- Useful for setting up callbacks without anonymous functions.
local wrap = function(func, ...)
  local bound = { ... }
  return function(...)
    return func(unpack(vim.list_extend(vim.list_extend({}, bound), { ... })))
  end
end

-- Like wrap(), but arguments passed to the func are ignored.
local iwrap = function(func, ...)
  local bound = { ... }
  return function()
    return func(unpack(bound))
  end
end

local m = require('mapx').setup {
  whichkey = true,
  enableCountArg = false,
  debug = vim.g.mapxDebug or false,
}

local recent_wins = fn.require_on_call_rec 'user.util.recent-wins'
local auto_resize = require 'user.util.auto-resize'

-- Extra keys
-- Configure your terminal emulator to send the unicode codepoint for each
-- given key sequence
M.xk = fn.utf8keys {
  [ [[<C-S-q>]] ] = 0xff01,
  [ [[<C-S-n>]] ] = 0xff02,
  [ [[<C-M-q>]] ] = 0xff03,
  [ [[<C-M-S-q>]] ] = 0xff04,
  [ [[<C-\>]] ] = 0x00f0,
  [ [[<C-S-\>]] ] = 0x00f1,
  [ [[<M-S-\>]] ] = 0x00f2,
  [ [[<C-`>]] ] = 0x00f3,
  [ [[<C-S-w>]] ] = 0x00f4,
  [ [[<C-S-f>]] ] = 0x00f5,
  [ [[<C-S-t>]] ] = 0x00f6,
  [ [[<C-S-a>]] ] = 0x00f7,
  [ [[<C-'>]] ] = 0x00f8,
  [ [[<C-S-p>]] ] = 0x00f9,
  [ [[<C-S-.>]] ] = 0x00fa,
  [ [[<C-.>]] ] = 0x00fb,
  [ [[<C-S-o>]] ] = 0x00fc,
  [ [[<C-S-i>]] ] = 0x00fd,
  [ [[<M-c>]] ] = 0x00fe,
  [ [[<C-/>]] ] = 0x00d4,
  [ [[<C-M-/>]] ] = 0x00d5,
  [ [[<C-S-/>]] ] = 0x00d6,
  [ [[<M-S-/>]] ] = 0x00d7,
  [ [[<C-M-S-/>]] ] = 0x00d8,
  [ [[<M-Space>]] ] = 0x00d9,
}
local xk = M.xk

-- Disable C-z suspend
m.map([[<C-z>]], [[<Nop>]])
m.mapbang([[<C-z>]], [[<Nop>]])

-- Disable C-c warning
-- map     ([[<C-c>]], [[<Nop>]])

-- Disable Ex mode
m.nnoremap([[Q]], [[<Nop>]])

-- Disable command-line window
m.nnoremap([[q:]], [[<Nop>]])
m.nnoremap([[q/]], [[<Nop>]])
m.nnoremap([[q?]], [[<Nop>]])

m.noremap([[j]], function()
  return vim.v.count > 1 and 'j' or 'gj'
end, m.silent, m.expr, 'Line down')
m.noremap([[k]], function()
  return vim.v.count > 0 and 'k' or 'gk'
end, m.silent, m.expr, 'Like up')
m.noremap([[J]], [[5j]], 'Jump down')
m.noremap([[K]], [[5k]], 'Jump up')
m.xnoremap([[J]], [[5j]], 'Jump down')
m.xnoremap([[K]], [[5k]], 'Jump up')
m.noremap([[<C-d>]], [[25j]], 'Page down')
m.noremap([[<C-u>]], [[25k]], 'Page up')
m.xnoremap([[<C-d>]], [[25j]], 'Page down')
m.xnoremap([[<C-u>]], [[25k]], 'Page up')

m.nnoremap([[<M-Down>]], [[<C-e>]], 'Scroll view down 1')
m.nnoremap([[<M-Up>]], [[<C-y>]], 'Scroll view up 1')
m.nnoremap([[<M-S-Down>]], [[5<C-e>]], 'Scroll view down 5')
m.nnoremap([[<M-S-Up>]], [[5<C-y>]], 'Scroll view up 5')
m.xnoremap([[<M-Down>]], [[<C-e>]], 'Scroll view down 1')
m.xnoremap([[<M-Up>]], [[<C-y>]], 'Scroll view up 1')
m.xnoremap([[<M-S-Down>]], [[5<C-e>]], 'Scroll view down 5')
m.xnoremap([[<M-S-Up>]], [[5<C-y>]], 'Scroll view up 5')
m.inoremap([[<M-Down>]], [[<C-o><C-e>]], 'Scroll view down 1')
m.inoremap([[<M-Up>]], [[<C-o><C-y>]], 'Scroll view up 1')
m.inoremap([[<M-S-Down>]], [[<C-o>5<C-e>]], 'Scroll view down 5')
m.inoremap([[<M-S-Up>]], [[<C-o>5<C-y>]], 'Scroll view up 5')

-- since the vim-wordmotion plugin overrides the normal `w` wordwise movement,
-- make `W` behave as vanilla `w`
m.nnoremap([[W]], [[w]], 'Move full word forward')

m.nnoremap([[<M-b>]], [[ge]], 'Move to the end of the previous word')

m.nnoremap({ [[Q]], [[<F29>]] }, '<Cmd>CloseWin<Cr>', m.silent, 'Close window')
m.nnoremap([[ZQ]], '<Cmd>confirm qall<Cr>', m.silent, 'Quit all')
m.nnoremap(xk [[<C-S-w>]], '<Cmd>tabclose<Cr>', m.silent, 'Close tab (except last one)')
m.nnoremap([[<leader>H]], '<Cmd>hide<Cr>', m.silent, 'Hide buffer')

m.noremap([[<C-s>]], '<Cmd>w<Cr>', m.silent, 'Write buffer')

-- quickly enter command mode with substitution commands prefilled
-- TODO: need to force redraw
m.nnoremap([[<leader>/]], [[:%s/]], 'Substitute')
m.nnoremap([[<leader>?]], [[:%S/]], 'Substitute (rev)')
m.xnoremap([[<leader>/]], [[:s/]], 'Substitute')
m.xnoremap([[<leader>?]], [[:S/]], 'Substitute (rev)')

-- Buffer-local option toggles
local function map_toggle_locals(keys, opts, vals)
  keys = type(keys) == 'table' and keys or { keys }
  opts = type(opts) == 'table' and opts or { opts }
  vals = vals or { true, false }

  local lhs = vim.tbl_map(function(k)
    return [[<localleader><localleader>]] .. k
  end, keys)

  local rhs = function()
    vim.tbl_map(function(opt)
      local cur = vim.opt_local[opt]:get()
      local target = vals[1]
      for i, v in ipairs(vals) do
        if v == cur then
          if vals[i + 1] ~= nil then
            target = vals[i + 1]
          end
          break
        end
      end
      local msg
      if type(target) == 'boolean' then
        msg = (target and 'Enable ' or 'Disable ') .. opt
      else
        msg = 'Set ' .. opt .. '=' .. target
      end
      vim.notify(msg)
      vim.opt_local[opt] = target
    end, opts)
  end

  m.nnoremap(lhs, rhs, m.silent, 'Toggle ' .. table.concat(opts, ', '))
end

map_toggle_locals({ 'A', 'ar' }, { 'autoread' })
map_toggle_locals({ 'B' }, { 'cursorbind', 'scrollbind' })
map_toggle_locals({ 'bi' }, { 'breakindent' })
map_toggle_locals({ 'C', 'ci' }, { 'copyindent' })
map_toggle_locals({ 'cc' }, { 'concealcursor' }, { '', 'n' })
map_toggle_locals({ 'cl' }, { 'conceallevel' }, { 0, 2 })
map_toggle_locals({ 'cb' }, { 'cursorbind' })
map_toggle_locals({ 'D', 'di' }, { 'diff' })
map_toggle_locals({ 'E', 'et' }, { 'expandtab' })
map_toggle_locals({ 'F', 'fe' }, { 'foldenable' })
map_toggle_locals({ 'L', 'lb' }, { 'linebreak' })
map_toggle_locals({ 'N', 'nn' }, { 'number', 'relativenumber' })
map_toggle_locals({ 'nr', 'rn' }, { 'relativenumber' })
map_toggle_locals({ 'nu' }, { 'number' })
map_toggle_locals({ 'R', 'ru' }, { 'ruler' })
map_toggle_locals({ 'S', 'sg' }, { 'laststatus' }, { 2, 3 })
map_toggle_locals({ 'sp' }, { 'spell' })
map_toggle_locals({ 'sb' }, { 'scrollbind' })
map_toggle_locals({ 'sr' }, { 'shiftround' })
map_toggle_locals({ 'st' }, { 'smarttab' })
map_toggle_locals({ '|' }, { 'cursorcolumn' })
map_toggle_locals({ 'W', 'ww' }, { 'wrap' })

---- Cut/Copy Buffers
local cutbuf = fn.require_on_call_rec 'user.util.cutbuf'
m.nnoremap([[<localleader>x]], iwrap(cutbuf.cut), m.silent, 'cutbuf: cut')
m.nnoremap([[<localleader>c]], iwrap(cutbuf.copy), m.silent, 'cutbuf: copy')
m.nnoremap([[<localleader>p]], iwrap(cutbuf.paste), m.silent, 'cutbuf: paste')

---- Zoomer
local zoomer = fn.require_on_call_rec 'user.util.zoomer'
zoomer.setup {
  -- on_open = function(props)
  --   local state = {
  --     incline_ignore_wintypes = require 'incline.config'.ignore.wintypes,
  --     incline_ignore_floating_wins = require 'incline.config'.ignore.floating_wins,
  --   }
  --   require 'incline'.setup {
  --     ignore = {
  --       wintypes = function(winid)
  --         return winid == props.floatwin
  --       end,
  --       floating_wins = false,
  --     }
  --   }
  --   return state
  -- end,
  -- on_close = function(props)
  --   require 'incline'.setup {
  --     ignore = {
  --       wintypes = props.prev_state.incline_ignore_wintypes,
  --       floating_wins = props.prev_state.incline_ignore_floating_wins,
  --     }
  --   }
  -- end,
  -- zindex = 40,
}
m.nnoremap([[<localleader>z]], iwrap(zoomer.toggle), 'zoom current window')

---- Editing

-- https://vim.fandom.com/wiki/Insert_a_single_character
m.nnoremap([[gi]], [[:exec "normal i".nr2char(getchar())."\e"<Cr>]], m.silent, 'Insert a single character')
m.nnoremap([[ga]], [[:exec "normal a".nr2char(getchar())."\e"<Cr>]], m.silent, 'Insert a single character')

m.xnoremap([[>]], [[>gv]], 'Indent')
m.xnoremap([[<]], [[<gv]], 'De-Indent')

m.nnoremap([[<M-.>]], [[m'Do<Esc>p`']], 'Break line at cursor')
m.nnoremap([[<M-,>]], [[m'DO<Esc>p`']], 'Break line at cursor (reverse)')

m.nnoremap([[<M-o>]], 'o<C-u>', m.silent, 'Begin a new line below the cursor and insert text (no autocomment)')
m.nnoremap([[<M-O>]], 'O<C-u>', m.silent, 'Begin a new line above the cursor and insert text (no autocomment)')

m.nnoremap([[Y]], [[y$]], 'Yank until end of line')

m.xnoremap([[<leader>y]], [["+y]], 'Yank to system clipboard')
m.nnoremap([[<leader>Y]], [["+yg_]], "Yank 'til EOL to system clipboard")
m.nnoremap([[<leader>yy]], [["+yy]], 'Yank line to system clipboard')
m.nnoremap([[<C-y>]], [[pumvisible() ? "\<C-y>" : '"+yy']], m.expr)
m.xnoremap([[<C-y>]], [[pumvisible() ? "\<C-y>" : '"+y']], m.expr)

m.nnoremap([[<leader>yp]], '<Cmd>let @+ = expand("%:p")<Cr>:echom "Copied " . @+<Cr>', m.silent, 'Yank file path')
m.nnoremap([[<leader>y:]], [[<Cmd>let @+=@:<Cr>:echom "Copied '" . @+ . "'"<Cr>]], m.silent, 'Yank last command')

m.xnoremap([[<C-p>]], [["+p]], 'Paste from system clipboard')
m.nnoremap([[<C-p>]], [["+p]], 'Paste from system clipboard')

m.nnoremap([[<M-p>]], [[a <Esc>p]], 'Insert a space and then paste after cursor')
m.nnoremap([[<M-P>]], [[i <Esc>P]], 'Insert a space and then paste before cursor')

m.nnoremap([[<C-M-j>]], [["dY"dp]], 'Duplicate line downwards')
m.nnoremap([[<C-M-k>]], [["dY"dP]], 'Duplicate line upwards')

m.xnoremap([[<C-M-j>]], [["dy`<"dPjgv]], 'Duplicate selection downwards')
m.xnoremap([[<C-M-k>]], [["dy`>"dpgv]], 'Duplicate selection upwards')

-- Selection Wrapping
-- TODO: Support function calls, e.g. "foo(" -> ")"
local function get_closing_seq(input_str)
  local pairings = {
    -- brackets
    ['('] = ')',
    ['{'] = '}',
    ['['] = ']',
    ['<'] = '>',
    -- quotes
    ['"'] = '"',
    ["'"] = "'",
    ['`'] = '`',
    -- misc
    ['|'] = '|',
    ['/'] = '/',
    ['_'] = '_',
    [' '] = ' ',
    ['*'] = '*',
  }
  local str = ''
  local valid = true
  local i = 1
  while i <= #input_str do
    local tag, tag_name = input_str:sub(i):match '^(<([^/> ]*)[^>]*>)'
    if tag then
      str = '</' .. tag_name .. '>' .. str
      i = i + #tag
    else
      local c = input_str:sub(i, i)
      if pairings[c] then
        str = pairings[c] .. str
      else
        valid = false
        break
      end
    end
    i = i + 1
  end
  if valid then
    return str
  end
  return nil
end

local function wrap_visual_selection()
  local lhs = vim.fn.input { prompt = 'LHS: ', cancelreturn = -1 }
  if lhs == -1 then
    return
  end
  local default_rhs = get_closing_seq(lhs) or lhs
  local rhs = vim.fn.input { prompt = 'RHS: ', default = default_rhs, cancelreturn = -1 }
  if rhs == -1 then
    return
  end
  fn.transform_visual_selection(function(text, meta)
    local mode = meta.selection.mode

    if mode == '' or mode == '<CTRL-V>' then
      -- TODO: implement block-wise
      return text
    end

    if mode == 'v' then
      return lhs .. text .. rhs
    end

    if mode == 'V' then
      local indent = fn.get_indent_info()
      local lines = vim.split(text, '\n')
      local current_indent = ''
      if #lines > 0 then
        current_indent = lines[1]:match('^' .. indent.char .. '*')
      end
      local new_lines = {}
      table.insert(new_lines, current_indent .. lhs)
      for _, line in ipairs(lines) do
        table.insert(new_lines, indent.char:rep(indent.size) .. line)
      end
      table.insert(new_lines, current_indent .. rhs)
      return new_lines
    end
  end)
end

m.xnoremap([[<M-w>]], wrap_visual_selection, 'Wrap selection')

m.nnoremap([[<M-S-W>]], function()
  vim.cmd [[normal! V]]
  wrap_visual_selection()
end, 'Wrap line')

m.nnoremap([[<M-w>]], function()
  vim.cmd [[normal! viw]]
  wrap_visual_selection()
end, 'Wrap word')

-- match the indentation of the next line
local function match_indent(dir)
  return function()
    local target_line = vim.fn.search([[\S]], 'nW' .. (dir == -1 and 'bz' or ''))
    if target_line == 0 then
      return
    end
    local cur = vim.api.nvim_win_get_cursor(0)
    local indent = vim.fn.indent(cur[1])
    local new_indent = vim.fn.indent(target_line)
    local text = vim.fn.trim(vim.api.nvim_get_current_line())
    local new_text = string.rep(' ', new_indent) .. text
    vim.api.nvim_set_current_line(new_text)
    vim.api.nvim_win_set_cursor(0, { cur[1], cur[2] + (new_indent - indent) })
  end
end

m.inoremap([[<M-,>]], match_indent(-1), 'Match indent of prev line')
m.inoremap([[<M-.>]], match_indent(1), 'Match indent of next line')

-- Clear UI state:
-- - Clear search highlight
-- - Clear command-line
-- - Close floating windows
m.nnoremap([[<Esc>]], function()
  vim.cmd 'nohlsearch'
  fn.close_float_wins()
  vim.cmd "echo ''"
end, m.silent, 'Clear UI')

m.noremap([[gF]], [[<C-w>gf]], 'Go to file under cursor (new tab)')

-- emacs-style motion & editing in insert mode
m.inoremap([[<C-a>]], [[<Home>]], 'Goto beginning of line')
m.inoremap([[<C-e>]], [[<End>]], 'Goto end of line')
m.inoremap([[<C-b>]], [[<Left>]], 'Goto char backward')
m.inoremap([[<C-f>]], [[<Right>]], 'Goto char forward')
m.inoremap([[<M-b>]], [[<S-Left>]], 'Goto word backward')
m.inoremap([[<M-f>]], [[<S-Right>]], 'Goto word forward')
m.inoremap([[<C-d>]], [[<Delete>]], 'Kill char forward')
m.inoremap([[<M-d>]], [[<C-o>de]], 'Kill word forward')
m.inoremap([[<M-Backspace>]], [[<C-o>dB]], 'Kill word backward')
m.inoremap([[<C-k>]], [[<C-o>D]], 'Kill to end of line')

m.inoremap([[<M-h>]], [[<Left>]])
m.inoremap([[<M-j>]], [[<Down>]])
m.inoremap([[<M-k>]], [[<Up>]])
m.inoremap([[<M-l>]], [[<Right>]])

m.inoremap([[<M-a>]], [[<C-o>_]])

-- unicode stuff
m.inoremap(xk [[<C-'>]], [[<C-k>]], 'Insert digraph')
m.nnoremap([[gxa]], [[ga]], 'Show char code in decimal, hexadecimal and octal')

-- nano-like kill buffer
-- TODO
vim.cmd [[
  let @k=''
  let @l=''
]]
m.nnoremap([[<F30>]], [["ldd:let @k=@k.@l | let @l=@k<Cr>]], m.silent)
m.nnoremap([[<F24>]], '<Cmd>if @l != "" | let @k=@l | end<Cr>"KgP:let @l=@k<Cr>:let @k=""<Cr>', m.silent)

m.inoremap(xk [[<C-`>]], [[<C-o>~<Left>]], 'Toggle case')

-- emacs-style motion & editing in command mode
m.cnoremap([[<C-a>]], [[<Home>]]) -- Goto beginning of line
m.cnoremap([[<C-b>]], [[<Left>]]) -- Goto char backward
m.cnoremap([[<C-d>]], [[<Delete>]]) -- Kill char forward
m.cnoremap([[<C-f>]], [[<Right>]]) -- Goto char forward
m.cnoremap([[<C-g>]], [[<C-c>]]) -- Cancel
m.cnoremap([[<C-k>]], [[<C-\>e(" ".getcmdline())[:getcmdpos()-1][1:]<Cr>]]) -- Kill to end of line
m.cnoremap([[<M-f>]], [[<C-\>euser#fn#cmdlineMoveWord( 1, 0)<Cr>]]) -- Goto word forward
m.cnoremap([[<M-b>]], [[<C-\>euser#fn#cmdlineMoveWord(-1, 0)<Cr>]]) -- Goto word backward
m.cnoremap([[<M-d>]], [[<C-\>euser#fn#cmdlineMoveWord( 1, 1)<Cr>]]) -- Kill word forward
m.cnoremap([[<M-Backspace>]], [[<C-\>euser#fn#cmdlineMoveWord(-1, 1)<Cr>]]) -- Kill word backward

m.cnoremap([[<M-k>]], [[<C-k>]]) -- Insert digraph

-- Make c-n and c-p behave like up/down arrows, i.e. take into account the
-- beginning of the text entered in the command line when jumping, but only if
-- the pop-up menu (completion menu) is not visible
-- See: https://github.com/mhinz/vim-galore#saner-command-line-history
m.cnoremap([[<c-p>]], [[pumvisible() ? "\<C-p>" : "\<Up>"]], m.expr, 'History prev')
m.cnoremap([[<c-n>]], [[pumvisible() ? "\<C-n>" : "\<Down>"]], m.expr, 'History next')
m.cmap([[<M-/>]], [[pumvisible() ? "\<C-y>" : "\<M-/>"]], m.expr, 'Accept completion suggestion')
m.cmap(
  xk [[<C-/>]],
  [[pumvisible() ? "\<C-y>\<Tab>" : nr2char(0x001f)]],
  m.expr,
  'Accept completion suggestion and continue completion'
)

local function cursor_lock(lock)
  return function()
    local win = vim.api.nvim_get_current_win()
    local augid = vim.api.nvim_create_augroup('user_cursor_lock_' .. win, { clear = true })
    if not lock or vim.w.cursor_lock == lock then
      vim.w.cursor_lock = nil
      fn.notify 'Cursor lock disabled'
      return
    end
    local cb = function()
      if vim.w.cursor_lock then
        vim.cmd('silent normal z' .. vim.w.cursor_lock)
      end
    end
    vim.w.cursor_lock = lock
    vim.api.nvim_create_autocmd('CursorMoved', {
      desc = 'Cursor lock for window ' .. win,
      buffer = 0,
      group = augid,
      callback = cb,
    })
    cb()
    fn.notify 'Cursor lock enabled'
  end
end

m.nnoremap([[<leader>zt]], cursor_lock 't', m.silent, 'Toggle cursor lock (top)')
m.nnoremap([[<leader>zz]], cursor_lock 'z', m.silent, 'Toggle cursor lock (middle)')
m.nnoremap([[<leader>zb]], cursor_lock 'b', m.silent, 'Toggle cursor lock (bottom)')

m.inoremap([[<M-t>]], [[<C-o>zt]], m.silent, 'Scroll current line to top of screen')
m.inoremap([[<M-z>]], [[<C-o>zz]], m.silent, 'Scroll current line to middle of screen')
m.inoremap([[<M-b>]], [[<C-o>zb]], m.silent, 'Scroll current line to bottom of screen')

---- Jumplist
m.nnoremap(xk [[<C-S-o>]], iwrap(fn.jumplist_jump_buf, -1), m.silent, 'Jumplist: Go to last buffer')
m.nnoremap(xk [[<C-S-i>]], iwrap(fn.jumplist_jump_buf, 1), m.silent, 'Jumplist: Go to next buffer')

---- Tabs
-- Navigate tabs
-- Go to a tab by index; If it doesn't exist, create a new tab
local function tabnm(n)
  return function()
    local tabs = vim.api.nvim_list_tabpages()
    if n > #tabs then
      vim.cmd '$tabnew'
    else
      local tabpage = tabs[n]
      vim.api.nvim_set_current_tabpage(tabpage)
    end
  end
end

m.noremap([[<M-'>]], '<Cmd>tabn<Cr>', m.silent, 'Tabs: Goto next')
m.noremap([[<M-;>]], '<Cmd>tabp<Cr>', m.silent, 'Tabs: Goto prev')
m.tnoremap([[<M-'>]], [[<C-\><C-n>:tabn<Cr>]], m.silent) -- Tabs: goto next
m.tnoremap([[<M-;>]], [[<C-\><C-n>:tabp<Cr>]], m.silent) -- Tabs: goto prev
m.noremap([[<M-S-a>]], [[:execute "wincmd g\<Tab>"<Cr>]], m.silent, 'Tabs: Goto last accessed')

m.noremap([[<M-a>]], iwrap(recent_wins.focus_most_recent), m.silent, 'Panes: Goto previously focused')
m.noremap([[<M-x>]], iwrap(recent_wins.flip_recents), m.silent, 'Panes: Flip the last normal wins')

m.noremap([[<M-1>]], tabnm(1), m.silent, 'Goto tab 1')
m.noremap([[<M-2>]], tabnm(2), m.silent, 'Goto tab 2')
m.noremap([[<M-3>]], tabnm(3), m.silent, 'Goto tab 3')
m.noremap([[<M-4>]], tabnm(4), m.silent, 'Goto tab 4')
m.noremap([[<M-5>]], tabnm(5), m.silent, 'Goto tab 5')
m.noremap([[<M-6>]], tabnm(6), m.silent, 'Goto tab 6')
m.noremap([[<M-7>]], tabnm(7), m.silent, 'Goto tab 7')
m.noremap([[<M-8>]], tabnm(8), m.silent, 'Goto tab 8')
m.noremap([[<M-9>]], tabnm(9), m.silent, 'Goto tab 9')
m.noremap([[<M-0>]], tabnm(10), m.silent, 'Goto tab 10')

m.noremap([[<M-">]], '<Cmd>+tabm<Cr>', m.silent, 'Move tab right')
m.noremap([[<M-:>]], '<Cmd>-tabm<Cr>', m.silent, 'Move tab left')

m.noremap([[<F13>]], '<Cmd>tabnew<Cr>', m.silent, 'Open new tab')

m.tnoremap([[<M-h>]], [[<C-\><C-n><C-w>h]]) -- Goto tab left
m.tnoremap([[<M-j>]], [[<C-\><C-n><C-w>j]]) -- Goto tab down
m.tnoremap([[<M-k>]], [[<C-\><C-n><C-w>k]]) -- Goto tab up
m.tnoremap([[<M-l>]], [[<C-\><C-n><C-w>l]]) -- Goto tab right

m.nnoremap([[<leader>sa]], '<Cmd>wincmd =<Cr>', m.silent, 'Auto-resize')
-- m.nnoremap ([[<leader>sa]], auto_resize.enable,  "Enable auto-resize")
-- m.nnoremap ([[<leader>sA]], auto_resize.disable, "Disable auto-resize")

m.nnoremap([[<leader>sf]], iwrap(fn.toggle_winfix, 'height'), 'Toggle fixed window height')
m.nnoremap([[<leader>sF]], iwrap(fn.toggle_winfix, 'width'), 'Toggle fixed window width')

m.nnoremap([[<leader>s<M-f>]], iwrap(fn.set_winfix, true, 'height', 'width'), 'Enable fixed window height/width')
m.nnoremap([[<leader>s<C-f>]], iwrap(fn.set_winfix, false, 'height', 'width'), 'Disable fixed window height/width')

-- see also the VSplit plugin mappings below
m.nnoremap([[<leader>S]], '<Cmd>new<Cr>', m.silent, 'Split (horiz, new)')
m.nnoremap([[<leader>sn]], '<Cmd>new<Cr>', m.silent, 'Split (horiz, new)')
m.nnoremap([[<leader>V]], '<Cmd>vnew<Cr>', m.silent, 'Split (vert, new)')
m.nnoremap([[<leader>vn]], '<Cmd>vnew<Cr>', m.silent, 'Split (vert, new)')
m.nnoremap([[<leader>ss]], '<Cmd>split<Cr>', m.silent, 'Split (horiz, cur)')
m.nnoremap([[<leader>st]], '<Cmd>split<Cr>', m.silent, 'Split (horiz, cur)')
m.nnoremap([[<leader>vv]], '<Cmd>vsplit<Cr>', m.silent, 'Split (vert, cur)')
m.nnoremap([[<leader>vt]], '<Cmd>vsplit<Cr>', m.silent, 'Split (vert, cur)')

m.xnoremap([[<leader>S]], '<Cmd>VSSplitAbove<Cr>', m.silent, 'Visual Split (above)')
m.xnoremap([[<leader>ss]], '<Cmd>VSSplitAbove<Cr>', m.silent, 'Visual Split (above)')
m.xnoremap([[<leader>sS]], '<Cmd>VSSplit<Cr>', m.silent, 'Visual Split (below)')

m.xnoremap([[<leader>I]], [[<Esc>:call user#fn#interleave()<Cr>]], m.silent, 'Interleave two contiguous blocks')

-- Tabline
local tabline = require 'user.tabline'
m.nmap({ '<C-t><C-l>', '<C-t>l' }, tabline.tabpage_toggle_titlestyle, 'Tabpage: Toggle title style')
m.nmap({ '<C-t><C-t>', '<C-t>t' }, tabline.do_rename_tab, 'Tabpage: Set title')
m.nmap({ '<C-t><C-h>', '<C-t>h' }, tabline.toggle_hide, 'Tabline: Toggle hide')

-- PasteRestore
-- paste register without overwriting with the original selection
-- use P for original behavior
m.xnoremap([[p]], [[user#fn#pasteRestore()]], m.silent, m.expr)

m.tnoremap(xk [[<C-S-n>]], [[<C-\><C-n>]]) -- Enter Normal mode
m.tnoremap([[<C-n>]], [[<C-n>]])
m.tnoremap([[<C-p>]], [[<C-p>]])
m.tnoremap([[<M-n>]], [[<M-n>]])
m.tnoremap([[<M-p>]], [[<M-p>]])

m.nnoremap([[<Leader>ml]], '<Cmd>call AppendModeline()<Cr>', m.silent, 'Append modeline with current settings')

------ Filetypes
m.group(m.silent, { ft = 'lua' }, function()
  m.nmap([[<leader><Enter>]], fn.luarun, 'Lua: Eval line')
  m.nmap([[<localleader><Enter>]], iwrap(fn.luarun, true), 'Lua: Eval file')
  m.xmap([[<leader><Enter>]], fn.luarun, 'Lua: Eval selection')

  m.nmap([[<leader><F12>]], "<Cmd>Put lua require'user.fn'.luarun()<Cr>", 'Lua: Eval line (Append)')
  m.xmap([[<leader><F12>]], "<Cmd>Put lua require'user.fn'.luarun()<Cr>", 'Lua: Eval selection (Append)')
end)

m.group(m.silent, { ft = { 'typescriptreact', 'javascriptreact' } }, function()
  local tailwind_sort = function()
    fn.transform_visual_selection({ 'rustywind', '--stdin', '--custom-regex', '(.*)' }, function(pre)
      -- if the selection includes quotes at the beginning and end, remove them
      local first = pre:sub(0, 1)
      local last = pre:sub(-1)
      if first == last and (first == "'" or first == '"' or first == '`') then
        return pre:sub(2, -2), { first, last }
      end
      return pre
    end, function(post, ctx)
      -- if the selection was quoted, re-add the quotes
      if ctx then
        return ctx[1] .. post .. ctx[2]
      end
      return post
    end)
  end
  m.xmap([[<leader>ft]], function()
    tailwind_sort()
  end)
  m.nmap([[<leader>ft]], function()
    require('nvim-treesitter.textobjects.select').select_textobject('@string', 'textobjects', 'x')
    tailwind_sort()
  end)
end)

m.group(m.silent, { ft = 'man' }, function()
  -- open manpage tag (e.g. isatty(3)) in current buffer
  m.nnoremap([[<C-]>]], function()
    fn.man('', vim.fn.expand '<cword>')
  end, 'Man: Open tag in current buffer')
  m.nnoremap([[<M-]>]], function()
    fn.man('tab', vim.fn.expand '<cword>')
  end, 'Man: Open tag in new tab')
  m.nnoremap([[}]], function()
    fn.man('split', vim.fn.expand '<cword>')
  end, 'Man: Open tag in new split')

  -- TODO
  -- go back to previous manpage
  -- nnoremap ([[<C-t>]],   [[:call man#pop_page))
  -- nnoremap ([[<C-o>]],   '<Cmd>call man#pop_page()<Cr>')
  -- nnoremap ([[<M-o>]],   [[<C-o>]])

  -- navigate to next/prev section
  m.nnoremap('[[', [[:<C-u>call user#fn#manSectionMove('b', 'n', v:count1)<Cr>]], m.silent, 'Man: Goto prev section')
  m.nnoremap(']]', [[:<C-u>call user#fn#manSectionMove('' , 'n', v:count1)<Cr>]], m.silent, 'Man: Goto next section')
  m.xnoremap('[[', [[:<C-u>call user#fn#manSectionMove('b', 'v', v:count1)<Cr>]], m.silent, 'Man: Goto prev section')
  m.xnoremap(']]', [[:<C-u>call user#fn#manSectionMove('' , 'v', v:count1)<Cr>]], m.silent, 'Man: Goto next section')

  -- navigate to next/prev manpage tag
  m.nnoremap([[<Tab>]], [[:call search('\(\w\+(\w\+)\)', 's')<Cr>]], m.silent, 'Man: Goto next tag')
  m.nnoremap([[<S-Tab>]], [[:call search('\(\w\+(\w\+)\)', 'sb')<Cr>]], m.silent, 'Man: Goto prev tag')

  -- search from beginning of line (useful for finding command args like -h)
  m.nnoremap([[g/]], [[/^\s*\zs]], { silent = false }, 'Man: Start BOL search')
end)

------ LSP
m.nname('<leader>l', 'LSP')
m.nnoremap([[<leader>lif]], '<Cmd>LspInfo<Cr>', m.silent, 'LSP: Show LSP information')
m.nnoremap([[<leader>lr]], '<Cmd>LspRestart<Cr>', m.silent, 'LSP: Restart LSP')
m.nnoremap([[<leader>ls]], '<Cmd>LspStart<Cr>', m.silent, 'LSP: Start LSP')
m.nnoremap([[<leader>lS]], '<Cmd>LspStop<Cr>', m.silent, 'LSP: Stop LSP')

local lsp_attached_bufs
M.on_first_lsp_attach = function()
  ---- trouble.nvim
  local trouble = fn.require_on_call_rec 'trouble'
  local function trouble_get_win()
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
      if ft == 'Trouble' then
        return winid
      end
    end
  end

  m.nmap([[<M-S-t>]], function()
    local winid = trouble_get_win()
    if winid then
      trouble.close()
    else
      trouble.open()
      recent_wins.focus_most_recent()
    end
  end, m.silent, 'Trouble: Toggle')
  m.nmap(
    [[<M-t>]],
    fn.filetype_command('Trouble', iwrap(recent_wins.focus_most_recent), iwrap(trouble.open)),
    m.silent,
    'Trouble: Toggle Focus'
  )

  local user_lsp = fn.require_on_call_rec 'user.lsp'
  m.nname('<leader>li', 'LSP-InlayHints')
  m.nnoremap([[<leader>lii]], iwrap(user_lsp.set_inlay_hints_global), 'LSP: Toggle inlay hints')
  m.nnoremap([[<leader>lie]], iwrap(user_lsp.set_inlay_hints_global, true), 'LSP: Enable inlay hints')
  m.nnoremap([[<leader>lid]], iwrap(user_lsp.set_inlay_hints_global, false), 'LSP: Disable inlay hints')
end

M.on_lsp_attach = function(bufnr)
  if not lsp_attached_bufs then
    lsp_attached_bufs = {}
    M.on_first_lsp_attach()
  elseif lsp_attached_bufs[bufnr] or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  lsp_attached_bufs[bufnr] = true

  local user_lsp = fn.require_on_call_rec 'user.lsp'
  local trouble = fn.require_on_call_rec 'trouble'

  m.group({ buffer = bufnr, silent = true }, function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    m.nname('<localleader>i', 'LSP-InlayHints')
    m.nnoremap([[<localleader>ii]], iwrap(user_lsp.set_inlay_hints, 0), 'LSP: Toggle inlay hints for buffer')
    m.nnoremap([[<localleader>ie]], iwrap(user_lsp.set_inlay_hints, 0, true), 'LSP: Enable inlay hints for buffer')
    m.nnoremap([[<localleader>id]], iwrap(user_lsp.set_inlay_hints, 0, false), 'LSP: Disable inlay hints for buffer')

    m.nname('<localleader>g', 'LSP-Glance')
    m.nnoremap([[<localleader>gD]], iwrap(vim.lsp.buf.declaration), 'LSP: Goto declaration')
    m.nnoremap({ [[<localleader>gd]], [[gd]] }, [[<Cmd>Glance definitions<Cr>]], 'LSP: Glance definitions')
    m.nnoremap([[<localleader>gi]], [[<Cmd>Glance implementations<Cr>]], 'LSP: Glance implementation')
    m.nnoremap([[<localleader>gt]], [[<Cmd>Glance type_definitions<Cr>]], 'LSP: Glance type definitions')
    m.nnoremap([[<localleader>gr]], [[<Cmd>Glance references<Cr>]], 'LSP: Glance references')

    m.nname('<localleader>w', 'LSP-Workspace')
    m.nnoremap([[<localleader>wa]], iwrap(vim.lsp.buf.add_workspace_folder), 'LSP: Add workspace folder')
    m.nnoremap([[<localleader>wr]], iwrap(vim.lsp.buf.remove_workspace_folder), 'LSP: Rm workspace folder')

    m.nnoremap([[<localleader>wl]], function()
      fn.inspect(vim.lsp.buf.list_workspace_folders())
    end, 'LSP: List workspace folders')

    m.nnoremap([[<localleader>R]], function()
      require 'inc_rename'
      return ':IncRename ' .. vim.fn.expand '<cword>'
    end, m.expr, 'LSP: Rename')

    -- m.nnoremap({ [[<localleader>A]], [[<localleader>ca]] }, ithunk(vim.lsp.buf.code_action), "LSP: Code action")
    -- m.xnoremap({ [[<localleader>A]], [[<localleader>ca]] }, ithunk(vim.lsp.buf.range_code_action),
    --   "LSP: Code action (range)")
    local code_actions = fn.require_on_call_rec('actions-preview').code_actions
    m.nnoremap({ [[<localleader>A]], [[<localleader>ca]] }, iwrap(code_actions), 'LSP: Code action')
    m.xnoremap({ [[<localleader>A]], [[<localleader>ca]] }, iwrap(code_actions), 'LSP: Code action')

    local function gotoDiag(dir, sev)
      return function()
        local _dir = dir
        local args = {
          enable_popup = true,
          severity = vim.diagnostic.severity[sev],
        }
        if _dir == 'first' or _dir == 'last' then
          args.wrap = false
          if dir == 'first' then
            args.cursor_position = { 1, 1 }
            _dir = 'next'
          else
            args.cursor_position = { vim.api.nvim_buf_line_count(0) - 1, 1 }
            _dir = 'prev'
          end
        end
        vim.diagnostic['goto_' .. _dir](args)
      end
    end

    m.nname('<localleader>d', 'LSP-Diagnostics')
    m.nnoremap([[<localleader>ds]], iwrap(vim.diagnostic.show), 'LSP: Show diagnostics')
    m.nnoremap({ [[<localleader>dt]], [[<localleader>T]] }, iwrap(trouble.toggle), 'LSP: Toggle Trouble')
    m.nnoremap([[<localleader>dd]], function()
      if vim.diagnostic.is_disabled(0) then
        vim.diagnostic.enable(0)
        vim.notify 'Diagnostics enabled'
      else
        vim.diagnostic.disable(0)
        vim.notify 'Diagnostics disabled'
      end
    end, 'LSP: Toggle Diagnostic')

    m.nnoremap('[d', gotoDiag 'prev', 'LSP: Goto prev diagnostic')
    m.nnoremap(']d', gotoDiag 'next', 'LSP: Goto next diagnostic')
    m.nnoremap('[h', gotoDiag('prev', 'HINT'), 'LSP: Goto prev hint')
    m.nnoremap(']h', gotoDiag('next', 'HINT'), 'LSP: Goto next hint')
    m.nnoremap('[i', gotoDiag('prev', 'INFO'), 'LSP: Goto prev info')
    m.nnoremap(']i', gotoDiag('next', 'INFO'), 'LSP: Goto next info')
    m.nnoremap('[w', gotoDiag('prev', 'WARN'), 'LSP: Goto prev warning')
    m.nnoremap(']w', gotoDiag('next', 'WARN'), 'LSP: Goto next warning')
    m.nnoremap('[e', gotoDiag('prev', 'ERROR'), 'LSP: Goto prev error')
    m.nnoremap(']e', gotoDiag('next', 'ERROR'), 'LSP: Goto next error')

    m.nnoremap('[D', gotoDiag 'first', 'LSP: Goto first diagnostic')
    m.nnoremap(']D', gotoDiag 'last', 'LSP: Goto last diagnostic')
    m.nnoremap('[H', gotoDiag('first', 'HINT'), 'LSP: Goto first hint')
    m.nnoremap(']H', gotoDiag('last', 'HINT'), 'LSP: Goto last hint')
    m.nnoremap('[I', gotoDiag('first', 'INFO'), 'LSP: Goto first info')
    m.nnoremap(']I', gotoDiag('last', 'INFO'), 'LSP: Goto last info')
    m.nnoremap('[W', gotoDiag('first', 'WARN'), 'LSP: Goto first warning')
    m.nnoremap(']W', gotoDiag('last', 'WARN'), 'LSP: Goto last warning')
    m.nnoremap('[E', gotoDiag('first', 'ERROR'), 'LSP: Goto first error')
    m.nnoremap(']E', gotoDiag('last', 'ERROR'), 'LSP: Goto last error')

    m.nname('<localleader>s', 'LSP-Search')
    m.nnoremap(
      { [[<localleader>so]], [[<leader>so]] },
      iwrap(fn.require_on_call_rec('user.plugin.telescope').cmds.lsp_document_symbols),
      'LSP: Telescope symbol search'
    )

    m.nname('<localleader>h', 'LSP-Hover')
    m.nnoremap([[<localleader>hs]], iwrap(vim.lsp.buf.signature_help), 'LSP: Signature help')
    m.nnoremap([[<localleader>ho]], iwrap(vim.lsp.buf.hover), 'LSP: Hover')
    m.noremap([[<M-i>]], iwrap(vim.lsp.buf.hover), 'LSP: Hover')
    m.inoremap([[<M-i>]], iwrap(vim.lsp.buf.hover), 'LSP: Hover')
    m.nnoremap([[<M-S-i>]], iwrap(user_lsp.peek_definition), 'LSP: Peek definition')
  end)
end

------ Plugins
---- folke/which-key.nvim
m.nnoremap([[<leader><leader>]], '<Cmd>WhichKey<Cr>', m.silent, 'WhichKey: Show all')

---- AndrewRadev/splitjoin.vim
-- m.nnoremap([[gJ]], '<Cmd>SplitjoinJoin<Cr>', "Splitjoin: Join")
-- m.nnoremap([[gS]], '<Cmd>SplitjoinSplit<Cr>', "Splitjoin: Split")

---- Wansmer/treesj
local treesj = fn.require_on_call_rec 'treesj'
m.nnoremap([[gJ]], iwrap(treesj.toggle), 'Treesj: Toggle')
m.nnoremap([[gsj]], iwrap(treesj.join), 'Treesj: Join')
m.nnoremap({ [[gS]], [[gss]] }, iwrap(treesj.split), 'Treesj: Split')

---- numToStr/Comment.nvim
local comment = fn.require_on_call_rec 'Comment.api'
m.nnoremap([[<M-/>]], iwrap(comment.toggle.linewise), m.silent)
m.xnoremap([[<M-/>]], function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
  comment.toggle.linewise(vim.fn.visualmode())
end, m.silent)

---- aserowy/tmux.nvim
local tmux = fn.require_on_exported_call 'tmux'
local function tmux_move(dir)
  return function()
    if vim.bo.filetype == 'toggleterm' then
      local key = ({ left = 'h', right = 'l', top = 'k', bottom = 'j' })[dir]
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(xk [[<M-Space>]] .. key, true, false, true), 'n', false)
    else
      tmux['move_' .. dir]()
    end
  end
end

m.nmap([[<M-h>]], iwrap(tmux.move_left), m.silent, 'Goto window/tmux pane left')
m.nmap([[<M-j>]], iwrap(tmux.move_bottom), m.silent, 'Goto window/tmux pane down')
m.nmap([[<M-k>]], iwrap(tmux.move_top), m.silent, 'Goto window/tmux pane up')
m.nmap([[<M-l>]], iwrap(tmux.move_right), m.silent, 'Goto window/tmux pane right')
m.tnoremap([[<M-h>]], tmux_move 'left', m.silent, 'Goto window/tmux pane left')
m.tnoremap([[<M-j>]], tmux_move 'bottom', m.silent, 'Goto window/tmux pane down')
m.tnoremap([[<M-k>]], tmux_move 'top', m.silent, 'Goto window/tmux pane up')
m.tnoremap([[<M-l>]], tmux_move 'right', m.silent, 'Goto window/tmux pane right')

m.group(m.silent, function()
  local tu = fn.require_on_call_rec 'user.plugin.telescope'
  local tc = tu.cmds

  m.nname([[<C-f>]], 'Telescope')
  m.nnoremap(xk [[<C-S-f>]], iwrap(tc.builtin), 'Telescope: Builtins')
  m.nnoremap([[<C-f>b]], iwrap(tc.buffers), 'Telescope: Buffers')
  m.nnoremap({ [[<C-f>h]], [[<C-f><C-h>]] }, iwrap(tc.help_tags), 'Telescope: Help tags')
  m.nnoremap({ [[<C-f>t]], [[<C-f><C-t>]] }, iwrap(tc.tags), 'Telescope: Tags')
  m.nnoremap({ [[<C-f>a]], [[<C-f><C-a>]] }, iwrap(tc.grep_string), 'Telescope: Grep for string')
  m.nnoremap({ [[<C-f>p]], [[<C-f><C-p>]] }, iwrap(tc.live_grep_args), 'Telescope: Live grep')
  m.nnoremap({ [[<C-f>o]], [[<C-f><C-o>]] }, iwrap(tc.oldfiles), 'Telescope: Old files')
  m.nnoremap({ [[<C-f>f]], [[<C-f><C-f>]] }, iwrap(tc.smart_files), 'Telescope: Files (Smart)')
  m.nnoremap({ [[<C-f>F]] }, iwrap(tc.any_files), 'Telescope: Any Files')
  m.nnoremap({ [[<C-f>w]], [[<C-f><C-w>]] }, iwrap(tc.windows, {}), 'Telescope: Windows')
  m.nnoremap({ [[<C-f>i]], [[<C-f><C-i>]] }, '<Cmd>Easypick headers<Cr>', m.silent, 'Telescope: Includes (headers)')

  m.nnoremap({ [[<C-M-f>]], [[<C-f>r]], [[<C-f><C-r>]] }, iwrap(tc.resume), 'Telescope: Resume last picker')

  m.nname([[<C-f>g]], 'Telescope-Git')
  m.nnoremap([[<C-f>gf]], iwrap(tc.git_files), 'Telescope-Git: Files')

  m.nname([[<M-f>]], 'Telescope-Buffer')
  m.nnoremap({ [[<M-f>b]], [[<M-f><M-b>]] }, iwrap(tc.current_buffer_fuzzy_find), 'Telescope-Buffer: Fuzzy find')
  m.nnoremap({ [[<M-f>t]], [[<M-f><M-t>]] }, iwrap(tc.tags), 'Telescope-Buffer: Tags')
  -- m.nnoremap({ [[<M-f>u]], [[<M-f><M-u>]] }, ithunk(tc.urlview), "Telescope-Buffer: URLs")

  m.nname([[<M-f>]], 'Telescope-Workspace')
  m.nnoremap([[<C-f>A]], iwrap(tc.aerial), 'Telescope-Workspace: Aerial')
end)

---- NeogitOrg/neogit
-- TODO: Use official API if/when merged:
-- https://github.com/NeogitOrg/neogit/pull/865
local git = fn.require_on_call_rec 'neogit.lib.git'
local git_cli = fn.require_on_call_rec 'neogit.lib.git.cli'

local neogit_action = function(popup, action, args)
  return function()
    require('plenary.async').run(function()
      require('neogit.popups.' .. popup .. '.actions')[action] {
        state = { env = {} },
        get_arguments = function()
          return args
        end,
      }
    end)
  end
end

local async_action = function(cmd, ...)
  local arg0 = ...
  local args = { select(2, ...) }
  return function()
    require('plenary.async').run(function()
      if type(arg0) == 'function' then
        cmd(arg0(unpack(args)))
      else
        cmd(arg0, unpack(args))
      end
    end)
  end
end

m.nnoremap({ [[<leader>G]], [[<leader>gg]], [[<leader>gs]] }, '<Cmd>Neogit<Cr>', m.silent, 'Neogit')

m.nname('<leader>g', 'Git')
m.nname('<leader>ga', 'Git-Add')
m.nnoremap(
  { [[<leader>gA]], [[<leader>gaa]] },
  async_action(function()
    git_cli.add.args('--all').call()
  end),
  'Git: Add all'
)
m.nnoremap(
  [[<leader>gaf]],
  async_action(git.index.add, function()
    return { vim.fn.expand '%:p' }
  end),
  'Git: Add file'
)

m.nname('<leader>gc', 'Git-Commit')
m.nnoremap([[<leader>gC]], '<Cmd>Neogit commit<Cr>', m.silent, 'Neogit: Commit popup')
m.nnoremap([[<leader>gcc]], neogit_action('commit', 'commit', { '--verbose' }), 'Git: Commit')
m.nnoremap([[<leader>gca]], neogit_action('commit', 'commit', { '--verbose', '--all' }), 'Git: Commit (all)')
m.nnoremap([[<leader>gcA]], neogit_action('commit', 'commit', { '--verbose', '--amend' }), 'Git: Commit (amend)')

m.nnoremap([[<leader>gl]], '<Cmd>Neogit log<Cr>', m.silent, 'Git: Log')

m.nname('<leader>gp', 'Git-Push-Pull')
m.nnoremap([[<leader>gp]], '<Cmd>Neogit push<Cr>', m.silent, 'Neogit: Push popup')
m.nnoremap([[<leader>gP]], '<Cmd>Neogit pull<Cr>', m.silent, 'Neogit: Pull popup')

m.nnoremap([[<leader>gR]], async_action(git_cli.reset.call), 'Git: Reset')

local function gitsigns_visual_op(op)
  return function()
    return require('gitsigns')[op] { vim.fn.line '.', vim.fn.line 'v' }
  end
end

-- lewis6991/gitsigns.nvim
M.on_gistsigns_attach = function(bufnr)
  m.group({ buffer = bufnr, silent = true }, function()
    local gs = require 'gitsigns'
    m.nnoremap([[<leader>hs]], iwrap(gs.stage_hunk), 'Gitsigns: Stage hunk')
    m.nnoremap([[<leader>hr]], iwrap(gs.reset_hunk), 'Gitsigns: Reset hunk')
    m.nnoremap([[<leader>hu]], iwrap(gs.undo_stage_hunk), 'Gitsigns: Undo stage hunk')
    m.xnoremap([[<leader>hs]], gitsigns_visual_op 'stage_hunk', 'Gitsigns: Stage selected hunk(s)')
    m.xnoremap([[<leader>hr]], gitsigns_visual_op 'reset_hunk', 'Gitsigns: Reset selected hunk(s)')
    m.xnoremap([[<leader>hu]], gitsigns_visual_op 'undo_stage_hunk', 'Gitsigns: Undo stage hunk')
    m.nnoremap([[<leader>hS]], iwrap(gs.stage_buffer), 'Gitsigns: Stage buffer')
    m.nnoremap([[<leader>hR]], iwrap(gs.reset_buffer), 'Gitsigns: Reset buffer')
    m.nnoremap([[<leader>hp]], iwrap(gs.preview_hunk), 'Gitsigns: Preview hunk')
    m.nnoremap([[<leader>hb]], iwrap(gs.blame_line, { full = true }), 'Gitsigns: Blame hunk')
    m.nnoremap([[<leader>htb]], iwrap(gs.toggle_current_line_blame), 'Gitsigns: Toggle current line blame')
    m.nnoremap([[<leader>hd]], iwrap(gs.diffthis), 'Gitsigns: Diff this')
    m.nnoremap([[<leader>hD]], iwrap(gs.diffthis, '~'), 'Gitsigns: Diff this against last commit')
    m.nnoremap([[<leader>htd]], iwrap(gs.toggle_deleted), 'Gitsigns: Toggle deleted')

    m.nnoremap(']c', "&diff ? ']c' : '<Cmd>Gitsigns next_hunk<Cr>'", 'Gitsigns: Next hunk', m.expr)
    m.nnoremap('[c', "&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<Cr>'", 'Gitsigns: Prev hunk', m.expr)
    m.onoremap([[ih]], '<Cmd><C-U>Gitsigns select_hunk<Cr>', '[TextObj] Gitsigns: Inner hunk')
    m.xnoremap([[ih]], '<Cmd><C-U>Gitsigns select_hunk<Cr>', '[TextObj] Gitsigns: Inner hunk')
  end)
end

-- mbbill/undotree
m.nnoremap([[<leader>ut]], '<Cmd>UndotreeToggle<Cr>', m.silent, 'Undotree: Toggle')

-- godlygeek/tabular
m.nmap([[<Leader>a]], ':Tabularize /', 'Tabularize')
m.xmap([[<Leader>a]], ':Tabularize /', 'Tabularize')

---- KabbAmine/vCoolor.vim
m.nmap([[<leader>co]], '<Cmd>VCoolor<Cr>', m.silent, 'Open VCooler color picker')

------ nvim-neo-tree/neo-tree.nvim & kyazdani42/nvim-tree.lua
---- nvim-neo-tree/neo-tree.nvim
local neotree_mgr = fn.require_on_call_rec 'neo-tree.sources.manager'
local user_neotree = {}
user_neotree.get_state = function()
  return neotree_mgr.get_state 'filesystem' or {}
end
user_neotree.is_visible = function()
  local state = user_neotree.get_state()
  local winid = state.winid or -1
  return vim.api.nvim_win_is_valid(winid), winid
end
local setup_neotree = function()
  m.nmap(xk [[<C-S-\>]], function()
    vim.cmd [[Neotree show toggle]]
    vim.schedule(auto_resize.trigger)
  end, m.silent, 'NeoTree: Toggle')

  m.nmap(
    xk [[<C-\>]],
    fn.filetype_command('neo-tree', iwrap(recent_wins.focus_most_recent), function()
      vim.cmd [[Neotree focus]]
      vim.schedule(auto_resize.trigger)
    end),
    m.silent,
    'Nvim-Tree: Toggle Focus'
  )
end

---- kyazdani42/nvim-tree.lua
local setup_nvimtree = function()
  m.nmap(xk [[<C-S-\>]], function()
    if require('nvim-tree.view').is_visible() then
      require('nvim-tree.view').close()
    else
      require('nvim-tree.lib').open()
      recent_wins.focus_most_recent()
    end
  end, m.silent, 'Nvim-Tree: Toggle')

  m.nmap(
    xk [[<C-\>]],
    fn.filetype_command('NvimTree', iwrap(recent_wins.focus_most_recent), wrap(vim.cmd, [[NvimTreeFocus]])),
    m.silent,
    'Nvim-Tree: Toggle Focus'
  )

  m.group({ ft = 'NvimTree' }, function()
    local function withSelected(cmd, fmt)
      return function()
        local file = require('nvim-tree.lib').get_node_at_cursor().absolute_path
        vim.cmd(fmt and (cmd):format(file) or ('%s %s'):format(cmd, file))
      end
    end

    m.nnoremap([[ga]], withSelected 'Git add', 'Nvim-Tree: Git add')
    m.nnoremap([[gr]], withSelected 'Git reset --quiet', 'Nvim-Tree: Git reset')
    m.nnoremap([[gb]], withSelected 'tabnew | Git blame', 'Nvim-Tree: Git blame')
    m.nnoremap([[gd]], withSelected 'tabnew | Gdiffsplit', 'Nvim-Tree: Git diff')
  end)
end

local setup_tree = function(use_neotree)
  if use_neotree ~= nil then
    vim.g.use_neotree = use_neotree
  end
  if vim.g.use_neotree then
    setup_neotree()
  else
    setup_nvimtree()
  end
end

local toggle_tree = function()
  local tree_foc = false
  local open_nvimtree = false
  local open_neotree = false
  if vim.g.use_neotree then
    if user_neotree.is_visible() then
      open_nvimtree = true
      if vim.api.nvim_buf_get_option(0, 'filetype') == 'neo-tree' then
        tree_foc = true
      end
      vim.cmd [[Neotree close]]
    end
  else
    if package.loaded['nvim-tree'] and require('nvim-tree.view').is_visible() then
      open_neotree = true
      if vim.api.nvim_buf_get_option(0, 'filetype') == 'NvimTree' then
        tree_foc = true
      end
      require('nvim-tree.view').close()
    end
  end

  vim.g.use_neotree = not vim.g.use_neotree
  vim.notify('Using ' .. (vim.g.use_neotree and 'NeoTree' or 'NvimTree'))
  setup_tree()

  if open_nvimtree then
    require('nvim-tree.lib').open()
    if not tree_foc then
      recent_wins.focus_most_recent()
    end
  elseif open_neotree then
    if tree_foc then
      vim.cmd [[Neotree focus]]
    else
      vim.cmd [[Neotree show]]
    end
  end
end

m.nmap(xk [[<C-S-t>]], toggle_tree, m.silent, 'Toggle selected file tree plugin')

setup_tree(false)

-- stevearc/aerial.nvim
local aerial = fn.require_on_index 'aerial'
local aerial_util = fn.require_on_index 'aerial.util'

local function aerial_get_win()
  local active_bufnr = aerial_util.get_aerial_buffer()
  if active_bufnr ~= -1 then
    local active_winid = aerial_util.buf_first_win_in_tabpage(active_bufnr)
    if active_winid then
      return active_winid
    end
  end
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local winbuf = vim.api.nvim_win_get_buf(winid)
    if aerial_util.is_aerial_buffer(winbuf) then
      return winid
    end
  end
end

local function aerial_open(focus)
  if not package.loaded.aerial then
    require 'aerial'
    require('aerial').close() -- force aerial setup
  end
  local winid = aerial_get_win()
  if winid then
    vim.api.nvim_set_current_win(winid)
    return
  end
  if not pcall(require('aerial.backends').get) then
    require('aerial').open()
    if not focus then
      recent_wins.focus_most_recent()
    end
    return
  end

  -- Get width of nvim-tree or neo-tree before opening aerial (sometimes
  -- opening aerial causes file tree windows to get smooshed)
  local nvt_win = package.loaded['nvim-tree'] and require('nvim-tree.view').get_winnr(0)
  local nvt_width
  if nvt_win and vim.api.nvim_win_is_valid(nvt_win) then
    nvt_width = vim.api.nvim_win_get_width(nvt_win)
  end
  local neo_vis, neo_win, neo_width
  if package.loaded['neo-tree'] then
    neo_vis, neo_win = user_neotree.is_visible()
    if neo_vis then
      neo_width = vim.api.nvim_win_get_width(neo_win)
    end
  end

  require('aerial').open { focus = focus or false }

  -- Reset tree window width in case smooshing occurred
  if nvt_width then
    vim.api.nvim_win_set_width(nvt_win, nvt_width)
  end
  if neo_width then
    vim.api.nvim_win_set_width(neo_win, neo_width)
  end

  auto_resize.trigger()
end

m.nmap(xk [[<M-S-\>]], function()
  if package.loaded.aerial and aerial_get_win() then
    local foc = require('aerial.util').is_aerial_buffer()
    aerial.close()
    if foc then
      recent_wins.focus_most_recent()
    end
  else
    aerial_open()
  end
end, m.silent, 'Aerial: Toggle')

m.nmap(
  [[<M-\>]],
  fn.filetype_command('aerial', iwrap(recent_wins.focus_most_recent), iwrap(aerial_open, true)),
  m.silent,
  'Aerial: Toggle Focus'
)

m.group(m.silent, { ft = 'aerial' }, function()
  local function aerial_select(opts)
    local winid = recent_wins.get_most_recent_smart()
    if not vim.api.nvim_win_is_valid(winid or -1) then
      winid = nil
    end
    require('aerial.navigation').select(vim.tbl_extend('force', {
      winid = winid,
    }, opts or {}))
  end

  local function aerial_view(cmd)
    vim.schedule(iwrap(aerial_select, { jump = false }))
    return cmd or '\\<Nop>'
  end

  m.nnoremap([[<Cr>]], iwrap(aerial_select), 'Aerial: Select item')
  m.nnoremap([[<Tab>]], iwrap(aerial_view), m.expr, 'Aerial: Bring item into view')
  m.nnoremap([[J]], iwrap(aerial_view, 'j'), m.expr, 'Aerial: Bring next item into view')
  m.nnoremap([[K]], iwrap(aerial_view, 'k'), m.expr, 'Aerial: Bring previous item into view')
end)

---- mfussenegger/nvim-dap
local function dap_pre()
  m.nnoremap([[<leader>D]], function()
    require('user.dap').launch(vim.bo.filetype)
  end, 'DAP: Launch')
end

dap_pre()

M.on_dap_attach = function()
  local dap = require 'dap'
  local dap_ui_vars = require 'dap.ui.variables'
  local dap_ui_widgets = require 'dap.ui.widgets'

  m.nnoremap([[<leader>D]], function()
    require('user.dap').close(vim.bo.filetype)
  end, 'DAP: Disconnect')

  local breakpointCond = function()
    dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
  end

  local toggleRepl = function()
    dap.repl.toggle({}, ' vsplit')
    vim.fn.wincmd 'l'
  end

  m.nname([[<leader>d]], 'DAP')
  m.nnoremap([[<leader>dR]], dap.restart, 'DAP: Restart')
  m.nnoremap([[<leader>dh]], dap.toggle_breakpoint, 'DAP: Toggle breakpoint')
  m.nnoremap([[<leader>dH]], breakpointCond, 'DAP: Set breakpoint condition')
  m.nnoremap([[<leader>de]], iwrap(dap.set_exception_breakpoints, { 'all' }), 'DAP: Break on exception')
  m.nnoremap([[<leader>dr]], toggleRepl, 'DAP: Toggle REPL')
  m.nnoremap([[<leader>di]], dap_ui_vars.hover, 'DAP: Hover variables')
  m.nnoremap([[<leader>di]], dap_ui_vars.visual_hover, 'DAP: Hover variables (visual)')
  m.nnoremap([[<leader>d?]], dap_ui_vars.scopes, 'DAP: Scopes')
  m.nnoremap([[<leader>dk]], dap.up, 'DAP: Up')
  m.nnoremap([[<leader>dj]], dap.down, 'DAP: Down')
  m.nnoremap([[<leader>di]], dap_ui_widgets.hover, 'DAP: Hover')
  m.nnoremap([[<leader>d?]], dap_ui_widgets.centered_float, dap_ui_widgets.scopes, 'DAP: Scopes')

  --   nnoremap([[<leader>dR]],  ithunk(dap.disconnect, {restart = false, terminateDebuggee = false}), "DAP: Restart")

  m.nnoremap({ [[<leader>dso]], [[<c-k>]] }, dap.step_out, 'DAP: Step out')
  m.nnoremap({ [[<leader>dsi]], [[<c-l>]] }, dap.step_into, 'DAP: Step into')
  m.nnoremap({ [[<leader>dsO]], [[<c-j>]] }, dap.step_over, 'DAP: Step over')
  m.nnoremap({ [[<leader>dsc]], [[<c-h>]] }, dap.continue, 'DAP: Continue')

  -- nnoremap([[<leader>da]],  require"debugHelper".attach()<Cr>')
  -- nnoremap([[<leader>dA]],  require"debugHelper".attachToRemote()<Cr>')
end

M.on_dap_detach = function()
  -- TODO
end

---- sindrets/winshift.nvim
m.nnoremap([[<Leader>M]], [[<Cmd>WinShift<Cr>]], 'WinShift: Start')
m.nnoremap([[<Leader>mm]], [[<Cmd>WinShift<Cr>]], 'WinShift: Start')
m.nnoremap([[<Leader>ws]], [[<Cmd>WinShift swap<Cr>]], 'WinShift: Swap')

---- chentau/marks.nvim
m.nmap([[<M-m>]], [[m;]], 'Mark: create next')
m.nnoremap([[]"]], [[[']], 'Mark: goto previous')
m.nnoremap([[<leader>']], iwrap(fn.require_on_call_rec('marks').toggle_signs), 'Mark: toggle signs')

---- mrjones2014/smart-splits.nvim
local smart_splits = fn.require_on_exported_call 'smart-splits'
m.noremap([[<M-[>]], iwrap(smart_splits.resize_left), 'Resize-Win: Left')
m.noremap([[<M-]>]], iwrap(smart_splits.resize_right), 'Resize-Win: Right')
m.noremap([[<M-{>]], iwrap(smart_splits.resize_up), 'Resize-Win: Up')
m.noremap([[<M-}>]], iwrap(smart_splits.resize_down), 'Resize-Win: Down')

---- github/copilot.vim
-- m.inoremap(xk [[<C-\>]], [[copilot#Accept("\<CR>")]], m.silent, m.expr, "Copilot: Accept")
-- m.inoremap([[]], [[copilot#Accept("\<CR>")]], m.silent, m.expr, "Copilot: Accept")

---- zbirenbaum/copilot.lua
local copilot_suggestion = fn.require_on_exported_call 'copilot.suggestion'
local copilot_panel = fn.require_on_exported_call 'copilot.panel'
local copilot_accept_or_insert = function(action, fallback)
  return function()
    if copilot_suggestion.is_visible() then
      copilot_suggestion[action]()
    else
      vim.api.nvim_put(vim.split(fallback, '\n'), 'c', false, true)
    end
  end
end

m.inoremap(xk [[<C-\>]], copilot_accept_or_insert('accept', '\n'), m.silent, 'Copilot: Accept') -- For Alacritty w/custom conf
m.inoremap([[]], copilot_accept_or_insert('accept', '\n'), m.silent, 'Copilot: Accept') -- For other terminals
m.inoremap([[<M-\>]], copilot_accept_or_insert('accept_word', ' '), m.silent, 'Copilot: Accept Word')
m.inoremap(xk [[<M-S-\>]], copilot_accept_or_insert('accept_line', '\n'), m.silent, 'Copilot: Accept Line')
m.inoremap([[<M-[>]], iwrap(copilot_suggestion.prev), m.silent, 'Copilot: Previous Suggestion')
m.inoremap([[<M-]>]], iwrap(copilot_suggestion.next), m.silent, 'Copilot: Next Suggestion')
m.inoremap(xk [[<C-S-\>]], iwrap(copilot_panel.open), m.silent, 'Copilot: Open panel')

---- monaqa/dial.nvim
local dial_map = require 'dial.map'
m.nnoremap([[<C-a>]], dial_map.inc_normal(), 'Dial: Increment')
m.nnoremap([[<C-x>]], dial_map.dec_normal(), 'Dial: Decrement')
m.vnoremap([[<C-a>]], dial_map.inc_visual(), 'Dial: Increment')
m.vnoremap([[<C-x>]], dial_map.dec_visual(), 'Dial: Decrement')
m.vnoremap([[g<C-a>]], dial_map.inc_gvisual(), 'Dial: Increment')
m.vnoremap([[g<C-x>]], dial_map.dec_gvisual(), 'Dial: Decrement')

---- Wansmer/sibling-swap.nvim
local sibling_swap = fn.require_on_call_rec 'sibling-swap'
m.nnoremap(xk [[<C-.>]], iwrap(sibling_swap.swap_with_right), 'Sibling-Swap: Swap with right')
m.nnoremap([[<F34>]], iwrap(sibling_swap.swap_with_left), 'Sibling-Swap: Swap with left')

---- jakemason/ouroboros.nvim
m.group(m.silent, { ft = { 'c', 'cpp' } }, function()
  m.nnoremap(
    { [[<leader>O]], [[<leader>oo]] },
    '<Cmd>Ouroboros<Cr>',
    m.silent,
    'Ouroboros: Switch between header and source file'
  )
  m.nnoremap([[<leader>os]], '<Cmd>split | Ouroboros<Cr>', m.silent, 'Ouroboros: Open other in split')
  m.nnoremap([[<leader>ov]], '<Cmd>vsplit | Ouroboros<Cr>', m.silent, 'Ouroboros: Open other in vsplit')
end)

---- akinsho/nvim-toggleterm.lua
local toggleterm_smart_toggle = function()
  local tabwins = vim.api.nvim_tabpage_list_wins(0)
  local focwin = vim.api.nvim_get_current_win()
  for _, win in ipairs(tabwins) do
    local buf = vim.api.nvim_win_get_buf(win)
    ---@diagnostic disable-next-line: param-type-mismatch
    if vim.api.nvim_buf_get_option(buf, 'filetype') == 'toggleterm' then
      if win == focwin then
        recent_wins.focus_most_recent()
      else
        vim.api.nvim_set_current_win(win)
      end
      return
    end
  end
  vim.cmd 'ToggleTerm'
end
m.nnoremap(xk [[<C-M-S-/>]], '<Cmd>ToggleTerm direction=float<Cr>', m.silent, 'ToggleTerm: Toggle (float)')
m.tnoremap(xk [[<C-M-S-/>]], [[<C-\><C-n>:ToggleTerm direction=float<Cr>]], m.silent, 'ToggleTerm: Toggle (float)')
m.nnoremap(xk [[<M-S-/>]], '<Cmd>ToggleTerm direction=vertical<Cr>', m.silent, 'ToggleTerm: Toggle (vertical)')
m.tnoremap(xk [[<M-S-/>]], [[<C-\><C-n>:ToggleTerm direction=vertical<Cr>]], m.silent, 'ToggleTerm: Toggle (vertical)')
m.nnoremap(xk [[<C-M-/>]], '<Cmd>ToggleTerm direction=horizontal<Cr>', m.silent, 'ToggleTerm: Toggle (horizontal)')
m.tnoremap(
  xk [[<C-M-/>]],
  [[<C-\><C-n>:ToggleTerm direction=horizontal<Cr>]],
  m.silent,
  'ToggleTerm: Toggle (horizontal)'
)
m.nnoremap(xk [[<C-/>]], toggleterm_smart_toggle, m.silent, 'ToggleTerm: Smart Toggle')
m.tnoremap(xk [[<C-/>]], toggleterm_smart_toggle, m.silent, 'ToggleTerm: Smart Toggle')

---- dpayne/CodeGPT.nvim
m.nnoremap(xk [[<M-c>]], [[:Chat ]], 'CodeGPT: Chat')
m.vnoremap(xk [[<M-c>]], [[:'<,'>Chat]], 'CodeGPT: Chat')

---- romgrk/nvim-treesitter-context
m.nnoremap([[<leader>tsc]], [[<cmd>TSContextToggle<Cr>]], 'Treesitter Context: Toggle')

---- ThePrimeagen/refactoring.nvim
local refactoring = fn.require_on_call_rec 'refactoring'
m.nname('<localleader>r', 'Refactoring')
m.vname('<localleader>r', 'Refactoring')
m.vnoremap([[<localleader>re]], iwrap(refactoring.refactor, 'Extract Function'), 'Refactoring: Extract Function')
m.vnoremap(
  [[<localleader>rf]],
  iwrap(refactoring.refactor, 'Extract Function To File'),
  'Refactoring: Extract Function To File'
)
m.vnoremap([[<localleader>rv]], iwrap(refactoring.refactor, 'Extract Variable'), 'Refactoring: Extract Variable')
m.vnoremap([[<localleader>ri]], iwrap(refactoring.refactor, 'Inline Variable'), 'Refactoring: Inline Variable')
m.nname('<localleader>rb', 'Refactoring: Extract Block')
m.nnoremap(
  { [[<localleader>rB]], [[<localleader>rbb]] },
  iwrap(refactoring.refactor, 'Extract Block'),
  'Refactoring: Extract Block'
)
m.nnoremap(
  [[<localleader>rbf]],
  iwrap(refactoring.refactor, 'Extract Block To File'),
  'Refactoring: Extract Block To File'
)
m.nnoremap([[<localleader>ri]], iwrap(refactoring.refactor, 'Inline Variable'), 'Refactoring: Inline Variable')
m.vnoremap([[<localleader>rr]], iwrap(refactoring.select_refactor), 'Refactoring: Select Refactor')

---- nvim-neotest/neotest
local neotest = fn.require_on_call_rec 'neotest'
local neotest_summary = fn.require_on_call_rec 'neotest.consumers.summary'
m.nname('<leader>n', 'Neoest')
m.nnoremap([[<leader>nn]], iwrap(neotest.run.run), 'Neotest: Run Nearest Test')
m.nnoremap({ [[<leader>N]], [[<leader>nf]] }, function()
  neotest.run.run(vim.fn.expand '%')
end, 'Neotest: Run File')
m.nnoremap({ '[t', '[n' }, iwrap(neotest.jump.prev, { status = 'failed' }), 'Neotest: Jump Prev Failed')
m.nnoremap({ ']t', ']n' }, iwrap(neotest.jump.next, { status = 'failed' }), 'Neotest: Jump Next Failed')
m.nnoremap([[<M-n>]], function()
  neotest_summary.open()
  if vim.bo.filetype == 'neotest-summary' then
    vim.cmd 'wincmd p'
  else
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      ---@diagnostic disable-next-line: redundant-parameter
      if vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), 'filetype') == 'neotest-summary' then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end
end, 'Neotest: Open or Focus Summary')
m.nnoremap([[<M-S-n>]], iwrap(neotest.summary.toggle), 'Neotest: Toggle Summary')

---- mg979/vim-visual-multi
m.xmap([[<leader>v]], [[<Plug>(VM-Visual-Cursors)]], 'Visual Multi: Start Visual Multi')

---- stevearc/conform.nvim
local conform = fn.require_on_call_rec 'conform'
local user_conform = fn.require_on_call_rec 'user.plugin.conform'
m.nnoremap([[<localleader>F]], iwrap(conform.format, { lsp_fallback = true }), 'LSP: Format')
m.xnoremap([[<localleader>F]], iwrap(conform.format, { lsp_fallback = true }), 'LSP: Format (range)')

m.nnoremap(
  { [[<localleader>S]], [[<localleader>ss]] },
  iwrap(user_conform.toggle_format_on_save),
  'Conform: Toggle format on save'
)
m.nnoremap([[<localleader>se]], iwrap(user_conform.set_format_on_save, true), 'Conform: Enable format on save')
m.nnoremap([[<localleader>sd]], iwrap(user_conform.set_format_on_save, false), 'Conform: Disable format on save')

---- folke/lazy.nvim
m.nnoremap([[<leader>ll]], '<Cmd>Lazy<cr>', 'Lazy')

---- folke/noice.nvim
m.nnoremap([[<leader>L]], '<Cmd>NoiceHistory<cr>', 'Noice: History log')

return M
