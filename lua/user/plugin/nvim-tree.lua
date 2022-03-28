---- kyazdani42/nvim-tree.lua
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_highlight_opened_files = 1
vim.g.nvim_tree_add_trailing = 1
vim.g.nvim_tree_group_empty = 1
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
  lsp = vim.tbl_map(vim.fn.trim, require('user.lsp').signs),
  -- view = {
  --   mappings = {
  --     custom_only = true,
  --   },
  -- },
}
_G.nvim_tree_highlights = function()
  local colors_gui = vim.g.colors_gui or {}
  for hi, c in
    pairs {
      NvimTreeGitDirty = colors_gui['13'] or 'yellow',
      NvimTreeGitStaged = colors_gui['14'] or 'lightgreen',
      NvimTreeGitMerge = colors_gui['16'] or 'magenta',
      NvimTreeGitRenamed = colors_gui['17'] or 'orange',
      NvimTreeGitNew = colors_gui['8'] or 'cyan',
      NvimTreeGitDeleted = colors_gui['12'] or 'lightred',
    }
  do
    vim.cmd(('highlight %s guifg=%s'):format(hi, c))
  end
end

require('nvim-tree').setup {
  auto_close = true,
  open_on_tab = true,
  hijack_cursor = true,
  update_cwd = true,
  diagnostics = {
    enable = true,
  },
  auto_resize = false,
  update_focused_file = {
    enable = true,
  },
  system_open = {
    cmd = 'xdg-open',
  },
  filters = {
    custom = { '.git', 'node_modules', '.cache' },
  },
}
