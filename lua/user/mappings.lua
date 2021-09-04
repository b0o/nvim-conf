local m = require'mapx'.setup{ global = true, whichkey = true }
local silent = m.silent
local expr = m.expr

-- require"user/util".pprint(m)

-- map("zx", "z", "silent", "expr")
-- map("zy", "z", expr, "foobar")
--

local counter = 1
map("zz", function() print("Hello " .. counter); counter = counter + 1 end, "silent")

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

-- make j and k treat wrapped lines as independent lines
nnoremap ([[j]], function(count) return count > 0 and "j" or "gj" end, silent, expr)
nnoremap ([[k]], function(count) return count > 0 and "k" or "gk" end, silent, expr)
-- nnoremap ([[j]], [[v:count ? 'j' : 'gj']], silent, expr)
-- nnoremap ([[k]], [[v:count ? 'k' : 'gk']], silent, expr)

-- Quick movement
noremap ([[J]], [[5j]])
noremap ([[K]], [[5k]])

-- since the vim-wordmotion plugin overrides the normal `w` wordwise movement,
-- make `W` behave as vanilla `w`
nnoremap ([[W]], [[w]])

-- move to the end of the previous word
nnoremap ([[<M-b>]], [[ge]])

-- insert a single character
-- https://vim.fandom.com/wiki/Insert_a_single_character
nnoremap ([[<M-i>]], [[:exec "normal i".nr2char(getchar())."\e"<Cr>]], silent)
nnoremap ([[<M-a>]], [[:exec "normal a".nr2char(getchar())."\e"<Cr>]], silent)

-- Indent visual selection without clearing selection
vnoremap ([[>]], [[>gv]])
vnoremap ([[<]], [[<gv]])

-- quit active
nnoremap ([[Q]],     [[:CloseWin<Cr>]], silent)
nnoremap ([[<F29>]], [[:CloseWin<Cr>]], silent)

-- quit all
nnoremap ([[ZQ]], [[:confirm qall<Cr>]])

-- close tab (except last one)
nnoremap ([[<C-w>]], [[:tabclose<Cr>]])

-- save file
noremap ([[<C-s>]], [[:w<Cr>]])

-- quickly enter command mode with substitution commands prefilled
nnoremap ([[<leader>/]], [[:%s/]], "Substitute")
nnoremap ([[<leader>?]], [[:%S/]], "Substitute (rev)")
vnoremap ([[<leader>/]], [[:s/]], "Substitute")
vnoremap ([[<leader>?]], [[:S/]], "Substitute (rev)")

-- Toggle line wrapping
nnoremap ([[<leader>w]], [[:setlocal wrap!<Cr>:setlocal wrap?<Cr>]], silent, "Toggle wrap")

-- Insert a space and then paste before/after cursor
nnoremap ([[<M-o>]], [[maDo<esc>p`a]])
nnoremap ([[<M-O>]], [[maDO<esc>p`a]])

-- Make Y consistent with C and D.
nnoremap ([[Y]], [[y$]])

-- Yank to system clipboard
vnoremap ([[<leader>y]], [["+y]], "Yank to system clipboard")
nnoremap ([[<leader>Y]], [["+yg_]], "Yank 'til EOL to system clipboard")
nnoremap ([[<leader>yy]], [["+yy]], "Yank line to system clipboard")
nnoremap ([[<C-y>]], [[pumvisible() ? "\<C-y>" : '"+yy']], expr)
vnoremap ([[<C-y>]], [[pumvisible() ? "\<C-y>" : '"+y']], expr)

-- yank path of current file to system clipboard
nnoremap ([[<leader>yp]], [[:let @+ = expand("%:p")<Cr>:echom "Copied " . @+<Cr>]], silent, "Yank file path to system clipboard")

-- Paste from system clipboard
vnoremap ([[<C-p>]], [["+p]])
nnoremap ([[<C-p>]], [["+p]])

-- Insert a space and then paste before/after cursor
nnoremap ([[<M-p>]], [[a <esc>p]])
nnoremap ([[<M-P>]], [[i <esc>P]])

-- Duplicate line downwards/upwards
nnoremap ([[<C-M-j>]], [["dY"dp]])
nnoremap ([[<C-M-k>]], [["dY"dP]])

-- Duplicate selection downwards/upwards
vnoremap ([[<C-M-j>]], [["dy`<"dPjgv]])
vnoremap ([[<C-M-k>]], [["dy`>"dpgv]])

-- Clear search highlight and command-line on esc
nnoremap ([[<esc>]], [[:noh \| echo ""<Cr>]], silent)

-- Force redraw
-- See: https://github.com/mhinz/vim-galore#saner-ctrl-l
nnoremap ([[<leader>L]], [[:nohlsearch<Cr>:diffupdate<Cr>:syntax sync fromstart<Cr><c-l>]], "Redraw")

-- Reload vim configuration
nnoremap ([[<leader>rr]], [[:ReloadConfig<Cr>]], silent, "Reload config")

-- goto file under cursor in new tab
noremap ([[gF]], [[<C-w>gf]], "Go to file under cursor (new tab)")

-- open tab in new terminal instance
nnoremap ([[<leader>W]], [[:call user#fn#windowToNewTerminal()<Cr>]], "Move window to new terminal")

-- conceal
nnoremap ([[<leader>cl]], [[:call user#fn#toggleConcealLevel()<Cr>]], silent, "Toggle conceal level")
nnoremap ([[<leader>cc]], [[:call user#fn#toggleConcealCursor()<Cr>]], silent, "Toggle conceal cursor")

-- cursorcolumn
nmap     ([[<leader>|]], [[:set invcursorcolumn<Cr>]], silent, "Toggle cursorcolumn")

-- emacs-style motion & editing in insert mode
inoremap ([[<C-a>]], [[<Home>]])
inoremap ([[<C-e>]], [[<End>]])
inoremap ([[<C-b>]], [[<Left>]])
inoremap ([[<C-f>]], [[<Right>]])
inoremap ([[<C-n>]], [[<Down>]])
inoremap ([[<M-b>]], [[<S-Left>]])
inoremap ([[<M-f>]], [[<S-Right>]])
inoremap ([[<M-d>]], [[<C-o>de]])
inoremap ([[<C-k>]], [[<C-o>D]])
inoremap ([[<C-p>]], [[<Up>]])
inoremap ([[<C-d>]], [[<Delete>]])

-- restore support for digraphs to M-k
inoremap ([[<M-k>]], [[<C-k>]])

-- nano-like kill buffer
-- TODO
vim.cmd([[
  let @k=''
  let @l=''
]])
nnoremap ([[<F30>]], [["ldd:let @k=@k.@l \| let @l=@k<cr>]], silent)
nnoremap ([[<F24>]], [[:if @l != "" \| let @k=@l \| end<cr>"KgP:let @l=@k<cr>:let @k=""<cr>]], silent)

-- overload tab key to also perform next/prev in popup menus
inoremap ([[<Tab>]],   [[pumvisible() ? "\<C-n>" : "\<Tab>"]], silent, expr)
inoremap ([[<S-Tab>]], [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], silent, expr)

-- emacs-style motion & editing in command mode
cnoremap ([[<C-a>]], [[<Home>]])
cnoremap ([[<C-b>]], [[<Left>]])
cnoremap ([[<C-d>]], [[<Delete>]])
cnoremap ([[<C-f>]], [[<Right>]])
cnoremap ([[<C-g>]], [[<C-c>]])
cnoremap ([[<C-k>]], [[<C-\>e(" ".getcmdline())[:getcmdpos()-1][1:]<Cr>]])
cnoremap ([[<M-f>]], [[<C-\>euser#fn#cmdlineMoveWord( 1, 0)<Cr>]])
cnoremap ([[<M-b>]], [[<C-\>euser#fn#cmdlineMoveWord(-1, 0)<Cr>]])
cnoremap ([[<M-d>]], [[<C-\>euser#fn#cmdlineMoveWord( 1, 1)<Cr>]])
cnoremap ([[<M-Backspace>]], [[<C-\>euser#fn#cmdlineMoveWord(-1, 1)<Cr>]])

-- restore support for digraphs to M-k
cnoremap ([[<M-k>]], [[<C-k>]])

-- Make c-n and c-p behave like up/down arrows, i.e. take into account the
-- beginning of the text entered in the command line when jumping, but only if
-- the pop-up menu (completion menu) is not visible
-- See: https://github.com/mhinz/vim-galore#saner-command-line-history
cnoremap ([[<c-p>]], [[pumvisible() ? "\<C-p>" : "\<up>"]], expr)
cnoremap ([[<c-n>]], [[pumvisible() ? "\<C-n>" : "\<down>"]], expr)

--"" Tabs

-- Navigate left/right through tabs
noremap ([[<M-'>]], [[:tabn<Cr>]], silent)
noremap ([[<M-;>]], [[:tabp<Cr>]], silent)
tnoremap ([[<M-'>]], [[<C-\><C-n>:tabn<Cr>]], silent)
tnoremap ([[<M-;>]], [[<C-\><C-n>:tabp<Cr>]], silent)

-- Rearrange tabs
noremap ([[<M-">]], [[:+tabm<Cr>]], silent)
noremap ([[<M-:>]], [[:-tabm<Cr>]], silent)

-- Open/close tabs
noremap ([[<F13>]], [[:tabnew<Cr>]], silent)
noremap ([[<M-Backspace>]], [[:tabclose<Cr>]], silent)

-- Navigation through tabs by index
noremap ([[<M-1>]], [[:call user#fn#tabnm(1)<Cr>]], silent)
noremap ([[<M-2>]], [[:call user#fn#tabnm(2)<Cr>]], silent)
noremap ([[<M-3>]], [[:call user#fn#tabnm(3)<Cr>]], silent)
noremap ([[<M-4>]], [[:call user#fn#tabnm(4)<Cr>]], silent)
noremap ([[<M-5>]], [[:call user#fn#tabnm(5)<Cr>]], silent)
noremap ([[<M-6>]], [[:call user#fn#tabnm(6)<Cr>]], silent)
noremap ([[<M-7>]], [[:call user#fn#tabnm(7)<Cr>]], silent)
noremap ([[<M-8>]], [[:call user#fn#tabnm(8)<Cr>]], silent)
noremap ([[<M-9>]], [[:call user#fn#tabnm(9)<Cr>]], silent)
noremap ([[<M-0>]], [[:call user#fn#tabnm(10)<Cr>]], silent)

-- Swap splits (lol)
noremap ([[<M-S-h>]], [[:call user#fn#windowSwapInDirection('h')<Cr>]], silent)
noremap ([[<M-S-j>]], [[:call user#fn#windowSwapInDirection('j')<Cr>]], silent)
noremap ([[<M-S-k>]], [[:call user#fn#windowSwapInDirection('k')<Cr>]], silent)
noremap ([[<M-S-l>]], [[:call user#fn#windowSwapInDirection('l')<Cr>]], silent)

-- Alt+[hjkl] to navigate through splits in terminal mode
tnoremap ([[<M-h>]], [[<C-\><C-n><C-w>h]])
tnoremap ([[<M-j>]], [[<C-\><C-n><C-w>j]])
tnoremap ([[<M-k>]], [[<C-\><C-n><C-w>k]])
tnoremap ([[<M-l>]], [[<C-\><C-n><C-w>l]])

-- resize splits left/right
noremap ([[<M-[>]], [[<C-w>3<]])
noremap ([[<M-]>]], [[<C-w>3>]])

-- resize splits up/down
noremap ([[<M-{>]], [[<C-w>3-]])
noremap ([[<M-}>]], [[<C-w>3+]])

-- make splits equally wide and high
nnoremap ([[<leader>sa]], [[<c-w>=]], "Equalize window sizes")

-- create splits
-- see also the VSplit plugin mappings below
nnoremap ([[<leader>S]],  [[:new<Cr>]],    silent, "Split (horiz, new)")
nnoremap ([[<leader>sn]], [[:new<Cr>]],    silent, "Split (horiz, new)")
nnoremap ([[<leader>V]],  [[:vnew<Cr>]],   silent, "Split (vert, new)")
nnoremap ([[<leader>vn]], [[:vnew<Cr>]],   silent, "Split (vert, new)")
nnoremap ([[<leader>ss]], [[:split<Cr>]],  silent, "Split (horiz, cur)")
nnoremap ([[<leader>st]], [[:split<Cr>]],  silent, "Split (horiz, cur)")
nnoremap ([[<leader>vv]], [[:vsplit<Cr>]], silent, "Split (vert, cur)")
nnoremap ([[<leader>vt]], [[:vsplit<Cr>]], silent, "Split (vert, cur)")

-- Interleave two same-sized contiguous blocks
vnoremap ([[<leader>I]], [[<esc>:call user#fn#interleave()<Cr>]], silent, "Interleave two contiguous blocks")

-- PasteRestore
-- paste register without overwriting with the original selection
-- use P for original behavior
vnoremap ([[p]], [[user#fn#pasteRestore()]], silent, expr)

-- Open Terminal
nnoremap ([[<leader>T]], [[:Term!<Cr>]], silent, "New term (tab)")
nnoremap ([[<leader>t]], [[:10Term<Cr>]], silent, "New term (split)")

-- close terminal window
-- map <C-S-q> to \x1b[15;5~ (F29) in your terminal emulator
tnoremap ([[<F29>]], [[<C-\><C-n>:q<Cr>]])

-- switch to normal mode
-- map <C-S-n> to \x1b[14;5~ (F28) in your terminal emulator
tnoremap ([[<F24>]], [[<C-\><C-n>]])

tnoremap ([[<C-n>]], [[<C-n>]])
tnoremap ([[<C-p>]], [[<C-p>]])
tnoremap ([[<M-n>]], [[<M-n>]])
tnoremap ([[<M-p>]], [[<M-p>]])

-- Modeline
nnoremap ([[<Leader>ml]], [[:call AppendModeline()<Cr>]], silent, "Append modeline with current settings")

------ Plugins
-- wbthomason/packer.nvim
nmap     ([[<leader>pC]], [[:PackerClean<Cr>]])
nmap     ([[<leader>pc]], [[:PackerCompile<Cr>]])
nmap     ([[<leader>pi]], [[:PackerInstall<Cr>]])
nmap     ([[<leader>pu]], [[:PackerUpdate<Cr>]])
nmap     ([[<leader>ps]], [[:PackerSync<Cr>]])
nmap     ([[<leader>pl]], [[:PackerLoad<Cr>]])

---- tpope/vim-commentary
map      ([[<M-/>]], [[:Commentary<Cr>]], silent)

---- christoomey/vim-tmux-navigator
nmap     ([[<M-h>]], [[:TmuxNavigateLeft<cr>]],  silent)
nmap     ([[<M-j>]], [[:TmuxNavigateDown<cr>]],  silent)
nmap     ([[<M-k>]], [[:TmuxNavigateUp<cr>]],    silent)
nmap     ([[<M-l>]], [[:TmuxNavigateRight<cr>]], silent)

---- L3MON4D3/LuaSnip TODO
local luasnip = require 'luasnip'

_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t '<C-n>'
  elseif luasnip.expand_or_jumpable() then
    return t '<Plug>luasnip-expand-or-jump'
  elseif check_back_space() then
    return t '<Tab>'
  else
    return vim.fn['compe#complete']()
  end
end

_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t '<C-p>'
  elseif luasnip.jumpable(-1) then
    return t '<Plug>luasnip-jump-prev'
  else
    return t '<S-Tab>'
  end
end

-- Map tab to the above tab complete functiones
imap    ([[<Tab>]],   [[v:lua.tab_complete()]],   expr)
smap    ([[<Tab>]],   [[v:lua.tab_complete()]],   expr)
imap    ([[<S-Tab>]], [[v:lua.s_tab_complete()]], expr)
smap    ([[<S-Tab>]], [[v:lua.s_tab_complete()]], expr)

---- hrsh7th/nvim-compe TODO
imap    ([[<cr>]],      [[compe#confirm("<cr>")]], expr)
imap    ([[<c-space>]], [[compe#complete()]],      expr)

-- nvim-telescope/telescope.nvim
nnoremap ({[[<C-f>b]], [[<C-f><C-b>]]}, [[:lua require('telescope.builtin').buffers()<Cr>]],                         silent, "Telescope: Buffers")
nnoremap ({[[<C-f>f]], [[<C-f><C-f>]]}, [[:lua require('telescope.builtin').find_files({previewer = false})<Cr>]],   silent, "Telescope: Files")
nnoremap ({[[<M-f>b]], [[<M-f><M-b>]]}, [[:lua require('telescope.builtin').current_buffer_fuzzy_find()<Cr>]],       silent, "Telescope: Buffer (fuzzy)")
nnoremap ({[[<C-f>h]], [[<C-f><C-h>]]}, [[:lua require('telescope.builtin').help_tags()<CR>]],                       silent, "Telescope: Help tags")
nnoremap ({[[<C-f>t]], [[<C-f><C-t>]]}, [[:lua require('telescope.builtin').tags()<CR>]],                            silent, "Telescope: Tags")
nnoremap ({[[<C-f>d]], [[<C-f><C-d>]]}, [[:lua require('telescope.builtin').grep_string()<CR>]],                     silent, "Telescope: Grep for string")
nnoremap ({[[<C-f>p]], [[<C-f><C-p>]]}, [[:lua require('telescope.builtin').live_grep()<CR>]],                       silent, "Telescope: Live grep")
nnoremap ({[[<M-f>t]], [[<M-f><M-t>]]}, [[:lua require('telescope.builtin').tags({only_current_buffer = true}<Cr>]], silent, "Telescope: Tags (buffer)")
nnoremap ({[[<C-f>o]], [[<C-f><C-o>]]}, [[:lua require('telescope.builtin').oldfiles()<CR>]],                        silent, "Telescope: Old files")

-- neovim/nvim-lspconfig
_G.nvim_lsp_mapfn = function(bufnr)
  local opts = { buffer = bufnr, silent = true }
  nnoremap ([[gD]],         [[<cmd>lua vim.lsp.buf.declaration()<Cr>]],                                opts, "LSP: Goto declaration")
  nnoremap ([[gd]],         [[<cmd>lua vim.lsp.buf.definition()<Cr>]],                                 opts, "LSP: Goto definition")
  nnoremap ([[gi]],         [[<cmd>lua vim.lsp.buf.implementation()<Cr>]],                             opts, "LSP: Goto implementation")
  nnoremap ([[<leader>D]],  [[<cmd>lua vim.lsp.buf.type_definition()<Cr>]],                            opts, "LSP: Goto type definition")
  nnoremap ([[<leader>wa]], [[<cmd>lua vim.lsp.buf.add_workspace_folder()<Cr>]],                       opts, "LSP: Add workspace folder")
  nnoremap ([[<leader>wr]], [[<cmd>lua vim.lsp.buf.remove_workspace_folder()<Cr>]],                    opts, "LSP: Rm workspace folder")
  nnoremap ([[<leader>rn]], [[<cmd>lua vim.lsp.buf.rename()<Cr>]],                                     opts, "LSP: Rename")
  nnoremap ([[gr]],         [[<cmd>lua vim.lsp.buf.references()<Cr>]],                                 opts, "LSP: List all references")

  nnoremap ([[<leader>ca]], [[<cmd>lua vim.lsp.buf.code_action()<Cr>]],                                opts, "LSP: Code action")
  vnoremap ([[<leader>ca]], [[<cmd>lua vim.lsp.buf.range_code_action()<CR>]],                          opts, "LSP: Code action (range)")

  nnoremap ([[<leader>e]],  [[<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<Cr>]],               opts, "LSP: Show diagnostics (floatwin)")
  nnoremap ([[<leader>q]],  [[<cmd>lua vim.lsp.diagnostic.set_loclist()<Cr>]],                         opts, "LSP: Show diagnostics (loclist)")
  nnoremap ([[[d]],         [[<cmd>lua vim.lsp.diagnostic.goto_prev()<Cr>]],                           opts, "LSP: Goto prev diagnostic")
  nnoremap ([[]d]],         [[<cmd>lua vim.lsp.diagnostic.goto_next()<Cr>]],                           opts, "LSP: Goto next diagnostic")

  nnoremap ([[<leader>so]], [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<Cr>]],      opts, "LSP: Telescope symbol search")
  nnoremap ([[<leader>wl]], [[<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<Cr>]], opts, "LSP: List workspace folders")

  nnoremap ([[<C-d>]],      [[<cmd>lua vim.lsp.buf.hover()<Cr>]],                                      opts)
  nnoremap ([[<C-k>]],      [[<cmd>lua vim.lsp.buf.signature_help()<Cr>]],                             opts)
end

---- rbong/vim-buffest
-- use + as default register
-- nnoremap ([[c@@]], [[:Regsplit +<Cr>]], silent, "Edit @+ in Buffest")

---- tpope/vim-fugitive
nnoremap ([[<leader>gA]],  [[:Git add --all<Cr>]],                "Fugitive: Add all")
nnoremap ([[<leader>gaa]], [[:Git add --all<Cr>]],                "Fugitive: Add all")
nnoremap ([[<leader>gaf]], [[:Git add :%<Cr>]],                   "Fugitive: Add file")

nnoremap ([[<leader>gC]],  [[:Git commit --verbose<Cr>]],         "Fugitive: Commit")
nnoremap ([[<leader>gcc]], [[:Git commit --verbose<Cr>]],         "Fugitive: Commit")
nnoremap ([[<leader>gca]], [[:Git commit --verbose --all<Cr>]],   "Fugitive: Commit (all)")
nnoremap ([[<leader>gcA]], [[:Git commit --verbose --amend<Cr>]], "Fugitive: Commit (amend)")

nnoremap ([[<leader>gL]],  [[:Gclog!<Cr>]],                       "Fugitive: Log")
nnoremap ([[<leader>gll]], [[:Gclog!<Cr>]],                       "Fugitive: Log")
nnoremap ([[<leader>glL]], [[:tabnew \| Gclog<Cr>]],              "Fugitive: Log (tab)")

nnoremap ([[<leader>gpa]], [[:Git push --all<Cr>]],               "Fugitive: Push all")
nnoremap ([[<leader>gpp]], [[:Git push<Cr>]],                     "Fugitive: Push")
nnoremap ([[<leader>gpl]], [[:Git pull<Cr>]],                     "Fugitive: Pull")

nnoremap ([[<leader>gR]],  [[:Git reset<Cr>]],                    "Fugitive: Reset")

nnoremap ([[<leader>gS]],  [[:Gstatus<Cr>]],                      "Fugitive: Status")
nnoremap ([[<leader>gss]], [[:Gstatus<Cr>]],                      "Fugitive: Status")
nnoremap ([[<leader>gst]], [[:Gstatus<Cr>]],                      "Fugitive: Status")

nnoremap ([[<leader>gsp]], [[:Gsplit<Cr>]],                       "Fugitive: Split")

nnoremap ([[<leader>GG]],  [[:Git<space>]],                       "Fugitive: Git")
nnoremap ([[<leader>GA]],  [[:Git add<space>]],                   "Fugitive: Add")
nnoremap ([[<leader>GC]],  [[:Git commit<space>]],                "Fugitive: Commit")
nnoremap ([[<leader>GF]],  [[:Git fetch<space>]],                 "Fugitive: Fetch")
nnoremap ([[<leader>GL]],  [[:Git log<space>]],                   "Fugitive: Log")
nnoremap ([[<leader>GPP]], [[:Git push<space>]],                  "Fugitive: Push")
nnoremap ([[<leader>GPL]], [[:Git pull<space>]],                  "Fugitive: Pull")
nnoremap ([[<leader>GS]],  [[:Git status<space>]],                "Fugitive: Status")

-- mbbill/undotree
nnoremap ([[<leader>ut]], [[:UndotreeToggle<Cr>]], "Undotree: Toggle")

-- godlygeek/tabular
nnoremap ([[<Leader>a=]], [[:Tabularize /=<Cr>]],    "Tabular: Align on '='")
vnoremap ([[<Leader>a=]], [[:Tabularize /=<Cr>]],    "Tabular: Align on '=")
nnoremap ([[<Leader>a:]], [[:Tabularize /:\zs<Cr>]], "Tabular: Align on ':'")
vnoremap ([[<Leader>a:]], [[:Tabularize /:\zs<Cr>]], "Tabular: Align on ':'")

-- b0o/vim-man
_G.vim_man_mapfn = function(bufnr)
  local opts = { buffer = bufnr, silent = true }
  -- open manpage tag (e.g. isatty(3)) in current buffer
  nnoremap ([[<C-]>]],   [[:call man#get_page_from_cword('horizontal', v:count)<CR>]], opts)

  -- open manpage tag in new tab
  nnoremap ([[<M-]>]],   [[<c-w>s<c-w>T:call man#get_page_from_cword('tab', v:count)<CR>]], opts)
  nnoremap ([[<C-M-]>]], [[<c-w>s<c-w>T:call man#get_page_from_cword('tab', v:count)<CR>]], opts)

  -- go back to previous manpage
  nnoremap ([[<C-t>]],   [[:call man#pop_page()<CR>]], opts)
  nnoremap ([[<C-o>]],   [[:call man#pop_page()<CR>]], opts)
  nnoremap ([[<M-o>]],   [[<C-o>]], opts)

  -- navigate to next/prev section
  nnoremap ("[[",        [[:<C-u>call man#section#move('b', 'n', v:count1)<CR>]], opts)
  nnoremap ("]]",        [[:<C-u>call man#section#move('' , 'n', v:count1)<CR>]], opts)
  xnoremap ("[[",        [[:<C-u>call man#section#move('b', 'v', v:count1)<CR>]], opts)
  xnoremap ("]]",        [[:<C-u>call man#section#move('' , 'v', v:count1)<CR>]], opts)

  -- navigate to next/prev manpage tag
  nnoremap ([[<tab>]],   [[:call search('\(\w\+(\w\+)\)', 's')<CR>]], opts)
  nnoremap ([[<S-tab>]], [[:call search('\(\w\+(\w\+)\)', 'sb')<CR>]], opts)

  -- search from beginning of line (useful for finding command args like -h)
  nnoremap ([[g/]], [[/^\s*\zs]], opts)
end

---- KabbAmine/vCoolor.vim
nmap([[<leader>co]], [[:VCoolor<CR>]], silent)

---- TODO

-- "" ale.vim
-- nnoremap <leader>af :ALEFix<Cr>
-- nnoremap <leader>al :ALELint<Cr>

-- nmap ]a <Plug>(ale_next_wrap)
-- nmap [a <Plug>(ale_previous_wrap)
-- nmap ]e <Plug>(ale_next_wrap_error)
-- nmap [e <Plug>(ale_previous_wrap_error)
-- nmap ]w <Plug>(ale_next_wrap_warning)
-- nmap [w <Plug>(ale_previous_wrap_warning)

-- nnoremap <leader>ad :ALEDisable<Cr>:let g:ale_enabled<Cr>
-- nnoremap <leader>ae :ALEEnable<Cr>:let g:ale_enabled<Cr>
-- nnoremap <leader>aD :ALEToggle<Cr>:let g:ale_enabled<Cr>
-- nnoremap <leader>aE :ALEToggle<Cr>:let g:ale_enabled<Cr>
-- nnoremap <leader>as :let g:ale_fix_on_save=!g:ale_fix_on_save<Cr>:let g:ale_fix_on_save<Cr>
-- nnoremap <leader>aS :let g:ale_fix_on_save=0<Cr>:let g:ale_fix_on_save<Cr>

-- "" LCD
-- " nnoremap <silent> <leader>k :call LCDToggle()<Cr>
-- "
-- " nnoremap <leader>lk :call LanguageClient#textDocument_hover()<Cr>
-- " nnoremap <leader>lg :call LanguageClient#textDocument_definition()<Cr>
-- " nnoremap <leader>lG :call LanguageClient#textDocument_definition({"gotoCmd": "tabedit"})<Cr>
-- " nnoremap <leader>lr :call LanguageClient#textDocument_rename()<Cr>
-- " nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<Cr>
-- " nnoremap <leader>lb :call LanguageClient#textDocument_references()<Cr>
-- " nnoremap <leader>la :call LanguageClient#textDocument_codeAction()<Cr>
-- " nnoremap <leader>ls :call LanguageClient#textDocument_documentSymbol()<Cr>
-- " nnoremap <leader>lm :call LanguageClient_contextMenu()<Cr>

-- " nmap <silent> gd         <leader>lg
-- " nmap <silent> gD         <leader>lG
-- " nmap <silent> gr         <leader>lb
-- " nmap <silent> <leader>gr <leader>lr
-- "
-- " nmap <silent> <M-S-k>    <leader>lk

-- "" vim-clap
-- " map <C-,> to \x1b[21;5~ (F34) in your terminal emulator
-- nnoremap <silent> <F34>C     :Clap<Cr>
-- nnoremap <silent> <F34><F34> :Clap<Cr>

-- nnoremap <silent> <F34>X     :call clap#floating_win#close()<Cr>
-- nnoremap <silent> <F34>xx    :call clap#floating_win#close()<Cr>

-- nnoremap <silent> <F34>B     :Clap buffers<Cr>
-- nnoremap <silent> <F34>bb    :Clap buffers<Cr>
-- nnoremap <silent> <F34>bgc   :Clap bcommits<Cr>
-- nnoremap <silent> <F34>bu    :Clap buffers<Cr>
-- nnoremap <silent> <F34>bl    :Clap blines<Cr>

-- nnoremap <silent> <F34>cc    :Clap command<Cr>
-- nnoremap <silent> <F34>cmd   :Clap command<Cr>
-- nnoremap <silent> <F34>col   :Clap colors<Cr>
-- nnoremap <silent> <F34>ch    :Clap command_history<Cr>
-- nnoremap <silent> <F34>h     :Clap command_history<Cr>

-- nnoremap <silent> <F34>F     :Clap files<Cr>
-- nnoremap <silent> <F34>ff    :Clap files<Cr>
-- nnoremap <silent> <F34>fi    :Clap files<Cr>
-- nnoremap <silent> <F34><c-f> :Clap files<Cr>
-- nnoremap <silent> <F34>ft    :Clap filetypes<Cr>

-- nnoremap <silent> <F34>G     :Clap grep<Cr>
-- nnoremap <silent> <F34>gg    :Clap grep<Cr>
-- nnoremap <silent> <F34>gr    :Clap grep<Cr>
-- nnoremap <silent> <F34>gc    :Clap commits<Cr>
-- nnoremap <silent> <F34>gf    :Clap git_files<Cr>
-- nnoremap <silent> <F34>gd    :Clap git_diff_files<Cr>

-- nnoremap <silent> <F34>H     :Clap help_tags<Cr>
-- nnoremap <silent> <F34>hh    :Clap help_tags<Cr>
-- nnoremap <silent> <F34>hi    :Clap history<Cr>
-- nnoremap <silent> <F34>hs    :Clap search_history<Cr>
-- nnoremap <silent> <F34>h/    :Clap search_history<Cr>
-- nnoremap <silent> <F34>/     :Clap search_history<Cr>

-- nnoremap <silent> <F34>J     :Clap jumps<Cr>
-- nnoremap <silent> <F34>jj    :Clap jumps<Cr>
-- nnoremap <silent> <F34>ju    :Clap jumps<Cr>

-- nnoremap <silent> <F34>L     :Clap lines<Cr>
-- nnoremap <silent> <F34>li    :Clap lines<Cr>
-- nnoremap <silent> <F34>lo    :Clap loclist<Cr>
-- nnoremap <silent> <F34>ll    :Clap loclist<Cr>

-- nnoremap <silent> <F34>Q     :Clap quickfix<Cr>
-- nnoremap <silent> <F34>qq    :Clap quickfix<Cr>
-- nnoremap <silent> <F34>qi    :Clap quickfix<Cr>
-- nnoremap <silent> <F34>qf    :Clap quickfix<Cr>

-- nnoremap <silent> <F34>M     :Clap maps<Cr>
-- nnoremap <silent> <F34>mm    :Clap maps<Cr>
-- nnoremap <silent> <F34>mr    :Clap marks<Cr>
-- nnoremap <silent> <F34>mk    :Clap marks<Cr>

-- nnoremap <silent> <F34>P     :Clap providers<Cr>
-- nnoremap <silent> <F34>pp    :Clap providers<Cr>
-- nnoremap <silent> <F34>pr    :Clap providers<Cr>

-- nnoremap <silent> <F34>R     :Clap registers<Cr>
-- nnoremap <silent> <F34>rr    :Clap registers<Cr>
-- nnoremap <silent> <F34>re    :Clap registers<Cr>

-- nnoremap <silent> <F34>T     :Clap tags<Cr>
-- nnoremap <silent> <F34>tt    :Clap tags<Cr>
-- nnoremap <silent> <F34>ta    :Clap tags<Cr>

-- nnoremap <silent> <F34>W     :Clap windows<Cr>
-- nnoremap <silent> <F34>ww    :Clap windows<Cr>
-- nnoremap <silent> <F34>wi    :Clap windows<Cr>

-- "" fzf
-- nnoremap <silent> <C-f><C-f> :Files<Cr>
-- nnoremap <silent> <C-f>f     :Files<Cr>
-- nnoremap <silent> <C-f><C-g> :GFiles<Cr>
-- nnoremap <silent> <C-f>gg    :GFiles<Cr>
-- nnoremap <silent> <C-f>gf    :GFiles<Cr>
-- nnoremap <silent> <C-f><C-b> :Buffers<Cr>
-- nnoremap <silent> <C-f>b     :Buffers<Cr>
-- nnoremap <silent> <C-f><C-a> :Ag<Cr>
-- nnoremap <silent> <C-f>a     :Ag<Cr>
-- nnoremap <silent> <C-f>gc    :Commits<Cr>
-- nnoremap <silent> <C-f><C-c> :Commands<Cr>
-- nnoremap <silent> <C-f>c     :Commands<Cr>
-- nnoremap <silent> <C-f><C-m> :Maps<Cr>
-- nnoremap <silent> <C-f>m     :Maps<Cr>

-- "" emmet.vim
-- let g:user_emmet_leader_key='<C-z>'

-- nmap <C-z><C-z> <C-z>,
-- imap <C-z><C-z> <C-z>,
-- vmap <C-z><C-z> <C-z>,

-- "" LuaTree (nvim-tree.lua.vim)
-- nnoremap <leader>N :LuaTreeToggle<Cr>
-- nnoremap <leader>nn :LuaTreeToggle<Cr>

-- "" VSplit
-- xmap <leader>vsr <Plug>(Visual-Split-VSResize)
-- xmap <leader>vss <Plug>(Visual-Split-VSSplit)
-- xmap <leader>vsa <Plug>(Visual-Split-VSSplitAbove)
-- xmap <leader>vsb <Plug>(Visual-Split-VSSplitBelow)
-- nmap <leader>vsr <Plug>(Visual-Split-Resize)
-- nmap <leader>vss <Plug>(Visual-Split-Split)
-- nmap <leader>vsa <Plug>(Visual-Split-SplitAbove)
-- nmap <leader>vsb <Plug>(Visual-Split-SplitBelow)

-- "" vim-expand-region
-- nmap - <Plug>(expand_region_shrink)
-- vmap - <Plug>(expand_region_shrink)
-- ]])
