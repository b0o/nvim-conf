local fn = require 'user.fn'

vim.o.spell = true
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

vim.o.updatetime = 250
vim.o.timeoutlen = 1000
vim.o.matchtime = 2 -- show matching parens/brackets for 200ms

vim.o.signcolumn = 'auto:4'

vim.o.clipboard = 'unnamedplus' -- Enable yanking between vim sessions and system

vim.o.switchbuf = 'usetab,newtab'

vim.o.sessionoptions = 'globals,blank,buffers,curdir,folds,help,tabpages,winsize'

vim.o.splitright = true -- default vertical splits to open on right
vim.o.splitbelow = true -- default horizontal splits to open on bottom

vim.o.eadirection = 'hor'

vim.o.wildchar = 9 -- equivalent to 'set wildchar=<Tab>'

vim.o.modeline = true -- always parse modelines when loading files

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- vim.o.foldmethod = 'expr'
-- vim.o.foldlevelstart = 99
-- vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

vim.o.title = true
vim.o.titlestring = '%{luaeval("require[[user.tabline]].titlestring()")}'

vim.o.showtabline = 2
vim.o.tabline = "%!luaeval('require[[user.tabline]].tabline()')"

vim.o.cursorline = true

vim.o.showmode = false
vim.o.showcmd = true
vim.o.laststatus = 2

vim.o.showmatch = true

vim.o.scrolloff = 5

vim.cmd [[
  set guicursor=n-v-c:block-Cursor
  set guicursor+=n-v-c:blinkon0
]]

vim.opt.list = true
vim.opt.listchars = {
  eol = '⌐',
  tab = 'ᐧᐧᐧ',
  trail = '~',
  extends = '»',
  precedes = '«',
}

vim.o.termguicolors = true

if not vim.g.colorscheme then
  if vim.env.COLORSCHEME then
    vim.g.colorscheme = vim.env.COLORSCHEME
  elseif vim.g.colors_name ~= nil then
    vim.g.colorscheme = vim.g.colors_name
  else
    vim.g.colorscheme = 'lavi'
  end
end

vim.g.lavi_italic = 1
vim.g.lavi_cursor_line_number_background = 1

if vim.fn.exists 'g:colorscheme' then
  vim.cmd [[
    try
      exec 'colorscheme ' . g:colorscheme
    catch
      echom 'Error: Unable to set colorscheme ' . g:colorscheme . "\n"
    endtry
  ]]
end

vim.notify = function(...)
  if vim.g.nvim_focused == nil or vim.g.nvim_focused == 1 then
    local ok, notify = pcall(require, 'notify')
    if not ok then
      local args = {...}
      vim.defer_fn(function()
        vim.notify(unpack(args))
      end, 100)
      return
    end
    require'user.plugin.notify'
    return notify.notify(...)
  else
    return require('desktop-notify').notify(...)
  end
end

---- Providers
vim.g.loaded_perl_provider = 0
-- vim.g.loaded_python_provider = 0
-- vim.g.loaded_python3_provider = 0
-- vim.g.loaded_node_provider = 0
-- vim.g.loaded_ruby_provider = 0

vim.g.python_host_prog = '/usr/bin/python2'
vim.g.python3_host_prog = vim.env.HOME .. '/.asdf/shims/python3'
vim.g.node_host_prog = vim.env.XDG_DATA_HOME .. '/yarn/global/node_modules/neovim/bin/cli.js'
vim.g.ruby_host_prog = '/usr/bin/ruby'

---- Filetypes
-- disable default man.vim mappings
vim.g.no_man_maps = 1

-- Automatically equalize window sizes when Neovim is resized
fn.autoresize_enable()
