local fn = require 'user.fn'

---- AndrewRadev/splitjoin.vim
vim.g.splitjoin_join_mapping = ''
vim.g.splitjoin_split_mapping = ''

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

---- andymass/vim-matchup
vim.g.matchup_matchparen_offscreen = { method = 'popup' }
vim.g.matchup_matchparen_deferred = 1
vim.g.matchup_matchparen_deferred_show_delay = 40

---- mbbill/undotree
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_DiffCommand = 'delta'

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

vim.g.shot_f_highlight_graph = string.format(
  'cterm=bold ctermbg=NONE ctermfg=%s gui=underline guibg=NONE guifg=%s',
  shotf_cterm,
  shotf_gui
)

vim.g.shot_f_highlight_blank = string.format(
  'cterm=bold ctermbg=%s ctermfg=NONE guibg=%s guifg=NONE',
  shotf_cterm,
  shotf_gui
)

---- luukvbaal/stabilize.nvim
require('stabilize').setup()

---- lewis6991/spellsitter.nvim
-- require('spellsitter').setup()
