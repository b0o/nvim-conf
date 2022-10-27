local M = {}

local fn = require 'user.fn'
local thunk, ithunk = fn.thunk, fn.ithunk

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
  [ [[<C-/>]] ] = 0x001f,
}
local xk = M.xk

-- stylua: ignore start
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
  return vim.v.count > 1 and "j" or "gj"
end, m.silent, m.expr, "Line down")
m.noremap([[k]], function()
  return vim.v.count > 0 and "k" or "gk"
end, m.silent, m.expr, "Like up")
m.noremap([[J]], [[5j]], "Jump down")
m.noremap([[K]], [[5k]], "Jump up")
m.xnoremap([[J]], [[5j]], "Jump down")
m.xnoremap([[K]], [[5k]], "Jump up")

m.nnoremap([[<M-Down>]], [[<C-e>]], "Scroll view down 1")
m.nnoremap([[<M-Up>]], [[<C-y>]], "Scroll view up 1")
m.nnoremap([[<M-S-Down>]], [[5<C-e>]], "Scroll view down 5")
m.nnoremap([[<M-S-Up>]], [[5<C-y>]], "Scroll view up 5")
m.xnoremap([[<M-Down>]], [[<C-e>]], "Scroll view down 1")
m.xnoremap([[<M-Up>]], [[<C-y>]], "Scroll view up 1")
m.xnoremap([[<M-S-Down>]], [[5<C-e>]], "Scroll view down 5")
m.xnoremap([[<M-S-Up>]], [[5<C-y>]], "Scroll view up 5")
m.inoremap([[<M-Down>]], [[<C-o><C-e>]], "Scroll view down 1")
m.inoremap([[<M-Up>]], [[<C-o><C-y>]], "Scroll view up 1")
m.inoremap([[<M-S-Down>]], [[<C-o>5<C-e>]], "Scroll view down 5")
m.inoremap([[<M-S-Up>]], [[<C-o>5<C-y>]], "Scroll view up 5")

-- since the vim-wordmotion plugin overrides the normal `w` wordwise movement,
-- make `W` behave as vanilla `w`
m.nnoremap([[W]], [[w]], "Move full word forward")

m.nnoremap([[<M-b>]], [[ge]], "Move to the end of the previous word")

m.nnoremap({ [[Q]], [[<F29>]] }, [[:CloseWin<Cr>]], m.silent, "Close window")
m.nnoremap([[ZQ]], [[:confirm qall<Cr>]], m.silent, "Quit all")
m.nnoremap(xk [[<C-S-w>]], [[:tabclose<Cr>]], m.silent, "Close tab (except last one)")
m.nnoremap([[<leader>H]], [[:hide<Cr>]], m.silent, "Hide buffer")

m.noremap([[<C-s>]], [[:w<Cr>]], "Write buffer")

-- quickly enter command mode with substitution commands prefilled
-- TODO: need to force redraw
m.nnoremap([[<leader>/]], [[:%s/]], "Substitute")
m.nnoremap([[<leader>?]], [[:%S/]], "Substitute (rev)")
m.xnoremap([[<leader>/]], [[:s/]], "Substitute")
m.xnoremap([[<leader>?]], [[:S/]], "Substitute (rev)")

-- Buffer-local option toggles
local function map_toggle_locals(keys, opts, vals)
  keys = type(keys) == "table" and keys or { keys }
  opts = type(opts) == "table" and opts or { opts }
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
      if type(target) == "boolean" then
        msg = (target and 'Enable ' or 'Disable ') .. opt
      else
        msg = 'Set ' .. opt .. '=' .. target
      end
      vim.notify(msg)
      vim.opt_local[opt] = target
    end, opts)
  end

  m.nnoremap(lhs, rhs, m.silent, "Toggle " .. table.concat(opts, ", "))
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
local cutbuf = fn.require_on_call_rec('user.util.cutbuf')
m.nnoremap([[<localleader>x]], ithunk(cutbuf.cut), m.silent, "cutbuf: cut")
m.nnoremap([[<localleader>c]], ithunk(cutbuf.copy), m.silent, "cutbuf: copy")
m.nnoremap([[<localleader>p]], ithunk(cutbuf.paste), m.silent, "cutbuf: paste")

---- Maximize
local maximize = fn.require_on_call_rec 'user.util.maximize'
m.nnoremap([[<localleader>z]], ithunk(maximize.toggle), "Maximize current window")

---- Editing

-- https://vim.fandom.com/wiki/Insert_a_single_character
m.nnoremap([[gi]], [[:exec "normal i".nr2char(getchar())."\e"<Cr>]], m.silent, "Insert a single character")
m.nnoremap([[ga]], [[:exec "normal a".nr2char(getchar())."\e"<Cr>]], m.silent, "Insert a single character")

m.xnoremap([[>]], [[>gv]], "Indent")
m.xnoremap([[<]], [[<gv]], "De-Indent")

m.nnoremap([[<M-o>]], [[m'Do<Esc>p`']], "Break line at cursor")
m.nnoremap([[<M-O>]], [[m'DO<Esc>p`']], "Break line at cursor (reverse)")

m.nnoremap([[Y]], [[y$]], "Yank until end of line")

m.xnoremap([[<leader>y]], [["+y]], "Yank to system clipboard")
m.nnoremap([[<leader>Y]], [["+yg_]], "Yank 'til EOL to system clipboard")
m.nnoremap([[<leader>yy]], [["+yy]], "Yank line to system clipboard")
m.nnoremap([[<C-y>]], [[pumvisible() ? "\<C-y>" : '"+yy']], m.expr)
m.xnoremap([[<C-y>]], [[pumvisible() ? "\<C-y>" : '"+y']], m.expr)

m.nnoremap([[<leader>yp]], [[:let @+ = expand("%:p")<Cr>:echom "Copied " . @+<Cr>]], m.silent, "Yank file path")
m.nnoremap([[<leader>y:]], [[:let @+=@:<Cr>:echom "Copied '" . @+ . "'"<Cr>]], m.silent, "Yank last command")

m.xnoremap([[<C-p>]], [["+p]], "Paste from system clipboard")
m.nnoremap([[<C-p>]], [["+p]], "Paste from system clipboard")

m.nnoremap([[<M-p>]], [[a <Esc>p]], "Insert a space and then paste after cursor")
m.nnoremap([[<M-P>]], [[i <Esc>P]], "Insert a space and then paste before cursor")

m.nnoremap([[<C-M-j>]], [["dY"dp]], "Duplicate line downwards")
m.nnoremap([[<C-M-k>]], [["dY"dP]], "Duplicate line upwards")

m.xnoremap([[<C-M-j>]], [["dy`<"dPjgv]], "Duplicate selection downwards")
m.xnoremap([[<C-M-k>]], [["dy`>"dpgv]], "Duplicate selection upwards")

-- Clear UI state:
-- - Clear search highlight
-- - Clear command-line
-- - Close floating windows
m.nnoremap([[<Esc>]], function()
  vim.cmd("nohlsearch")
  fn.close_float_wins()
  vim.cmd("echo ''")
end, m.silent, "Clear UI")

-- See: https://github.com/mhinz/vim-galore#saner-ctrl-l
m.nnoremap([[<leader>L]], [[:nohlsearch<Cr>:diffupdate<Cr>:syntax sync fromstart<Cr><c-l>]], "Redraw")

m.nnoremap([[<leader>rr]], [[:lua require'user.fn'.reload()<Cr>]], m.silent, "Reload config")

m.noremap([[gF]], [[<C-w>gf]], "Go to file under cursor (new tab)")

-- emacs-style motion & editing in insert mode
m.inoremap([[<C-a>]], [[<Home>]], "Goto beginning of line")
m.inoremap([[<C-e>]], [[<End>]], "Goto end of line")
m.inoremap([[<C-b>]], [[<Left>]], "Goto char backward")
m.inoremap([[<C-f>]], [[<Right>]], "Goto char forward")
m.inoremap([[<M-b>]], [[<S-Left>]], "Goto word backward")
m.inoremap([[<M-f>]], [[<S-Right>]], "Goto word forward")
m.inoremap([[<C-d>]], [[<Delete>]], "Kill char forward")
m.inoremap([[<M-d>]], [[<C-o>de]], "Kill word forward")
m.inoremap([[<M-Backspace>]], [[<C-o>dB]], "Kill word backward")
m.inoremap([[<C-k>]], [[<C-o>D]], "Kill to end of line")

m.inoremap([[<M-h>]], [[<Left>]])
m.inoremap([[<M-j>]], [[<Down>]])
m.inoremap([[<M-k>]], [[<Up>]])
m.inoremap([[<M-l>]], [[<Right>]])

m.inoremap([[<M-a>]], [[<C-o>_]])

-- unicode stuff
m.inoremap(xk [[<C-'>]], [[<C-k>]], "Insert digraph")
m.nnoremap([[gxa]], [[ga]], "Show char code in decimal, hexadecimal and octal")

-- nano-like kill buffer
-- TODO
vim.cmd([[
  let @k=''
  let @l=''
]])
m.nnoremap([[<F30>]], [["ldd:let @k=@k.@l | let @l=@k<Cr>]], m.silent)
m.nnoremap([[<F24>]], [[:if @l != "" | let @k=@l | end<Cr>"KgP:let @l=@k<Cr>:let @k=""<Cr>]], m.silent)

m.inoremap(xk [[<C-`>]], [[<C-o>~<Left>]], "Toggle case")

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
m.cnoremap([[<c-p>]], [[pumvisible() ? "\<C-p>" : "\<Up>"]], m.expr, "History prev")
m.cnoremap([[<c-n>]], [[pumvisible() ? "\<C-n>" : "\<Down>"]], m.expr, "History next")
m.cmap([[<M-/>]], [[pumvisible() ? "\<C-y>" : "\<M-/>"]], m.expr, "Accept completion suggestion")
m.cmap(xk [[<C-/>]], [[pumvisible() ? "\<C-y>\<Tab>" : nr2char(0x001f)]], m.expr,
  "Accept completion suggestion and continue completion")

local function cursor_lock(lock)
  return function()
    local win = vim.api.nvim_get_current_win()
    local augid = vim.api.nvim_create_augroup('user_cursor_lock_' .. win, { clear = true })
    if not lock or vim.w.cursor_lock == lock then
      vim.w.cursor_lock = nil
      fn.notify("Cursor lock disabled")
      return
    end
    vim.w.cursor_lock = lock
    vim.api.nvim_create_autocmd("CursorMoved", {
      desc = "Cursor lock for window " .. win,
      buffer = 0,
      group = augid,
      callback = function()
        if vim.w.cursor_lock then
          vim.cmd("silent normal z" .. vim.w.cursor_lock)
        end
      end
    })
    fn.notify("Cursor lock enabled")
  end
end

m.nnoremap([[<leader>zt]], cursor_lock("t"), m.silent, "Toggle cursor lock (top)")
m.nnoremap([[<leader>zz]], cursor_lock("z"), m.silent, "Toggle cursor lock (middle)")
m.nnoremap([[<leader>zb]], cursor_lock("b"), m.silent, "Toggle cursor lock (bottom)")

---- Jumplist
m.nnoremap(xk [[<C-S-o>]], ithunk(fn.jumplist_jump_buf, -1), m.silent, "Jumplist: Go to last buffer")
m.nnoremap(xk [[<C-S-i>]], ithunk(fn.jumplist_jump_buf, 1), m.silent, "Jumplist: Go to next buffer")

---- Tabs
-- Navigate tabs
-- Go to a tab by index; If it doesn't exist, create a new tab
local function tabnm(n)
  return function()
    if vim.api.nvim_tabpage_is_valid(n) then
      vim.cmd('tabn ' .. n)
    else
      vim.cmd('$tabnew')
    end
  end
end

m.noremap([[<M-'>]], [[:tabn<Cr>]], m.silent, "Tabs: Goto next")
m.noremap([[<M-;>]], [[:tabp<Cr>]], m.silent, "Tabs: Goto prev")
m.tnoremap([[<M-'>]], [[<C-\><C-n>:tabn<Cr>]], m.silent) -- Tabs: goto next
m.tnoremap([[<M-;>]], [[<C-\><C-n>:tabp<Cr>]], m.silent) -- Tabs: goto prev
m.noremap([[<M-S-a>]], [[:execute "wincmd g\<Tab>"<Cr>]], m.silent, "Tabs: Goto last accessed")

m.noremap([[<M-a>]], ithunk(recent_wins.focus_most_recent), m.silent, "Panes: Goto previously focused")
m.noremap([[<M-x>]], ithunk(recent_wins.flip_recents), m.silent, "Panes: Flip the last normal wins")

m.noremap([[<M-1>]], tabnm(1), m.silent, "Goto tab 1")
m.noremap([[<M-2>]], tabnm(2), m.silent, "Goto tab 2")
m.noremap([[<M-3>]], tabnm(3), m.silent, "Goto tab 3")
m.noremap([[<M-4>]], tabnm(4), m.silent, "Goto tab 4")
m.noremap([[<M-5>]], tabnm(5), m.silent, "Goto tab 5")
m.noremap([[<M-6>]], tabnm(6), m.silent, "Goto tab 6")
m.noremap([[<M-7>]], tabnm(7), m.silent, "Goto tab 7")
m.noremap([[<M-8>]], tabnm(8), m.silent, "Goto tab 8")
m.noremap([[<M-9>]], tabnm(9), m.silent, "Goto tab 9")
m.noremap([[<M-0>]], tabnm(10), m.silent, "Goto tab 10")

m.noremap([[<M-">]], [[:+tabm<Cr>]], m.silent, "Move tab right")
m.noremap([[<M-:>]], [[:-tabm<Cr>]], m.silent, "Move tab left")

m.noremap([[<F13>]], [[:tabnew<Cr>]], m.silent, "Open new tab")

m.tnoremap([[<M-h>]], [[<C-\><C-n><C-w>h]]) -- Goto tab left
m.tnoremap([[<M-j>]], [[<C-\><C-n><C-w>j]]) -- Goto tab down
m.tnoremap([[<M-k>]], [[<C-\><C-n><C-w>k]]) -- Goto tab up
m.tnoremap([[<M-l>]], [[<C-\><C-n><C-w>l]]) -- Goto tab right

m.nnoremap([[<leader>sa]], [[:wincmd =<Cr>]], "Auto-resize")
-- m.nnoremap ([[<leader>sa]], auto_resize.enable,  "Enable auto-resize")
-- m.nnoremap ([[<leader>sA]], auto_resize.disable, "Disable auto-resize")

m.nnoremap([[<leader>sf]], ithunk(fn.toggle_winfix, 'height'), "Toggle fixed window height")
m.nnoremap([[<leader>sF]], ithunk(fn.toggle_winfix, 'width'), "Toggle fixed window width")

m.nnoremap([[<leader>s<M-f>]], ithunk(fn.set_winfix, true, 'height', 'width'), "Enable fixed window height/width")
m.nnoremap([[<leader>s<C-f>]], ithunk(fn.set_winfix, false, 'height', 'width'), "Disable fixed window height/width")

-- see also the VSplit plugin mappings below
m.nnoremap([[<leader>S]], [[:new<Cr>]], m.silent, "Split (horiz, new)")
m.nnoremap([[<leader>sn]], [[:new<Cr>]], m.silent, "Split (horiz, new)")
m.nnoremap([[<leader>V]], [[:vnew<Cr>]], m.silent, "Split (vert, new)")
m.nnoremap([[<leader>vn]], [[:vnew<Cr>]], m.silent, "Split (vert, new)")
m.nnoremap([[<leader>ss]], [[:split<Cr>]], m.silent, "Split (horiz, cur)")
m.nnoremap([[<leader>st]], [[:split<Cr>]], m.silent, "Split (horiz, cur)")
m.nnoremap([[<leader>vv]], [[:vsplit<Cr>]], m.silent, "Split (vert, cur)")
m.nnoremap([[<leader>vt]], [[:vsplit<Cr>]], m.silent, "Split (vert, cur)")

m.xnoremap([[<leader>S]], [[:VSSplitAbove<Cr>]], m.silent, "Visual Split (above)")
m.xnoremap([[<leader>ss]], [[:VSSplitAbove<Cr>]], m.silent, "Visual Split (above)")
m.xnoremap([[<leader>sS]], [[:VSSplit<Cr>]], m.silent, "Visual Split (below)")

m.xnoremap([[<leader>I]], [[<Esc>:call user#fn#interleave()<Cr>]], m.silent, "Interleave two contiguous blocks")

-- Tabline
local tabline = require 'user.tabline'
m.nmap({ '<C-t><C-t>', '<C-t>t' }, tabline.do_rename_tab, 'Tabpage: Set title')
m.nmap({ '<C-t><C-l>', '<C-t>l' }, tabline.tabpage_toggle_titlestyle, 'Tabpage: Toggle title style')

-- PasteRestore
-- paste register without overwriting with the original selection
-- use P for original behavior
m.xnoremap([[p]], [[user#fn#pasteRestore()]], m.silent, m.expr)

m.nnoremap([[<leader>T]], [[:Term!<Cr>]], m.silent, "New term (tab)")
m.nnoremap([[<leader>t]], [[:10Term<Cr>]], m.silent, "New term (split)")

m.tnoremap(xk [[<C-S-q>]], [[<C-\><C-n>:q<Cr>]]) -- Close terminal
m.tnoremap(xk [[<C-S-n>]], [[<C-\><C-n>]]) -- Enter Normal mode
m.tnoremap([[<C-n>]], [[<C-n>]])
m.tnoremap([[<C-p>]], [[<C-p>]])
m.tnoremap([[<M-n>]], [[<M-n>]])
m.tnoremap([[<M-p>]], [[<M-p>]])

m.nnoremap([[<Leader>ml]], [[:call AppendModeline()<Cr>]], m.silent, "Append modeline with current settings")

---- Quickfix/Loclist
m.nnoremap([[<M-S-q>]], function()
  if fn.get_qfwin() then
    vim.cmd [[cclose]]
  else
    vim.cmd [[copen]]
    recent_wins.focus_most_recent()
  end
end, m.silent, "Quickfix: Toggle")

local function focus_qf()
  local qfwin = require 'user.apiutil'.tabpage_get_quickfix_win(0)
  if qfwin then
    vim.api.nvim_set_current_win(qfwin)
  else
    vim.cmd [[copen]]
  end
end

m.nmap([[<M-q>]], fn.filetype_command("qf", ithunk(recent_wins.focus_most_recent), focus_qf), m.silent,
  "Quickfix: Toggle focus")

------ Filetypes
m.group(m.silent, { ft = "lua" }, function()
  m.nmap([[<leader><Enter>]], fn.luarun, "Lua: Eval line")
  m.nmap([[<localleader><Enter>]], ithunk(fn.luarun, true), "Lua: Eval file")
  m.xmap([[<leader><Enter>]], fn.luarun, "Lua: Eval selection")

  m.nmap([[<leader><F12>]], "<Cmd>Put lua require'user.fn'.luarun()<Cr>", "Lua: Eval line (Append)")
  m.xmap([[<leader><F12>]], "<Cmd>Put lua require'user.fn'.luarun()<Cr>", "Lua: Eval selection (Append)")
end)

m.group(m.silent, { ft = "man" }, function()
  -- open manpage tag (e.g. isatty(3)) in current buffer
  m.nnoremap([[<C-]>]], function()
    fn.man('', vim.fn.expand('<cword>'))
  end, "Man: Open tag in current buffer")
  m.nnoremap([[<M-]>]], function()
    fn.man('tab', vim.fn.expand('<cword>'))
  end, "Man: Open tag in new tab")
  m.nnoremap([[}]], function()
    fn.man('split', vim.fn.expand('<cword>'))
  end, "Man: Open tag in new split")

  -- TODO
  -- go back to previous manpage
  -- nnoremap ([[<C-t>]],   [[:call man#pop_page))
  -- nnoremap ([[<C-o>]],   [[:call man#pop_page()<Cr>]])
  -- nnoremap ([[<M-o>]],   [[<C-o>]])

  -- navigate to next/prev section
  m.nnoremap("[[", [[:<C-u>call user#fn#manSectionMove('b', 'n', v:count1)<Cr>]], "Man: Goto prev section")
  m.nnoremap("]]", [[:<C-u>call user#fn#manSectionMove('' , 'n', v:count1)<Cr>]], "Man: Goto next section")
  m.xnoremap("[[", [[:<C-u>call user#fn#manSectionMove('b', 'v', v:count1)<Cr>]], "Man: Goto prev section")
  m.xnoremap("]]", [[:<C-u>call user#fn#manSectionMove('' , 'v', v:count1)<Cr>]], "Man: Goto next section")

  -- navigate to next/prev manpage tag
  m.nnoremap([[<Tab>]], [[:call search('\(\w\+(\w\+)\)', 's')<Cr>]], "Man: Goto next tag")
  m.nnoremap([[<S-Tab>]], [[:call search('\(\w\+(\w\+)\)', 'sb')<Cr>]], "Man: Goto prev tag")

  -- search from beginning of line (useful for finding command args like -h)
  m.nnoremap([[g/]], [[/^\s*\zs]], { silent = false }, "Man: Start BOL search")
end)

------ LSP
m.nname("<leader>l", "LSP")
m.nnoremap([[<leader>li]], [[:LspInfo<Cr>]], "LSP: Show LSP information")
m.nnoremap([[<leader>lr]], [[:LspRestart<Cr>]], "LSP: Restart LSP")
m.nnoremap([[<leader>ls]], [[:LspStart<Cr>]], "LSP: Start LSP")
m.nnoremap([[<leader>lS]], [[:LspStop<Cr>]], "LSP: Stop LSP")

local lsp_attached_bufs
M.on_first_lsp_attach = function()
  ---- trouble.nvim
  local trouble = fn.require_on_call_rec('trouble')
  local function trouble_get_win()
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      if ft == "Trouble" then
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
  end, m.silent, "Trouble: Toggle")
  m.nmap([[<M-t>]],
    fn.filetype_command("Trouble", ithunk(recent_wins.focus_most_recent), ithunk(trouble.open)),
    m.silent, "Trouble: Toggle Focus")
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
  local trouble = fn.require_on_call_rec('trouble')

  m.group({ buffer = bufnr, silent = true }, function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    m.nname("<localleader>g", "LSP-Goto")
    m.nnoremap({ [[<localleader>gd]], [[gd]] }, ithunk(vim.lsp.buf.definition), "LSP: Goto definition")
    m.nnoremap({ [[<localleader>gd]], [[gd]] }, ithunk(vim.lsp.buf.definition), "LSP: Goto definition")
    m.nnoremap([[<localleader>gD]], ithunk(vim.lsp.buf.declaration), "LSP: Goto declaration")
    m.nnoremap([[<localleader>gi]], ithunk(vim.lsp.buf.implementation), "LSP: Goto implementation")
    m.nnoremap([[<localleader>gt]], ithunk(vim.lsp.buf.type_definition), "LSP: Goto type definition")
    m.nnoremap([[<localleader>gr]], ithunk(vim.lsp.buf.references), "LSP: Goto references")

    m.nname("<localleader>w", "LSP-Workspace")
    m.nnoremap([[<localleader>wa]], ithunk(vim.lsp.buf.add_workspace_folder), "LSP: Add workspace folder")
    m.nnoremap([[<localleader>wr]], ithunk(vim.lsp.buf.remove_workspace_folder), "LSP: Rm workspace folder")

    m.nnoremap([[<localleader>wl]], function()
      fn.inspect(vim.lsp.buf.list_workspace_folders())
    end, "LSP: List workspace folders")

    m.nnoremap([[<localleader>R]], ithunk(vim.lsp.buf.rename), "LSP: Rename")

    m.nnoremap({ [[<localleader>A]], [[<localleader>ca]] }, ithunk(vim.lsp.buf.code_action), "LSP: Code action")
    m.xnoremap({ [[<localleader>A]], [[<localleader>ca]] }, ithunk(vim.lsp.buf.range_code_action),
      "LSP: Code action (range)")

    m.nnoremap([[<localleader>F]], ithunk(vim.lsp.buf.format), "LSP: Format")
    m.xnoremap([[<localleader>F]], ithunk(vim.lsp.buf.range_formatting), "LSP: Format (range)")

    m.nname("<localleader>s", "LSP-Save")
    m.nnoremap([[<localleader>S]], ithunk(user_lsp.set_fmt_on_save), "LSP: Toggle format on save")
    m.nnoremap([[<localleader>ss]], ithunk(user_lsp.set_fmt_on_save), "LSP: Toggle format on save")
    m.nnoremap([[<localleader>se]], ithunk(user_lsp.set_fmt_on_save, true), "LSP: Enable format on save")
    m.nnoremap([[<localleader>sd]], ithunk(user_lsp.set_fmt_on_save, false), "LSP: Disable format on save")

    local function gotoDiag(dir, sev)
      return function()
        local _dir = dir
        local args = {
          enable_popup = true,
          severity = vim.diagnostic.severity[sev]
        }
        if _dir == "first" or _dir == "last" then
          args.wrap = false
          if dir == "first" then
            args.cursor_position = { 1, 1 }
            _dir = "next"
          else
            args.cursor_position = { vim.api.nvim_buf_line_count(0) - 1, 1 }
            _dir = "prev"
          end
        end
        vim.diagnostic["goto_" .. _dir](args)
      end
    end

    m.nname("<localleader>d", "LSP-Diagnostics")
    m.nnoremap([[<localleader>ds]], ithunk(vim.diagnostic.show), "LSP: Show diagnostics")
    m.nnoremap({ [[<localleader>dt]], [[<localleader>T]] }, ithunk(trouble.toggle), "LSP: Toggle Trouble")

    m.nnoremap({ [[<localleader>dd]], [[[d]] }, gotoDiag("prev"), "LSP: Goto prev diagnostic")
    m.nnoremap({ [[<localleader>dD]], [[]d]] }, gotoDiag("next"), "LSP: Goto next diagnostic")
    m.nnoremap({ [[<localleader>dh]], [[[h]] }, gotoDiag("prev", "HINT"), "LSP: Goto prev hint")
    m.nnoremap({ [[<localleader>dH]], [[]h]] }, gotoDiag("next", "HINT"), "LSP: Goto next hint")
    m.nnoremap({ [[<localleader>di]], [[[i]] }, gotoDiag("prev", "INFO"), "LSP: Goto prev info")
    m.nnoremap({ [[<localleader>dI]], [[]i]] }, gotoDiag("next", "INFO"), "LSP: Goto next info")
    m.nnoremap({ [[<localleader>dw]], [[[w]] }, gotoDiag("prev", "WARN"), "LSP: Goto prev warning")
    m.nnoremap({ [[<localleader>dW]], [[]w]] }, gotoDiag("next", "WARN"), "LSP: Goto next warning")
    m.nnoremap({ [[<localleader>de]], [[[e]] }, gotoDiag("prev", "ERROR"), "LSP: Goto prev error")
    m.nnoremap({ [[<localleader>dE]], [[]e]] }, gotoDiag("next", "ERROR"), "LSP: Goto next error")

    m.nnoremap([[[D]], gotoDiag("first"), "LSP: Goto first diagnostic")
    m.nnoremap([[]D]], gotoDiag("last"), "LSP: Goto last diagnostic")
    m.nnoremap([[[H]], gotoDiag("first", "HINT"), "LSP: Goto first hint")
    m.nnoremap([[]H]], gotoDiag("last", "HINT"), "LSP: Goto last hint")
    m.nnoremap([[[I]], gotoDiag("first", "INFO"), "LSP: Goto first info")
    m.nnoremap([[]I]], gotoDiag("last", "INFO"), "LSP: Goto last info")
    m.nnoremap([[[W]], gotoDiag("first", "WARN"), "LSP: Goto first warning")
    m.nnoremap([[]W]], gotoDiag("last", "WARN"), "LSP: Goto last warning")
    m.nnoremap([[[E]], gotoDiag("first", "ERROR"), "LSP: Goto first error")
    m.nnoremap([[]E]], gotoDiag("last", "ERROR"), "LSP: Goto last error")

    m.nnoremap(']t', ithunk(trouble.next, { skip_groups = true, jump = true }), "Trouble: Next")
    m.nnoremap('[t', ithunk(trouble.previous, { skip_groups = true, jump = true }), "Trouble: Previous")

    m.nname("<localleader>s", "LSP-Search")
    m.nnoremap({ [[<localleader>so]], [[<leader>so]] },
      ithunk(fn.require_on_call_rec('user.plugin.telescope').cmds.lsp_document_symbols), "LSP: Telescope symbol search")

    m.nname("<localleader>h", "LSP-Hover")
    m.nnoremap([[<localleader>hs]], ithunk(vim.lsp.buf.signature_help), "LSP: Signature help")
    m.nnoremap([[<localleader>ho]], ithunk(vim.lsp.buf.hover), "LSP: Hover")
    m.nnoremap([[<M-i>]], ithunk(vim.lsp.buf.hover), "LSP: Hover")
    m.inoremap([[<M-i>]], ithunk(vim.lsp.buf.hover), "LSP: Hover")
    m.nnoremap([[<M-S-i>]], ithunk(user_lsp.peek_definition), "LSP: Peek definition")
  end)
end

------ Plugins
---- folke/which-key.nvim
m.nnoremap([[<leader><leader>]], [[:WhichKey<Cr>]], "WhichKey: Show all")

---- AndrewRadev/splitjoin.vim
m.nnoremap([[gJ]], [[:SplitjoinJoin<Cr>]], "Splitjoin: Join")
m.nnoremap([[gS]], [[:SplitjoinSplit<Cr>]], "Splitjoin: Split")

---- wbthomason/packer.nvim
m.nname("<leader>p", "Packer")
m.nnoremap([[<leader>pC]], [[:PackerClean<Cr>]], "Packer: Clean")
m.nnoremap([[<leader>pc]], [[:PackerCompile<Cr>]], "Packer: Compile")
m.nnoremap([[<leader>pi]], [[:PackerInstall<Cr>]], "Packer: Install")
m.nnoremap([[<leader>pu]], [[:PackerUpdate<Cr>]], "Packer: Update")
m.nnoremap([[<leader>ps]], [[:PackerSync<Cr>]], "Packer: Sync")
m.nnoremap([[<leader>pl]], [[:PackerLoad<Cr>]], "Packer: Load")

m.group(m.silent, { ft = "packer" }, function()
  m.nmap([[O]], function()
    if not vim.env.BROWSER or vim.env.BROWSER == "" then
      vim.notify("Packer: Can't open repo: BROWSER environment variable is unset", vim.log.levels.ERROR)
      return
    end
    local pd = require 'packer.display'
    local plugin_name = pd.status.disp:find_nearest_plugin()
    local plugin = pd.status.disp.items[plugin_name]
    local spec = plugin and plugin.spec
    if not spec then
      vim.notify("Packer: Plugin not available", vim.log.levels.WARN)
      return
    end
    local url = spec.url
    if not url then
      vim.notify("Packer: Plugin URL not available", vim.log.levels.WARN)
      return
    end
    local current_line = pd.status.disp:get_current_line()
    local commit_hash = vim.fn.matchstr(current_line, [[^\X*\zs[0-9a-f]\{7,9}]])
    if commit_hash and commit_hash ~= "" then
      url = url .. '/commit/' .. commit_hash
    end
    vim.notify("Opening " .. url)
    vim.fn.system({ vim.env.BROWSER, url })
  end, "Packer: Open plugin or commit in browser")
end)

---- numToStr/Comment.nvim
local comment = fn.require_on_call_rec('Comment.api')
m.nnoremap([[<M-/>]], ithunk(comment.toggle.linewise), m.silent)
m.xnoremap([[<M-/>]], function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
  comment.toggle.linewise(vim.fn.visualmode())
end, m.silent)

---- aserowy/tmux.nvim
local tmux = fn.require_on_exported_call 'tmux'
m.nmap([[<M-h>]], ithunk(tmux.move_left), m.silent, "Goto window/tmux pane left")
m.nmap([[<M-j>]], ithunk(tmux.move_bottom), m.silent, "Goto window/tmux pane down")
m.nmap([[<M-k>]], ithunk(tmux.move_top), m.silent, "Goto window/tmux pane up")
m.nmap([[<M-l>]], ithunk(tmux.move_right), m.silent, "Goto window/tmux pane right")

m.group(m.silent, function()
  local tu = fn.require_on_call_rec 'user.plugin.telescope'
  local tc = tu.cmds

  m.nname([[<C-f>]], "Telescope")
  m.nnoremap(xk [[<C-S-f>]], ithunk(tc.builtin), "Telescope: Builtins")
  m.nnoremap([[<C-f>b]], ithunk(tc.buffers), "Telescope: Buffers")
  m.nnoremap({ [[<C-f>h]], [[<C-f><C-h>]] }, ithunk(tc.help_tags), "Telescope: Help tags")
  m.nnoremap({ [[<C-f>t]], [[<C-f><C-t>]] }, ithunk(tc.tags), "Telescope: Tags")
  m.nnoremap({ [[<C-f>a]], [[<C-f><C-a>]] }, ithunk(tc.grep_string), "Telescope: Grep for string")
  -- m.nnoremap({ [[<C-f>p]], [[<C-f><C-p>]] }, ithunk(tc.live_grep), "Telescope: Live grep")
  m.nnoremap({ [[<C-f>p]], [[<C-f><C-p>]] }, ithunk(tc.live_grep_args), "Telescope: Live grep")
  m.nnoremap({ [[<C-f>o]], [[<C-f><C-o>]] }, ithunk(tc.oldfiles), "Telescope: Old files")
  m.nnoremap({ [[<C-f>f]], [[<C-f><C-f>]] }, ithunk(tc.smart_files), "Telescope: Files (Smart)")
  m.nnoremap({ [[<C-f>F]] }, ithunk(tc.find_files), "Telescope: Files")
  m.nnoremap({ [[<C-f>w]], [[<C-f><C-w>]] }, ithunk(tc.windows, {}), "Telescope: Windows")

  m.nnoremap({ [[<C-M-f>]], [[<C-f>r]], [[<C-f><C-r>]] }, ithunk(tc.resume), "Telescope: Resume last picker")

  local tcgw = tc.git_worktree
  m.nname([[<C-f>g]], "Telescope-Git")
  m.nnoremap([[<C-f>gw]], ithunk(tcgw.git_worktrees), "Telescope-Git: Worktrees")

  m.nname([[<M-f>]], "Telescope-Buffer")
  m.nnoremap({ [[<M-f>b]], [[<M-f><M-b>]] }, ithunk(tc.current_buffer_fuzzy_find), "Telescope-Buffer: Fuzzy find")
  m.nnoremap({ [[<M-f>t]], [[<M-f><M-t>]] }, ithunk(tc.tags), "Telescope-Buffer: Tags")
  m.nnoremap({ [[<M-f>u]], [[<M-f><M-u>]] }, ithunk(tc.urlview), "Telescope-Buffer: URLs")

  m.nname([[<M-f>]], "Telescope-Workspace")
  m.nnoremap([[<C-f>A]], ithunk(tc.aerial), "Telescope-Workspace: Aerial")
end)

---- tpope/vim-fugitive and TimUntersberger/neogit
m.nname("<leader>g", "Git")
m.nname("<leader>ga", "Git-Add")
m.nnoremap([[<leader>gA]], [[:Git add --all<Cr>]], "Git: Add all")
m.nnoremap([[<leader>gaa]], [[:Git add --all<Cr>]], "Git: Add all")
m.nnoremap([[<leader>gaf]], [[:Git add :%<Cr>]], "Git: Add file")

m.nname("<leader>gc", "Git-Commit")
m.nnoremap([[<leader>gC]], [[:Git commit --verbose<Cr>]], "Git: Commit")
m.nnoremap([[<leader>gcc]], [[:Git commit --verbose<Cr>]], "Git: Commit")
m.nnoremap([[<leader>gca]], [[:Git commit --verbose --all<Cr>]], "Git: Commit (all)")
m.nnoremap([[<leader>gcA]], [[:Git commit --verbose --amend<Cr>]], "Git: Commit (amend)")

m.nname("<leader>gl", "Git-Log")
m.nnoremap([[<leader>gL]], [[:Gclog!<Cr>]], "Git: Log")
m.nnoremap([[<leader>gll]], [[:Gclog!<Cr>]], "Git: Log")
m.nnoremap([[<leader>glL]], [[:tabnew | Gclog<Cr>]], "Git: Log (tab)")

m.nname("<leader>gp", "Git-Push-Pull")
m.nnoremap([[<leader>gpa]], [[:Git push --all<Cr>]], "Git: Push all")
m.nnoremap([[<leader>gpp]], [[:Git push<Cr>]], "Git: Push")
m.nnoremap([[<leader>gpl]], [[:Git pull<Cr>]], "Git: Pull")

m.nnoremap([[<leader>gR]], [[:Git reset<Cr>]], "Git: Reset")

m.nname("<leader>gs", "Git-Status")
m.nnoremap([[<leader>gS]], [[:Neogit<Cr>]], "Git: Status")
m.nnoremap([[<leader>gss]], [[:Neogit<Cr>]], "Git: Status")
m.nnoremap([[<leader>gst]], [[:Neogit<Cr>]], "Git: Status")

m.nnoremap([[<leader>gsp]], [[:Gsplit<Cr>]], "Git: Split")

m.nname("<leader>G", "Git")
m.nnoremap([[<leader>GG]], [[:Git<Cr>]], "Git: Status")
m.nnoremap([[<leader>GS]], [[:Git<Cr>]], "Git: Status")
m.nnoremap([[<leader>GA]], [[:Git add<Cr>]], "Git: Add")
m.nnoremap([[<leader>GC]], [[:Git commit<Cr>]], "Git: Commit")
m.nnoremap([[<leader>GF]], [[:Git fetch<Cr>]], "Git: Fetch")
m.nnoremap([[<leader>GL]], [[:Git log<Cr>]], "Git: Log")
m.nnoremap([[<leader>GPP]], [[:Git push<Cr>]], "Git: Push")
m.nnoremap([[<leader>GPL]], [[:Git pull<Cr>]], "Git: Pull")

local function gitsigns_visual_op(op)
  return function()
    return require('gitsigns')[op]({ vim.fn.line("."), vim.fn.line("v") })
  end
end

-- lewis6991/gitsigns.nvim
M.on_gistsigns_attach = function(bufnr)
  m.group({ buffer = bufnr, silent = true }, function()
    local gs = require 'gitsigns'
    m.nnoremap([[<leader>hs]], ithunk(gs.stage_hunk), "Gitsigns: Stage hunk")
    m.nnoremap([[<leader>hr]], ithunk(gs.reset_hunk), "Gitsigns: Reset hunk")
    m.nnoremap([[<leader>hu]], ithunk(gs.undo_stage_hunk), "Gitsigns: Undo stage hunk")
    m.xnoremap([[<leader>hs]], gitsigns_visual_op "stage_hunk", "Gitsigns: Stage selected hunk(s)")
    m.xnoremap([[<leader>hr]], gitsigns_visual_op "reset_hunk", "Gitsigns: Reset selected hunk(s)")
    m.xnoremap([[<leader>hu]], gitsigns_visual_op "undo_stage_hunk", "Gitsigns: Undo stage hunk")
    m.nnoremap([[<leader>hS]], ithunk(gs.stage_buffer), "Gitsigns: Stage buffer")
    m.nnoremap([[<leader>hR]], ithunk(gs.reset_buffer), "Gitsigns: Reset buffer")
    m.nnoremap([[<leader>hp]], ithunk(gs.preview_hunk), "Gitsigns: Preview hunk")
    m.nnoremap([[<leader>hb]], ithunk(gs.blame_line, { full = true }), "Gitsigns: Blame hunk")
    m.nnoremap([[<leader>htb]], ithunk(gs.toggle_current_line_blame), "Gitsigns: Toggle current line blame")
    m.nnoremap([[<leader>hd]], ithunk(gs.diffthis), "Gitsigns: Diff this")
    m.nnoremap([[<leader>hD]], ithunk(gs.diffthis, "~"), "Gitsigns: Diff this against last commit")
    m.nnoremap([[<leader>htd]], ithunk(gs.toggle_deleted), "Gitsigns: Toggle deleted")

    m.nnoremap("]c", "&diff ? ']c' : '<Cmd>Gitsigns next_hunk<Cr>'", "Gitsigns: Next hunk", m.expr)
    m.nnoremap("[c", "&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<Cr>'", "Gitsigns: Prev hunk", m.expr)
    m.onoremap([[ih]], ":<C-U>Gitsigns select_hunk<Cr>", "[TextObj] Gitsigns: Inner hunk")
    m.xnoremap([[ih]], ":<C-U>Gitsigns select_hunk<Cr>", "[TextObj] Gitsigns: Inner hunk")
  end)
end

-- mbbill/undotree
m.nnoremap([[<leader>ut]], [[:UndotreeToggle<Cr>]], "Undotree: Toggle")

-- godlygeek/tabular
m.nmap([[<Leader>a]], ":Tabularize /", "Tabularize")
m.xmap([[<Leader>a]], ":Tabularize /", "Tabularize")

---- KabbAmine/vCoolor.vim
m.nmap([[<leader>co]], [[:VCoolor<Cr>]], m.silent, "Open VCooler color picker")

------ nvim-neo-tree/neo-tree.nvim & kyazdani42/nvim-tree.lua
---- nvim-neo-tree/neo-tree.nvim
local neotree_mgr = fn.require_on_call_rec 'neo-tree.sources.manager'
local user_neotree = {}
user_neotree.get_state = function()
  return neotree_mgr.get_state('filesystem') or {}
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
  end, m.silent, "NeoTree: Toggle")

  m.nmap(xk [[<C-\>]], fn.filetype_command("neo-tree", ithunk(recent_wins.focus_most_recent), function()
    vim.cmd [[Neotree focus]]
    vim.schedule(auto_resize.trigger)
  end), m.silent, "Nvim-Tree: Toggle Focus")
end

---- kyazdani42/nvim-tree.lua
local setup_nvimtree = function()
  m.nmap(xk [[<C-S-\>]], function()
    if require 'nvim-tree.view'.is_visible() then
      require 'nvim-tree.view'.close()
    else
      require 'nvim-tree.lib'.open()
      recent_wins.focus_most_recent()
    end
  end, m.silent, "Nvim-Tree: Toggle")

  m.nmap(xk [[<C-\>]],
    fn.filetype_command("NvimTree", ithunk(recent_wins.focus_most_recent), thunk(vim.cmd, [[NvimTreeFocus]])), m.silent,
    "Nvim-Tree: Toggle Focus")

  m.group({ ft = "NvimTree" }, function()
    local function withSelected(cmd, fmt)
      return function()
        local file = require 'nvim-tree.lib'.get_node_at_cursor().absolute_path
        vim.cmd(fmt and (cmd):format(file) or ("%s %s"):format(cmd, file))
      end
    end

    m.nnoremap([[ga]], withSelected("Git add"), "Nvim-Tree: Git add")
    m.nnoremap([[gr]], withSelected("Git reset --quiet"), "Nvim-Tree: Git reset")
    m.nnoremap([[gb]], withSelected("tabnew | Git blame"), "Nvim-Tree: Git blame")
    m.nnoremap([[gd]], withSelected("tabnew | Gdiffsplit"), "Nvim-Tree: Git diff")
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
    if package.loaded['nvim-tree'] and require 'nvim-tree.view'.is_visible() then
      open_neotree = true
      if vim.api.nvim_buf_get_option(0, 'filetype') == 'NvimTree' then
        tree_foc = true
      end
      require 'nvim-tree.view'.close()
    end
  end

  vim.g.use_neotree = not vim.g.use_neotree
  vim.notify('Using ' .. (vim.g.use_neotree and 'NeoTree' or 'NvimTree'))
  setup_tree()

  if open_nvimtree then
    require 'nvim-tree.lib'.open()
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

m.nmap(xk [[<C-S-t>]], toggle_tree, m.silent, "Toggle selected file tree plugin")

setup_tree(false)

-- stevearc/aerial.nvim
local aerial = fn.require_on_index "aerial"
local aerial_util = fn.require_on_index "aerial.util"

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
  local winid = aerial_get_win()
  if winid then
    vim.api.nvim_set_current_win(winid)
    return
  end
  if not require "aerial.backends".get() then
    fn.notify("no aerial backend")
    return
  end

  -- Get width of nvim-tree or neo-tree before opening aerial (sometimes
  -- opening aerial causes file tree windows to get smooshed)
  local nvt_win = package.loaded['nvim-tree'] and require 'nvim-tree.view'.get_winnr()
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

  require "aerial.window".open(focus)

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
  if aerial_get_win() then
    local foc = require "aerial.util".is_aerial_buffer()
    aerial.close()
    if foc then
      recent_wins.focus_most_recent()
    end
  else
    aerial_open()
  end
end, m.silent, "Aerial: Toggle")

m.nmap([[<M-\>]],
  fn.filetype_command("aerial", ithunk(recent_wins.focus_most_recent), ithunk(aerial_open, true)),
  m.silent, "Aerial: Toggle Focus")

m.group(m.silent, { ft = "aerial" }, function()
  local function aerial_select(opts)
    require 'aerial.navigation'.select(vim.tbl_extend("force", {
      winid = recent_wins.get_most_recent()
    }, opts or {}))
  end

  local function aerial_view(cmd)
    vim.schedule(ithunk(aerial_select, { jump = false }))
    return cmd or "\\<Nop>"
  end

  m.nnoremap([[<Cr>]], ithunk(aerial_select), "Aerial: Select item")
  m.nnoremap([[<Tab>]], ithunk(aerial_view), m.expr, "Aerial: Bring item into view")
  m.nnoremap([[J]], ithunk(aerial_view, "j"), m.expr, "Aerial: Bring next item into view")
  m.nnoremap([[K]], ithunk(aerial_view, "k"), m.expr, "Aerial: Bring previous item into view")
end)

---- mfussenegger/nvim-dap
local function dap_pre()
  m.nnoremap([[<leader>D]], function()
    require 'user.dap'.launch(vim.bo.filetype)
  end, "DAP: Launch")
end

dap_pre()

M.on_dap_attach = function()
  local dap = require 'dap'
  local dap_ui_vars = require 'dap.ui.variables'
  local dap_ui_widgets = require 'dap.ui.widgets'

  m.nnoremap([[<leader>D]], function()
    require 'user.dap'.close(vim.bo.filetype)
  end, "DAP: Disconnect")

  local breakpointCond = function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end

  local toggleRepl = function()
    dap.repl.toggle({}, " vsplit")
    vim.fn.wincmd('l')
  end

  m.nname([[<leader>d]], "DAP")
  m.nnoremap([[<leader>dR]], dap.restart, "DAP: Restart")
  m.nnoremap([[<leader>dh]], dap.toggle_breakpoint, "DAP: Toggle breakpoint")
  m.nnoremap([[<leader>dH]], breakpointCond, "DAP: Set breakpoint condition")
  m.nnoremap([[<leader>de]], ithunk(dap.set_exception_breakpoints, { "all" }), "DAP: Break on exception")
  m.nnoremap([[<leader>dr]], toggleRepl, "DAP: Toggle REPL")
  m.nnoremap([[<leader>di]], dap_ui_vars.hover, "DAP: Hover variables")
  m.nnoremap([[<leader>di]], dap_ui_vars.visual_hover, "DAP: Hover variables (visual)")
  m.nnoremap([[<leader>d?]], dap_ui_vars.scopes, "DAP: Scopes")
  m.nnoremap([[<leader>dk]], dap.up, "DAP: Up")
  m.nnoremap([[<leader>dj]], dap.down, "DAP: Down")
  m.nnoremap([[<leader>di]], dap_ui_widgets.hover, "DAP: Hover")
  m.nnoremap([[<leader>d?]], dap_ui_widgets.centered_float, dap_ui_widgets.scopes, "DAP: Scopes")

  --   nnoremap([[<leader>dR]],  ithunk(dap.disconnect, {restart = false, terminateDebuggee = false}), "DAP: Restart")

  m.nnoremap({ [[<leader>dso]], [[<c-k>]] }, dap.step_out, "DAP: Step out")
  m.nnoremap({ [[<leader>dsi]], [[<c-l>]] }, dap.step_into, "DAP: Step into")
  m.nnoremap({ [[<leader>dsO]], [[<c-j>]] }, dap.step_over, "DAP: Step over")
  m.nnoremap({ [[<leader>dsc]], [[<c-h>]] }, dap.continue, "DAP: Continue")

  -- nnoremap([[<leader>da]],  require"debugHelper".attach()<Cr>')
  -- nnoremap([[<leader>dA]],  require"debugHelper".attachToRemote()<Cr>')
end

M.on_dap_detach = function()
  -- TODO
end

---- sindrets/winshift.nvim
m.nnoremap([[<Leader>M]], [[<Cmd>WinShift<Cr>]], "WinShift: Start")
m.nnoremap([[<Leader>mm]], [[<Cmd>WinShift<Cr>]], "WinShift: Start")

---- chentau/marks.nvim
m.nmap([[<M-m>]], [[m;]], "Mark: create next")
m.nnoremap([[]"]], [[[']], "Mark: goto previous")
m.nnoremap([[<leader>']], ithunk(require 'marks'.toggle_signs), "Mark: toggle signs")

---- mrjones2014/smart-splits.nvim
local smart_splits = fn.require_on_exported_call('smart-splits')
m.noremap([[<M-[>]], ithunk(smart_splits.resize_left), 'Resize-Win: Left')
m.noremap([[<M-]>]], ithunk(smart_splits.resize_right), 'Resize-Win: Right')
m.noremap([[<M-{>]], ithunk(smart_splits.resize_up), 'Resize-Win: Up')
m.noremap([[<M-}>]], ithunk(smart_splits.resize_down), 'Resize-Win: Down')

return M
