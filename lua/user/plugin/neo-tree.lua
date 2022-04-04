---- nvim-neo-tree/neo-tree.nvim
require('neo-tree').setup {
  close_if_last_window = true,
  popup_border_style = 'rounded',
  enable_git_status = true,
  enable_diagnostics = true,
  default_component_configs = {
    indent = {
      indent_size = 2,
      padding = 1, -- extra padding on left hand side
      -- indent guides
      with_markers = true,
      indent_marker = '│',
      last_indent_marker = '└',
      highlight = 'NeoTreeIndentMarker',
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = '',
      expander_expanded = '',
      expander_highlight = 'NeoTreeExpander',
    },
    icon = {
      folder_closed = '',
      folder_open = '',
      folder_empty = '',
      default = '',
    },
    modified = {
      symbol = '',
      highlight = 'NeoTreeModified',
    },
    name = {
      trailing_slash = true,
      use_git_status_colors = true,
    },
    git_status = {
      symbols = {
        -- Change type
        added = '', -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified = '', -- or "", but this is redundant info if you use git_status_colors on the name
        deleted = '', -- this can only be used in the git_status source
        ignored = '◌',
        renamed = '➜', -- this can only be used in the git_status source
        staged = '+',
        unstaged = 'ϟ',
        untracked = '?',
        conflict = '',
      },
    },
  },
  window = {
    position = 'left',
    width = 30,
    mappings = {
      ['<Tab>'] = 'toggle_node',
      ['<2-LeftMouse>'] = 'open',
      ['<Cr>'] = 'open',
      ['<C-x>'] = 'open_split',
      ['<C-v>'] = 'open_vsplit',
      ['<C-t>'] = 'open_tabnew',
      --['C'] = 'close_node',
      --['<Bs>'] = 'navigate_up',
      --['.'] = 'set_root',
      ['<C-h>'] = 'toggle_hidden',
      ['R'] = 'refresh',
      ['/'] = 'fuzzy_finder',
      ['f'] = 'filter_on_submit',
      ['<C-l>'] = 'clear_filter',
      ['a'] = 'add',
      ['A'] = 'add_directory',
      ['d'] = 'delete',
      ['r'] = 'rename',
      ['y'] = 'copy_to_clipboard',
      ['x'] = 'cut_to_clipboard',
      ['p'] = 'paste_from_clipboard',
      ['c'] = 'copy', -- takes text input for destination
      ['m'] = 'move', -- takes text input for destination
      ['q'] = 'close_window',
    },
  },
  nesting_rules = {},
  filesystem = {
    window = {
      mappings = {
        ['H'] = 'toggle_hidden',
        ['/'] = 'fuzzy_finder',
        ['f'] = 'filter_on_submit',
        ['<C-l>'] = 'clear_filter',
        ['<Bs>'] = 'navigate_up',
        ['.'] = 'set_root',
        ['<C-x>'] = 'open_split',
      },
    },
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = true,
      hide_gitignored = true,
      hide_by_name = {
        '.DS_Store',
        'thumbs.db',
        --"node_modules"
      },
      never_show = { -- remains hidden even if visible is toggled to true
        --".DS_Store",
        --"thumbs.db"
      },
    },
    follow_current_file = true, -- This will find and focus the file in the active buffer every
    -- time the current file is changed while the tree is open.
    hijack_netrw_behavior = 'open_default', -- netrw disabled, opening a directory opens neo-tree
    -- in whatever position is specified in window.position
    -- "open_current",  -- netrw disabled, opening a directory opens within the
    -- window like netrw would, regardless of window.position
    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
    -- instead of relying on nvim autocmd events.
  },
  buffers = {
    show_unloaded = true,
    window = {
      mappings = {
        ['bd'] = 'buffer_delete',
      },
    },
  },
  git_status = {
    window = {
      position = 'float',
      mappings = {
        ['A'] = 'git_add_all',
        ['gu'] = 'git_unstage_file',
        ['ga'] = 'git_add_file',
        ['gr'] = 'git_revert_file',
        ['gc'] = 'git_commit',
        ['gp'] = 'git_push',
        ['gg'] = 'git_commit_and_push',
      },
    },
  },
  event_handlers = {
    {
      event = 'neo_tree_buffer_enter',
      handler = function()
        vim.wo.signcolumn = 'no'
        --vim.cmd [[map <C-x> :echo "c-x"<Cr>]]
      end,
    },
  },
}

local colors_gui = vim.g.colors_gui or {}
local colors = require 'user.colors'
for hi, c in pairs {
  NeoTreeModified = colors.hydrangea,

  NeoTreeGitAdded = colors_gui['14'] or 'lightgreen',
  NeoTreeGitConflict = colors_gui['16'] or 'magenta',
  NeoTreeGitDeleted = colors_gui['12'] or 'lightred',
  NeoTreeGitModified = colors_gui['13'] or 'yellow',
  NeoTreeGitUntracked = colors_gui['8'] or 'cyan',
} do
  vim.cmd(('highlight %s guifg=%s'):format(hi, c))
end
