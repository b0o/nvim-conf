-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use 'tpope/vim-fugitive' -- Git commands in nvim
  use 'tpope/vim-rhubarb' -- Fugitive-companion to interact with github
  use 'tpope/vim-commentary' -- "gc" to comment visual regions/lines
  use 'ludovicchabant/vim-gutentags' -- Automatic tags management
  -- UI to select things (files, grep results, open buffers...)
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      { 'nvim-lua/popup.nvim' },
      { 'nvim-lua/plenary.nvim' },
    }
  }
  use 'joshdick/onedark.vim' -- Theme inspired by Atom
  use 'itchyny/lightline.vim' -- Fancier statusline
  -- Add indentation guides even on blank lines
  -- XXX: https://github.com/lukas-reineke/indent-blankline.nvim/issues/74
  -- use 'lukas-reineke/indent-blankline.nvim'
  -- Add git related info in the signs columns and popups
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'hrsh7th/nvim-compe' -- Autocompletion plugin
  use 'L3MON4D3/LuaSnip' -- Snippets plugin

  --- Migrate
  use 'chriskempson/base16-vim'
  use 'christoomey/vim-tmux-navigator'
  use 'wesQ3/vim-windowswap'
  use 'chaoren/vim-wordmotion'
  use 'mg979/vim-visual-multi'
  use 'kana/vim-textobj-user'
  use 'kana/vim-textobj-line'
  use 'kana/vim-textobj-fold'
  use 'kana/vim-textobj-indent'
  use 'coderifous/textobj-word-column.vim'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use 'tpope/vim-abolish'
  use 'tpope/vim-speeddating'
  use 'AndrewRadev/splitjoin.vim'
  use 'matze/vim-move'
  use 'andymass/vim-matchup'
  use 'b0o/vim-shot-f'
  use 'triglav/vim-visual-increment'
  use 'terryma/vim-expand-region'
  use 'wellle/visual-split.vim'
  use 'mbbill/undotree'
  use 'godlygeek/tabular'
  use 'gpanders/editorconfig.nvim'
  use 'christoomey/vim-conflicted'
  use 'b0o/shellcheck-extras.vim'
  use 'liuchengxu/vista.vim'
  use 'rescript-lang/vim-rescript'
  use 'Akin909/vim-dune'
  use 'mboughaba/i3config.vim'
  use 'alx741/vinfo'
  use 'KabbAmine/vCoolor.vim'
  use {
    'rrethy/vim-hexokinase',
    run = 'make hexokinase'
  }
  use 'chrisbra/Recover.vim'
  use {
    'mattn/gist-vim',
    requires = 'mattn/webapi-vim'
  }
  use 'tpope/vim-eunuch'
  use 'folke/which-key.nvim'

  local git_projects_dir = os.getenv('GIT_PROJECTS_DIR')
  if git_projects_dir ~= nil then
    use { git_projects_dir .. '/vim-man' }
    use { git_projects_dir .. '/extended-scrolloff.vim' }
    use { git_projects_dir .. '/mapx.lua' }
    use { git_projects_dir .. '/vim-buffest' }
  end
  --- /Migrate

  --- New
  use 'ericbn/vim-relativize'
  use { 'lewis6991/impatient.nvim', rocks = 'mpack' }
  --- /New
end)

--Set statusbar
vim.g.lightline = {
  -- colorscheme = 'onedark', -- TODO
  active = { left = { { 'mode', 'paste' }, { 'gitbranch', 'readonly', 'filename', 'modified' } } },
  component_function = { gitbranch = 'fugitive#head' },
}

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { hl = 'GitGutterAdd', text = '+' },
    change = { hl = 'GitGutterChange', text = '~' },
    delete = { hl = 'GitGutterDelete', text = '_' },
    topdelete = { hl = 'GitGutterDelete', text = '‾' },
    changedelete = { hl = 'GitGutterChange', text = '~' },
  },
}

-- Telescope
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

-- LSP settings
local lsp = require'lspconfig'
local on_attach = function(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  _G.nvim_lsp_mapfn(bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Enable the following language servers
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
for _, server in ipairs(servers) do
  lsp[server].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- Lua language server
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lsp.sumneko_lua.setup {
  cmd = {
    '/usr/lib/lua-language-server/lua-language-server',
    '-E', '/usr/share/lua-language-server/main.lua',
    '--logpath="' .. vim.fn.stdpath('cache') .. '/lua-language-server/log"',
    '--metapath="' .. vim.fn.stdpath('cache') .. '/lua-language-server/meta"',
  },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          'vim',
          -- mapx.lua:
          'map', 'nmap', 'vmap', 'xmap', 'smap', 'omap', 'imap', 'lmap', 'cmap', 'tmap',
          'noremap', 'nnoremap', 'vnoremap', 'xnoremap', 'snoremap', 'onoremap',
          'inoremap', 'lnoremap', 'cnoremap', 'tnoremap', 'mapbang', 'noremapbang',
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
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

---- Use (s-)tab to:
-- move to prev/next item in completion menuone
-- jump to prev/next snippet's placeholder

------ Migrate
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
      suggestions = 20,
    },
  },
}

---- b0o/vim-shot-f
local shotf_cterm = 'lightcyan'
local shotf_gui   = '#7CFFE4'
vim.g.shot_f_highlight_graph = 'ctermfg=' .. shotf_cterm .. ' ctermbg=NONE cterm=bold guifg=' .. shotf_gui .. ' guibg=NONE gui=underline'
vim.g.shot_f_highlight_blank = 'ctermfg=NONE ctermbg=' .. shotf_cterm .. ' cterm=NONE guifg=NONE guibg=' .. shotf_gui .. ' gui=underline'

---- KabbAmine/vCoolor.vim
vim.g.vcoolor_lowercase = 0
vim.g.vcoolor_disable_mappings = 1

-- Use yad as the color picker (Linux)
vim.g.vcoolor_custom_picker = 'yad --title="Color Picker" --color --splash --on-top --skip-taskbar --init-color='

----- /Migrate

----- Added
----- /Added
