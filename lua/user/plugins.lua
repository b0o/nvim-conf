local M = {
  telescope_exts = {},
}

local private = require 'user.private'

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
    dev = true,
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
      if (vim.env.COLORSCHEME or 'lavi') == 'lavi' then
        vim.cmd [[colorscheme lavi]]
      end
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    config = function()
      require('tokyonight').setup {
        on_highlights = function(hl, c)
          hl.CmpSel = {
            bg = c.bg_visual,
          }
        end,
      }
      vim.cmd [[colorscheme tokyonight]]
    end,
    cond = function()
      return vim.env.COLORSCHEME == 'tokyonight'
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
    dependencies = {
      'nvim-lualine/lualine.nvim',
    },
  },
  'kyazdani42/nvim-web-devicons',
  -- {
  --   'folke/which-key.nvim',
  --   -- enabled = false,
  --   config = function()
  --     -- Fix compatibility with multiple-cursors.nvim:
  --     local presets = require 'which-key.plugins.presets'
  --     presets.operators['v'] = nil
  --
  --     require('which-key').setup {
  --       plugins = {
  --         spelling = {
  --           enabled = true,
  --           suggestions = 30,
  --         },
  --       },
  --       triggers_blacklist = {
  --         i = { 'j', 'k', "'" },
  --         v = { 'j', 'k', "'" },
  --         n = { "'" },
  --       },
  --       window = {
  --         border = 'rounded',
  --         padding = { 0, 0, 0, 0 },
  --       },
  --       show_help = false,
  --     }
  --   end,
  --   event = 'VeryLazy',
  -- },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'VeryLazy',
    main = 'ibl',
    enabled = true,
    opts = {
      indent = {
        char = '│',
      },
      scope = {
        show_start = false,
        enabled = false,
      },
    },
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
    dependencies = {
      {
        'b0o/nvim-tree-preview.lua',
        dev = true,
      },
      'antosha417/nvim-lsp-file-operations',
    },
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    cmd = 'Neotree',
    conf = 'user.plugin.neo-tree',
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
    end,
    dependencies = {
      'antosha417/nvim-lsp-file-operations',
    },
  },
  {
    'stevearc/oil.nvim',
    conf = 'user.plugin.oil',
    cmd = 'Oil',
    -- If nvim is started with a directory argument, load oil immediately
    -- via https://github.com/folke/lazy.nvim/issues/533
    init = function()
      if vim.fn.argc() == 1 then
        local argv0 = vim.fn.argv(0)
        ---@cast argv0 string
        local stat = vim.loop.fs_stat(argv0)
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
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function()
      local notify = require 'notify'
      notify.setup {
        top_down = false,
        on_open = function(win)
          vim.api.nvim_win_set_config(win, { zindex = 200 })
        end,
      }
      vim.notify = notify
    end,
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    conf = 'user.plugin.noice',
    dependencies = {
      'MunifTanjim/nui.nvim',
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
    event = 'VeryLazy',
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
    'brenton-leighton/multiple-cursors.nvim',
    opts = {},
    cmd = {
      'MultipleCursorsAddDown',
      'MultipleCursorsAddUp',
      'MultipleCursorsMouseAddDelete',
      'MultipleCursorsAddMatches',
      'MultipleCursorsAddMatchesV',
      'MultipleCursorsAddJumpNextMatch',
      'MultipleCursorsJumpNextMatch',
    },
    keys = {
      { '<C-Down>', '<Cmd>MultipleCursorsAddDown<CR>', mode = { 'n', 'i' } },
      { '<C-Up>', '<Cmd>MultipleCursorsAddUp<CR>', mode = { 'n', 'i' } },
      { '<C-LeftMouse>', '<Cmd>MultipleCursorsMouseAddDelete<CR>', mode = { 'n', 'i' } },
      { '<C-n>', '<Cmd>MultipleCursorsAddJumpNextMatch<CR>', mode = { 'n', 'x' } },
      { [[\\A]], '<Cmd>MultipleCursorsAddMatches<CR>', mode = { 'n', 'x' } },
      { '<C-q>', '<Cmd>MultipleCursorsJumpNextMatch<CR>' },
    },
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
    keys = { '<Plug>(dial-increment)', '<Plug>(dial-decrement)' },
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
    event = 'VeryLazy',
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
  },
  {
    'supermaven-inc/supermaven-nvim',
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
    lazy = false,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    --HACK: Load TS config here to speed up startup without lazy-loading TS itself
    conf = 'user.treesitter',
    event = 'VeryLazy',
  },
  'JoosepAlviste/nvim-ts-context-commentstring',
  'Wansmer/sibling-swap.nvim',
  'Wansmer/treesj',
  'windwp/nvim-ts-autotag',

  -- LSP
  {
    'neovim/nvim-lspconfig',
    conf = 'user.lsp',
    cmd = { 'LspInfo', 'LspStart', 'LspStop', 'LspRestart', 'LspLog' },
    event = 'VeryLazy',
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
  'b0o/schemastore.nvim',
  'aznhe21/actions-preview.nvim',
  {
    'smjonas/inc-rename.nvim',
    cmd = { 'IncRename' },
    config = true,
  },
  {
    -- TODO: https://github.com/DNLHC/glance.nvim/pull/67
    'DNLHC/glance.nvim',
    conf = 'user.plugin.glance',
    cmd = 'Glance',
  },
  {
    'pmizio/typescript-tools.nvim',
    conf = 'user.plugin.typescript-tools',
    ft = {
      'typescript',
      'javascript',
      'typescriptreact',
      'javascriptreact',
    },
  },
  {
    'marilari88/twoslash-queries.nvim',
    dev = true,
    opts = { multi_line = true },
    ft = {
      'typescript',
      'javascript',
      'typescriptreact',
      'javascriptreact',
    },
  },
  {
    'folke/trouble.nvim',
    branch = 'dev',
    cmd = { 'Trouble', 'TroubleClose', 'TroubleRefresh', 'TroubleToggle' },
  },

  -- Testing
  {
    'nvim-neotest/neotest',
    conf = 'user.plugin.neotest',
    cmd = { 'Neotest' },
  },
  'marilari88/neotest-vitest',

  -- Git
  {
    'lewis6991/gitsigns.nvim',
    conf = 'user.plugin.gitsigns',
    cmd = { 'Gitsigns' },
    event = 'VeryLazy',
  },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    conf = 'user.plugin.neogit',
    branch = 'nightly',
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
    module = 'cmp',
    event = 'VeryLazy',
    dependencies = {
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'rcarriga/cmp-dap',
      'ray-x/cmp-treesitter',
      'petertriho/cmp-git',
      {
        'dcampos/cmp-emmet-vim',
        dependencies = 'mattn/emmet-vim',
      },
      {
        'L3MON4D3/LuaSnip',
        run = 'make install_jsregexp',
        conf = 'user.plugin.luasnip',
        dependencies = {
          'saadparwaiz1/cmp_luasnip',
        },
      },
    },
  },

  -- Debugging
  {
    'mfussenegger/nvim-dap',
    conf = 'user.dap',
    cmd = {
      'DapContinue',
      'DapLoadLaunchJSON',
      'DapRestartFrame',
      'DapSetLogLevel',
      'DapShowLog',
      'DapStepInto',
      'DapStepOut',
      'DapStepOver',
      'DapTerminate',
      'DapToggleBreakpoint',
      'DapToggleRepl',
    },
  },
  'LiadOz/nvim-dap-repl-highlights',
  'mfussenegger/nvim-dap-python',
  'theHamsta/nvim-dap-virtual-text',

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
  { 'MunifTanjim/nui.nvim', dev = false },
  {
    'b0o/blender.nvim',
    dev = true,
    config = function()
      require('blender').setup {
        notify = {
          verbosity = 'TRACE',
        },
      }
    end,
    cmd = {
      'Blender',
      'BlenderLaunch',
      'BlenderManage',
      'BlenderTest',
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      { 'grapp-dev/nui-components.nvim', dev = false },
      'mfussenegger/nvim-dap',
      'LiadOz/nvim-dap-repl-highlights',
    },
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
    cmd = { 'Colorize' },
  },

  -- Notes
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    event = {
      ('BufReadPre %s/**.md'):format(private.obsidian_vault.path),
      ('BufNewFile %s/**.md'):format(private.obsidian_vault.path),
    },
    conf = 'user.plugin.obsidian',
    cmd = {
      'ObsidianOpen',
      'ObsidianNew',
      'ObsidianQuickSwitch',
      'ObsidianFollowLink',
      'ObsidianBacklinks',
      'ObsidianTags',
      'ObsidianToday',
      'ObsidianYesterday',
      'ObsidianTomorrow',
      'ObsidianDailies',
      'ObsidianTemplate',
      'ObsidianSearch',
      'ObsidianLink',
      'ObsidianLinkNew',
      'ObsidianLinks',
      'ObsidianExtractNote',
      'ObsidianWorkspace',
      'ObsidianPasteImg',
      'ObsidianRename',
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
