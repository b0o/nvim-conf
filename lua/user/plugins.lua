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
  dev = {
    path = vim.env.GIT_PROJECTS_DIR .. '/nvim',
    fallback = true,
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
  {
    'b0o/lavi.nvim',
    dev = true,
    lazy = false,
    dependencies = { 'rktjmp/lush.nvim' },
    config = function()
      vim.cmd [[colorscheme lavi]]
    end,
  },

  -- UI
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    conf = 'user.plugin.lualine',
  },
  {
    'vimpostor/vim-tpipeline',
    event = 'VeryLazy',
    init = function()
      vim.g.tpipeline_autoembed = 0
      vim.g.tpipeline_statusline = ''
    end,
    config = function()
      vim.cmd.hi { 'link', 'StatusLine', 'WinSeparator' }
      vim.g.tpipeline_statusline = ''
      vim.o.laststatus = 0
      vim.defer_fn(function()
        vim.o.laststatus = 0
      end, 0)
      vim.o.fillchars = 'stl:─,stlnc:─'
      vim.api.nvim_create_autocmd('OptionSet', {
        pattern = 'laststatus',
        callback = function()
          if vim.o.laststatus ~= 0 then
            vim.notify 'Auto-setting laststatus to 0'
            vim.o.laststatus = 0
          end
        end,
      })
    end,
    cond = function()
      return vim.env.TMUX ~= nil
    end,
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
    'b0o/incline.nvim',
    dev = true,
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
    cmd = {
      'AerialClose',
      'AerialCloseAll',
      'AerialGo',
      'AerialInfo',
      'AerialNavClose',
      'AerialNavOpen',
      'AerialNavToggle',
      'AerialNext',
      'AerialOpen',
      'AerialOpenAll',
      'AerialPrev',
      'AerialToggle',
    },
  },
  {
    'stevearc/dressing.nvim',
    opts = {},
    event = 'VeryLazy',
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
      {
        'rcarriga/nvim-notify',
        opts = {
          top_down = false,
          on_open = function(win)
            vim.api.nvim_win_set_config(win, { zindex = 200 })
          end,
        },
      },
    },
  },

  -- Window/Buffer/Tab Management
  {
    'sindrets/winshift.nvim',
    cmd = 'WinShift',
    conf = 'user.plugin.winshift',
  },
  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
  },
  {
    'famiu/bufdelete.nvim',
    config = function()
      local command = require('user.util.command').command
      command { 'Bd', ':Bdelete' }
    end,
    cmd = { 'Bdelete', 'Bd' },
  },

  -- Terminal/External Commands
  {
    'akinsho/nvim-toggleterm.lua',
    conf = 'user.plugin.toggleterm',
    cmd = 'ToggleTerm',
  },
  {
    'stevearc/overseer.nvim',
    conf = 'user.plugin.overseer',
    cmd = {
      'OverseerOpen',
      'OverseerClose',
      'OverseerToggle',
      'OverseerSaveBundle',
      'OverseerLoadBundle',
      'OverseerDeleteBundle',
      'OverseerRunCmd',
      'OverseerRun',
      'OverseerInfo',
      'OverseerBuild',
      'OverseerQuickAction',
      'OverseerTaskAction',
      'OverseerClearCache',
    },
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
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      labels = "fjdghksla;eiworuqpcnxmz,vbty'",
      search = {},
      jump = {
        autojump = true,
      },
      label = {
        uppercase = false,
      },
      modes = {
        treesitter = {
          labels = 'abcdefghijklmnopqrstuvwxyz',
          label = {
            uppercase = false,
            rainbow = {
              enabled = true,
              shade = 3,
            },
          },
        },
        treesitter_search = {
          labels = 'abcdefghijklmnopqrstuvwxyz',
          label = {
            uppercase = false,
            rainbow = {
              enabled = true,
              shade = 3,
            },
          },
        },
        char = {
          keys = { 'f', 'F', 't', 'T', [';'] = '<Tab>', [','] = '<S-Tab>' },
        },
      },
    },
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
    init = function()
      vim.g.VM_custom_motions = {
        ['<M-,>'] = ',', -- Remap , to <M-,> because , conflicts with <localleader>
      }
    end,
    setup = function()
      vim.cmd [[VMClear]]
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
    'folke/todo-comments.nvim',
    event = 'BufRead',
    opts = {
      keywords = {
        TEST = { icon = ' ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING' } },
        XXX = { icon = ' ', color = 'error' },
      },
      highlight = {
        pattern = { [[.*<(KEYWORDS)\s*(\(.+\))?\s*:]] },
        -- TODO: use 'wide' when https://github.com/folke/todo-comments.nvim/issues/10 is fixed
        keyword = 'fg',
        after = 'fg',
      },
      search = {
        pattern = [[\b(KEYWORDS)(\(.*\))?:]], -- ripgrep regex
      },
    },
    telescope_ext = 'todo-comments',
  },

  -- AI
  {
    'zbirenbaum/copilot.lua',
    conf = 'user.plugin.copilot',
    event = 'VeryLazy',
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
    lazy = false,
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
          Copilot = '',
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
    -- TODO: https://github.com/DNLHC/glance.nvim/pull/67
    -- 'DNLHC/glance.nvim',
    'b0o/glance.nvim',
    branch = 'jump-opts',
    conf = 'user.plugin.glance',
    cmd = 'Glance',
  },
  {
    'pmizio/typescript-tools.nvim',
    enabled = true,
    conf = 'user.plugin.typescript-tools',
    ft = {
      'typescript',
      'javascript',
      'typescriptreact',
      'javascriptreact',
    },
    dependencies = {
      {
        'marilari88/twoslash-queries.nvim',
        dev = true,
        opts = { multi_line = true },
      },
    },
  },
  {
    'folke/trouble.nvim',
    opts = {
      auto_open = false,
      auto_close = false,
      auto_preview = false,
      use_diagnostic_signs = true,
    },
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
    event = { 'VeryLazy' },
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
    'rgroli/other.nvim',
    cmd = { 'Other', 'OtherTabNew', 'OtherSplit', 'OtherVSplit' },
    conf = 'user.plugin.other',
  },

  -- Color
  {
    'KabbAmine/vCoolor.vim',
    conf = { 'vcoolor', nolua = true },
    cmd = { 'VCoolIns', 'VCoolor' },
  },
  {
    'uga-rosa/ccc.nvim',
    conf = 'user.plugin.ccc',
    cmd = { 'CccPick' },
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

  -- Misc
  {
    '2kabhishek/nerdy.nvim',
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-telescope/telescope.nvim',
    },
    cmd = 'Nerdy',
  },

  --- Vim Plugin Development
  { 'bfredl/nvim-luadev', ft = 'lua' },
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
