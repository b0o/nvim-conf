-- NOTE: We're using some custom packer extensions
-- SEE: ./packer.lua

local packer = require 'user.packer'

-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
local use, uselocal, xuse, xuselocal = packer.use, packer.uselocal, packer.xuse, packer.xuselocal

local startup = function()
  -- Package management
  use 'wbthomason/packer.nvim'

  -- Config
  uselocal 'b0o/mapx.nvim/worktree/current'

  -- Meta
  use 'nvim-lua/plenary.nvim'

  -- Colors
  use 'Mofiqul/dracula.nvim'

  -- UI
  uselocal { 'b0o/incline.nvim/worktree/main/', conf = 'incline' }
  use 'SmiteshP/nvim-gps'
  use 'chriskempson/base16-vim'
  use 'Famiu/feline.nvim'
  use 'ericbn/vim-relativize'
  use 'folke/which-key.nvim'
  use { 'kevinhwang91/nvim-hlslens', conf = 'hlslens' }
  use 'kyazdani42/nvim-web-devicons'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'rcarriga/nvim-notify'
  use 'stevearc/dressing.nvim'
  use 'VonHeikemen/fine-cmdline.nvim'
  use { 's1n7ax/nvim-window-picker', lazymod = 'window-picker' }
  use { 'kyazdani42/nvim-tree.lua', conf = 'nvim-tree' }
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
    'stevearc/aerial.nvim',
    lazymod = 'aerial',
    telescope_ext = 'aerial',
  }
  use { 'MunifTanjim/nui.nvim', module = 'nui' }
  use { 'winston0410/range-highlight.nvim', requires = 'winston0410/cmd-parser.nvim' }

  -- Window Management
  use 'sindrets/winshift.nvim'
  use { 'mrjones2014/smart-splits.nvim', module = 'smart-splits' }
  use { 'aserowy/tmux.nvim', lazymod = 'tmux' }
  use { 'wellle/visual-split.vim', cmd = { 'VSResize', 'VSSplit', 'VSSplitAbove', 'VSSplitBelow' } }

  -- Terminal
  use { 'akinsho/nvim-toggleterm.lua', conf = 'toggleterm' }

  -- Telescope
  use { 'nvim-telescope/telescope.nvim', requires = 'nvim-lua/popup.nvim', lazymod = 'telescope' }
  use { 'kyoh86/telescope-windows.nvim', telescope_ext = 'windows' }
  use { 'nvim-telescope/telescope-github.nvim', telescope_ext = 'gh' }
  use { 'natecraddock/telescope-zf-native.nvim', telescope_ext = 'zf-native' }
  use { 'nvim-telescope/telescope-live-grep-args.nvim', telescope_ext = 'live_grep_args' }
  use {
    'axkirillov/easypick.nvim',
    cmd = { 'Easypick' },
    requires = 'nvim-telescope/telescope.nvim',
    conf = 'easypick',
  }

  -- Editing
  use { 'smjonas/live-command.nvim' }
  use { 'andymass/vim-matchup', config = [[vim.g.matchup_motion_enabled = false]] }
  use 'chrisgrieser/nvim-recorder'
  use 'jinh0/eyeliner.nvim'
  use 'chaoren/vim-wordmotion'
  use { 'chentoast/marks.nvim', conf = 'marks' }
  use 'kana/vim-textobj-user'
  use { 'kana/vim-textobj-fold', after = 'vim-textobj-user' }
  use { 'kana/vim-textobj-indent', after = 'vim-textobj-user' }
  use { 'kana/vim-textobj-line', after = 'vim-textobj-user' }
  use { 'sgur/vim-textobj-parameter', after = 'vim-textobj-user' }
  use 'mg979/vim-visual-multi'
  use { 'numToStr/Comment.nvim', lazymod = { mod = 'Comment', conf = 'comment' }, keys = { { '', 'gcc' } } }
  use 'tpope/vim-repeat'
  use { 'tpope/vim-surround', config = [[vim.g.surround_no_insert_mappings = true]] }
  use 'monaqa/dial.nvim'
  use 'Wansmer/treesj'
  use { 'godlygeek/tabular', cmd = { 'AddTabularPattern', 'AddTabularPipeline', 'Tabularize', 'GTabularize' } }
  use { 'tpope/vim-abolish' }
  use { 'ThePrimeagen/refactoring.nvim', lazymod = 'refactoring' }
  use { 'matze/vim-move', setup = [[ vim.g.move_key_modifier = 'C'; vim.g.move_key_modifier_visualmode = 'C' ]] }

  -- AI
  use { 'zbirenbaum/copilot.lua', conf = 'copilot' }
  use { 'dpayne/CodeGPT.nvim', conf = 'codegpt' }

  -- Quickfix/Loclist
  use { 'kevinhwang91/nvim-bqf', lazymod = 'bqf', ft = 'qf', event = 'QuickFixCmdPre' }

  -- Backup, Undo
  use 'chrisbra/Recover.vim'
  use { 'mbbill/undotree', cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus' } }

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' }
  use { 'nvim-treesitter/nvim-treesitter-context', after = 'nvim-treesitter' }
  use { 'JoosepAlviste/nvim-ts-context-commentstring', after = 'nvim-treesitter' }
  use { 'Wansmer/sibling-swap.nvim', after = 'nvim-treesitter' }
  use { 'nvim-treesitter/playground', after = 'nvim-treesitter', cmd = 'TSPlaygroundToggle' }

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'folke/lsp-colors.nvim'
  use 'lukas-reineke/lsp-format.nvim'
  use 'nvim-lua/lsp-status.nvim'
  use 'onsails/lspkind-nvim'
  use { 'lewis6991/hover.nvim', lazymod = 'hover' }
  use { 'DNLHC/glance.nvim', lazymod = 'glance', cmd = 'Glance' }
  use { 'jose-elias-alvarez/null-ls.nvim', module = 'null-ls' }
  use { 'ray-x/lsp_signature.nvim', module = 'lsp_signature' }
  use { 'b0o/schemastore.nvim', module = 'schemastore' }
  use {
    'folke/trouble.nvim',
    lazymod = 'trouble',
    cmd = { 'Trouble', 'TroubleClose', 'TroubleRefresh', 'TroubleToggle' },
  }

  -- Code Style, Formatting, Linting
  use 'editorconfig/editorconfig-vim'

  -- Git
  use 'lewis6991/gitsigns.nvim'
  use { 'ThePrimeagen/git-worktree.nvim', lazymod = 'git-worktree', telescope_ext = 'git_worktree' }
  use { 'TimUntersberger/neogit', cmd = 'Neogit', lazymod = 'neogit' }
  use { 'mattn/gist-vim', requires = 'mattn/webapi-vim', cmd = 'Gist' }
  use 'ruifm/gitlinker.nvim'
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
  use 'L3MON4D3/LuaSnip'

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

  -- Debugging
  -- use { 'mfussenegger/nvim-dap', module = 'dap' }
  -- use { 'jbyuki/one-small-step-for-vimkind', module = 'osv' } -- Lua DAP adapter, a.k.a. osv

  -- Sessions
  use {
    'Shatur/neovim-session-manager',
    lazymod = 'session_manager',
  }

  -- Language-specific
  use 'mboughaba/i3config.vim'
  use 'aouelete/sway-vim-syntax'
  use 'fatih/vim-go'
  use 'jose-elias-alvarez/typescript.nvim'
  use 'jakemason/ouroboros.nvim' -- C/C++ header/source file switching
  use 'ziglang/zig.vim'

  -- Documentation
  use { 'alx741/vinfo', cmd = { 'Vinfo', 'VinfoClean', 'VinfoNext', 'VinfoPrevious' } }

  -- Color
  use { 'KabbAmine/vCoolor.vim', lazymod = { 'vcoolor', nolua = true }, cmd = { 'VCoolIns', 'VCoolor' } }
  use { 'rrethy/vim-hexokinase', run = 'make hexokinase' }

  --- Vim Plugin Development
  use { 'bfredl/nvim-luadev', ft = 'lua' }
  use { 'folke/neodev.nvim' }
  use {
    'rktjmp/lush.nvim',
    cmd = { 'LushRunQuickstart', 'LushRunTutorial', 'Lushify', 'LushImport' },
    module = 'lush',
  }

  -- Performance
  use { 'dstein64/vim-startuptime', cmd = 'StartupTime' }
end

packer.startup {
  startup,
  config = {
    max_jobs = tonumber(vim.fn.system 'nproc 2>/dev/null || echo 8'),
  },
}
