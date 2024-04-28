local M = {}

vim.o.spell = false
vim.o.spellfile = vim.fn.stdpath 'config' .. '/spellfile.utf-8.add'

vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath 'cache' .. '/undo'

vim.o.backup = true
vim.o.backupdir = vim.fn.stdpath 'data' .. '/backup'

vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.numberwidth = 1

vim.o.hidden = true

vim.o.mouse = 'n'

vim.o.breakindent = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.ignorecase = true -- ignore case when searching
vim.o.smartcase = true -- don't ignore case if user types an uppercase letter
vim.o.hlsearch = true -- keep matches highlighted after searching
vim.o.incsearch = true -- show matches while typing
vim.o.magic = true -- change set of special search characters

vim.o.inccommand = 'nosplit' -- when typing a :s/foo/bar/g command, show live preview

vim.o.timeoutlen = 1000
vim.o.matchtime = 2 -- show matching parens/brackets for 200ms

vim.o.updatetime = 500
-- vim.g.cursorhold_updatetime = 150 -- antoinemadec/FixCursorHold.nvim

vim.o.signcolumn = 'auto:1-2'

vim.o.clipboard = 'unnamedplus' -- Enable yanking between vim sessions and system

vim.o.sessionoptions = 'globals,blank,buffers,curdir,folds,help,tabpages,winsize'

vim.o.splitright = true -- default vertical splits to open on right
vim.o.splitbelow = true -- default horizontal splits to open on bottom

vim.o.eadirection = 'hor'

vim.o.wildchar = 9 -- equivalent to 'set wildchar=<Tab>'

vim.o.modeline = true -- always parse modelines when loading files
vim.o.exrc = true -- enable exrc files - .nvim.lua, .nvimrc, .exrc

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- SEE: https://github.com/luukvbaal/stabilize.nvim
-- SEE: https://github.com/neovim/neovim/pull/19243
vim.o.splitkeep = 'screen'

-- vim.o.foldmethod = 'expr'
-- vim.o.foldlevelstart = 99
-- vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

-- Disable intro message
vim.opt.shortmess:append 'I'

vim.o.title = true
-- vim.o.titlestring = '%{luaeval("require[[user.tabline]].titlestring()")}'
vim.o.titlestring = '%f'

vim.o.showtabline = 1
vim.o.tabline = "%!luaeval('require[[user.tabline]].tabline()')"
vim.o.statuscolumn = "%!luaeval('require[[user.statuscolumn]].render()')"

vim.o.cursorline = true

vim.o.showmode = false
vim.o.showcmd = true
vim.o.showcmdloc = 'statusline'
vim.o.ruler = false
vim.o.cmdheight = 0

vim.o.laststatus = 3
vim.o.statusline = '%{""}'

vim.o.showmatch = true

vim.o.scrolloff = 5
vim.o.smoothscroll = true -- scroll by screen line rather than by text line when wrap is set

vim.opt.list = true
vim.opt.listchars = {
  eol = '⌐',
  tab = 'ᐧᐧᐧ',
  trail = '~',
  extends = '»',
  precedes = '«',
}

vim.o.termguicolors = true

---- Providers
vim.g.loaded_perl_provider = 0

---- Builtin plugins
-- Disable default matchparen plugin
vim.g.loaded_matchparen = 1

---- Filetypes
-- disable default man.vim mappings
vim.g.no_man_maps = 1

-- Automatically equalize window sizes when Neovim is resized
-- fn.silent(require('user.util.auto-resize').enable)

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return M
