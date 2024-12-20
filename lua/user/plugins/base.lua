---@type LazySpec[]
return {
  {
    'nvim-lua/plenary.nvim',
    cmd = { 'PlenaryBustedFile', 'PlenaryBustedDirectory' },
  },
  'MunifTanjim/nui.nvim',
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      local Snacks = require 'snacks'
      local maputil = require 'user.util.map'
      local map = maputil.map

      Snacks.setup {
        bigfile = { enabled = true },
        notifier = {
          enabled = true,
          margin = { top = 2, right = 1, bottom = 1 },
        },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        terminal = { enabled = false },
        words = { enabled = true },
      }

      vim.api.nvim_create_user_command(
        'Bdelete',
        function(opts) Snacks.bufdelete.delete { force = opts.bang == true } end,
        { bang = true }
      )

      vim.api.nvim_create_user_command('Gbrowse', function() Snacks.gitbrowse() end, {})

      vim.api.nvim_create_user_command('Notifications', function() Snacks.notifier.show_history() end, {})

      map('n', ')', function() Snacks.words.jump(vim.v.count1, true) end, 'Snacks: Jump to next word')

      map('n', '(', function() Snacks.words.jump(-vim.v.count1, true) end, 'Snacks: Jump to prev word')
    end,
  },
}
