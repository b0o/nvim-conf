local M = {
  telescope_exts = {},
}

-- lazy.nvim options
local opts = {
  defaults = {
    lazy = true,
  },
}

local plugins = {
  -- Config
  {
    'b0o/mapx.nvim',
    conf = 'user.mappings',
    event = 'VeryLazy',
  },

  -- Meta
  'nvim-lua/plenary.nvim',

  -- Colorschemes
  -- 'Mofiqul/dracula.nvim',
  -- 'chriskempson/base16-vim',

  -- UI
  {
    'Famiu/feline.nvim',
    event = 'VeryLazy',
    conf = 'user.statusline',
  },
  'kyazdani42/nvim-web-devicons',
  'SmiteshP/nvim-gps',
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      plugins = {
        spelling = {
          enabled = true,
          suggestions = 30,
        },
      },
      triggers_blacklist = {
        i = { 'j', 'k', "'" },
        v = { 'j', 'k', "'" },
        n = { "'" },
      },
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'VeryLazy',
    conf = 'user.plugin.ibl',
  },
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    opts = {
      select = {
        backend = { 'telescope', 'fzf_lua', 'fzf', 'builtin', 'nui' },
      },
    },
  },
  {
    name = 'incline.nvim',
    dir = vim.env.HOME .. '/proj/incline.nvim/worktree/main',
    conf = 'user.plugin.incline',
    event = 'VeryLazy',
  },
  {
    'kevinhwang91/nvim-hlslens',
    conf = 'user.plugin.hlslens',
  },
  {
    's1n7ax/nvim-window-picker',
    conf = 'user.plugin.window-picker',
  },
  {
    'kyazdani42/nvim-tree.lua',
    conf = 'user.plugin.nvim-tree',
    module = 'nvim-tree',
    cmd = { 'NvimTreeOpen', 'NvimTreeFocus' },
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    cmd = 'Neotree',
    conf = 'user.plugin.neo-tree',
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
    end,
  },
  {
    'stevearc/aerial.nvim',
    conf = 'user.plugin.aerial',
    telescope_ext = 'aerial',
  },
  {
    'MunifTanjim/nui.nvim',
    module = 'nui',
  },
  {
    'winston0410/range-highlight.nvim',
    dependencies = 'winston0410/cmd-parser.nvim',
    config = true,
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    conf = 'user.plugin.noice',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
      -- 'hrsh7th/nvim-cmp',
    },
  },

  -- Window Management
  {
    'sindrets/winshift.nvim',
    cmd = 'WinShift',
    conf = 'user.plugin.winshift',
  },

  'mrjones2014/smart-splits.nvim',
  {
    'aserowy/tmux.nvim',
    conf = 'user.plugin.tmux',
  },
  {
    'wellle/visual-split.vim',
    cmd = { 'VSResize', 'VSSplit', 'VSSplitAbove', 'VSSplitBelow' },
  },

  -- Terminal
  {
    'akinsho/nvim-toggleterm.lua',
    conf = 'user.plugin.toggleterm',
    cmd = 'ToggleTerm',
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    module = 'telescope',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/popup.nvim',
      { 'kyoh86/telescope-windows.nvim', telescope_ext = 'windows' },
      { 'nvim-telescope/telescope-github.nvim', telescope_ext = 'gh' },
      { 'natecraddock/telescope-zf-native.nvim', telescope_ext = 'zf-native' },
      { 'nvim-telescope/telescope-live-grep-args.nvim', telescope_ext = 'live_grep_args' },
      {
        'axkirillov/easypick.nvim',
        cmd = { 'Easypick' },
        conf = 'user.plugin.easypick',
      },
    },
  },

  -- Editing
  {
    'smjonas/live-command.nvim',
    module = 'live-command',
    main = 'live-command',
    event = 'CmdlineEnter',
    opts = {
      commands = {
        Norm = { cmd = 'norm' },
        S = { cmd = 'Subvert' },
      },
    },
  },
  {
    'andymass/vim-matchup',
    event = 'VeryLazy',
    config = function()
      vim.g.matchup_motion_enabled = false
      vim.g.matchup_matchparen_offscreen = {}
    end,
  },
  {
    'jinh0/eyeliner.nvim',
    config = function()
      local colors = require 'user.colors'
      require('eyeliner').setup {
        highlight_on_key = true,
      }
      vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg = colors.cyan, bold = true, underline = true })
      vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg = colors.yellow, bold = true, underline = true })
    end,
  },
  'chaoren/vim-wordmotion',
  { 'chentoast/marks.nvim', conf = 'user.plugin.marks' },
  {
    'kana/vim-textobj-user',
    event = 'VeryLazy',
    dependencies = {
      'kana/vim-textobj-fold',
      'kana/vim-textobj-indent',
      'kana/vim-textobj-line',
      'sgur/vim-textobj-parameter',
    },
  },
  {
    'mg979/vim-visual-multi',
    config = function()
      vim.g.VM_custom_motions = {
        ['<M-,>'] = ',', -- Remap , to <M-,> because , conflicts with <localleader>
      }
    end,
  },
  {
    'numToStr/Comment.nvim',
    conf = 'user.plugin.comment',
  },
  {
    'tpope/vim-repeat',
    event = 'VeryLazy',
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    conf = 'user.plugin.nvim-surround',
  },
  {
    'monaqa/dial.nvim',
    conf = 'user.plugin.dial',
  },
  {
    'godlygeek/tabular',
    cmd = { 'AddTabularPattern', 'AddTabularPipeline', 'Tabularize', 'GTabularize' },
  },
  'tpope/vim-abolish',
  { 'ThePrimeagen/refactoring.nvim', conf = 'user.plugin.refactoring' },
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
  {
    'zbirenbaum/copilot.lua',
    conf = 'user.plugin.copilot',
    event = 'InsertEnter',
  },
  {
    'dpayne/CodeGPT.nvim',
    config = function()
      local private = require 'user.private'
      vim.g['codegpt_openai_api_key'] = private.openai_api_key
    end,
    cmd = 'Chat',
  },
  {
    'piersolenski/wtf.nvim',
    conf = 'user.plugin.wtf',
    cmd = 'Wtf',
  },

  -- Backup, Undo
  {
    'chrisbra/Recover.vim',
    lazy = false,
  },
  {
    'mbbill/undotree',
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
    cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus' },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'BufRead',
    conf = 'user.treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'Wansmer/sibling-swap.nvim',
      'Wansmer/treesj',
      'windwp/nvim-ts-autotag',
    },
  },
  {
    'nvim-treesitter/playground',
    cmd = 'TSPlaygroundToggle',
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    conf = 'user.lsp',
    cmd = { 'LspInfo', 'LspStart', 'LspStop', 'LspRestart', 'LspLog' },
    event = 'BufReadPost',
  },
  'folke/lsp-colors.nvim',
  {
    'stevearc/conform.nvim',
    conf = 'user.plugin.conform',
    event = 'BufWritePre',
  },
  'nvim-lua/lsp-status.nvim',
  {
    'onsails/lspkind-nvim',
    module = 'lspkind',
    config = function()
      require('lspkind').init {
        symbol_map = {
          Type = '',
        },
      }
    end,
  },
  'lewis6991/hover.nvim',
  'nvimtools/none-ls.nvim',
  'ray-x/lsp_signature.nvim',
  'b0o/schemastore.nvim',
  'aznhe21/actions-preview.nvim',
  { 'smjonas/inc-rename.nvim', config = true },
  {
    'DNLHC/glance.nvim',
    conf = 'user.plugin.glance',
    cmd = 'Glance',
  },
  {
    'pmizio/typescript-tools.nvim',
    -- enabled = false,
    conf = 'user.plugin.typescript-tools',
    ft = {
      'typescript',
      'javascript',
      'typescriptreact',
      'javascriptreact',
    },
  },
  {
    'folke/trouble.nvim',
    conf = 'user.plugin.trouble',
    cmd = { 'Trouble', 'TroubleClose', 'TroubleRefresh', 'TroubleToggle' },
  },

  -- Code Style, Formatting, Linting
  'editorconfig/editorconfig-vim',

  -- Testing
  {
    'nvim-neotest/neotest',
    conf = 'user.plugin.neotest',
    cmd = { 'Neotest' },
    dependencies = {
      'marilari88/neotest-vitest',
    },
  },

  -- Git
  {
    'lewis6991/gitsigns.nvim',
    conf = 'user.plugin.gitsigns',
    event = { 'BufRead', 'BufNewFile' },
    cmd = { 'Gitsigns' },
  },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    conf = 'user.plugin.neogit',
  },
  {
    'mattn/gist-vim',
    dependencies = 'mattn/webapi-vim',
    cmd = 'Gist',
  },
  'ruifm/gitlinker.nvim',
  {
    'christoomey/vim-conflicted',
    cmd = { 'Conflicted', 'Merger', 'GitNextConflict' },
    -- keys = { '<Plug>DiffgetLocal', '<Plug>DiffgetUpstream', '<Plug>DiffgetLocal', '<Plug>DiffgetUpstream' },
  },
  {
    'sindrets/diffview.nvim',
    conf = 'user.plugin.diffview',
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

  -- System
  {
    'tpope/vim-eunuch',
    cmd = { 'Chmod', 'Delete', 'Edit', 'Grep', 'Mkdir', 'Move', 'Rename', 'Unlink', 'Wall', 'Write' },
  },

  -- Snippets
  'L3MON4D3/LuaSnip',

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    conf = 'user.plugin.nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    module = 'cmp',
    dependencies = {
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
    },
  },

  -- Sessions
  {
    'Shatur/neovim-session-manager',
    conf = 'user.plugin.session_manager',
  },

  -- Language-specific
  'mboughaba/i3config.vim',
  'aouelete/sway-vim-syntax',
  -- 'HerringtonDarkholme/yats.vim', -- typescript syntax highlighting
  {
    'fatih/vim-go',
    ft = 'go',
    config = function()
      vim.g.go_doc_keywordprg_enabled = 0
    end,
  },
  {
    -- C/C++ header/source file switching
    'jakemason/ouroboros.nvim',
    ft = { 'c', 'cpp' },
  },
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

local function preprocess_plugin_specs(specs)
  if type(specs) ~= 'table' then
    return specs
  end

  local new_specs = {}
  for _, spec in ipairs(specs) do
    local new_spec = {}

    if type(spec) == 'string' then
      new_spec = { spec }
    elseif type(spec) == 'table' then
      new_spec = vim.deepcopy(spec)
    end

    if new_spec.dependencies then
      new_spec.dependencies = preprocess_plugin_specs(new_spec.dependencies)
    end

    if type(new_spec.conf) == 'string' then
      local conf = new_spec.conf
      local config = new_spec.config
      new_spec.config = function()
        if not package.loaded[conf] then
          require(conf)
        end
        if config then
          config()
        end
      end
      new_spec.conf = nil
    end

    if type(new_spec.telescope_ext) == 'string' then
      table.insert(M.telescope_exts, new_spec.telescope_ext)
      new_spec.telescope_ext = nil
    end

    table.insert(new_specs, new_spec)
  end

  return new_specs
end

require('lazy').setup(preprocess_plugin_specs(plugins), opts)

return M
