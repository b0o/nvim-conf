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

-- Extra keys
-- Configure your terminal emulator to send the unicode codepoint for each
-- given key sequence
local xk = fn.utf8keys {
  [ [[<C-S-q>]] ] = 0xff01,
  [ [[<C-S-n>]] ] = 0xff02,
  [ [[<C-\>]] ] = 0x00f0,
  [ [[<C-S-\>]] ] = 0x00f1,
  [ [[<M-S-\>]] ] = 0x00f2,
  [ [[<C-`>]] ] = 0x00f3,
  [ [[<C-S-w>]] ] = 0x00f4,
  [ [[<C-S-f>]] ] = 0x00f5,
  [ [[<C-/>]] ] = 0x001f,
}

-- stylua: ignore start
-- Disable C-z suspend
map     ([[<C-z>]], [[<Nop>]])
mapbang ([[<C-z>]], [[<Nop>]])

-- Disable C-c warning
map     ([[<C-c>]], [[<Nop>]])

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

-- https://vim.fandom.com/wiki/Insert_a_single_character
nnoremap ([[gi]], [[:exec "normal i".nr2char(getchar())."\e"<Cr>]], silent, "Insert a single character")
nnoremap ([[ga]], [[:exec "normal a".nr2char(getchar())."\e"<Cr>]], silent, "Insert a single character")

vnoremap ([[>]], [[>gv]], "Indent")
vnoremap ([[<]], [[<gv]], "De-Indent")

nnoremap ({[[Q]], [[<F29>]]}, [[:CloseWin<Cr>]],     silent, "Close window")
nnoremap ([[ZQ]],             [[:confirm qall<Cr>]], silent, "Quit all")
nnoremap (xk[[<C-S-w>]],        [[:tabclose<Cr>]],     silent, "Close tab (except last one)")
nnoremap ([[<leader>H]],      [[:hide<Cr>]],         silent, "Hide buffer")

noremap ([[<C-s>]], [[:w<Cr>]], "Write buffer")

-- quickly enter command mode with substitution commands prefilled
-- TODO: need to force redraw
nnoremap ([[<leader>/]], [[:%s/]], "Substitute")
nnoremap ([[<leader>?]], [[:%S/]], "Substitute (rev)")
vnoremap ([[<leader>/]], [[:s/]],  "Substitute")
vnoremap ([[<leader>?]], [[:S/]],  "Substitute (rev)")

nnoremap ({[[<leader>W]], [[<leader>ww]]}, [[:setlocal wrap!<Cr>:setlocal wrap?<Cr>]], silent, "Toggle wrap")

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

-- conceal
nnoremap ([[<leader>cl]], [[:call user#fn#toggleConcealLevel()<Cr>]], silent, "Toggle conceal level")
nnoremap ([[<leader>cc]], [[:call user#fn#toggleConcealCursor()<Cr>]], silent, "Toggle conceal cursor")

-- cursorcolumn
nnoremap ([[<leader>|]], [[:set invcursorcolumn<Cr>]], silent, "Toggle cursorcolumn")

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

-- unicode stuff
inoremap ([[<M-k>]], [[<C-k>]], "Insert digraph")
nnoremap ([[gxa]],   [[ga]], "Show char code in decimal, hexadecimal and octal")

-- nano-like kill buffer
-- TODO
vim.cmd([[
  let @k=''
  let @l=''
]])
nnoremap ([[<F30>]], [["ldd:let @k=@k.@l | let @l=@k<cr>]], silent)
nnoremap ([[<F24>]], [[:if @l != "" | let @k=@l | end<cr>"KgP:let @l=@k<cr>:let @k=""<cr>]], silent)

-- overload tab key to also perform next/prev in popup menus
-- inoremap ([[<Tab>]],   [[pumvisible() ? "\<C-n>" : "\<Tab>"]], silent, expr)
-- inoremap ([[<S-Tab>]], [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], silent, expr)

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

--"" Tabs

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
noremap  ([[<M-a>]],   fn.focus_last_normal_win,          silent, "Panes: Goto previously focused")

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

noremap ([[<M-[>]], ithunk(fn.resize_win, '<', 3), 'Shrink window width')
noremap ([[<M-]>]], ithunk(fn.resize_win, '>', 3), 'Grow window width')

noremap ([[<M-{>]], ithunk(fn.resize_win, '-', 3), 'Shrink window height')
noremap ([[<M-}>]], ithunk(fn.resize_win, '+', 3), 'Grow window height')

nnoremap ([[<leader>sa]], fn.autoresize_enable,  "Enable autoresize")
nnoremap ([[<leader>sA]], fn.autoresize_disable, "Disable autoresize")

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

vnoremap ([[<leader>I]], [[<esc>:call user#fn#interleave()<Cr>]], silent, "Interleave two contiguous blocks")

-- PasteRestore
-- paste register without overwriting with the original selection
-- use P for original behavior
vnoremap ([[p]], [[user#fn#pasteRestore()]], silent, expr)

nnoremap ([[<leader>T]], [[:Term!<Cr>]], silent, "New term (tab)")
nnoremap ([[<leader>t]], [[:10Term<Cr>]], silent, "New term (split)")

-- map <C-S-q> to \x1b[15;5~ (F29) in your terminal emulator
-- tnoremap ([[<F29>]], [[<C-\><C-n>:q<Cr>]]) -- Close terminal

tnoremap (xk[[<C-S-q>]], [[<C-\><C-n>:q<Cr>]]) -- Close terminal
tnoremap (xk[[<C-S-n>]], [[<C-\><C-n>]]) -- Enter Normal mode
tnoremap ([[<C-n>]], [[<C-n>]])
tnoremap ([[<C-p>]], [[<C-p>]])
tnoremap ([[<M-n>]], [[<M-n>]])
tnoremap ([[<M-p>]], [[<M-p>]])

nnoremap ([[<Leader>ml]], [[:call AppendModeline()<Cr>]], silent, "Append modeline with current settings")

------ Filetypes
mapx.group(silent, { ft = "lua" }, function()
  nmap     ([[<leader><Enter>]], require'user.fn'.luarun, "Lua: Eval line")
  xmap     ([[<leader><Enter>]], require'user.fn'.luarun, "Lua: Eval selection")
  nmap     ([[<leader><F12>]],   "<Cmd>Put lua require'user.fn'.luarun()<Cr>", "Lua: Eval line (Append)")
  xmap     ([[<leader><F12>]],   "<Cmd>Put lua require'user.fn'.luarun()<Cr>", "Lua: Eval selection (Append)")
end)

mapx.group({ "silent", ft = "man" }, function()
  -- open manpage tag (e.g. isatty(3)) in current buffer
  nnoremap ([[<C-]>]], function() require'user.fn'.man('', vim.fn.expand('<cword>')) end,      "Man: Open tag in current buffer")
  nnoremap ([[<M-]>]], function() require'user.fn'.man('tab', vim.fn.expand('<cword>')) end,   "Man: Open tag in new tab")
  nnoremap ([[}]],     function() require'user.fn'.man('split', vim.fn.expand('<cword>')) end, "Man: Open tag in new split")

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

local lsp_attached_bufs = {}
M.on_lsp_attach = function(bufnr)
  if lsp_attached_bufs[bufnr] or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  lsp_attached_bufs[bufnr] = true
  local user_lsp = require'user.lsp'

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

    nnoremap ([[<localleader>F]], ithunk(require'user.lsp'.buf_formatting_sync), "LSP: Format")
    vnoremap ([[<localleader>F]], ithunk(vim.lsp.buf.range_formatting),          "LSP: Format (range)")

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
    nnoremap ([[<localleader>ds]],                        ithunk(vim.diagnostic.show),      "LSP: Show diagnostics")
    nnoremap ({[[<localleader>dt]], [[<localleader>T]]},  ithunk(require'trouble'.toggle), "LSP: Toggle Trouble")

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

    nnoremap (']t', ithunk(require("trouble").next,     {skip_groups = true, jump = true}), "Trouble: Next")
    nnoremap ('[t', ithunk(require("trouble").previous, {skip_groups = true, jump = true}), "Trouble: Previous")

    mapx.nname("<localleader>s", "LSP-Search")
    nnoremap ({[[<localleader>so]], [[<leader>so]]}, require('telescope.builtin').lsp_document_symbols, "LSP: Telescope symbol search")

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

---- wbthomason/packer.nvim
mapx.nname("<leader>p", "Packer")
nnoremap ([[<leader>pC]], [[:PackerClean<Cr>]], "Packer clean")
nnoremap ([[<leader>pc]], [[:PackerCompile<Cr>]], "Packer compile")
nnoremap ([[<leader>pi]], [[:PackerInstall<Cr>]], "Packer install")
nnoremap ([[<leader>pu]], [[:PackerUpdate<Cr>]], "Packer update")
nnoremap ([[<leader>ps]], [[:PackerSync<Cr>]], "Packer sync")
nnoremap ([[<leader>pl]], [[:PackerLoad<Cr>]], "Packer load")

---- numToStr/Comment.nvim
map      ([[<M-/>]], [[gcc<Esc>]], silent) -- Toggle line comment
inoremap ([[<M-/>]], [[v:count == 0 ? '<Esc><Cmd>set operatorfunc=v:lua.___comment_gcc<Cr>g@$a' : '<Esc><Cmd>lua ___comment_count_gcc()<Cr>a']], silent, expr, "Toggle line comment")

---- aserowy/tmux.nvim
local tmux = require("tmux")
nmap     ([[<M-h>]], ithunk(tmux.move_left),   silent, "Goto window/tmux pane left")
nmap     ([[<M-j>]], ithunk(tmux.move_bottom), silent, "Goto window/tmux pane down")
nmap     ([[<M-k>]], ithunk(tmux.move_top),    silent, "Goto window/tmux pane up")
nmap     ([[<M-l>]], ithunk(tmux.move_right),  silent, "Goto window/tmux pane right")

---- nvim-telescope/telescope.nvim TODO: In-telescope maps
mapx.group("silent", function()
  local t = require'telescope'
  local tb = require'telescope.builtin'
  local tx = t.extensions

  local tu = require'user.plugin.telescope'
  local tc = tu.cmds

  mapx.nname([[<C-f>]], "Telescope")
  nnoremap (xk[[<C-S-f>]],                tc.builtin,     "Telescope: Builtins")
  nnoremap ([[<C-f>b]],                   tc.buffers,     "Telescope: Buffers")
  nnoremap ({[[<C-f>h]], [[<C-f><C-h>]]}, tc.help_tags,   "Telescope: Help tags")
  nnoremap ({[[<C-f>t]], [[<C-f><C-t>]]}, tc.tags,        "Telescope: Tags")
  nnoremap ({[[<C-f>a]], [[<C-f><C-a>]]}, tc.grep_string, "Telescope: Grep for string")
  nnoremap ({[[<C-f>p]], [[<C-f><C-p>]]}, tc.live_grep,   "Telescope: Live grep")
  nnoremap ({[[<C-f>o]], [[<C-f><C-o>]]}, tc.oldfiles,    "Telescope: Old files")
  nnoremap ({[[<C-f>f]], [[<C-f><C-f>]]}, tc.find_files,  "Telescope: Files")

  local txw = tx.windows
  nnoremap ({[[<C-f>w]], [[<C-f><C-w>]]}, ithunk(txw.windows, {}), "Telescope: Windows")

  local txgw = tx.git_worktree
  mapx.nname([[<C-f>g]], "Telescope-Git")
  nnoremap ([[<C-f>gw]], ithunk(txgw.git_worktrees), "Telescope: Git worktrees")
  nnoremap ([[<C-f>gW]], ithunk(txgw.git_worktrees), "Telescope: Git worktree create")

  mapx.nname([[<M-f>]], "Telescope-Buffer")
  nnoremap ({[[<M-f>b]], [[<M-f><M-b>]]}, tb.current_buffer_fuzzy_find,          "Telescope: Buffer (fuzzy)")
  nnoremap ({[[<M-f>t]], [[<M-f><M-t>]]}, tb.tags, "Telescope: Tags (buffer)")
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

---- kyazdani42/nvim-tree.lua
nmap(xk[[<C-S-\>]], function()
  if require'nvim-tree.view'.is_visible() then
    require'nvim-tree.view'.close()
  else
    require'nvim-tree.lib'.open()
    fn.focus_last_normal_win()
  end
end, silent, "Nvim-Tree: Toggle")
nmap(xk[[<C-\>]],
  fn.filetype_command( "NvimTree", fn.focus_last_normal_win, thunk(vim.cmd, [[NvimTreeFocus]])),
  silent, "Nvim-Tree: Toggle Focus")

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

-- trouble.nvim
local function trouble_get_win()
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
    if ft == "Trouble" then
      return winid
    end
  end
end

M.trouble_get_win = trouble_get_win

local trouble = fn.require_on_exported_call'trouble'

nmap([[<M-S-t>]], function()
  local winid = trouble_get_win()
  if winid then
    trouble.close()
  else
    trouble.open()
    -- vim.cmd[[wincmd p]]
    fn.focus_last_normal_win()
  end
end, silent, "Trouble: Toggle")

nmap([[<M-t>]],
  fn.filetype_command("Trouble", fn.focus_last_normal_win, ithunk(trouble.open)),
  silent, "Trouble: Toggle Focus")

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
  require"aerial.window".open(focus)
end

nmap(xk[[<M-S-\>]], function()
  if require"aerial.util".is_aerial_buffer() or aerial_get_win() then
    aerial.close()
  else
    aerial_open()
  end
end, silent, "Aerial: Toggle")

nmap([[<M-\>]],
  fn.filetype_command("aerial", fn.focus_last_normal_win, ithunk(aerial_open, true)),
  silent, "Trouble: Toggle Focus")

-- mapx.group({ ft = "aerial" }, function()
--   nmap([[<Cr>]], "e")
-- end)

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

---- VonHeikemen/fine-cmdline.nvim
local fcl = require'fine-cmdline'
noremap  ([[<leader>:]], fcl.open, "FineCmdline: Open")

M.fine_cmdline = function()
  mapx.group("buffer", function()
    inoremap ([[<C-g>]], fcl.fn.close, "FineCmdline: Close")
    imap ([[<c-p>]], [[pumvisible() ? "\<C-p>" : "\<up>"]],   expr)
    imap ([[<c-n>]], [[pumvisible() ? "\<C-n>" : "\<down>"]], expr)
  end)
end

---- chentau/marks.nvim
nmap     ([[<M-m>]],     [[m;]],                              "Mark: create next")
nnoremap ([[]"]],        [[[']],                              "Mark: goto previous")
nnoremap ([[<leader>']], ithunk(require'marks'.toggle_signs), "Mark: toggle signs")

return M
