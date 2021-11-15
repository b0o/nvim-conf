local M = {}
-- print(1, vim.fn.reltimefloat(vim.fn.reltime()))

local fn = require 'user.fn'
local thunk, ithunk = fn.thunk, fn.ithunk

local m = require('mapx').setup {
  global = true,
  whichkey = true,
  enableCountArg = false,
  debug = vim.g.mapxDebug or false,
}

local silent = m.silent
local expr = m.expr

-- Extra keys
-- Configure your terminal emulator to send the unicode codepoint for each
-- given key sequence
local xk = fn.utf8keys {
  ['<C-S-n>'] = 0xff00,
  ['<C-S-q>'] = 0xff01,
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
nnoremap ([[<C-w>]],          [[:tabclose<Cr>]],     silent, "Close tab (except last one)")
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
nnoremap ([[<leader>y:]], [[:let @+=@:<Cr>:echom "Copied " . @+<Cr>]], silent, "Yank last command")

vnoremap ([[<C-p>]], [["+p]], "Paste from system clipboard")
nnoremap ([[<C-p>]], [["+p]], "Paste from system clipboard")

nnoremap ([[<M-p>]], [[a <esc>p]], "Insert a space and then paste after cursor")
nnoremap ([[<M-P>]], [[i <esc>P]], "Insert a space and then paste before cursor")

nnoremap ([[<C-M-j>]], [["dY"dp]], "Duplicate line downwards")
nnoremap ([[<C-M-k>]], [["dY"dP]], "Duplicate line upwards")

vnoremap ([[<C-M-j>]], [["dy`<"dPjgv]], "Duplicate selection downwards")
vnoremap ([[<C-M-k>]], [["dy`>"dpgv]], "Duplicate selection upwards")

vnoremap ([[<leader>z]], [[1z=]], "Fix spelling under cursor")

-- Clear UI state:
-- - Clear search highlight
-- - Clear command-line
-- - Close floating windows
nnoremap ([[<Esc>]], function()
  vim.cmd("nohlsearch")
  fn.closeFloatWins()
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
inoremap ([[<C-k>]], [[<C-o>D]], "Kill to end of line")

inoremap ([[<M-k>]], [[<C-k>]], "Insert digraph")

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
cnoremap ([[<c-p>]], [[pumvisible() ? "\<C-p>" : "\<up>"]], expr) -- History prev
cnoremap ([[<c-n>]], [[pumvisible() ? "\<C-n>" : "\<down>"]], expr) -- History next

--"" Tabs
-- print(2, vim.fn.reltimefloat(vim.fn.reltime()))

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

noremap  ([[<M-'>]],   [[:tabn<Cr>]],                silent, "Tabs: Goto next")
noremap  ([[<M-;>]],   [[:tabp<Cr>]],                silent, "Tabs: Goto prev")
tnoremap ([[<M-'>]],   [[:tabn<Cr>]],                silent) -- Tabs: goto next
tnoremap ([[<M-;>]],   [[:tabp<Cr>]],                silent) -- Tabs: goto prev
noremap  ([[<M-S-a>]], [[execute "wincmd g\<Tab>"]], silent, "Tabs: Goto last accessed")
noremap  ([[<M-a>]], [[:wincmd p<Cr>]], silent, "Panes: Goto previously focused")

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

noremap ([[<M-[>]], ithunk(fn.resizeWin, '<', 3), 'Shrink window width')
noremap ([[<M-]>]], ithunk(fn.resizeWin, '>', 3), 'Grow window width')

noremap ([[<M-{>]], ithunk(fn.resizeWin, '-', 3), 'Shrink window height')
noremap ([[<M-}>]], ithunk(fn.resizeWin, '+', 3), 'Grow window height')

nnoremap ([[<leader>sa]], fn.autoresizeEnable,  "Enable autoresize")
nnoremap ([[<leader>sA]], fn.autoresizeDisable, "Disable autoresize")

nnoremap ([[<leader>sf]], ithunk(fn.toggleWinfix, 'height'), "Toggle fixed window height")
nnoremap ([[<leader>sF]], ithunk(fn.toggleWinfix, 'width'), "Toggle fixed window width")

nnoremap ([[<leader>s<M-f>]], ithunk(fn.setWinfix, true, 'height', 'width'), "Enable fixed window height/width")
nnoremap ([[<leader>s<C-f>]], ithunk(fn.setWinfix, false, 'height', 'width'), "Disable fixed window height/width")

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

tnoremap (xk["<C-S-q>"], [[<C-\><C-n>:q<Cr>]]) -- Close terminal
tnoremap (xk["<C-S-n>"], [[<C-\><C-n>]]) -- Enter Normal mode

tnoremap ([[<C-n>]], [[<C-n>]])
tnoremap ([[<C-p>]], [[<C-p>]])
tnoremap ([[<M-n>]], [[<M-n>]])
tnoremap ([[<M-p>]], [[<M-p>]])

nnoremap ([[<Leader>ml]], [[:call AppendModeline()<Cr>]], silent, "Append modeline with current settings")

------ Filetypes
m.group(silent, { ft = "lua" }, function()
  nmap     ([[<leader><Enter>]], require'user.fn'.luarun, "Lua: Eval line")
  xmap     ([[<leader><Enter>]], require'user.fn'.luarun, "Lua: Eval selection")
  nmap     ([[<leader><F12>]],   "<Cmd>Put lua require'user.fn'.luarun()<Cr>", "Lua: Eval line (Append)")
  xmap     ([[<leader><F12>]],   "<Cmd>Put lua require'user.fn'.luarun()<Cr>", "Lua: Eval selection (Append)")
end)

m.group({ "silent", ft = "man" }, function()
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
m.nname("<leader>l", "LSP")
nnoremap ([[<leader>li]], [[:LspInfo<Cr>]],    "LSP: Show LSP information")
nnoremap ([[<leader>lr]], [[:LspRestart<Cr>]], "LSP: Restart LSP")
nnoremap ([[<leader>ls]], [[:LspStart<Cr>]],   "LSP: Start LSP")
nnoremap ([[<leader>lS]], [[:LspStop<Cr>]],    "LSP: Stop LSP")

local lsp_attached_bufs = {}
M.on_lsp_attach = function(bufnr)
  if lsp_attached_bufs[bufnr] then
    return
  end
  lsp_attached_bufs[bufnr] = true
  -- print(1, vim.fn.reltimefloat(vim.fn.reltime()))
  local user_lsp = require'user.lsp'
  -- print(2, vim.fn.reltimefloat(vim.fn.reltime()))

  m.group({ buffer = bufnr, silent = true }, function()
  -- print(3, vim.fn.reltimefloat(vim.fn.reltime()))
    m.nname("<localleader>g", "LSP-Goto")
    nnoremap ({[[<localleader>gd]], [[gd]]}, vim.lsp.buf.definition,      "LSP: Goto definition")
    nnoremap ({[[<localleader>gd]], [[gd]]}, vim.lsp.buf.definition,      "LSP: Goto definition")
    nnoremap ([[<localleader>gD]],           vim.lsp.buf.declaration,     "LSP: Goto declaration")
    nnoremap ([[<localleader>gi]],           vim.lsp.buf.implementation,  "LSP: Goto implementation")
    nnoremap ([[<localleader>gt]],           vim.lsp.buf.type_definition, "LSP: Goto type definition")
    nnoremap ([[<localleader>gr]],           vim.lsp.buf.references,      "LSP: Goto references")

  -- print(4, vim.fn.reltimefloat(vim.fn.reltime()))
    m.nname("<localleader>w", "LSP-Workspace")
    nnoremap ([[<localleader>wa]], vim.lsp.buf.add_workspace_folder,    "LSP: Add workspace folder")
    nnoremap ([[<localleader>wr]], vim.lsp.buf.remove_workspace_folder, "LSP: Rm workspace folder")

    nnoremap ([[<localleader>wl]], function() fn.inspect(vim.lsp.buf.list_workspace_folders()) end, "LSP: List workspace folders")

    nnoremap ([[<localleader>R]],  vim.lsp.buf.rename, "LSP: Rename")

    nnoremap ({[[<localleader>A]], [[<localleader>ca]]}, vim.lsp.buf.code_action,       "LSP: Code action")
    vnoremap ({[[<localleader>A]], [[<localleader>ca]]}, vim.lsp.buf.range_code_action, "LSP: Code action (range)")

    nnoremap ([[<localleader>F]], ithunk(vim.lsp.buf.formatting),       "LSP: Format")
    vnoremap ([[<localleader>F]], ithunk(vim.lsp.buf.range_formatting), "LSP: Format (range)")

  -- print(5, vim.fn.reltimefloat(vim.fn.reltime()))
    m.nname("<localleader>s", "LSP-Save")
    nnoremap ([[<localleader>S]],  user_lsp.setFmtOnSave,               "LSP: Toggle format on save")
    nnoremap ([[<localleader>ss]], user_lsp.setFmtOnSave,               "LSP: Toggle format on save")
    nnoremap ([[<localleader>se]], thunk(user_lsp.setFmtOnSave, true),  "LSP: Enable format on save")
    nnoremap ([[<localleader>sd]], thunk(user_lsp.setFmtOnSave, false), "LSP: Disable format on save")

  -- print(6, vim.fn.reltimefloat(vim.fn.reltime()))
    local function gotoDiag(dir, sev)
      return thunk(
        vim.diagnostic["goto_" .. (dir == -1 and "prev" or "next")],
        { enable_popup = true, severity = sev }
      )
    end
    m.nname("<localleader>d", "LSP-Diagnostics")
    nnoremap ([[<localleader>di]],                        vim.diagnostic.show,     "LSP: Show diagnostics")
    nnoremap ({[[<localleader>dI]], [[<localleader>T]]},  require'trouble'.toggle, "LSP: Toggle Trouble")

  -- print(7, vim.fn.reltimefloat(vim.fn.reltime()))
    nnoremap ({[[<localleader>dd]], [[[d]]}, gotoDiag(-1),            "LSP: Goto prev diagnostic")
    nnoremap ({[[<localleader>dD]], [[]d]]}, gotoDiag(1),             "LSP: Goto next diagnostic")
    nnoremap ({[[<localleader>dw]], [[[w]]}, gotoDiag(-1, "Warning"), "LSP: Goto prev diagnostic (warning)")
    nnoremap ({[[<localleader>dW]], [[]w]]}, gotoDiag(1,  "Warning"), "LSP: Goto next diagnostic (warning)")
    nnoremap ({[[<localleader>de]], [[[e]]}, gotoDiag(-1, "Error"),   "LSP: Goto prev diagnostic (error)")
    nnoremap ({[[<localleader>dE]], [[]e]]}, gotoDiag(1,  "Error"),   "LSP: Goto next diagnostic (error)")

  -- print(8, vim.fn.reltimefloat(vim.fn.reltime()))
    m.nname("<localleader>s", "LSP-Search")
    nnoremap ({[[<localleader>so]], [[<leader>so]]}, require('telescope.builtin').lsp_document_symbols, "LSP: Telescope symbol search")

    m.nname("<localleader>h", "LSP-Hover")
    nnoremap ([[<localleader>hs]], vim.lsp.buf.signature_help, "LSP: Signature help")
    nnoremap ([[<localleader>ho]], vim.lsp.buf.hover,          "LSP: Hover")
    nnoremap ([[<M-i>]],           vim.lsp.buf.hover,          "LSP: Hover")
    inoremap ([[<M-i>]],           vim.lsp.buf.hover,          "LSP: Hover")
    nnoremap ([[<M-S-i>]],         user_lsp.peekDefinition,    "LSP: Peek definition")
  -- print(9, vim.fn.reltimefloat(vim.fn.reltime()))
  end)
  -- print(10, vim.fn.reltimefloat(vim.fn.reltime()))
end

------ Plugins
---- wbthomason/packer.nvim
m.nname("<leader>p", "Packer")
nmap     ([[<leader>pC]], [[:PackerClean<Cr>]], "Packer clean")
nmap     ([[<leader>pc]], [[:PackerCompile<Cr>]], "Packer compile")
nmap     ([[<leader>pi]], [[:PackerInstall<Cr>]], "Packer install")
nmap     ([[<leader>pu]], [[:PackerUpdate<Cr>]], "Packer update")
nmap     ([[<leader>ps]], [[:PackerSync<Cr>]], "Packer sync")
nmap     ([[<leader>pl]], [[:PackerLoad<Cr>]], "Packer load")

---- numToStr/Comment.nvim
map      ([[<M-/>]], [[gcc<Esc>]], silent) -- Toggle line comment
inoremap ([[<M-/>]], [[v:count == 0 ? '<Esc><Cmd>set operatorfunc=v:lua.___comment_gcc<Cr>g@$a' : '<Esc><Cmd>lua ___comment_count_gcc()<Cr>a']], silent, expr, "Toggle line comment")

---- christoomey/vim-tmux-navigator
nmap     ([[<M-h>]], [[:TmuxNavigateLeft<cr>]],  silent, "Goto window/tmux pane left")
nmap     ([[<M-j>]], [[:TmuxNavigateDown<cr>]],  silent, "Goto window/tmux pane down")
nmap     ([[<M-k>]], [[:TmuxNavigateUp<cr>]],    silent, "Goto window/tmux pane up")
nmap     ([[<M-l>]], [[:TmuxNavigateRight<cr>]], silent, "Goto window/tmux pane right")

---- nvim-telescope/telescope.nvim TODO: In-telescope maps
m.group("silent", function()
  m.nname("<C-f>", "Telescope")
  nnoremap ({[[<C-f>b]], [[<C-f><C-b>]]}, require('telescope.builtin').buffers,                                 "Telescope: Buffers")
  nnoremap ({[[<C-f>h]], [[<C-f><C-h>]]}, require('telescope.builtin').help_tags,                               "Telescope: Help tags")
  nnoremap ({[[<C-f>t]], [[<C-f><C-t>]]}, require('telescope.builtin').tags,                                    "Telescope: Tags")
  nnoremap ({[[<C-f>a]], [[<C-f><C-a>]]}, require('telescope.builtin').grep_string,                             "Telescope: Grep for string")
  nnoremap ({[[<C-f>p]], [[<C-f><C-p>]]}, require('telescope.builtin').live_grep,                               "Telescope: Live grep")
  nnoremap ({[[<C-f>o]], [[<C-f><C-o>]]}, require('telescope.builtin').oldfiles,                                "Telescope: Old files")
  nnoremap ({[[<C-f>f]], [[<C-f><C-f>]]}, ithunk(require('telescope.builtin').find_files, {previewer = false}), "Telescope: Files")
  nnoremap ({[[<C-f>s]], [[<C-f><C-s>]]}, require('telescope').extensions.sessions.sessions,                    "Telescope: Sessions")

  m.nname("<M-f>", "Telescope-Buffer")
  nnoremap ({[[<M-f>b]], [[<M-f><M-b>]]}, require('telescope.builtin').current_buffer_fuzzy_find,                  "Telescope: Buffer (fuzzy)")
  nnoremap ({[[<M-f>t]], [[<M-f><M-t>]]}, ithunk(require('telescope.builtin').tags ,{only_current_buffer = true}), "Telescope: Tags (buffer)")
end)

---- tpope/vim-fugitive
m.nname("<leader>g",  "Fugitive")
m.nname("<leader>ga", "Fugitive-Add")
nnoremap ([[<leader>gA]],  [[:Git add --all<Cr>]],                "Fugitive: Add all")
nnoremap ([[<leader>gaa]], [[:Git add --all<Cr>]],                "Fugitive: Add all")
nnoremap ([[<leader>gaf]], [[:Git add :%<Cr>]],                   "Fugitive: Add file")

m.nname("<leader>gc", "Fugitive-Commit")
nnoremap ([[<leader>gC]],  [[:Git commit --verbose<Cr>]],         "Fugitive: Commit")
nnoremap ([[<leader>gcc]], [[:Git commit --verbose<Cr>]],         "Fugitive: Commit")
nnoremap ([[<leader>gca]], [[:Git commit --verbose --all<Cr>]],   "Fugitive: Commit (all)")
nnoremap ([[<leader>gcA]], [[:Git commit --verbose --amend<Cr>]], "Fugitive: Commit (amend)")

m.nname("<leader>gl", "Fugitive-Log")
nnoremap ([[<leader>gL]],  [[:Gclog!<Cr>]],                       "Fugitive: Log")
nnoremap ([[<leader>gll]], [[:Gclog!<Cr>]],                       "Fugitive: Log")
nnoremap ([[<leader>glL]], [[:tabnew | Gclog<Cr>]],               "Fugitive: Log (tab)")

m.nname("<leader>gp", "Fugitive-Push-Pull")
nnoremap ([[<leader>gpa]], [[:Git push --all<Cr>]],               "Fugitive: Push all")
nnoremap ([[<leader>gpp]], [[:Git push<Cr>]],                     "Fugitive: Push")
nnoremap ([[<leader>gpl]], [[:Git pull<Cr>]],                     "Fugitive: Pull")

nnoremap ([[<leader>gR]],  [[:Git reset<Cr>]],                    "Fugitive: Reset")

m.nname("<leader>gs", "Fugitive-Status")
nnoremap ([[<leader>gS]],  [[:Git<Cr>]],                          "Fugitive: Status")
nnoremap ([[<leader>gss]], [[:Git<Cr>]],                          "Fugitive: Status")
nnoremap ([[<leader>gst]], [[:Git<Cr>]],                          "Fugitive: Status")

nnoremap ([[<leader>gsp]], [[:Gsplit<Cr>]],                       "Fugitive: Split")

m.nname("<leader>G", "Fugitive")
nnoremap ([[<leader>GG]],  [[:Git<Cr>]],                          "Fugitive: Status")
nnoremap ([[<leader>GS]],  [[:Git<Cr>]],                          "Fugitive: Status")
nnoremap ([[<leader>GA]],  [[:Git add<Cr>]],                      "Fugitive: Add")
nnoremap ([[<leader>GC]],  [[:Git commit<Cr>]],                   "Fugitive: Commit")
nnoremap ([[<leader>GF]],  [[:Git fetch<Cr>]],                    "Fugitive: Fetch")
nnoremap ([[<leader>GL]],  [[:Git log<Cr>]],                      "Fugitive: Log")
nnoremap ([[<leader>GPP]], [[:Git push<Cr>]],                     "Fugitive: Push")
nnoremap ([[<leader>GPL]], [[:Git pull<Cr>]],                     "Fugitive: Pull")

-- mbbill/undotree
nnoremap ([[<leader>ut]], [[:UndotreeToggle<Cr>]], "Undotree: Toggle")

-- godlygeek/tabular
nmap ([[<Leader>a]], ":Tabularize /", "Tabularize")
vmap ([[<Leader>a]], ":Tabularize /", "Tabularize")

---- KabbAmine/vCoolor.vim
nmap([[<leader>co]], [[:VCoolor<CR>]], silent, "Open VCooler color picker")

---- kyazdani42/nvim-tree.lua
nmap([[<C-\>]], [[:NvimTreeToggle<CR>]], silent, "Nvim-Tree: Toggle")
nmap([[<M-\>]], function()
  if vim.fn.bufname() == "NvimTree" then
    vim.cmd([[wincmd p]])
  else
    vim.cmd([[NvimTreeFocus]])
  end
end, silent, "Nvim-Tree: Toggle Focus")

m.group({ ft = "NvimTree" }, function()
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

  m.nname([[<leader>d]], "DAP")
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

-- print(3, vim.fn.reltimefloat(vim.fn.reltime()))
return M
