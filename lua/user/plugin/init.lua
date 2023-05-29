local fn = require 'user.fn'
local colors = require 'user.colors'
local mappings = require 'user.mappings'

---- AndrewRadev/splitjoin.vim
-- vim.g.splitjoin_join_mapping = ''
-- vim.g.splitjoin_split_mapping = ''

---- lukas-reineke/indent-blankline.nvim
require('indent_blankline').setup {
  show_whitespace = true,
  strict_tabs = true,
  use_treesitter = false,
  show_current_context = false,
}
fn.tmpl_hi [[
  hi link IndentBlanklineSpaceChar Comment
  hi IndentBlanklineContextChar guifg=${mid_velvet} gui=nocombine
]]

---- lewis6991/gitsigns.nvim
require('gitsigns').setup {
  on_attach = require('user.mappings').on_gistsigns_attach,
  signs = {
    add = { hl = 'GitSignsAdd', text = '│', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
    change = { hl = 'GitSignsChange', text = '│', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
    delete = { hl = 'GitSignsDelete', text = '_', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    topdelete = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
    untracked = { hl = 'GitSignsAdd', text = '┆', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
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

---- andymass/vim-matchup
vim.g.matchup_matchparen_offscreen = { method = 'popup' }
vim.g.matchup_matchparen_deferred = 1
vim.g.matchup_matchparen_deferred_show_delay = 40

---- mbbill/undotree
vim.g.undotree_SetFocusWhenToggle = 1

---- fatih/vim-go
vim.g.go_doc_keywordprg_enabled = 0

---- mg979/vim-visual-multi
vim.g.VM_custom_motions = {
  ['<M-,>'] = ',', -- Remap , to <M-,> because , conflicts with <localleader>
}

---- winston0410/range-highlight.nvim
require('range-highlight').setup {}

---- onsails/lspkind-nvim
require('lspkind').init {
  symbol_map = {
    Type = '',
  },
}

---- folke/which-key.nvim
require('which-key').setup {
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
}

---- stevearc/dressing.nvim
require('dressing').setup {
  select = {
    backend = { 'telescope', 'fzf_lua', 'fzf', 'builtin', 'nui' },
  },
}

---- b0o/vim-shot-f
local shotf_cterm = 'lightcyan'
local shotf_gui = '#7CFFE4'

vim.g.shot_f_highlight_graph =
  string.format('cterm=bold ctermbg=NONE ctermfg=%s gui=underline guibg=NONE guifg=%s', shotf_cterm, shotf_gui)

vim.g.shot_f_highlight_blank =
  string.format('cterm=bold ctermbg=%s ctermfg=NONE guibg=%s guifg=NONE', shotf_cterm, shotf_gui)

---- smjonas/live-command.nvim
require('live-command').setup {
  commands = {
    Norm = { cmd = 'norm' },
    S = { cmd = 'Subvert' },
  },
}

---- lewis6991/spellsitter.nvim
-- require('spellsitter').setup()

-- Do not source the default filetype.vim
vim.g.did_load_filetypes = 1

---- github/copilot.vim
-- imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
-- vim.g.copilot_no_tab_map = true

---- monaqa/dial.nvim
local augend = require 'dial.augend'
require('dial.config').augends:register_group {
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.constant.new {
      elements = { 'false', 'true' },
      cyclic = false,
    },
    augend.constant.new {
      elements = { 'False', 'True' },
      cyclic = false,
    },
    augend.constant.alias.alpha,
    augend.constant.alias.Alpha,
    augend.semver.alias.semver,
    augend.date.alias['%Y/%m/%d'],
    augend.date.alias['%m/%d/%Y'],
    augend.date.alias['%d/%m/%Y'],
    augend.date.alias['%m/%d/%y'],
    augend.date.alias['%m/%d'],
    augend.date.alias['%Y-%m-%d'],
    augend.date.alias['%H:%M:%S'],
    augend.date.alias['%H:%M'],
    augend.constant.new {
      elements = { 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun' },
      word = true,
      cyclic = true,
    },
    augend.constant.new {
      elements = { 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' },
      word = true,
      cyclic = true,
    },
  },
}

---- jinh0/eyeliner.nvim
require('eyeliner').setup {
  highlight_on_key = true,
}
vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg = colors.cyan, bold = true, underline = true })
vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg = colors.yellow, bold = true, underline = true })

---- chrisgrieser/nvim-recorder
require('recorder').setup {
  -- Named registers where macros are saved. The first register is the default
  -- register/macro-slot used after startup.
  slots = { 'a', 'b', 'c', 'd' },

  -- default keymaps, see README for description what the commands do
  mapping = {
    startStopRecording = mappings.xk [[<C-M-S-q>]],
    playMacro = mappings.xk [[<C-M-q>]],
    switchSlot = '<C-q>',
    editMacro = 'cq',
    yankMacro = 'yq', -- also decodes it for turning macros to mappings
    addBreakPoint = '##', -- ⚠️ this should be a string you don't use in insert mode during a macro
  },

  -- clears all macros-slots on startup
  clear = false,

  -- log level used for any notification, mostly relevant for nvim-notify
  -- (note that by default, nvim-notify does not show the levels trace and debug.)
  logLevel = vim.log.levels.INFO,

  -- experimental, see README
  dapSharedKeymaps = false,
}

---- Wansmer/treesj
require('treesj').setup {
  -- Use default keymaps
  -- (<space>m - toggle, <space>j - join, <space>s - split)
  use_default_keymaps = false,

  -- Node with syntax error will not be formatted
  check_syntax_error = true,

  -- If line after join will be longer than max value,
  -- node will not be formatted
  max_join_length = 120,

  -- hold|start|end:
  -- hold - cursor follows the node/place on which it was called
  -- start - cursor jumps to the first symbol of the node being formatted
  -- end - cursor jumps to the last symbol of the node being formatted
  cursor_behavior = 'hold',

  -- Notify about possible problems or not
  notify = true,
  langs = { --[[ configuration for languages ]]
  },

  -- Use `dot` for repeat action
  dot_repeat = true,
}
