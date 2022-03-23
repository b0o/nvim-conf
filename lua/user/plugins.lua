-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer = require 'packer'
local use = packer.use

local function _use(p, ...)
  if type(p) ~= 'table' then
    p = { p }
  end
  use(#{ ... } > 0 and vim.tbl_extend('force', p, ...) or p)
end

local function uselocal(p, ...)
  local git_projects_dir = os.getenv 'GIT_PROJECTS_DIR'
  if git_projects_dir == nil then
    vim.notify('plugins.uselocal: missing environment variable: GIT_PROJECTS_DIR', vim.log.levels.ERROR)
    return
  end
  if type(p) ~= 'table' then
    p = { p }
  end
  local extend = #{ ... } > 0 and vim.tbl_extend('force', {}, ...) or {}
  if not string.match(p[1], '^.?.?/') then
    local path = vim.split(p[1], '/')
    extend.as = p.as or path[2]
    local realpath = git_projects_dir .. '/' .. table.concat(vim.list_slice(path, 2), '/')
    extend[1] = realpath
  end
  _use(p, extend)
end

---@diagnostic disable-next-line: unused-local,unused-function
local function xuse(p)
  return _use(p, { disable = true })
end

---@diagnostic disable-next-line: unused-local,unused-function
local function xuselocal(p)
  return uselocal(p, { disable = true })
end

packer.init {
  max_jobs = tonumber(vim.fn.system 'nproc') or 8,
}

packer.startup(function()
  -- Package management
  use 'wbthomason/packer.nvim'

  -- Config
  uselocal 'b0o/mapx.nvim/worktree/current'

  -- Meta
  use 'nvim-lua/plenary.nvim'

  -- Colorschemes
  -- use 'chriskempson/base16-vim'
  -- use 'dracula/vim'

  -- UI
  use 'Famiu/feline.nvim'
  use 'ericbn/vim-relativize'
  use 'folke/which-key.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'lukas-reineke/indent-blankline.nvim'
  xuse 'luukvbaal/stabilize.nvim'
  use 'kevinhwang91/nvim-hlslens'
  use 'kyazdani42/nvim-tree.lua'
  use 'rcarriga/nvim-notify'
  use {
    'simrat39/desktop-notify.nvim',
    setup = [[pcall(vim.cmd, 'delcommand Notifications')]],
    config = [[vim.cmd'command! Notifications :lua require("notify")._print_history()<CR>']],
  }
  use 'stevearc/dressing.nvim'
  -- use 'stevearc/aerial.nvim'
  uselocal 'stevearc/aerial.nvim/worktree/current'
  use 'MunifTanjim/nui.nvim'
  use { 'winston0410/range-highlight.nvim', requires = { 'winston0410/cmd-parser.nvim' } }

  -- Telescope
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/popup.nvim' } }
  use 'kyoh86/telescope-windows.nvim'

  -- Editing
  use 'AndrewRadev/splitjoin.vim'
  use 'b0o/vim-shot-f'
  use 'chaoren/vim-wordmotion'
  use 'godlygeek/tabular'
  use 'kana/vim-textobj-fold'
  use 'kana/vim-textobj-indent'
  use 'kana/vim-textobj-line'
  use 'kana/vim-textobj-user'
  use 'matze/vim-move'
  use 'mg979/vim-visual-multi'
  use 'numToStr/Comment.nvim'
  use 'sgur/vim-textobj-parameter'
  use 'tpope/vim-abolish'
  use 'tpope/vim-repeat'
  use 'tpope/vim-speeddating'
  use 'tpope/vim-surround'
  use 'triglav/vim-visual-increment'
  use 'wellle/visual-split.vim'
  xuse 'vigoux/architext.nvim'
  use 'chentau/marks.nvim'
  -- uselocal 'b0o/vim-buffest'
  use 'rbong/vim-buffest'
  -- use 'andymass/vim-matchup'
  -- uselocal 'extended-scrolloff.vim'

  -- Quickfix/Loclist
  use 'kevinhwang91/nvim-bqf'

  -- Backup, Undo
  use 'chrisbra/Recover.vim'
  use 'mbbill/undotree'

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use { 'nvim-treesitter/playground', cmd = 'TSPlaygroundToggle' }
  use 'romgrk/nvim-treesitter-context'
  use 'nkrkv/nvim-treesitter-rescript'

  -- LSP
  -- use 'neovim/nvim-lspconfig'
  use 'folke/lsp-colors.nvim'
  use 'folke/trouble.nvim'
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'nvim-lua/lsp-status.nvim'
  use 'onsails/lspkind-nvim'
  use 'ray-x/lsp_signature.nvim'
  use 'neovim/nvim-lspconfig'
  use 'b0o/schemastore.nvim'

  -- Code Style, Formatting, Linting
  use 'editorconfig/editorconfig-vim'

  -- Git
  use 'christoomey/vim-conflicted'
  use 'tpope/vim-fugitive'
  use 'sindrets/diffview.nvim'
  use 'TimUntersberger/neogit'
  use 'lewis6991/gitsigns.nvim'
  use 'ThePrimeagen/git-worktree.nvim'
  use { 'mattn/gist-vim', requires = 'mattn/webapi-vim' }

  -- System
  use 'tpope/vim-eunuch'

  -- Snippets
  use 'L3MON4D3/LuaSnip'

  -- Completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-calc'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'andersevenrud/cmp-tmux'
  use 'f3fora/cmp-spell'
  use 'ray-x/cmp-treesitter'
  use 'saadparwaiz1/cmp_luasnip'
  use { 'petertriho/cmp-git', requires = 'nvim-lua/plenary.nvim' }

  -- Debugging
  use 'mfussenegger/nvim-dap'
  use 'jbyuki/one-small-step-for-vimkind' -- Lua DAP adapter, a.k.a. osv

  -- Windows and Sessions
  use 'sindrets/winshift.nvim'
  use 'aserowy/tmux.nvim'
  use 'Shatur/neovim-session-manager'

  -- Language-specific
  use 'Akin909/vim-dune'
  use 'mboughaba/i3config.vim'
  use 'rescript-lang/vim-rescript'
  use 'aouelete/sway-vim-syntax'
  use 'fatih/vim-go'

  -- Documentation
  use 'alx741/vinfo'

  -- Color
  use 'KabbAmine/vCoolor.vim'
  use { 'rrethy/vim-hexokinase', run = 'make hexokinase' }

  --- Vim Plugin Development
  use 'bfredl/nvim-luadev'
  use 'folke/lua-dev.nvim'
  use 'rktjmp/lush.nvim'

  -- Performance
  use { 'lewis6991/impatient.nvim', rocks = 'mpack' }
  use 'nathom/filetype.nvim'
end)

packer.use_rocks {
  'base64',
}
