---- lukas-reineke/indent-blankline.nvim
vim.cmd [[highlight link IndentBlanklineSpaceChar Comment]]
vim.g.indent_blankline_show_whitespace = true
vim.g.indent_blankline_show_end_of_line = true
require('indent_blankline').setup {
  buftype_exclude = { 'terminal' },
}

---- lewis6991/gitsigns.nvim
require('gitsigns').setup {}

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
vim.g.tmux_navigator_preserve_zoom = 1

---- mbbill/undotree
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_DiffCommand = 'delta'

-- luukvbaal/stabilize.nvim
require('stabilize').setup()

-- Shatur/neovim-session-manager
require('session_manager').setup {
  -- Automatically load last session on startup is started without arguments.
  autoload_last_session = false,
  -- Automatically save last session on exit.
  autosave_last_session = false,
}

-- require('souvenir').setup {
--   session_path = vim.fn.stdpath('data') .. '/souvenirs/'
-- }
