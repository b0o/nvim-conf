-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer = require 'packer'
local use = packer.use

local function uselocal(p)
  if type(p) ~= 'table' then
    p = { p }
  end
  local git_projects_dir = os.getenv 'GIT_PROJECTS_DIR'
  if git_projects_dir == nil then
    return
  end
  p[1] = string.gsub(p[1], '.*/', '')
  p[1] = git_projects_dir .. '/' .. p[1]
  use(p)
end

packer.init {
  max_jobs = tonumber(vim.fn.system 'nproc') or 8,
}

packer.startup(function()
  -- Package management
  use 'wbthomason/packer.nvim'

  -- Config
  uselocal {
    'mapx.nvim',
    --     config = function()
    --       require'user.mappings'
    --     end,
  }

  -- Meta
  use 'nvim-lua/plenary.nvim'

  -- Colorschemes
  use 'chriskempson/base16-vim'
  use 'dracula/vim'

  -- UI
  use 'Famiu/feline.nvim'
  use 'ericbn/vim-relativize'
  use 'folke/which-key.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'liuchengxu/vista.vim'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'luukvbaal/stabilize.nvim'
  use 'kevinhwang91/nvim-hlslens'
  use 'kyazdani42/nvim-tree.lua'
  use 'rcarriga/nvim-notify'
  uselocal 'stevearc/aerial.nvim'
  -- use 'sidebar-nvim/sidebar.nvim'
  use {
    'VonHeikemen/fine-cmdline.nvim',
    requires = { 'MunifTanjim/nui.nvim' },
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/popup.nvim' },
  }
  use 'kyoh86/telescope-windows.nvim'

  -- Editing
  use 'AndrewRadev/splitjoin.vim'
  -- use 'andymass/vim-matchup'
  use 'b0o/vim-shot-f'
  use 'chaoren/vim-wordmotion'
  use 'coderifous/textobj-word-column.vim'
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
  use 'vigoux/architext.nvim'
  use 'chentau/marks.nvim'
  uselocal 'vim-buffest'
  -- uselocal 'extended-scrolloff.vim'

  -- Backup, Undo
  use 'chrisbra/Recover.vim'
  use 'mbbill/undotree'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'nvim-treesitter/playground'
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
  use 'tpope/vim-rhubarb'
  use 'lewis6991/gitsigns.nvim'
  use 'tanvirtin/vgit.nvim'
  use 'ThePrimeagen/git-worktree.nvim'
  use { 'mattn/gist-vim', requires = 'mattn/webapi-vim' }

  -- System
  use 'tpope/vim-eunuch'

  -- Tooling
  --   use 'ludovicchabant/vim-gutentags'

  -- Snippets
  use 'L3MON4D3/LuaSnip'

  -- Code Completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-calc'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-path'
  use 'octaltree/cmp-look'
  use 'saadparwaiz1/cmp_luasnip'
  use 'ray-x/cmp-treesitter'
  use 'f3fora/cmp-spell'
  use 'andersevenrud/cmp-tmux'

  -- Debugging
  use 'mfussenegger/nvim-dap'
  use 'jbyuki/one-small-step-for-vimkind' -- Lua DAP adapter, a.k.a. osv

  -- Windows and Sessions
  use 'sindrets/winshift.nvim'
  use 'aserowy/tmux.nvim'
  use 'Shatur/neovim-session-manager'
  -- use 'ingram1107/souvenir.nvim'

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

  -- Misc
  use { 'lewis6991/impatient.nvim', rocks = 'mpack' }
  use 'nathom/filetype.nvim'
end)

packer.use_rocks {
  'base64',
}
