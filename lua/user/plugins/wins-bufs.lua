local smart_splits = lazy_require 'smart-splits'
local wrap = require('user.util.map').wrap

very_lazy(function()
  if vim.env.ZELLIJ ~= nil then
    local map = require('user.util.map').map
    map('n', '<M-h>', '<C-w>h')
    map('n', '<M-j>', '<C-w>j')
    map('n', '<M-k>', '<C-w>k')
    map('n', '<M-l>', '<C-w>l')
  end
end)

---@type LazySpec[]
return {
  {
    'sindrets/winshift.nvim',
    cmd = 'WinShift',
    keys = {
      { '<Leader>M', '<Cmd>WinShift<Cr>', desc = 'WinShift: Start' },
      { '<Leader>mm', '<Cmd>WinShift<Cr>', desc = 'WinShift: Start' },
      { '<Leader>ws', '<Cmd>WinShift swap<Cr>', desc = 'WinShift: Swap' },
    },
    opts = {
      highlight_moving_win = true,
      focused_hl_group = 'Visual',
      moving_win_options = {
        wrap = false,
        cursorline = false,
        cursorcolumn = false,
        colorcolumn = '',
      },
    },
  },
  {
    'mrjones2014/smart-splits.nvim',
    cond = function() return vim.env.ZELLIJ == nil end,
    event = 'VeryLazy',
    keys = {
      { '<M-h>', wrap(smart_splits.move_cursor_left), desc = 'Goto window/pane left' },
      { '<M-j>', wrap(smart_splits.move_cursor_down), desc = 'Goto window/pane down' },
      { '<M-k>', wrap(smart_splits.move_cursor_up), desc = 'Goto window/pane up' },
      { '<M-l>', wrap(smart_splits.move_cursor_right), desc = 'Goto window/pane right' },
    },
  },
}
