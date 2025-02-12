local xk = require('user.keys').xk
local maputil = require 'user.util.map'
local map = maputil.map

local has_dap_repl_hl, dap_repl_hl = pcall(require, 'nvim-dap-repl-highlights')
if has_dap_repl_hl then
  dap_repl_hl.setup() -- must be setup before nvim-treesitter
end

vim.treesitter.language.register('markdown', { 'mdx' })

vim.treesitter.language.add('cython', {
  path = vim.fn.stdpath 'cache' .. '/../tree-sitter/lib/cython.so',
})
vim.treesitter.language.register('cython', { 'pyx', 'pxd' })

---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup {
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = { 'BufWrite', 'CursorHold' },
  },
  ensure_installed = {
    'bash',
    'c',
    'capnp',
    'cmake',
    'cpp',
    'css',
    'dockerfile',
    'dap_repl',
    'diff',
    'gitcommit',
    'git_rebase',
    'gitignore',
    'glsl',
    'go',
    'graphql',
    'html',
    'javascript',
    'jsdoc',
    'json',
    'jsonc',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'regex',
    'swift',
    'toml',
    'typescript',
    'tsx',
    'vim',
    'vimdoc',
    'yaml',
    'zig',
  },
  highlight = {
    enable = true,
    disable = function(_, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local stats
      ---@diagnostic disable-next-line: undefined-field
      has_dap_repl_hl, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if has_dap_repl_hl and stats and stats.size > max_filesize then
        return true
      end
    end,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ip'] = '@parameter.inner',
        ['ap'] = '@parameter.outer',
        ['ib'] = '@block.inner',
        ['ab'] = '@block.outer',
        ['im'] = '@class.inner', -- m as in "(M)odule"
        ['am'] = '@class.outer',
        ['aa'] = '@call.outer', -- a as in "function (A)pplication"
        ['ia'] = '@call.inner',
        ['a/'] = '@comment.outer',
        ['i/'] = '@comment.outer',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']f'] = '@function.outer',
        [']m'] = '@class.outer',
        [']p'] = '@parameter.outer',
        [']]'] = '@block.outer',
        [']a'] = '@call.outer',
        [']/'] = '@comment.outer',
      },
      goto_next_end = {
        [']F'] = '@function.outer',
        [']M'] = '@class.outer',
        [']P'] = '@parameter.outer',
        [']['] = '@block.outer',
        [']A'] = '@call.outer',
        [']\\'] = '@comment.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[m'] = '@class.outer',
        ['[p'] = '@parameter.outer',
        ['[['] = '@block.outer',
        ['[a'] = '@call.outer',
        ['[/'] = '@comment.outer',
      },
      goto_previous_end = {
        ['[F'] = '@function.outer',
        ['[M'] = '@class.outer',
        ['[P'] = '@parameter.outer',
        ['[]'] = '@block.outer',
        ['[A'] = '@call.outer',
        ['[\\'] = '@comment.outer',
      },
    },
  },
  ---- windwp/nvim-ts-autotag
  autotag = {
    enable = true,
  },
}

-- Additional Filetypes

-- ft_to_parser.mdx = 'markdown'

-- ---- JoosepAlviste/nvim-ts-context-commentstring
-- vim.g.skip_ts_context_commentstring_module = true
-- require('ts_context_commentstring').setup {
--   enable = true,
--   enable_autocmd = false,
--   languages = {
--     javascript = {
--       __default = '// %s',
--       jsx_element = '{/* %s */}',
--       jsx_fragment = '{/* %s */}',
--       jsx_attribute = '// %s',
--       comment = '// %s',
--     },
--   },
-- }

---- Wansmer/sibling-swap.nvim
local sibling_swap = require 'sibling-swap'

---@diagnostic disable-next-line: missing-fields
sibling_swap.setup {
  use_default_keymaps = false,
  allow_interline_swaps = true,
}

map('n', xk '<C-.>', sibling_swap.swap_with_right, 'Sibling-Swap: Swap with right')
map('n', xk '<C-,>', sibling_swap.swap_with_left, 'Sibling-Swap: Swap with left')

---- Wansmer/treesj
local lang_utils = require 'treesj.langs.utils'
local treesj = require 'treesj'

treesj.setup {
  -- Use default keymaps
  -- (<space>m - toggle, <space>j - join, <space>s - split)
  use_default_keymaps = false,

  -- Node with syntax error will not be formatted
  check_syntax_error = true,

  -- If line after join will be longer than max value,
  -- node will not be formatted
  max_join_length = 200,

  -- hold|start|end:
  -- hold - cursor follows the node/place on which it was called
  -- start - cursor jumps to the first symbol of the node being formatted
  -- end - cursor jumps to the last symbol of the node being formatted
  cursor_behavior = 'hold',

  -- Notify about possible problems or not
  notify = true,

  langs = {
    zig = {
      initializer_list = lang_utils.set_preset_for_list(),
      arguments = lang_utils.set_preset_for_args(),
      call_expression = lang_utils.set_preset_for_args {
        split = {
          last_separator = true,
        },
        both = {
          shrink_node = { from = '(', to = ')' },
        },
      },
    },
  },

  -- Use `dot` for repeat action
  dot_repeat = true,
}

map('n', 'gJ', treesj.toggle, 'Treesj: Toggle')
map('n', 'gsj', treesj.join, 'Treesj: Join')
map('n', 'gss', treesj.split, 'Treesj: Split')
