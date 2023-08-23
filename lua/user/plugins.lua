local M = {
  telescope_exts = {},
}

local plugins = {
  -- Config
  'b0o/mapx.nvim',

  -- Meta
  'nvim-lua/plenary.nvim',

  -- Colorschemes
  'Mofiqul/dracula.nvim',
  'chriskempson/base16-vim',

  -- UI
  'Famiu/feline.nvim',
  'kyazdani42/nvim-web-devicons',
  { 'b0o/incline.nvim', conf = 'incline' },
  'SmiteshP/nvim-gps',
  'folke/which-key.nvim',
  { 'kevinhwang91/nvim-hlslens', conf = 'hlslens' },
  'lukas-reineke/indent-blankline.nvim',
  'rcarriga/nvim-notify',
  'stevearc/dressing.nvim',
  { 's1n7ax/nvim-window-picker', lazymod = 'window-picker' },
  { 'kyazdani42/nvim-tree.lua', conf = 'nvim-tree' },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    cmd = { 'Neotree' },
    conf = 'neo-tree',
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
    end,
  },
  {
    'simrat39/desktop-notify.nvim',
    init = function()
      pcall(vim.cmd, 'delcommand Notifications')
    end,
    config = function()
      vim.cmd 'command! Notifications :lua require("notify")._print_history()<CR>'
    end,
  },
  {
    'stevearc/aerial.nvim',
    conf = 'aerial',
    telescope_ext = 'aerial',
  },
  { 'MunifTanjim/nui.nvim', module = 'nui' },
  { 'winston0410/range-highlight.nvim', dependencies = 'winston0410/cmd-parser.nvim' },

  -- Window Management
  'sindrets/winshift.nvim',
  { 'mrjones2014/smart-splits.nvim' },
  { 'aserowy/tmux.nvim', conf = 'tmux' },
  { 'wellle/visual-split.vim', cmd = { 'VSResize', 'VSSplit', 'VSSplitAbove', 'VSSplitBelow' } },

  -- Terminal
  { 'akinsho/nvim-toggleterm.lua', conf = 'toggleterm' },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/popup.nvim',
    conf = 'telescope',
  },
  { 'kyoh86/telescope-windows.nvim', telescope_ext = 'windows' },
  { 'nvim-telescope/telescope-github.nvim', telescope_ext = 'gh' },
  { 'natecraddock/telescope-zf-native.nvim', telescope_ext = 'zf-native' },
  { 'nvim-telescope/telescope-live-grep-args.nvim', telescope_ext = 'live_grep_args' },
  {
    'axkirillov/easypick.nvim',
    cmd = { 'Easypick' },
    conf = 'easypick',
  },

  -- Editing
  'smjonas/live-command.nvim',
  {
    'andymass/vim-matchup',
    config = function()
      vim.g.matchup_motion_enabled = false
    end,
  },
  'chrisgrieser/nvim-recorder',
  'jinh0/eyeliner.nvim',
  'chaoren/vim-wordmotion',
  { 'chentoast/marks.nvim', conf = 'marks' },
  'kana/vim-textobj-user',
  { 'kana/vim-textobj-fold', dependencies = 'kana/vim-textobj-user' },
  { 'kana/vim-textobj-indent', dependencies = 'kana/vim-textobj-user' },
  { 'kana/vim-textobj-line', dependencies = 'kana/vim-textobj-user' },
  { 'sgur/vim-textobj-parameter', dependencies = 'kana/vim-textobj-user' },
  'mg979/vim-visual-multi',
  { 'numToStr/Comment.nvim', conf = 'comment' },
  'tpope/vim-repeat',
  {
    'tpope/vim-surround',
    config = function()
      vim.g.surround_no_insert_mappings = true
    end,
  },
  'monaqa/dial.nvim',
  'Wansmer/treesj',
  { 'godlygeek/tabular', cmd = { 'AddTabularPattern', 'AddTabularPipeline', 'Tabularize', 'GTabularize' } },
  'tpope/vim-abolish',
  { 'ThePrimeagen/refactoring.nvim', conf = 'refactoring' },
  {
    'matze/vim-move',
    init = function()
      vim.g.move_key_modifier = 'C'
      vim.g.move_key_modifier_visualmode = 'C'
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      fast_wrap = {},
    },
  },

  -- AI
  { 'zbirenbaum/copilot.lua', conf = 'copilot' },
  { 'dpayne/CodeGPT.nvim', conf = 'codegpt' },

  -- Quickfix/Loclist
  { 'kevinhwang91/nvim-bqf', conf = 'bqf', ft = 'qf', event = 'QuickFixCmdPre' },

  -- Backup, Undo
  'chrisbra/Recover.vim',
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus' },
  },

  -- Treesitter
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  'nvim-treesitter/nvim-treesitter-textobjects',
  'nvim-treesitter/nvim-treesitter-context',
  'JoosepAlviste/nvim-ts-context-commentstring',
  'Wansmer/sibling-swap.nvim',
  { 'nvim-treesitter/playground', cmd = 'TSPlaygroundToggle' },
  'windwp/nvim-ts-autotag',

  -- LSP
  'neovim/nvim-lspconfig',
  'folke/lsp-colors.nvim',
  'lukas-reineke/lsp-format.nvim',
  'nvim-lua/lsp-status.nvim',
  'onsails/lspkind-nvim',
  'lewis6991/hover.nvim',
  {
    'pmizio/typescript-tools.nvim',
    conf = 'typescript-tools',
    ft = {
      'typescript',
      'javascript',
      'typescriptreact',
      'javascriptreact',
    },
  },
  { 'DNLHC/glance.nvim', conf = 'glance', cmd = 'Glance' },
  'jose-elias-alvarez/null-ls.nvim',
  'ray-x/lsp_signature.nvim',
  'b0o/schemastore.nvim',
  {
    'folke/trouble.nvim',
    conf = 'trouble',
    cmd = { 'Trouble', 'TroubleClose', 'TroubleRefresh', 'TroubleToggle' },
  },
  'aznhe21/actions-preview.nvim',

  -- Code Style, Formatting, Linting
  'editorconfig/editorconfig-vim',

  -- Testing
  {
    'nvim-neotest/neotest',
    conf = 'neotest',
    cmd = { 'Neotest' },
    dependencies = {
      'marilari88/neotest-vitest',
    },
  },

  -- Git
  'lewis6991/gitsigns.nvim',
  { 'ThePrimeagen/git-worktree.nvim', conf = 'git-worktree', telescope_ext = 'git_worktree' },
  { 'NeogitOrg/neogit', cmd = 'Neogit', conf = 'neogit' },
  { 'mattn/gist-vim', dependencies = 'mattn/webapi-vim', cmd = 'Gist' },
  'ruifm/gitlinker.nvim',
  {
    'christoomey/vim-conflicted',
    cmd = { 'Conflicted', 'Merger', 'GitNextConflict' },
    -- keys = { '<Plug>DiffgetLocal', '<Plug>DiffgetUpstream', '<Plug>DiffgetLocal', '<Plug>DiffgetUpstream' },
  },
  {
    'sindrets/diffview.nvim',
    conf = 'diffview',
    cmd = {
      'DiffviewClose',
      'DiffviewFileHistory',
      'DiffviewFocusFiles',
      'DiffviewLog',
      'DiffviewOpen',
      'DiffviewRefresh',
      'DiffviewToggleFiles',
    },
  },
  {
    'tpope/vim-fugitive',
    cmd = {
      'Git',
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
  },

  -- System
  {
    'tpope/vim-eunuch',
    cmd = { 'Chmod', 'Delete', 'Edit', 'Grep', 'Mkdir', 'Move', 'Rename', 'Unlink', 'Wall', 'Write' },
  },

  -- Snippets
  'L3MON4D3/LuaSnip',

  -- Completion
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-nvim-lua',
  'ray-x/cmp-treesitter',
  'saadparwaiz1/cmp_luasnip',
  'andersevenrud/cmp-tmux',
  'petertriho/cmp-git',
  'hrsh7th/cmp-cmdline',
  { 'dcampos/cmp-emmet-vim', dependencies = 'mattn/emmet-vim' },

  -- Sessions
  {
    'Shatur/neovim-session-manager',
    conf = 'session_manager',
  },

  -- Language-specific
  'mboughaba/i3config.vim',
  'aouelete/sway-vim-syntax',
  'fatih/vim-go',
  'jakemason/ouroboros.nvim', -- C/C++ header/source file switching
  'ziglang/zig.vim',

  -- Documentation
  { 'alx741/vinfo', cmd = { 'Vinfo', 'VinfoClean', 'VinfoNext', 'VinfoPrevious' } },

  -- Color
  {
    'KabbAmine/vCoolor.vim',
    conf = { 'vcoolor', nolua = true },
    cmd = { 'VCoolIns', 'VCoolor' },
  },
  { 'rrethy/vim-hexokinase', build = 'make hexokinase' },

  --- Vim Plugin Development
  { 'bfredl/nvim-luadev', ft = 'lua' },
  'folke/neodev.nvim',
  {
    'rktjmp/lush.nvim',
    cmd = { 'LushRunQuickstart', 'LushRunTutorial', 'Lushify', 'LushImport' },
  },

  -- Performance
  { 'dstein64/vim-startuptime', cmd = 'StartupTime' },
}

local opts = {}

for _, plugin in ipairs(plugins) do
  if type(plugin) == 'table' then
    if type(plugin.conf) == 'string' then
      local conf = plugin.conf
      local config = plugin.config
      plugin.config = function()
        require('user.plugin.' .. conf)
        if config then
          config()
        end
      end
      plugin.conf = nil
    end
    if type(plugin.telescope_ext) == 'string' then
      table.insert(M.telescope_exts, plugin.telescope_ext)
      plugin.telescope_ext = nil
    end
  end
end

require('lazy').setup(plugins, opts)

return M
