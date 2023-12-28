---- kyazdani42/nvim-tree.lua
-- vim.g.nvim_tree_indent_markers = 1
-- vim.g.nvim_tree_git_hl = 1
-- vim.g.nvim_tree_highlight_opened_files = 1
-- vim.g.nvim_tree_add_trailing = 1
-- vim.g.nvim_tree_group_empty = 1
-- vim.g.nvim_tree_respect_buf_cwd = 1
vim.g.nvim_tree_refresh_wait = 500
-- vim.g.nvim_tree_icons =

require('nvim-tree').setup {
  actions = {
    open_file = {
      window_picker = {
        enable = true,
        picker = require('window-picker').pick_window,
      },
    },
  },
  open_on_tab = true,
  hijack_cursor = true,
  update_cwd = true,
  respect_buf_cwd = true,
  diagnostics = {
    enable = true,
    icons = { error = '', warning = '', hint = '', info = '' },
  },
  update_focused_file = {
    enable = true,
  },
  system_open = {
    cmd = 'xdg-open',
  },
  filters = {
    custom = { '.git', 'node_modules', '.cache', '.vscode' },
    exclude = { '[.]env', '[.]env[.].*' },
  },
  renderer = {
    indent_markers = { enable = true },
    highlight_git = true,
    highlight_opened_files = 'all',
    add_trailing = true,
    group_empty = true,
    icons = {
      git_placement = 'after',
      glyphs = {
        default = '',
        symlink = '',
        git = {
          deleted = '',
          ignored = '◌',
          renamed = '➜',
          staged = '+',
          unmerged = '',
          unstaged = 'ϟ',
          untracked = '?',
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
      },
    },
  },
  view = {
    adaptive_size = false,
  },
}

require('nvim-tree.commands').setup()
