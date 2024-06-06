---@type LazySpec[]
return {
  {
    'hrsh7th/nvim-cmp',
    config = function()
      require 'user.cmp'
    end,
    event = 'VeryLazy',
    dependencies = {
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'rcarriga/cmp-dap',
      'ray-x/cmp-treesitter',
      'petertriho/cmp-git',
    },
  },
}
