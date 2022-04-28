-- NOTE: We're using some custom packer extensions
-- SEE: ./packer.lua

local packer = require 'user.packer'

---@diagnostic disable-next-line: unused-local
local use, uselocal, xuse, xuselocal = packer.use, packer.uselocal, packer.xuse, packer.xuselocal

local startup = function()
  -- Package management
  use 'wbthomason/packer.nvim'

  -- Config
  uselocal 'b0o/mapx.nvim/worktree/current'

  -- Meta
  use 'nvim-lua/plenary.nvim'

  -- UI
  uselocal { 'b0o/incline.nvim', conf = 'incline' }
  use 'Famiu/feline.nvim'
  use 'ericbn/vim-relativize'
  use 'folke/which-key.nvim'
  use { 'kevinhwang91/nvim-hlslens', conf = 'hlslens' }
  uselocal 'kyazdani42/nvim-web-devicons'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'rcarriga/nvim-notify'
  use 'stevearc/dressing.nvim'
  use { 'axieax/urlview.nvim', cmd = 'UrlView', telescope_ext = 'urlview' }
  use { 'kyazdani42/nvim-tree.lua', lazymod = 'nvim-tree', cmd = 'NvimTree*' }
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    lazymod = 'neo-tree',
    cmd = { 'Neotree', 'Neotree*' },
    setup = [[vim.g.neo_tree_remove_legacy_commands = 1]],
  }
  use {
    'simrat39/desktop-notify.nvim',
    setup = [[pcall(vim.cmd, 'delcommand Notifications')]],
    config = [[vim.cmd'command! Notifications :lua require("notify")._print_history()<CR>']],
  }
  use {
    'stevearc/aerial.nvim/worktree/current',
    lazymod = 'aerial',
    telescope_ext = 'aerial',
  }
  use { 'MunifTanjim/nui.nvim', module = 'nui' }
  use { 'winston0410/range-highlight.nvim', requires = 'winston0410/cmd-parser.nvim' }

  -- Telescope
  use { 'nvim-telescope/telescope.nvim', requires = 'nvim-lua/popup.nvim', lazymod = 'telescope' }
  use { 'kyoh86/telescope-windows.nvim', telescope_ext = 'windows' }
  use { 'nvim-telescope/telescope-github.nvim', telescope_ext = 'gh' }

  -- Editing
  use { 'andymass/vim-matchup', config = [[vim.g.matchup_motion_enabled = false]] }
  use 'b0o/vim-shot-f'
  use 'chaoren/vim-wordmotion'
  use { 'chentau/marks.nvim', conf = 'marks' }
  use 'kana/vim-textobj-user'
  use { 'kana/vim-textobj-fold', after = 'vim-textobj-user' }
  use { 'kana/vim-textobj-indent', after = 'vim-textobj-user' }
  use { 'kana/vim-textobj-line', after = 'vim-textobj-user' }
  use { 'sgur/vim-textobj-parameter', after = 'vim-textobj-user' }
  use 'matze/vim-move'
  use 'mg979/vim-visual-multi'
  use { 'numToStr/Comment.nvim', lazymod = { mod = 'Comment', conf = 'comment' }, keys = { { '', 'gcc' } } }
  use 'tpope/vim-repeat'
  use 'tpope/vim-speeddating'
  use { 'tpope/vim-surround', config = [[vim.g.surround_no_insert_mappings = true]] }
  use 'triglav/vim-visual-increment'
  use { 'AndrewRadev/splitjoin.vim', cmd = { 'SplitjoinSplit', 'SplitjoinJoin' } }
  use { 'godlygeek/tabular', cmd = { 'AddTabularPattern', 'AddTabularPipeline', 'Tabularize', 'GTabularize' } }
  use { 'tpope/vim-abolish', cmd = { 'Abolish', 'Subvert' } }
  use { 'wellle/visual-split.vim', cmd = { 'VSResize', 'VSSplit', 'VSSplitAbove', 'VSSplitBelow' } }
  use {
    'rbong/vim-buffest',
    cmd = {
      'Regsplit',
      'Regvsplit',
      'Regtabedit',
      'Regedit',
      'Regpedit',
      'Qflistsplit',
      'Qflistvsplit',
      'Qflisttabedit',
      'Qflistedit',
      'Loclistsplit',
      'Loclistvsplit',
      'Loclisttabedit',
      'Locflistedit',
    },
  }

  -- Quickfix/Loclist
  use { 'kevinhwang91/nvim-bqf', lazymod = 'bqf', ft = 'qf', event = 'QuickFixCmdPre' }

  -- Backup, Undo
  use 'chrisbra/Recover.vim'
  use { 'mbbill/undotree', cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus' } }

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' }
  use { 'romgrk/nvim-treesitter-context', after = 'nvim-treesitter' }
  use { 'nkrkv/nvim-treesitter-rescript', after = 'nvim-treesitter' }
  xuse { 'lewis6991/spellsitter.nvim', after = 'nvim-treesitter' }
  use { 'nvim-treesitter/playground', after = 'nvim-treesitter', cmd = 'TSPlaygroundToggle' }

  -- LSP
  -- use 'neovim/nvim-lspconfig'
  use 'folke/lsp-colors.nvim'
  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/lsp-status.nvim'
  use 'onsails/lspkind-nvim'
  use { 'jose-elias-alvarez/null-ls.nvim', module = 'null-ls' }
  use { 'ray-x/lsp_signature.nvim', module = 'lsp_signature' }
  use { 'b0o/schemastore.nvim', module = 'schemastore' }
  -- use {
  --   'folke/trouble.nvim',
  --   lazymod = 'trouble',
  --   cmd = { 'Trouble', 'TroubleClose', 'TroubleRefresh', 'TroubleToggle' },
  -- }

  -- Code Style, Formatting, Linting
  use 'editorconfig/editorconfig-vim'

  -- Git
  use 'lewis6991/gitsigns.nvim'
  use { 'ThePrimeagen/git-worktree.nvim', lazymod = 'git-worktree', telescope_ext = 'git_worktree' }
  use { 'TimUntersberger/neogit', cmd = 'Neogit', lazymod = 'neogit' }
  use { 'mattn/gist-vim', requires = 'mattn/webapi-vim', cmd = 'Gist' }
  use {
    'christoomey/vim-conflicted',
    cmd = { 'Conflicted', 'Merger', 'GitNextConflict' },
    keys = { '<Plug>DiffgetLocal', '<Plug>DiffgetUpstream', '<Plug>DiffgetLocal', '<Plug>DiffgetUpstream' },
  }
  use {
    'sindrets/diffview.nvim',
    lazymod = 'diffview',
    cmd = {
      'DiffviewClose',
      'DiffviewFileHistory',
      'DiffviewFocusFiles',
      'DiffviewLog',
      'DiffviewOpen',
      'DiffviewRefresh',
      'DiffviewToggleFiles',
    },
  }
  use {
    'tpope/vim-fugitive',
    cmd = {
      '0Git',
      'G',
      'GBrowse',
      'Gcd',
      'Gclog',
      'GDelete',
      'Gdiffsplit',
      'Gedit',
      'Ggrep',
      'Ghdiffsplit',
      'Git',
      'Glcd',
      'Glgrep',
      'Gllog',
      'GMove',
      'Gpedit',
      'Gread',
      'GRemove',
      'GRename',
      'Gsplit',
      'Gtabedit',
      'GUnlink',
      'Gvdiffsplit',
      'Gvsplit',
      'Gwq',
      'Gwrite',
    },
  }

  -- System
  use {
    'tpope/vim-eunuch',
    cmd = { 'Chmod', 'Delete', 'Edit', 'Grep', 'Mkdir', 'Move', 'Rename', 'Unlink', 'Wall', 'Write' },
  }

  -- Snippets
  use {
    'L3MON4D3/LuaSnip',
    -- conf = 'luasnip',
  }

  -- Completion
  use { 'hrsh7th/nvim-cmp', module = 'cmp' }
  use { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-path', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' }
  use { 'ray-x/cmp-treesitter', after = 'nvim-cmp' }
  use { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' }
  use { 'andersevenrud/cmp-tmux', after = 'nvim-cmp' }
  use { 'petertriho/cmp-git', after = 'nvim-cmp' }
  use { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' }
  xuse { 'hrsh7th/cmp-calc', after = 'nvim-cmp' }
  xuse { 'f3fora/cmp-spell', after = 'nvim-cmp' }

  -- Debugging
  use { 'mfussenegger/nvim-dap', module = 'dap' }
  use { 'jbyuki/one-small-step-for-vimkind', module = 'osv' } -- Lua DAP adapter, a.k.a. osv

  -- Window Management
  use 'sindrets/winshift.nvim'
  use 'luukvbaal/stabilize.nvim'
  use { 'mrjones2014/smart-splits.nvim', module = 'smart-splits' }
  use { 'aserowy/tmux.nvim', lazymod = 'tmux' }

  -- Sessions
  use {
    'Shatur/neovim-session-manager',
    lazymod = 'session_manager',
  }

  -- Language-specific
  use 'Akin909/vim-dune'
  use 'mboughaba/i3config.vim'
  use 'rescript-lang/vim-rescript'
  use 'aouelete/sway-vim-syntax'
  use 'fatih/vim-go'

  -- Documentation
  use { 'alx741/vinfo', cmd = { 'Vinfo', 'VinfoClean', 'VinfoNext', 'VinfoPrevious' } }

  -- Color
  use { 'KabbAmine/vCoolor.vim', lazymod = { 'vcoolor', nolua = true }, cmd = { 'VCoolIns', 'VCoolor' } }
  use { 'rrethy/vim-hexokinase', run = 'make hexokinase' }

  --- Vim Plugin Development
  use { 'bfredl/nvim-luadev', ft = 'lua' }
  use 'folke/lua-dev.nvim'
  use {
    'rktjmp/lush.nvim',
    cmd = { 'LushRunQuickstart', 'LushRunTutorial', 'Lushify', 'LushImport' },
    module = 'lush',
  }

  -- Performance
  use 'lewis6991/impatient.nvim'
  use 'nathom/filetype.nvim'
  use 'antoinemadec/FixCursorHold.nvim'
end

packer.startup {
  startup,
  config = {
    max_jobs = tonumber(vim.fn.system 'nproc 2>/dev/null || echo 8'),
  },
  -- rocks = {
  --   'base64',
  -- },
}
