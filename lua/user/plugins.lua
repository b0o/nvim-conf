local M = {
  telescope_exts = {},
}

-- lazy.nvim options
local opts = {
  defaults = {
    lazy = true,
  },
  ui = {
    border = 'rounded',
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
      window = {
        border = 'rounded',
        padding = { 0, 0, 0, 0 },
      },
      show_help = false,
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'VeryLazy',
    conf = 'user.plugin.ibl',
  },
  {
    name = 'incline.nvim',
    dir = vim.env.HOME .. '/proj/incline.nvim/worktree/main',
    conf = 'user.plugin.incline',
    event = 'VeryLazy',
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
    'stevearc/oil.nvim',
    conf = 'user.plugin.oil',
    cmd = 'Oil',
    -- If nvim is started with a directory argument, load oil immediately
    -- via https://github.com/folke/lazy.nvim/issues/533
    init = function()
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == 'directory' then
          require('lazy').load { plugins = { 'oil.nvim' } }
        end
      end
      if not require('lazy.core.config').plugins['oil.nvim']._.loaded then
        vim.api.nvim_create_autocmd('BufNew', {
          callback = function()
            if vim.fn.isdirectory(vim.fn.expand '<afile>') == 1 then
              require('lazy').load { plugins = { 'oil.nvim' } }
              -- Once oil is loaded, we can delete this autocmd
              return true
            end
          end,
        })
      end
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

  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
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
    keys = { 'f', 'F', 't', 'T' },
  },
  {
    'chaoren/vim-wordmotion',
    event = 'VeryLazy',
  },
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
    event = 'VeryLazy',
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
  {
    'tpope/vim-abolish',
    cmd = { 'Subvert', 'Abolish' },
  },
  {
    'ThePrimeagen/refactoring.nvim',
    conf = 'user.plugin.refactoring',
  },
  {
    'matze/vim-move',
    init = function()
      vim.g.move_key_modifier = 'C'
      vim.g.move_key_modifier_visualmode = 'C'
    end,
    keys = {
      { '<C-h>', mode = { 'n', 'v' } },
      { '<C-j>', mode = { 'n', 'v' } },
      { '<C-k>', mode = { 'n', 'v' } },
      { '<C-l>', mode = { 'n', 'v' } },
    },
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
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    conf = 'user.lsp',
    cmd = { 'LspInfo', 'LspStart', 'LspStop', 'LspRestart', 'LspLog' },
    event = 'BufReadPost',
  },
  {
    'stevearc/conform.nvim',
    conf = 'user.plugin.conform',
    event = 'BufWritePre',
  },
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
  {
    'jmbuhr/otter.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    conf = 'user.plugin.otter',
  },
  'nvimtools/none-ls.nvim',
  'b0o/schemastore.nvim',
  'aznhe21/actions-preview.nvim',
  {
    'smjonas/inc-rename.nvim',
    cmd = { 'IncRename' },
    config = true,
  },
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
      'andersevenrud/cmp-tmux',
      'petertriho/cmp-git',
      'hrsh7th/cmp-cmdline',
      { 'dcampos/cmp-emmet-vim', dependencies = 'mattn/emmet-vim' },
      -- Snippets
      {
        'L3MON4D3/LuaSnip',
        -- install jsregexp (optional)
        run = 'make install_jsregexp',
        conf = 'user.plugin.luasnip',
        dependencies = {
          'rafamadriz/friendly-snippets',
          'saadparwaiz1/cmp_luasnip',
        },
      },
    },
  },

  -- Sessions
  {
    'Shatur/neovim-session-manager',
    conf = 'user.plugin.session_manager',
  },

  -- Language-specific
  {
    'aouelete/sway-vim-syntax',
    ft = 'sway',
  },
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

  -- Color
  {
    'KabbAmine/vCoolor.vim',
    conf = { 'vcoolor', nolua = true },
    cmd = { 'VCoolIns', 'VCoolor' },
  },
  {
    'NvChad/nvim-colorizer.lua',
    event = 'BufRead',
    opts = {
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        css = true,
        tailwind = true,
        mode = 'virtualtext',
      },
    },
  },

  --- Vim Plugin Development
  { 'bfredl/nvim-luadev', ft = 'lua' },
  'folke/neodev.nvim',
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
