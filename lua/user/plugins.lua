-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer = require('packer')
local use = packer.use

local function uselocal(p, ...)
  local git_projects_dir = os.getenv('GIT_PROJECTS_DIR')
  if git_projects_dir ~= nil then
    use { git_projects_dir .. '/' .. p, ... }
  end
end

packer.init({
  max_jobs = tonumber(vim.fn.system("nproc")) or 8,
})

packer.startup(function()
   -- Package management
  use 'wbthomason/packer.nvim'

  -- Config
  uselocal 'mapx.nvim'

  -- UI
  use 'Famiu/feline.nvim'
  use 'kyazdani42/nvim-web-devicons'
  -- use 'itchyny/lightline.vim'
  use 'chriskempson/base16-vim'
  use 'ericbn/vim-relativize'
  use 'folke/which-key.nvim'
  use 'joshdick/onedark.vim'
  use 'liuchengxu/vista.vim'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim' }
  }
  -- XXX: https://github.com/lukas-reineke/indent-blankline.nvim/issues/74
  -- use 'lukas-reineke/indent-blankline.nvim'

  -- Editing
  use 'AndrewRadev/splitjoin.vim'
  use 'andymass/vim-matchup'
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
  use 'sgur/vim-textobj-parameter'
  use 'terryma/vim-expand-region'
  use 'tpope/vim-abolish'
  use 'tpope/vim-commentary'
  use 'tpope/vim-repeat'
  use 'tpope/vim-speeddating'
  use 'tpope/vim-surround'
  use 'triglav/vim-visual-increment'
  use 'wellle/visual-split.vim'
  -- uselocal 'extended-scrolloff.vim'
  uselocal 'vim-buffest'

  -- Backup, Undo
  use 'chrisbra/Recover.vim'
  use 'mbbill/undotree'

  -- Treesitter
  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'folke/lsp-colors.nvim'
  use 'folke/trouble.nvim'
  use 'nvim-lua/lsp-status.nvim'
  use 'glepnir/lspsaga.nvim'

  -- Code Style, Formatting, Linting
  use 'editorconfig/editorconfig-vim'
  use 'b0o/shellcheck-extras.vim'

  -- Git
  use 'christoomey/vim-conflicted'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  use { 'lewis6991/gitsigns.nvim', requires = 'nvim-lua/plenary.nvim' }
  use { 'mattn/gist-vim', requires = 'mattn/webapi-vim' }

  -- System
  use 'tpope/vim-eunuch'

  -- Tooling
  use 'ludovicchabant/vim-gutentags'

  -- Code Completion
  use 'L3MON4D3/LuaSnip'
  use 'hrsh7th/nvim-compe'

  -- Window Movement and Management
  use 'christoomey/vim-tmux-navigator'
  use 'wesQ3/vim-windowswap'

  -- Language-specific
  use 'Akin909/vim-dune'
  use 'mboughaba/i3config.vim'
  use 'rescript-lang/vim-rescript'

  -- Documentation
  use 'alx741/vinfo'
  uselocal 'vim-man'

  -- Color
  use 'KabbAmine/vCoolor.vim'
  use { 'rrethy/vim-hexokinase', run = 'make hexokinase' }

  --- Vim Plugin Development
  use 'bfredl/nvim-luadev'

  -- Misc
  use { 'lewis6991/impatient.nvim', rocks = 'mpack' }

  -- Local
end)

-- itchyny/lightline.vim
-- vim.g.lightline = {
--   -- colorscheme = 'onedark', -- TODO
--   active = { left = { { 'mode', 'paste' }, { 'gitbranch', 'readonly', 'filename', 'modified' } } },
--   component_function = { gitbranch = 'fugitive#head' },
-- }

-- Famiu/feline.nvim
-- require('feline').setup {}

-- lewis6991/gitsigns.nvim
require('gitsigns').setup {}

-- nvim-telescope/telescope.nvim
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-d>'] = false,
        ['<C-u>'] = false,
        ['<M-n>'] = require('telescope.actions').cycle_history_next,
        ['<M-p>'] = require('telescope.actions').cycle_history_next,
      },
    },
  },
}

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Compe setup
require('compe').setup {
  source = {
    path = true,
    nvim_lsp = true,
    luasnip = true,
    buffer = false,
    calc = false,
    nvim_lua = false,
    vsnip = false,
    ultisnips = false,
  },
}

-- Utility functions for compe and luasnip
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col '.' - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' then
    return true
  else
    return false
  end
end

---- b0o/vim-man
-- prevent /usr/share/nvim/runtime/plugin/man.vim from initializing
vim.g.loaded_man = 1

-- disable default man.vim and vim-man mappings
vim.g.no_man_maps = 1
vim.g.vim_man_no_maps = 1

---- wesQ3/vim-windowswap
vim.g.windowswap_map_keys = 0

---- matze/vim-move
vim.g.move_key_modifier = 'C'

vim.g.matchup_matchparen_offscreen = { method = "popup" }

---- christoomey/vim-tmux-navigator
vim.g.tmux_navigator_no_mappings = 1

---- mbbill/undotree
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_DiffCommand = 'delta'

---- folke/which-key.nvim
require('which-key').setup {
  plugins = {
    spelling = {
      enabled = true,
      suggestions = 30,
    },
  },
}

---- b0o/vim-shot-f
local shotf_cterm = 'lightcyan'
local shotf_gui   = '#7CFFE4'
vim.g.shot_f_highlight_graph = table.concat({
  'cterm=bold',
  'ctermbg=NONE',
  'ctermfg=' .. shotf_cterm,
  'gui=underline',
  'guibg=NONE',
  'guifg=' .. shotf_gui,
}, " ")
vim.g.shot_f_highlight_blank = table.concat({
  'cterm=bold',
  'ctermbg=' .. shotf_cterm,
  'ctermfg=NONE',
  'gui=underline',
  'guibg=' .. shotf_gui,
  'guifg=NONE',
}, " ")

---- KabbAmine/vCoolor.vim
vim.g.vcoolor_lowercase = 0
vim.g.vcoolor_disable_mappings = 1
-- Use yad as the color picker (Linux)
if vim.fn.has('unix') then
  vim.g.vcoolor_custom_picker = table.concat({
    'yad',
    '-title="Color Picker" --color', '-splash', '-on-top',
    '-skip-taskbar', '-init-color='
  }, " ")
end
