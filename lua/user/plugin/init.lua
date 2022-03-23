-- Generated with:
-- :Put !find lua/user/plugin/ -type f -name '*.lua' | sed "/init\.lua$/d; s|^lua/||; s|/|.|g; s/^/require '/; s/\.lua$/'/" | sort
require 'user.plugin.aerial'
require 'user.plugin.bqf'
require 'user.plugin.comment'
require 'user.plugin.diffview'
require 'user.plugin.dressing'
require 'user.plugin.hlslens'
require 'user.plugin.marks'
require 'user.plugin.neogit'
require 'user.plugin.nvim-tree'
require 'user.plugin.shot-f'
require 'user.plugin.telescope'
require 'user.plugin.tmux'
require 'user.plugin.trouble'
require 'user.plugin.vcoolor'
require 'user.plugin.which-key'

---- lukas-reineke/indent-blankline.nvim
vim.cmd [[highlight link IndentBlanklineSpaceChar Comment]]
require('indent_blankline').setup {
  show_whitespace = true,
  show_end_of_line = true,
  use_treesitter = true,
  buftype_exclude = { 'terminal' },
  filetype_exclude = { 'help' },
}

---- lewis6991/gitsigns.nvim
require('gitsigns').setup {
  on_attach = require('user.mappings').on_gistsigns_attach,
  signs = {
    add = { hl = 'GitSignsAdd', text = '│', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
    change = { hl = 'GitSignsChange', text = '│', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
    delete = { hl = 'GitSignsDelete', text = '_', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    topdelete = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
  },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1,
  },
  yadm = {
    enable = false,
  },
}

---- sindrets/winshift.nvim
require('winshift').setup {
  highlight_moving_win = true, -- Highlight the window being moved
  focused_hl_group = 'Visual', -- The highlight group used for the moving window
  moving_win_options = {
    -- These are local options applied to the moving window while it's
    -- being moved. They are unset when you leave Win-Move mode.
    wrap = false,
    cursorline = false,
    cursorcolumn = false,
    colorcolumn = '',
  },
}

---- matze/vim-move
vim.g.move_key_modifier = 'C'
vim.g.move_key_modifier_visualmode = 'C'

vim.g.matchup_matchparen_offscreen = { method = 'popup' }

---- mbbill/undotree
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_DiffCommand = 'delta'

-- ---- luukvbaal/stabilize.nvim
-- require('stabilize').setup()

-- Shatur/neovim-session-manager
require('session_manager').setup {
  autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
  autosave_last_session = false,
}

-- require('souvenir').setup {
--   session_path = vim.fn.stdpath('data') .. '/souvenirs/'
-- }

---- fatih/vim-go
vim.g.go_doc_keywordprg_enabled = 0

---- mg979/vim-visual-multi
vim.g.VM_custom_motions = {
  ['<M-,>'] = ',', -- Remap , to <M-,> because , conflicts with <localleader>
}

---- ThePrimeagen/git-worktree.nvim
require('git-worktree').setup {
  -- change_directory_command = <str> -- default: "cd",
  -- update_on_change = <boolean> -- default: true,
  -- update_on_change_command = <str> -- default: "e .",
  -- clearjumps_on_change = <boolean> -- default: true,
  -- autopush = <boolean> -- default: false,
}

---- winston0410/range-highlight.nvim
require('range-highlight').setup {}

---- onsails/lspkind-nvim
require('lspkind').init {
  -- defines how annotations are shown
  -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
  -- mode = 'symbol',

  -- default symbol map
  -- can be either 'default' (requires nerd-fonts font) or
  -- 'codicons' for codicon preset (requires vscode-codicons font)
  -- preset = 'default',

  -- override preset symbols
  symbol_map = {
    Type = '',
    --   Text = "",
    --   Method = "",
    --   Function = "",
    --   Constructor = "",
    --   Field = "ﰠ",
    --   Variable = "",
    --   Class = "ﴯ",
    --   Interface = "",
    --   Module = "",
    --   Property = "ﰠ",
    --   Unit = "塞",
    --   Value = "",
    --   Enum = "",
    --   Keyword = "",
    --   Snippet = "",
    --   Color = "",
    --   File = "",
    --   Reference = "",
    --   Folder = "",
    --   EnumMember = "",
    --   Constant = "",
    --   Struct = "פּ",
    --   Event = "",
    --   Operator = "",
    --   TypeParameter = ""
  },
}
