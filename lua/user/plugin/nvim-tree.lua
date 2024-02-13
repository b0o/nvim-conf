---- kyazdani42/nvim-tree.lua

local on_attach = function(bufnr)
  local api = require 'nvim-tree.api'

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Personal mappings are in lua/user/mappings.lua
  -- BEGIN_DEFAULT_ON_ATTACH
  vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts 'CD')
  vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts 'Open: In Place')
  vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts 'Info')
  vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts 'Rename: Omit Filename')
  vim.keymap.set('n', '<C-t>', api.node.open.tab, opts 'Open: New Tab')
  vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts 'Open: Vertical Split')
  vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts 'Open: Horizontal Split')
  vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts 'Close Directory')
  vim.keymap.set('n', '<CR>', api.node.open.edit, opts 'Open')
  vim.keymap.set('n', '<Tab>', api.node.open.preview, opts 'Open Preview')
  vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts 'Next Sibling')
  vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts 'Previous Sibling')
  vim.keymap.set('n', '.', api.node.run.cmd, opts 'Run Command')
  vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts 'Up')
  vim.keymap.set('n', 'a', api.fs.create, opts 'Create File Or Directory')
  -- vim.keymap.set('n', 'bd', api.marks.bulk.delete, opts 'Delete Bookmarked')
  vim.keymap.set('n', 'bt', api.marks.bulk.trash, opts 'Trash Bookmarked')
  vim.keymap.set('n', 'bmv', api.marks.bulk.move, opts 'Move Bookmarked')
  vim.keymap.set('n', 'B', api.tree.toggle_no_buffer_filter, opts 'Toggle Filter: No Buffer')
  vim.keymap.set('n', 'c', api.fs.copy.node, opts 'Copy')
  vim.keymap.set('n', 'C', api.tree.toggle_git_clean_filter, opts 'Toggle Filter: Git Clean')
  vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts 'Prev Git')
  vim.keymap.set('n', ']c', api.node.navigate.git.next, opts 'Next Git')
  vim.keymap.set('n', 'd', api.fs.remove, opts 'Delete')
  vim.keymap.set('n', 'D', api.fs.trash, opts 'Trash')
  vim.keymap.set('n', 'E', api.tree.expand_all, opts 'Expand All')
  vim.keymap.set('n', 'e', api.fs.rename_basename, opts 'Rename: Basename')
  vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts 'Next Diagnostic')
  vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts 'Prev Diagnostic')
  vim.keymap.set('n', 'F', api.live_filter.clear, opts 'Live Filter: Clear')
  vim.keymap.set('n', 'f', api.live_filter.start, opts 'Live Filter: Start')
  vim.keymap.set('n', 'g?', api.tree.toggle_help, opts 'Help')
  vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts 'Copy Absolute Path')
  vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts 'Toggle Filter: Dotfiles')
  vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts 'Toggle Filter: Git Ignore')
  vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts 'Last Sibling')
  vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts 'First Sibling')
  vim.keymap.set('n', 'M', api.tree.toggle_no_bookmark_filter, opts 'Toggle Filter: No Bookmark')
  vim.keymap.set('n', 'm', api.marks.toggle, opts 'Toggle Bookmark')
  vim.keymap.set('n', 'o', api.node.open.edit, opts 'Open')
  vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts 'Open: No Window Picker')
  vim.keymap.set('n', 'p', api.fs.paste, opts 'Paste')
  vim.keymap.set('n', 'P', api.node.navigate.parent, opts 'Parent Directory')
  vim.keymap.set('n', 'q', api.tree.close, opts 'Close')
  vim.keymap.set('n', 'r', api.fs.rename, opts 'Rename')
  vim.keymap.set('n', 'R', api.tree.reload, opts 'Refresh')
  vim.keymap.set('n', 's', api.node.run.system, opts 'Run System')
  vim.keymap.set('n', 'S', api.tree.search_node, opts 'Search')
  vim.keymap.set('n', 'u', api.fs.rename_full, opts 'Rename: Full Path')
  vim.keymap.set('n', 'U', api.tree.toggle_custom_filter, opts 'Toggle Filter: Hidden')
  vim.keymap.set('n', 'W', api.tree.collapse_all, opts 'Collapse')
  vim.keymap.set('n', 'x', api.fs.cut, opts 'Cut')
  vim.keymap.set('n', 'y', api.fs.copy.filename, opts 'Copy Name')
  vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts 'Copy Relative Path')
  vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts 'Open')
  vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts 'CD')
  -- END_DEFAULT_ON_ATTACH
end

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
    highlight_git = 'none',
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
  on_attach = on_attach,
}

require('nvim-tree.commands').setup()
