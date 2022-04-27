local M = {}

local fn = require 'user.fn'
local thunk, ithunk = fn.thunk, fn.ithunk

local mapx = require('mapx').setup {
  global = true,
  whichkey = true,
  enableCountArg = false,
  debug = vim.g.mapxDebug or false,
}

local silent = mapx.silent
local expr = mapx.expr

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
  [ [[<M-S-k>]] ] = 0x00f8,
  [ [[<C-S-p>]] ] = 0x00f9,
  [ [[<C-S-.>]] ] = 0x00fa,
  [ [[<C-.>]] ] = 0x00fb,
  [ [[<C-/>]] ] = 0x001f,
}
local xk = M.xk

-- stylua: ignore start
-- Disable C-z suspend
map     ([[<C-z>]], [[<Nop>]])
mapbang ([[<C-z>]], [[<Nop>]])

-- Disable C-c warning
-- map     ([[<C-c>]], [[<Nop>]])

-- Disable Ex mode
nnoremap ([[Q]], [[<Nop>]])

-- Disable command-line window
nnoremap ([[q:]], [[<Nop>]])
nnoremap ([[q/]], [[<Nop>]])
nnoremap ([[q?]], [[<Nop>]])

noremap ([[j]], function() return vim.v.count > 1 and "j" or "gj" end, silent, expr, "Line down")
noremap ([[k]], function() return vim.v.count > 0 and "k" or "gk" end, silent, expr, "Like up")
noremap ([[J]], [[5j]], "Jump down")
noremap ([[K]], [[5k]], "Jump up")
vnoremap ([[J]], [[5j]], "Jump down")
vnoremap ([[K]], [[5k]], "Jump up")

-- since the vim-wordmotion plugin overrides the normal `w` wordwise movement,
-- make `W` behave as vanilla `w`
nnoremap ([[W]], [[w]], "Move full word forward")

nnoremap ([[<M-b>]], [[ge]], "Move to the end of the previous word")

nnoremap ({[[Q]], [[<F29>]]}, [[:CloseWin<Cr>]],     silent, "Close window")
nnoremap ([[ZQ]],             [[:confirm qall<Cr>]], silent, "Quit all")
nnoremap (xk[[<C-S-w>]],      [[:tabclose<Cr>]],     silent, "Close tab (except last one)")
nnoremap ([[<leader>H]],      [[:hide<Cr>]],         silent, "Hide buffer")

noremap ([[<C-s>]], [[:w<Cr>]], "Write buffer")

-- quickly enter command mode with substitution commands prefilled
-- TODO: need to force redraw
nnoremap ([[<leader>/]], [[:%s/]], "Substitute")
nnoremap ([[<leader>?]], [[:%S/]], "Substitute (rev)")
vnoremap ([[<leader>/]], [[:s/]],  "Substitute")
vnoremap ([[<leader>?]], [[:S/]],  "Substitute (rev)")

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

  nnoremap (lhs, rhs,  silent, "Toggle " .. table.concat(opts, ", "))
end

map_toggle_locals({'A', 'ar'},   {'autoread'})
map_toggle_locals({'B'},         {'cursorbind', 'scrollbind'})
map_toggle_locals({'bi'},        {'breakindent'})
map_toggle_locals({'C', 'ci'},   {'copyindent'})
map_toggle_locals({'cc'},        {'concealcursor'}, {'', 'n'})
map_toggle_locals({'cl'},        {'conceallevel'}, {0, 2})
map_toggle_locals({'cb'},        {'cursorbind'})
map_toggle_locals({'D', 'di'},   {'diff'})
map_toggle_locals({'E', 'et'},   {'expandtab'})
map_toggle_locals({'F', 'fe'},   {'foldenable'})
map_toggle_locals({'L', 'lb'},   {'linebreak'})
map_toggle_locals({'N',  'nn'},  {'number', 'relativenumber'})
map_toggle_locals({'nr', 'rn'},  {'relativenumber'})
map_toggle_locals({'nu'},        {'number'})
map_toggle_locals({'R', 'ru'},   {'ruler'})
map_toggle_locals({'S', 'sg'},   {'laststatus'}, {2, 3})
map_toggle_locals({'sp'},        {'spell'})
map_toggle_locals({'sb'},        {'scrollbind'})
map_toggle_locals({'sr'},        {'shiftround'})
map_toggle_locals({'st'},        {'smarttab'})
map_toggle_locals({'|'},         {'cursorcolumn'})
map_toggle_locals({'W', 'ww'},   {'wrap'})

---- Editing

-- https://vim.fandom.com/wiki/Insert_a_single_character
nnoremap ([[gi]], [[:exec "normal i".nr2char(getchar())."\e"<Cr>]], silent, "Insert a single character")
nnoremap ([[ga]], [[:exec "normal a".nr2char(getchar())."\e"<Cr>]], silent, "Insert a single character")

vnoremap ([[>]], [[>gv]], "Indent")
vnoremap ([[<]], [[<gv]], "De-Indent")

nnoremap ([[<M-o>]], [[m'Do<esc>p`']], "Insert a space and then paste before/after cursor")
nnoremap ([[<M-O>]], [[m'DO<esc>p`']], "Insert a space and then paste before/after cursor")

nnoremap ([[Y]], [[y$]], "Yank until end of line")

vnoremap ([[<leader>y]], [["+y]], "Yank to system clipboard")
nnoremap ([[<leader>Y]], [["+yg_]], "Yank 'til EOL to system clipboard")
nnoremap ([[<leader>yy]], [["+yy]], "Yank line to system clipboard")
nnoremap ([[<C-y>]], [[pumvisible() ? "\<C-y>" : '"+yy']], expr)
vnoremap ([[<C-y>]], [[pumvisible() ? "\<C-y>" : '"+y']], expr)

nnoremap ([[<leader>yp]], [[:let @+ = expand("%:p")<Cr>:echom "Copied " . @+<Cr>]], silent, "Yank file path")
nnoremap ([[<leader>y:]], [[:let @+=@:<Cr>:echom "Copied '" . @+ . "'"<Cr>]], silent, "Yank last command")

vnoremap ([[<C-p>]], [["+p]], "Paste from system clipboard")
nnoremap ([[<C-p>]], [["+p]], "Paste from system clipboard")

nnoremap ([[<M-p>]], [[a <esc>p]], "Insert a space and then paste after cursor")
nnoremap ([[<M-P>]], [[i <esc>P]], "Insert a space and then paste before cursor")

nnoremap ([[<C-M-j>]], [["dY"dp]], "Duplicate line downwards")
nnoremap ([[<C-M-k>]], [["dY"dP]], "Duplicate line upwards")

vnoremap ([[<C-M-j>]], [["dy`<"dPjgv]], "Duplicate selection downwards")
vnoremap ([[<C-M-k>]], [["dy`>"dpgv]], "Duplicate selection upwards")

-- Clear UI state:
-- - Clear search highlight
-- - Clear command-line
-- - Close floating windows
nnoremap ([[<Esc>]], function()
  vim.cmd("nohlsearch")
  fn.close_float_wins()
  vim.cmd("echo ''")
end, silent, "Clear UI")

-- See: https://github.com/mhinz/vim-galore#saner-ctrl-l
nnoremap ([[<leader>L]], [[:nohlsearch<Cr>:diffupdate<Cr>:syntax sync fromstart<Cr><c-l>]], "Redraw")

nnoremap ([[<leader>rr]], [[:lua require'user.fn'.reload()<Cr>]], silent, "Reload config")

noremap ([[gF]], [[<C-w>gf]], "Go to file under cursor (new tab)")

-- emacs-style motion & editing in insert mode
inoremap ([[<C-a>]], [[<Home>]], "Goto beginning of line")
inoremap ([[<C-e>]], [[<End>]], "Goto end of line")
inoremap ([[<C-b>]], [[<Left>]], "Goto char backward")
inoremap ([[<C-f>]], [[<Right>]], "Goto char forward")
inoremap ([[<M-b>]], [[<S-Left>]], "Goto word backward")
inoremap ([[<M-f>]], [[<S-Right>]], "Goto word forward")
inoremap ([[<C-d>]], [[<Delete>]], "Kill char forward")
inoremap ([[<M-d>]], [[<C-o>de]], "Kill word forward")
inoremap ([[<M-Backspace>]], [[<C-o>dB]], "Kill word backward")
inoremap ([[<C-k>]], [[<C-o>D]], "Kill to end of line")

inoremap ([[<M-h>]], [[<left>]])
inoremap ([[<M-j>]], [[<down>]])
inoremap ([[<M-k>]], [[<up>]])
inoremap ([[<M-l>]], [[<right>]])

inoremap ([[<M-a>]], [[<C-o>_]])

-- unicode stuff
inoremap (xk[[<M-S-k>]], [[<C-k>]], "Insert digraph")
nnoremap ([[gxa]],       [[ga]], "Show char code in decimal, hexadecimal and octal")

-- nano-like kill buffer
-- TODO
vim.cmd([[
  let @k=''
  let @l=''
]])
nnoremap ([[<F30>]], [["ldd:let @k=@k.@l | let @l=@k<cr>]], silent)
nnoremap ([[<F24>]], [[:if @l != "" | let @k=@l | end<cr>"KgP:let @l=@k<cr>:let @k=""<cr>]], silent)

inoremap (xk[[<C-`>]], [[<C-o>~<left>]], "Toggle case")

-- emacs-style motion & editing in command mode
cnoremap ([[<C-a>]], [[<Home>]]) -- Goto beginning of line
cnoremap ([[<C-b>]], [[<Left>]]) -- Goto char backward
cnoremap ([[<C-d>]], [[<Delete>]]) -- Kill char forward
cnoremap ([[<C-f>]], [[<Right>]]) -- Goto char forward
cnoremap ([[<C-g>]], [[<C-c>]]) -- Cancel
cnoremap ([[<C-k>]], [[<C-\>e(" ".getcmdline())[:getcmdpos()-1][1:]<Cr>]]) -- Kill to end of line
cnoremap ([[<M-f>]], [[<C-\>euser#fn#cmdlineMoveWord( 1, 0)<Cr>]]) -- Goto word forward
cnoremap ([[<M-b>]], [[<C-\>euser#fn#cmdlineMoveWord(-1, 0)<Cr>]]) -- Goto word backward
cnoremap ([[<M-d>]], [[<C-\>euser#fn#cmdlineMoveWord( 1, 1)<Cr>]]) -- Kill word forward
cnoremap ([[<M-Backspace>]], [[<C-\>euser#fn#cmdlineMoveWord(-1, 1)<Cr>]]) -- Kill word backward

cnoremap ([[<M-k>]], [[<C-k>]]) -- Insert digraph

-- Make c-n and c-p behave like up/down arrows, i.e. take into account the
-- beginning of the text entered in the command line when jumping, but only if
-- the pop-up menu (completion menu) is not visible
-- See: https://github.com/mhinz/vim-galore#saner-command-line-history
cnoremap ([[<c-p>]],   [[pumvisible() ? "\<C-p>" : "\<up>"]],               expr, "History prev")
cnoremap ([[<c-n>]],   [[pumvisible() ? "\<C-n>" : "\<down>"]],             expr, "History next")
cmap     ([[<M-/>]],   [[pumvisible() ? "\<C-y>" : "\<M-/>"]],              expr, "Accept completion suggestion")
cmap     (xk[[<C-/>]], [[pumvisible() ? "\<C-y>\<Tab>" : nr2char(0x001f)]], expr, "Accept completion suggestion and continue completion")

local function cursor_lock(lock)
  return function()
    if not lock or vim.w.cursor_lock == lock then
      vim.w.cursor_lock = nil
      vim.cmd(([[
        augroup user_cursor_lock_%d
          autocmd!
        augroup END
      ]]):format(vim.api.nvim_get_current_win()))

      fn.notify("Cursor lock disabled")
      return
    end

    vim.w.cursor_lock = lock
    vim.cmd("silent normal z" .. lock)
    vim.cmd(([[
      augroup user_cursor_lock_%d
        autocmd!
        autocmd CursorMoved <buffer> lua if vim.w.cursor_lock then vim.cmd("silent normal z" .. vim.w.cursor_lock) end
      augroup END
    ]]):format(vim.api.nvim_get_current_win()))

    fn.notify("Cursor lock enabled")
  end
end

nnoremap ([[<leader>zt]], cursor_lock("t"), silent, "Toggle cursor lock (top)")
nnoremap ([[<leader>zz]], cursor_lock("z"), silent, "Toggle cursor lock (middle)")
nnoremap ([[<leader>zb]], cursor_lock("b"), silent, "Toggle cursor lock (bottom)")

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

noremap  ([[<M-'>]],   [[:tabn<Cr>]],                     silent, "Tabs: Goto next")
noremap  ([[<M-;>]],   [[:tabp<Cr>]],                     silent, "Tabs: Goto prev")
tnoremap ([[<M-'>]],   [[<C-\><C-n>:tabn<Cr>]],           silent) -- Tabs: goto next
tnoremap ([[<M-;>]],   [[<C-\><C-n>:tabp<Cr>]],           silent) -- Tabs: goto prev
noremap  ([[<M-S-a>]], [[:execute "wincmd g\<Tab>"<Cr>]], silent, "Tabs: Goto last accessed")

noremap  ([[<M-a>]],   ithunk(recent_wins.focus_most_recent),  silent, "Panes: Goto previously focused")
noremap  ([[<M-x>]],   ithunk(recent_wins.flip_recents),       silent, "Panes: Flip the last normal wins")

noremap ([[<M-1>]], tabnm(1),  silent, "Goto tab 1")
noremap ([[<M-2>]], tabnm(2),  silent, "Goto tab 2")
noremap ([[<M-3>]], tabnm(3),  silent, "Goto tab 3")
noremap ([[<M-4>]], tabnm(4),  silent, "Goto tab 4")
noremap ([[<M-5>]], tabnm(5),  silent, "Goto tab 5")
noremap ([[<M-6>]], tabnm(6),  silent, "Goto tab 6")
noremap ([[<M-7>]], tabnm(7),  silent, "Goto tab 7")
noremap ([[<M-8>]], tabnm(8),  silent, "Goto tab 8")
noremap ([[<M-9>]], tabnm(9),  silent, "Goto tab 9")
noremap ([[<M-0>]], tabnm(10), silent, "Goto tab 10")

noremap ([[<M-">]], [[:+tabm<Cr>]], silent, "Move tab right")
noremap ([[<M-:>]], [[:-tabm<Cr>]], silent, "Move tab left")

noremap ([[<F13>]], [[:tabnew<Cr>]], silent, "Open new tab")

tnoremap ([[<M-h>]], [[<C-\><C-n><C-w>h]]) -- Goto tab left
tnoremap ([[<M-j>]], [[<C-\><C-n><C-w>j]]) -- Goto tab down
tnoremap ([[<M-k>]], [[<C-\><C-n><C-w>k]]) -- Goto tab up
tnoremap ([[<M-l>]], [[<C-\><C-n><C-w>l]]) -- Goto tab right

nnoremap ([[<leader>sa]], auto_resize.enable,  "Enable auto-resize")
nnoremap ([[<leader>sA]], auto_resize.disable, "Disable auto-resize")

nnoremap ([[<leader>sf]], ithunk(fn.toggle_winfix, 'height'), "Toggle fixed window height")
nnoremap ([[<leader>sF]], ithunk(fn.toggle_winfix, 'width'), "Toggle fixed window width")

nnoremap ([[<leader>s<M-f>]], ithunk(fn.set_winfix, true, 'height', 'width'), "Enable fixed window height/width")
nnoremap ([[<leader>s<C-f>]], ithunk(fn.set_winfix, false, 'height', 'width'), "Disable fixed window height/width")

-- see also the VSplit plugin mappings below
nnoremap ([[<leader>S]],  [[:new<Cr>]],    silent, "Split (horiz, new)")
nnoremap ([[<leader>sn]], [[:new<Cr>]],    silent, "Split (horiz, new)")
nnoremap ([[<leader>V]],  [[:vnew<Cr>]],   silent, "Split (vert, new)")
nnoremap ([[<leader>vn]], [[:vnew<Cr>]],   silent, "Split (vert, new)")
nnoremap ([[<leader>ss]], [[:split<Cr>]],  silent, "Split (horiz, cur)")
nnoremap ([[<leader>st]], [[:split<Cr>]],  silent, "Split (horiz, cur)")
nnoremap ([[<leader>vv]], [[:vsplit<Cr>]], silent, "Split (vert, cur)")
nnoremap ([[<leader>vt]], [[:vsplit<Cr>]], silent, "Split (vert, cur)")

vnoremap ([[<leader>S]],  [[:VSSplitAbove<Cr>]],    silent, "Visual Split (above)")
vnoremap ([[<leader>ss]], [[:VSSplitAbove<Cr>]],    silent, "Visual Split (above)")
vnoremap ([[<leader>sS]], [[:VSSplit<Cr>]],         silent, "Visual Split (below)")

vnoremap ([[<leader>I]], [[<esc>:call user#fn#interleave()<Cr>]], silent, "Interleave two contiguous blocks")

-- Tabline
local tabline = require'user.tabline'
nmap({ '<C-t><C-t>', '<C-t>t' }, tabline.do_rename_tab, 'Tabpage: Set title')
nmap({ '<C-t><C-l>', '<C-t>l' }, tabline.tabpage_toggle_titlestyle, 'Tabpage: Toggle title style')

-- PasteRestore
-- paste register without overwriting with the original selection
-- use P for original behavior
vnoremap ([[p]], [[user#fn#pasteRestore()]], silent, expr)

nnoremap ([[<leader>T]], [[:Term!<Cr>]], silent, "New term (tab)")
nnoremap ([[<leader>t]], [[:10Term<Cr>]], silent, "New term (split)")

tnoremap (xk[[<C-S-q>]], [[<C-\><C-n>:q<Cr>]]) -- Close terminal
tnoremap (xk[[<C-S-n>]], [[<C-\><C-n>]]) -- Enter Normal mode
tnoremap ([[<C-n>]], [[<C-n>]])
tnoremap ([[<C-p>]], [[<C-p>]])
tnoremap ([[<M-n>]], [[<M-n>]])
tnoremap ([[<M-p>]], [[<M-p>]])

nnoremap ([[<Leader>ml]], [[:call AppendModeline()<Cr>]], silent, "Append modeline with current settings")

---- Quickfix/Loclist
nnoremap ([[<M-S-q>]], function()
  if fn.get_qfwin() then
    vim.cmd[[cclose]]
  else
    vim.cmd[[copen]]
    recent_wins.focus_most_recent()
  end
end, silent, "Quickfix: Toggle")

local function focus_qf()
  local qfwin = require'user.apiutil'.tabpage_get_quickfix_win(0)
  if qfwin then
    vim.api.nvim_set_current_win(qfwin)
  else
    vim.cmd[[copen]]
  end
end

nmap([[<M-q>]], fn.filetype_command("qf", ithunk(recent_wins.focus_most_recent), focus_qf), silent, "Quickfix: Toggle focus")

------ Filetypes
mapx.group(silent, { ft = "lua" }, function()
  nmap     ([[<leader><Enter>]],      fn.luarun,               "Lua: Eval line")
  nmap     ([[<localleader><Enter>]], ithunk(fn.luarun, true), "Lua: Eval file")
  xmap     ([[<leader><Enter>]],      fn.luarun,               "Lua: Eval selection")

  nmap     ([[<leader><F12>]],   "<Cmd>Put lua require'user.fn'.luarun()<Cr>", "Lua: Eval line (Append)")
  xmap     ([[<leader><F12>]],   "<Cmd>Put lua require'user.fn'.luarun()<Cr>", "Lua: Eval selection (Append)")
end)

mapx.group(silent, { ft = "man" }, function()
  -- open manpage tag (e.g. isatty(3)) in current buffer
  nnoremap ([[<C-]>]], function() fn.man('', vim.fn.expand('<cword>')) end,      "Man: Open tag in current buffer")
  nnoremap ([[<M-]>]], function() fn.man('tab', vim.fn.expand('<cword>')) end,   "Man: Open tag in new tab")
  nnoremap ([[}]],     function() fn.man('split', vim.fn.expand('<cword>')) end, "Man: Open tag in new split")

  -- TODO
  -- go back to previous manpage
--   nnoremap ([[<C-t>]],   [[:call man#pop_page))
--   nnoremap ([[<C-o>]],   [[:call man#pop_page()<CR>]])
--   nnoremap ([[<M-o>]],   [[<C-o>]])

  -- navigate to next/prev section
  nnoremap ("[[", [[:<C-u>call user#fn#manSectionMove('b', 'n', v:count1)<CR>]], "Man: Goto prev section")
  nnoremap ("]]", [[:<C-u>call user#fn#manSectionMove('' , 'n', v:count1)<CR>]], "Man: Goto next section")
  xnoremap ("[[", [[:<C-u>call user#fn#manSectionMove('b', 'v', v:count1)<CR>]], "Man: Goto prev section")
  xnoremap ("]]", [[:<C-u>call user#fn#manSectionMove('' , 'v', v:count1)<CR>]], "Man: Goto next section")

  -- navigate to next/prev manpage tag
  nnoremap ([[<Tab>]],   [[:call search('\(\w\+(\w\+)\)', 's')<CR>]],  "Man: Goto next tag")
  nnoremap ([[<S-Tab>]], [[:call search('\(\w\+(\w\+)\)', 'sb')<CR>]], "Man: Goto prev tag")

  -- search from beginning of line (useful for finding command args like -h)
  nnoremap ([[g/]], [[/^\s*\zs]], { silent = false }, "Man: Start BOL search")
end)

------ LSP
mapx.nname("<leader>l", "LSP")
nnoremap ([[<leader>li]], [[:LspInfo<Cr>]],    "LSP: Show LSP information")
nnoremap ([[<leader>lr]], [[:LspRestart<Cr>]], "LSP: Restart LSP")
nnoremap ([[<leader>ls]], [[:LspStart<Cr>]],   "LSP: Start LSP")
nnoremap ([[<leader>lS]], [[:LspStop<Cr>]],    "LSP: Stop LSP")

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
  nmap([[<M-S-t>]], function()
    local winid = trouble_get_win()
    if winid then
      trouble.close()
    else
      trouble.open()
      recent_wins.focus_most_recent()
    end
  end, silent, "Trouble: Toggle")
  nmap([[<M-t>]],
    fn.filetype_command("Trouble", ithunk(recent_wins.focus_most_recent), ithunk(trouble.open)),
    silent, "Trouble: Toggle Focus")
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

  mapx.group({ buffer = bufnr, silent = true }, function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    mapx.nname("<localleader>g", "LSP-Goto")
    nnoremap ({[[<localleader>gd]], [[gd]]}, ithunk(vim.lsp.buf.definition),      "LSP: Goto definition")
    nnoremap ({[[<localleader>gd]], [[gd]]}, ithunk(vim.lsp.buf.definition),      "LSP: Goto definition")
    nnoremap ([[<localleader>gD]],           ithunk(vim.lsp.buf.declaration),     "LSP: Goto declaration")
    nnoremap ([[<localleader>gi]],           ithunk(vim.lsp.buf.implementation),  "LSP: Goto implementation")
    nnoremap ([[<localleader>gt]],           ithunk(vim.lsp.buf.type_definition), "LSP: Goto type definition")
    nnoremap ([[<localleader>gr]],           ithunk(vim.lsp.buf.references),      "LSP: Goto references")

    mapx.nname("<localleader>w", "LSP-Workspace")
    nnoremap ([[<localleader>wa]], ithunk(vim.lsp.buf.add_workspace_folder),    "LSP: Add workspace folder")
    nnoremap ([[<localleader>wr]], ithunk(vim.lsp.buf.remove_workspace_folder), "LSP: Rm workspace folder")

    nnoremap ([[<localleader>wl]], function() fn.inspect(vim.lsp.buf.list_workspace_folders()) end, "LSP: List workspace folders")

    nnoremap ([[<localleader>R]],  ithunk(vim.lsp.buf.rename), "LSP: Rename")

    nnoremap ({[[<localleader>A]], [[<localleader>ca]]}, ithunk(vim.lsp.buf.code_action),       "LSP: Code action")
    vnoremap ({[[<localleader>A]], [[<localleader>ca]]}, ithunk(vim.lsp.buf.range_code_action), "LSP: Code action (range)")

    nnoremap ([[<localleader>F]], ithunk(vim.lsp.buf.formatting_sync),  "LSP: Format")
    vnoremap ([[<localleader>F]], ithunk(vim.lsp.buf.range_formatting), "LSP: Format (range)")

    mapx.nname("<localleader>s", "LSP-Save")
    nnoremap ([[<localleader>S]],  ithunk(user_lsp.set_fmt_on_save),        "LSP: Toggle format on save")
    nnoremap ([[<localleader>ss]], ithunk(user_lsp.set_fmt_on_save),        "LSP: Toggle format on save")
    nnoremap ([[<localleader>se]], ithunk(user_lsp.set_fmt_on_save, true),  "LSP: Enable format on save")
    nnoremap ([[<localleader>sd]], ithunk(user_lsp.set_fmt_on_save, false), "LSP: Disable format on save")

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

    mapx.nname("<localleader>d", "LSP-Diagnostics")
    nnoremap ([[<localleader>ds]],                        ithunk(vim.diagnostic.show),                      "LSP: Show diagnostics")
    nnoremap ({[[<localleader>dt]], [[<localleader>T]]},  ithunk(trouble.toggle), "LSP: Toggle Trouble")

    nnoremap ({[[<localleader>dd]], [[[d]]}, gotoDiag("prev"),          "LSP: Goto prev diagnostic")
    nnoremap ({[[<localleader>dD]], [[]d]]}, gotoDiag("next"),          "LSP: Goto next diagnostic")
    nnoremap ({[[<localleader>dh]], [[[h]]}, gotoDiag("prev", "HINT"),  "LSP: Goto prev hint")
    nnoremap ({[[<localleader>dH]], [[]h]]}, gotoDiag("next", "HINT"),  "LSP: Goto next hint")
    nnoremap ({[[<localleader>di]], [[[i]]}, gotoDiag("prev", "INFO"),  "LSP: Goto prev info")
    nnoremap ({[[<localleader>dI]], [[]i]]}, gotoDiag("next", "INFO"),  "LSP: Goto next info")
    nnoremap ({[[<localleader>dw]], [[[w]]}, gotoDiag("prev", "WARN"),  "LSP: Goto prev warning")
    nnoremap ({[[<localleader>dW]], [[]w]]}, gotoDiag("next", "WARN"),  "LSP: Goto next warning")
    nnoremap ({[[<localleader>de]], [[[e]]}, gotoDiag("prev", "ERROR"), "LSP: Goto prev error")
    nnoremap ({[[<localleader>dE]], [[]e]]}, gotoDiag("next", "ERROR"), "LSP: Goto next error")

    nnoremap ([[[D]], gotoDiag("first"),          "LSP: Goto first diagnostic")
    nnoremap ([[]D]], gotoDiag("last"),           "LSP: Goto last diagnostic")
    nnoremap ([[[H]], gotoDiag("first", "HINT"),  "LSP: Goto first hint")
    nnoremap ([[]H]], gotoDiag("last",  "HINT"),  "LSP: Goto last hint")
    nnoremap ([[[I]], gotoDiag("first", "INFO"),  "LSP: Goto first info")
    nnoremap ([[]I]], gotoDiag("last",  "INFO"),  "LSP: Goto last info")
    nnoremap ([[[W]], gotoDiag("first", "WARN"),  "LSP: Goto first warning")
    nnoremap ([[]W]], gotoDiag("last",  "WARN"),  "LSP: Goto last warning")
    nnoremap ([[[E]], gotoDiag("first", "ERROR"), "LSP: Goto first error")
    nnoremap ([[]E]], gotoDiag("last",  "ERROR"), "LSP: Goto last error")

    nnoremap (']t', ithunk(trouble.next,     {skip_groups = true, jump = true}), "Trouble: Next")
    nnoremap ('[t', ithunk(trouble.previous, {skip_groups = true, jump = true}), "Trouble: Previous")

    mapx.nname("<localleader>s", "LSP-Search")
    nnoremap ({[[<localleader>so]], [[<leader>so]]}, ithunk(fn.require_on_call_rec('user.plugin.telescope').cmds.lsp_document_symbols), "LSP: Telescope symbol search")

    mapx.nname("<localleader>h", "LSP-Hover")
    nnoremap ([[<localleader>hs]], ithunk(vim.lsp.buf.signature_help), "LSP: Signature help")
    nnoremap ([[<localleader>ho]], ithunk(vim.lsp.buf.hover),          "LSP: Hover")
    nnoremap ([[<M-i>]],           ithunk(vim.lsp.buf.hover),          "LSP: Hover")
    inoremap ([[<M-i>]],           ithunk(vim.lsp.buf.hover),          "LSP: Hover")
    nnoremap ([[<M-S-i>]],         ithunk(user_lsp.peek_definition),   "LSP: Peek definition")
  end)
end

------ Plugins
---- folke/which-key.nvim
nnoremap ([[<leader><leader>]], [[:WhichKey<Cr>]], "WhichKey: Show all")

---- AndrewRadev/splitjoin.vim
nnoremap ([[gJ]], [[:SplitjoinJoin<Cr>]],  "Splitjoin: Join")
nnoremap ([[gS]], [[:SplitjoinSplit<Cr>]], "Splitjoin: Split")

---- wbthomason/packer.nvim
mapx.nname("<leader>p", "Packer")
nnoremap ([[<leader>pC]], [[:PackerClean<Cr>]],   "Packer: Clean")
nnoremap ([[<leader>pc]], [[:PackerCompile<Cr>]], "Packer: Compile")
nnoremap ([[<leader>pi]], [[:PackerInstall<Cr>]], "Packer: Install")
nnoremap ([[<leader>pu]], [[:PackerUpdate<Cr>]],  "Packer: Update")
nnoremap ([[<leader>ps]], [[:PackerSync<Cr>]],    "Packer: Sync")
nnoremap ([[<leader>pl]], [[:PackerLoad<Cr>]],    "Packer: Load")

mapx.group(silent, { ft = "packer" }, function()
  nmap ([[O]], function()
    if not vim.env.BROWSER or vim.env.BROWSER == "" then
      vim.notify("Packer: Can't open repo: BROWSER environment variable is unset", vim.log.levels.ERROR)
      return
    end
    local pd = require'packer.display'
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
map      ([[<M-/>]], [[gcc<Esc>]], silent) -- Toggle line comment
inoremap ([[<M-/>]], [[v:count == 0 ? '<Esc><Cmd>set operatorfunc=v:lua.___comment_gcc<Cr>g@$a' : '<Esc><Cmd>lua ___comment_count_gcc()<Cr>a']], silent, expr, "Toggle line comment")

---- aserowy/tmux.nvim
local tmux = fn.require_on_exported_call 'tmux'
nmap     ([[<M-h>]], ithunk(tmux.move_left),   silent, "Goto window/tmux pane left")
nmap     ([[<M-j>]], ithunk(tmux.move_bottom), silent, "Goto window/tmux pane down")
nmap     ([[<M-k>]], ithunk(tmux.move_top),    silent, "Goto window/tmux pane up")
nmap     ([[<M-l>]], ithunk(tmux.move_right),  silent, "Goto window/tmux pane right")

mapx.group(silent, function()
  local tb = fn.require_on_call_rec 'telescope.builtin'
  local tu = fn.require_on_call_rec 'user.plugin.telescope'
  local tc = tu.cmds

  mapx.nname([[<C-f>]], "Telescope")
  nnoremap (xk[[<C-S-f>]],                ithunk(tc.builtin),     "Telescope: Builtins")
  nnoremap ([[<C-f>b]],                   ithunk(tc.buffers),     "Telescope: Buffers")
  nnoremap ({[[<C-f>h]], [[<C-f><C-h>]]}, ithunk(tc.help_tags),   "Telescope: Help tags")
  nnoremap ({[[<C-f>t]], [[<C-f><C-t>]]}, ithunk(tc.tags),        "Telescope: Tags")
  nnoremap ({[[<C-f>a]], [[<C-f><C-a>]]}, ithunk(tc.grep_string), "Telescope: Grep for string")
  nnoremap ({[[<C-f>p]], [[<C-f><C-p>]]}, ithunk(tc.live_grep),   "Telescope: Live grep")
  nnoremap ({[[<C-f>o]], [[<C-f><C-o>]]}, ithunk(tc.oldfiles),    "Telescope: Old files")
  nnoremap ({[[<C-f>f]], [[<C-f><C-f>]]}, ithunk(tc.smart_files), "Telescope: Files")

  nnoremap ({[[<C-M-f>]], [[<C-f>r]], [[<C-f><C-r>]]}, ithunk(tc.resume), "Telescope: Resume last picker")

  local tcw = tc.windows
  nnoremap ({[[<C-f>w]], [[<C-f><C-w>]]}, ithunk(tcw.windows, {}), "Telescope: Windows")

  local tcgw = tc.git_worktree
  mapx.nname([[<C-f>g]], "Telescope-Git")
  nnoremap ([[<C-f>gw]], ithunk(tcgw.git_worktrees), "Telescope-Git: Worktrees")

  mapx.nname([[<M-f>]], "Telescope-Buffer")
  nnoremap ({[[<M-f>b]], [[<M-f><M-b>]]}, ithunk(tc.current_buffer_fuzzy_find), "Telescope-Buffer: Fuzzy find")
  nnoremap ({[[<M-f>t]], [[<M-f><M-t>]]}, ithunk(tc.tags),                      "Telescope-Buffer: Tags")
  nnoremap ({[[<M-f>u]], [[<M-f><M-u>]]}, ithunk(tc.urlview),                   "Telescope-Buffer: URLs")

  mapx.nname([[<M-f>]], "Telescope-Workspace")
  nnoremap ([[<C-f>A]], ithunk(tc.aerial), "Telescope-Workspace: Aerial")
end)

---- tpope/vim-fugitive and TimUntersberger/neogit
mapx.nname("<leader>g",  "Git")
mapx.nname("<leader>ga", "Git-Add")
nnoremap ([[<leader>gA]],  [[:Git add --all<Cr>]],                "Git: Add all")
nnoremap ([[<leader>gaa]], [[:Git add --all<Cr>]],                "Git: Add all")
nnoremap ([[<leader>gaf]], [[:Git add :%<Cr>]],                   "Git: Add file")

mapx.nname("<leader>gc", "Git-Commit")
nnoremap ([[<leader>gC]],  [[:Git commit --verbose<Cr>]],         "Git: Commit")
nnoremap ([[<leader>gcc]], [[:Git commit --verbose<Cr>]],         "Git: Commit")
nnoremap ([[<leader>gca]], [[:Git commit --verbose --all<Cr>]],   "Git: Commit (all)")
nnoremap ([[<leader>gcA]], [[:Git commit --verbose --amend<Cr>]], "Git: Commit (amend)")

mapx.nname("<leader>gl", "Git-Log")
nnoremap ([[<leader>gL]],  [[:Gclog!<Cr>]],                       "Git: Log")
nnoremap ([[<leader>gll]], [[:Gclog!<Cr>]],                       "Git: Log")
nnoremap ([[<leader>glL]], [[:tabnew | Gclog<Cr>]],               "Git: Log (tab)")

mapx.nname("<leader>gp", "Git-Push-Pull")
nnoremap ([[<leader>gpa]], [[:Git push --all<Cr>]],               "Git: Push all")
nnoremap ([[<leader>gpp]], [[:Git push<Cr>]],                     "Git: Push")
nnoremap ([[<leader>gpl]], [[:Git pull<Cr>]],                     "Git: Pull")

nnoremap ([[<leader>gR]],  [[:Git reset<Cr>]],                    "Git: Reset")

mapx.nname("<leader>gs", "Git-Status")
nnoremap ([[<leader>gS]],  [[:Neogit<Cr>]],                       "Git: Status")
nnoremap ([[<leader>gss]], [[:Neogit<Cr>]],                       "Git: Status")
nnoremap ([[<leader>gst]], [[:Neogit<Cr>]],                       "Git: Status")

nnoremap ([[<leader>gsp]], [[:Gsplit<Cr>]],                       "Git: Split")

mapx.nname("<leader>G", "Git")
nnoremap ([[<leader>GG]],  [[:Git<Cr>]],                          "Git: Status")
nnoremap ([[<leader>GS]],  [[:Git<Cr>]],                          "Git: Status")
nnoremap ([[<leader>GA]],  [[:Git add<Cr>]],                      "Git: Add")
nnoremap ([[<leader>GC]],  [[:Git commit<Cr>]],                   "Git: Commit")
nnoremap ([[<leader>GF]],  [[:Git fetch<Cr>]],                    "Git: Fetch")
nnoremap ([[<leader>GL]],  [[:Git log<Cr>]],                      "Git: Log")
nnoremap ([[<leader>GPP]], [[:Git push<Cr>]],                     "Git: Push")
nnoremap ([[<leader>GPL]], [[:Git pull<Cr>]],                     "Git: Pull")

local function gitsigns_visual_op(op)
  return function()
    return require('gitsigns')[op]({ vim.fn.line("."), vim.fn.line("v") })
  end
end

-- lewis6991/gitsigns.nvim
M.on_gistsigns_attach = function(bufnr)
  mapx.group({ buffer = bufnr, silent = true }, function()
    local gs = require'gitsigns'
    nnoremap([[<leader>hs]],  ithunk(gs.stage_hunk),                "Gitsigns: Stage hunk")
    nnoremap([[<leader>hr]],  ithunk(gs.reset_hunk),                "Gitsigns: Reset hunk")
    nnoremap([[<leader>hu]],  ithunk(gs.undo_stage_hunk),           "Gitsigns: Undo stage hunk")
    vnoremap([[<leader>hs]],  gitsigns_visual_op"stage_hunk",       "Gitsigns: Stage selected hunk(s)")
    vnoremap([[<leader>hr]],  gitsigns_visual_op"reset_hunk",       "Gitsigns: Reset selected hunk(s)")
    vnoremap([[<leader>hu]],  gitsigns_visual_op"undo_stage_hunk",  "Gitsigns: Undo stage hunk")
    nnoremap([[<leader>hS]],  ithunk(gs.stage_buffer),              "Gitsigns: Stage buffer")
    nnoremap([[<leader>hR]],  ithunk(gs.reset_buffer),              "Gitsigns: Reset buffer")
    nnoremap([[<leader>hp]],  ithunk(gs.preview_hunk),              "Gitsigns: Preview hunk")
    nnoremap([[<leader>hb]],  ithunk(gs.blame_line, {full=true}),   "Gitsigns: Blame hunk")
    nnoremap([[<leader>htb]], ithunk(gs.toggle_current_line_blame), "Gitsigns: Toggle current line blame")
    nnoremap([[<leader>hd]],  ithunk(gs.diffthis),                  "Gitsigns: Diff this")
    nnoremap([[<leader>hD]],  ithunk(gs.diffthis, "~"),             "Gitsigns: Diff this against last commit")
    nnoremap([[<leader>htd]], ithunk(gs.toggle_deleted),            "Gitsigns: Toggle deleted")

    nnoremap ("]c", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", "Gitsigns: Next hunk", expr)
    nnoremap ("[c", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", "Gitsigns: Prev hunk", expr)
    onoremap([[ih]], ":<C-U>Gitsigns select_hunk<CR>",              "[TextObj] Gitsigns: Inner hunk")
    xnoremap([[ih]], ":<C-U>Gitsigns select_hunk<CR>",              "[TextObj] Gitsigns: Inner hunk")
  end)
end

-- mbbill/undotree
nnoremap ([[<leader>ut]], [[:UndotreeToggle<Cr>]], "Undotree: Toggle")

-- godlygeek/tabular
nmap ([[<Leader>a]], ":Tabularize /", "Tabularize")
vmap ([[<Leader>a]], ":Tabularize /", "Tabularize")

---- KabbAmine/vCoolor.vim
nmap([[<leader>co]], [[:VCoolor<CR>]], silent, "Open VCooler color picker")

------ nvim-neo-tree/neo-tree.nvim & kyazdani42/nvim-tree.lua
---- nvim-neo-tree/neo-tree.nvim
local neotree_mgr = fn.require_on_call_rec'neo-tree.sources.manager'
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
  nmap(xk[[<C-S-\>]], function()
    vim.cmd[[Neotree show toggle]]
    vim.schedule(auto_resize.trigger)
  end, silent, "NeoTree: Toggle")

  nmap(xk[[<C-\>]], fn.filetype_command("neo-tree", ithunk(recent_wins.focus_most_recent), function()
    vim.cmd[[Neotree focus]]
    vim.schedule(auto_resize.trigger)
  end), silent, "Nvim-Tree: Toggle Focus")
end

---- kyazdani42/nvim-tree.lua
local setup_nvimtree = function()
  nmap(xk[[<C-S-\>]], function()
    if require'nvim-tree.view'.is_visible() then
      require'nvim-tree.view'.close()
    else
      require'nvim-tree.lib'.open()
      recent_wins.focus_most_recent()
    end
  end, silent, "Nvim-Tree: Toggle")

  nmap(xk[[<C-\>]], fn.filetype_command("NvimTree", ithunk(recent_wins.focus_most_recent), thunk(vim.cmd, [[NvimTreeFocus]])), silent, "Nvim-Tree: Toggle Focus")

  mapx.group({ ft = "NvimTree" }, function()
    local function withSelected(cmd, fmt)
      return function()
        local file = require'nvim-tree.lib'.get_node_at_cursor().absolute_path
        vim.cmd(fmt and (cmd):format(file) or ("%s %s"):format(cmd, file))
      end
    end
    nnoremap ([[ga]], withSelected("Git add"),             "Nvim-Tree: Git add")
    nnoremap ([[gr]], withSelected("Git reset --quiet"),   "Nvim-Tree: Git reset")
    nnoremap ([[gb]], withSelected("tabnew | Git blame"),  "Nvim-Tree: Git blame")
    nnoremap ([[gd]], withSelected("tabnew | Gdiffsplit"), "Nvim-Tree: Git diff")
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
      vim.cmd[[Neotree close]]
    end
  else
    if package.loaded['nvim-tree'] and require'nvim-tree.view'.is_visible() then
      open_neotree = true
      if vim.api.nvim_buf_get_option(0, 'filetype') == 'NvimTree' then
        tree_foc = true
      end
      require'nvim-tree.view'.close()
    end
  end

  vim.g.use_neotree = not vim.g.use_neotree
  vim.notify('Using ' .. (vim.g.use_neotree and 'NeoTree' or 'NvimTree'))
  setup_tree()

  if open_nvimtree then
    require'nvim-tree.lib'.open()
    if not tree_foc then
      recent_wins.focus_most_recent()
    end
  elseif open_neotree then
    if tree_foc then
      vim.cmd[[Neotree focus]]
    else
      vim.cmd[[Neotree show]]
    end
  end
end

nmap(xk[[<C-S-t>]], toggle_tree, silent, "Toggle selected file tree plugin")

setup_tree(true)

-- stevearc/aerial.nvim
local aerial = fn.require_on_index"aerial"
local aerial_util = fn.require_on_index"aerial.util"

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
  if not require"aerial.backends".get() then
    fn.notify("no aerial backend")
    return
  end

  -- Get width of nvim-tree or neo-tree before opening aerial (sometimes
  -- opening aerial causes file tree windows to get smooshed)
  local nvt_win = package.loaded['nvim-tree'] and require'nvim-tree.view'.get_winnr()
  local nvt_width
  if nvt_win and vim.api.nvim_win_is_valid(nvt_win) then
    nvt_width = vim.api.nvim_win_get_width(nvt_win)
  end
  local neo_vis, neo_win, neo_width
  if package.loaded['neo-tree'] then
    neo_vis, neo_win =  user_neotree.is_visible()
    if neo_vis then
      neo_width = vim.api.nvim_win_get_width(neo_win)
    end
  end

  require"aerial.window".open(focus)

  -- Reset tree window width in case smooshing occurred
  if nvt_width then
    vim.api.nvim_win_set_width(nvt_win, nvt_width)
  end
  if neo_width then
    vim.api.nvim_win_set_width(neo_win, neo_width)
  end

  auto_resize.trigger()
end

nmap(xk[[<M-S-\>]], function()
  if  aerial_get_win() then
    local foc = require"aerial.util".is_aerial_buffer()
    aerial.close()
    if foc then recent_wins.focus_most_recent() end
  else
    aerial_open()
  end
end, silent, "Aerial: Toggle")

nmap([[<M-\>]],
  fn.filetype_command("aerial", ithunk(recent_wins.focus_most_recent), ithunk(aerial_open, true)),
  silent, "Aerial: Toggle Focus")

mapx.group(silent, { ft = "aerial" }, function()
  local function aerial_select(opts)
    require'aerial.navigation'.select(vim.tbl_extend("force", {
      winid = recent_wins.get_most_recent()
    }, opts or {}))
  end
  local function aerial_view(cmd)
    vim.schedule(ithunk(aerial_select, { jump = false }))
    return cmd or "\\<Nop>"
  end
  nnoremap([[<Cr>]],  ithunk(aerial_select),          "Aerial: Select item")
  nnoremap([[<Tab>]], ithunk(aerial_view),      expr, "Aerial: Bring item into view")
  nnoremap([[J]],     ithunk(aerial_view, "j"), expr, "Aerial: Bring next item into view")
  nnoremap([[K]],     ithunk(aerial_view, "k"), expr, "Aerial: Bring previous item into view")
end)

---- mfussenegger/nvim-dap
local function dap_pre()
  nnoremap([[<leader>D]], function()
    require'user.dap'.launch(vim.bo.filetype)
  end, "DAP: Launch")
end
dap_pre()

M.on_dap_attach = function()
  local dap = require'dap'
  local dap_ui_vars = require'dap.ui.variables'
  local dap_ui_widgets = require'dap.ui.widgets'

  nnoremap([[<leader>D]], function()
    require'user.dap'.close(vim.bo.filetype)
  end, "DAP: Disconnect")

  local breakpointCond = function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))end

  local toggleRepl = function() dap.repl.toggle({}, " vsplit")vim.fn.wincmd('l') end

  mapx.nname([[<leader>d]], "DAP")
  nnoremap([[<leader>dR]],  dap.restart,                                          "DAP: Restart")
  nnoremap([[<leader>dh]],  dap.toggle_breakpoint,                                "DAP: Toggle breakpoint")
  nnoremap([[<leader>dH]],  breakpointCond,                                       "DAP: Set breakpoint condition")
  nnoremap([[<leader>de]],  ithunk(dap.set_exception_breakpoints, {"all"}),       "DAP: Break on exception")
  nnoremap([[<leader>dr]],  toggleRepl,                                           "DAP: Toggle REPL")
  nnoremap([[<leader>di]],  dap_ui_vars.hover,                                    "DAP: Hover variables")
  nnoremap([[<leader>di]],  dap_ui_vars.visual_hover,                             "DAP: Hover variables (visual)")
  nnoremap([[<leader>d?]],  dap_ui_vars.scopes,                                   "DAP: Scopes")
  nnoremap([[<leader>dk]],  dap.up,                                               "DAP: Up")
  nnoremap([[<leader>dj]],  dap.down,                                             "DAP: Down")
  nnoremap([[<leader>di]],  dap_ui_widgets.hover,                                 "DAP: Hover")
  nnoremap([[<leader>d?]],  dap_ui_widgets.centered_float, dap_ui_widgets.scopes, "DAP: Scopes")

--   nnoremap([[<leader>dR]],  ithunk(dap.disconnect, {restart = false, terminateDebuggee = false}), "DAP: Restart")

  nnoremap({ [[<leader>dso]], [[<c-k>]] }, dap.step_out,  "DAP: Step out")
  nnoremap({ [[<leader>dsi]], [[<c-l>]] }, dap.step_into, "DAP: Step into")
  nnoremap({ [[<leader>dsO]], [[<c-j>]] }, dap.step_over, "DAP: Step over")
  nnoremap({ [[<leader>dsc]], [[<c-h>]] }, dap.continue,  "DAP: Continue")

  -- nnoremap([[<leader>da]],  require"debugHelper".attach()<CR>')
  -- nnoremap([[<leader>dA]],  require"debugHelper".attachToRemote()<CR>')
end

M.on_dap_detach = function()
  -- TODO
end

---- sindrets/winshift.nvim
nnoremap ([[<Leader>M]],  [[<Cmd>WinShift<Cr>]], "WinShift: Start")
nnoremap ([[<Leader>mm]], [[<Cmd>WinShift<Cr>]], "WinShift: Start")

---- chentau/marks.nvim
nmap     ([[<M-m>]],     [[m;]],                              "Mark: create next")
nnoremap ([[]"]],        [[[']],                              "Mark: goto previous")
nnoremap ([[<leader>']], ithunk(require'marks'.toggle_signs), "Mark: toggle signs")

---- mrjones2014/smart-splits.nvim
local smart_splits = fn.require_on_exported_call('smart-splits')
noremap ([[<M-[>]], ithunk(smart_splits.resize_left),  'Resize-Win: Left')
noremap ([[<M-]>]], ithunk(smart_splits.resize_right), 'Resize-Win: Right')
noremap ([[<M-{>]], ithunk(smart_splits.resize_up),    'Resize-Win: Up')
noremap ([[<M-}>]], ithunk(smart_splits.resize_down),  'Resize-Win: Down')

return M
