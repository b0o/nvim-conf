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
local telescope = require 'telescope'
telescope.setup {
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
telescope.load_extension 'sessions'

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

local comment_state = {}

---- numToStr/Comment.nvim
require('Comment').setup {
  pre_hook = function(ctx)
    if ctx.cmotion >= 3 and ctx.cmotion <= 5 then
      comment_state.marks = {
        vim.api.nvim_buf_get_mark(0, '<'),
        vim.api.nvim_buf_get_mark(0, '>'),
      }
    else
      comment_state.marks = {}
    end
  end,

  post_hook = function(ctx)
    inspect { ctx = ctx, comment_state = comment_state }
    vim.schedule(function()
      if #comment_state.marks > 0 then
        print(1)
        vim.api.nvim_buf_set_mark(0, '<', comment_state.marks[1][1], comment_state.marks[1][2], {})
        vim.api.nvim_buf_set_mark(0, '>', comment_state.marks[2][1], comment_state.marks[2][2], {})
        comment_state.marks = {}
        vim.cmd [[normal gv]]
      end
    end)
  end,
}

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
  lsp = {
    hint = '',
    info = '',
    warning = '',
    error = '',
  },
  -- view = {
  --   mappings = {
  --     custom_only = true,
  --   },
  -- },
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
