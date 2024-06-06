---@type LazySpec[]
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'VeryLazy',
    config = function()
      require 'user.treesitter'
    end,
  },
  'JoosepAlviste/nvim-ts-context-commentstring',
  'Wansmer/sibling-swap.nvim',
  'Wansmer/treesj',
  'windwp/nvim-ts-autotag',
}
