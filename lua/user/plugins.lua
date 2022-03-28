-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer = require 'packer'

local M = {}

M.lazymods = {}
-- lazymods are lazily loaded packages that load a config file inside
-- lua/user/plugin/ on load.
-- Should not be called directly.
local function use_lazymod(p)
  p = vim.deepcopy(p)
  assert(not p.config, "user.plugins.use(): properties 'config' and 'lazymod' are mutually exclusive")

  local lazymod = p.lazymod
  p.lazymod = nil

  local t = type(lazymod)
  assert(
    vim.tbl_contains({ 'boolean', 'string', 'table' }, t),
    "user.plugins.use(): property 'lazymod' should be a boolean, string, or table"
  )

  local short_name = require('packer.util').get_plugin_short_name { p[1] }

  if lazymod == true then
    lazymod = { short_name }
  elseif type(lazymod) == 'string' then
    lazymod = { lazymod }
  end

  if not lazymod.module_pattern and lazymod.mod ~= false then
    local mod_escaped = string.gsub(lazymod.mod or lazymod[1], '[%^%$%(%)%%%.%[%]%*%+%?%-]', '%%%1')
    lazymod.module_pattern = {
      '^' .. mod_escaped .. '$',
      '^' .. mod_escaped .. '%.',
    }
  end

  p.module = lazymod.module or {}
  if type(p.module) == 'string' then
    p.module = { p.module }
  end

  p.module_pattern = lazymod.module_pattern or {}
  if type(p.module_pattern) == 'string' then
    p.module_pattern = { p.module_pattern }
  end

  if #p.module == 0 then
    p.module = nil
  end
  if #p.module_pattern == 0 then
    p.module_pattern = nil
  end

  local _config = p.config -- save the original config function

  p.config = function(name, conf) -- This callback is what will be compiled by packer
    local mod = require('user.plugins').lazymods[name]
    if mod and mod.config then
      mod.config(name, conf, mod)
    end
  end

  M.lazymods[short_name] = {
    plugin = p,
    config = function(...) -- This callback will not be compiled by packer
      pcall(require, 'user.plugin.' .. lazymod[1])
      if _config then
        if type(_config) == 'string' then
          _config = loadstring(_config)
        end
        assert(type(_config) == 'function', "user.plugins.use(): expected 'config' to be a string or function")
        _config(...)
      end
    end,
  }

  return p
end

-- Same as packer.use() but:
-- - merges any extra tables on top of the plugin conf table
-- - truncates uselocal-style semi-relative paths like
--   b0o/mapx.nvim/worktree/current which to allow quickly swapping between use
--   and uselocal
-- - supports lazymods, see use_lazymod above
local function use(p, ...)
  if type(p) ~= 'table' then
    p = { p }
  end
  p = #{ ... } > 0 and vim.tbl_extend('force', p, ...) or p
  if not string.match(p[1], '^.?.?/') then
    local path = vim.split(p[1], '/')
    if #path > 2 then
      p[1] = table.concat(vim.list_slice(path, 1, 2), '/')
    end
  end
  if not p.disable then
    if p.conf then
      assert(not p.config, "user.plugins.use(): options 'config' and 'conf' are mutually exclusive")
      p.config = ("require('user.plugin.%s')"):format(p.conf)
      p.conf = nil
    end
    if p.lazymod then
      p = use_lazymod(p)
    end
  end
  packer.use(p)
end

-- Uselocal uses a plugin found inside $GIT_PROJECTS_DIR with the
-- shortname of the plugin as the subdirectory name. If more than two relative
-- path components are present, the extra ones refer to the path within the
-- plugin directory
-- For example, uselocal{ 'b0o/mapx.nvim/worktree/current' } resolves to
-- $GIT_PROJECTS_DIR/mapx.nvim/worktree/current.
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
  use(p, extend)
end

-- Same as use() but sets {disable=true}
---@diagnostic disable-next-line: unused-local,unused-function
local function xuse(p)
  return use(p, { disable = true })
end

-- Same as uselocal() but sets {disable=true}
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

  -- UI
  use 'Famiu/feline.nvim'
  use 'ericbn/vim-relativize'
  use 'folke/which-key.nvim'
  use { 'kevinhwang91/nvim-hlslens', conf = 'hlslens' }
  use 'kyazdani42/nvim-web-devicons'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'rcarriga/nvim-notify'
  use 'stevearc/dressing.nvim'
  use { 'kyazdani42/nvim-tree.lua', lazymod = 'nvim-tree', cmd = 'NvimTree*' }
  use {
    'simrat39/desktop-notify.nvim',
    setup = [[pcall(vim.cmd, 'delcommand Notifications')]],
    config = [[vim.cmd'command! Notifications :lua require("notify")._print_history()<CR>']],
  }
  use {
    'stevearc/aerial.nvim/worktree/current',
    lazymod = 'aerial',
    module = 'telescope._extensions.aerial',
  }
  use { 'MunifTanjim/nui.nvim', module = 'nui' }
  use { 'winston0410/range-highlight.nvim', requires = 'winston0410/cmd-parser.nvim' }

  -- Telescope
  use { 'kyoh86/telescope-windows.nvim', module = 'telescope._extensions.windows' }
  use { 'nvim-telescope/telescope.nvim', requires = 'nvim-lua/popup.nvim', lazymod = 'telescope' }

  -- Editing
  use 'andymass/vim-matchup'
  use 'b0o/vim-shot-f'
  use 'chaoren/vim-wordmotion'
  use { 'chentau/marks.nvim', conf = 'marks' }
  use 'kana/vim-textobj-fold'
  use 'kana/vim-textobj-indent'
  use 'kana/vim-textobj-line'
  use 'kana/vim-textobj-user'
  use 'matze/vim-move'
  use 'mg979/vim-visual-multi'
  use 'numToStr/Comment.nvim'
  use 'sgur/vim-textobj-parameter'
  use 'tpope/vim-repeat'
  use 'tpope/vim-speeddating'
  use 'tpope/vim-surround'
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
  use { 'kevinhwang91/nvim-bqf', lazymod = 'bqf', event = 'QuickFixCmdPre' }

  -- Backup, Undo
  use 'chrisbra/Recover.vim'
  use { 'mbbill/undotree', cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus' } }

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'romgrk/nvim-treesitter-context'
  use 'nkrkv/nvim-treesitter-rescript'
  use { 'nvim-treesitter/playground', cmd = 'TSPlaygroundToggle' }

  -- LSP
  -- use 'neovim/nvim-lspconfig'
  use 'folke/lsp-colors.nvim'
  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/lsp-status.nvim'
  use 'onsails/lspkind-nvim'
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
  use { 'ThePrimeagen/git-worktree.nvim', lazymod = 'git-worktree' }
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
  use { 'mfussenegger/nvim-dap', module = 'dap' }
  use { 'jbyuki/one-small-step-for-vimkind', module = 'osv' } -- Lua DAP adapter, a.k.a. osv

  -- Window Management
  use 'sindrets/winshift.nvim'
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
  use { 'rktjmp/lush.nvim', cmd = { 'LushRunQuickstart', 'LushRunTutorial', 'Lushify', 'LushImport' }, module = 'lush' }

  -- Performance
  use { 'lewis6991/impatient.nvim', rocks = 'mpack' }
  use 'nathom/filetype.nvim'
  use 'antoinemadec/FixCursorHold.nvim'
end)

packer.use_rocks {
  'base64',
}

return M
