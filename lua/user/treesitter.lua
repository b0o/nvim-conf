local ok, dap_repl_hl = pcall(require, 'nvim-dap-repl-highlights')
if ok then
  dap_repl_hl.setup() -- must be setup before nvim-treesitter
end

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
    -- 'comment',
    'cpp',
    'css',
    'dockerfile',
    -- 'dot',
    -- 'fennel',
    'dap_repl',
    'diff',
    'gitcommit',
    'git_rebase',
    'gitignore',
    'glsl',
    'go',
    -- 'gomod',
    'graphql',
    -- 'haskell',
    -- 'hjson',
    'html',
    -- 'http',
    'javascript',
    'jsdoc',
    'json',
    -- 'json5',
    'jsonc',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    -- 'nix',
    -- 'ocaml',
    -- 'ocaml_interface',
    -- 'ocamllex',
    'python',
    -- 'prisma',
    'query',
    -- 'r',
    -- 'regex',
    -- 'rst',
    -- 'ruby',
    -- 'rust',
    -- 'scss',
    -- 'teal',
    'toml',
    'typescript',
    'tsx',
    'vim',
    'vimdoc',
    -- 'wgsl',
    'yaml',
    'zig',
  },
  highlight = {
    enable = true,
    disable = function(_lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
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
        [']b'] = '@block.outer',
        [']a'] = '@call.outer',
        [']/'] = '@comment.outer',
      },
      goto_next_end = {
        [']F'] = '@function.outer',
        [']M'] = '@class.outer',
        [']P'] = '@parameter.outer',
        [']['] = '@block.outer',
        [']B'] = '@block.outer',
        [']A'] = '@call.outer',
        [']\\'] = '@comment.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[m'] = '@class.outer',
        ['[p'] = '@parameter.outer',
        ['[['] = '@block.outer',
        ['[b'] = '@block.outer',
        ['[a'] = '@call.outer',
        ['[/'] = '@comment.outer',
      },
      goto_previous_end = {
        ['[F'] = '@function.outer',
        ['[M'] = '@class.outer',
        ['[P'] = '@parameter.outer',
        ['[]'] = '@block.outer',
        ['[B'] = '@block.outer',
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

vim.treesitter.language.register('markdown', { 'mdx' })
-- ft_to_parser.mdx = 'markdown'

-- -- romgrk/nvim-treesitter-context
-- require('treesitter-context').setup {
--   enable = true,
--   throttle = true,
--   max_lines = 4,
--   multiline_threshold = 4,
--   -- zindex =
--   patterns = {
--     -- default = {
--     --   'class',
--     --   'function',
--     --   'method',
--     -- },
--     -- ocaml = {
--     --   'module_definition',
--     --   'type_definition',
--     --   'let_binding',
--     --   'match_expression',
--     --   'body',
--     -- },
--   },
-- }
--
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
require('sibling-swap').setup {
  use_default_keymaps = false,
  allow_interline_swaps = true,
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
