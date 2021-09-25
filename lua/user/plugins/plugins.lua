---- lukas-reineke/indent-blankline.nvim
vim.cmd [[highlight link IndentBlanklineSpaceChar Comment]]
vim.g.indent_blankline_show_whitespace = true
vim.g.indent_blankline_show_end_of_line = true
require('indent_blankline').setup {
  buftype_exclude = { 'terminal' },
}

---- lewis6991/gitsigns.nvim
require('gitsigns').setup {}

---- nvim-telescope/telescope.nvim
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

vim.g.matchup_matchparen_offscreen = { method = 'popup' }

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
local shotf_gui = '#7CFFE4'
vim.g.shot_f_highlight_graph = table.concat({
  'cterm=bold',
  'ctermbg=NONE',
  'ctermfg=' .. shotf_cterm,
  'gui=underline',
  'guibg=NONE',
  'guifg=' .. shotf_gui,
}, ' ')
vim.g.shot_f_highlight_blank = table.concat({
  'cterm=bold',
  'ctermbg=' .. shotf_cterm,
  'ctermfg=NONE',
  'gui=underline',
  'guibg=' .. shotf_gui,
  'guifg=NONE',
}, ' ')

---- KabbAmine/vCoolor.vim
vim.g.vcoolor_lowercase = 0
vim.g.vcoolor_disable_mappings = 1
-- Use yad as the color picker (Linux)
if vim.fn.has 'unix' then
  vim.g.vcoolor_custom_picker = table.concat({
    'yad',
    '--title="Color Picker"',
    '--color',
    '--splash',
    '--on-top',
    '--skip-taskbar',
    '--init-color=',
  }, ' ')
end

---- kyazdani42/nvim-tree.lua
vim.g.nvim_tree_auto_init = 0
vim.g.nvim_tree_ignore = { '.git', 'node_modules', '.cache' }
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_highlight_opened_files = 1
vim.g.nvim_tree_tab_open = 1
vim.g.nvim_tree_auto_resize = 0
vim.g.nvim_tree_add_trailing = 1
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_lsp_diagnostics = 1
vim.g.nvim_tree_update_cwd = 1
vim.g.nvim_tree_respect_buf_cwd = 1
vim.g.nvim_tree_refresh_wait = 500
vim.g.nvim_tree_icons = {
  default = '',
  symlink = '',
  git = {
    unstaged = 'ϟ',
    staged = '+',
    unmerged = '',
    renamed = '➜',
    untracked = '?',
    deleted = '',
    ignored = '◌',
  },
  folder = {
    arrow_open = '',
    arrow_closed = '',
    default = '',
    open = '',
    empty = '',
    empty_open = '',
    symlink = '',
    symlink_open = '',
  },
  lsp = {
    hint = '',
    info = '',
    warning = '',
    error = '',
  },
}
_G.nvim_tree_highlights = function()
  local colors_gui = vim.g.colors_gui or {}
  for hi, c in pairs {
    NvimTreeGitDirty = colors_gui['13'] or 'yellow',
    NvimTreeGitStaged = colors_gui['14'] or 'lightgreen',
    NvimTreeGitMerge = colors_gui['16'] or 'magenta',
    NvimTreeGitRenamed = colors_gui['17'] or 'orange',
    NvimTreeGitNew = colors_gui['8'] or 'cyan',
    NvimTreeGitDeleted = colors_gui['12'] or 'lightred',
  } do
    vim.cmd(('highlight %s guifg=%s'):format(hi, c))
  end
end
