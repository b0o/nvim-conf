---@type LazySpec[]
local spec = {
  {
    'mfussenegger/nvim-dap',
    cmd = {
      'DapContinue',
      'DapLoadLaunchJSON',
      'DapRestartFrame',
      'DapSetLogLevel',
      'DapShowLog',
      'DapStepInto',
      'DapStepOut',
      'DapStepOver',
      'DapTerminate',
      'DapToggleBreakpoint',
      'DapToggleRepl',
    },
    config = function()
      require 'user.dap'
    end,
  },
  'LiadOz/nvim-dap-repl-highlights',
  'mfussenegger/nvim-dap-python',
  'theHamsta/nvim-dap-virtual-text',
}

very_lazy(function()
  local fn = require 'user.fn'
  local maputil = require 'user.util.map'
  local map = maputil.map
  local wrap = maputil.wrap

  local dap = lazy_require 'dap'
  local dap_widgets = lazy_require 'dap.ui.widgets'

  map('n', '<leader>D', function()
    if dap.session() then
      require('user.dap').close(vim.bo.filetype)
    else
      require('user.dap').launch(vim.bo.filetype)
    end
  end, 'DAP: Toggle session')

  map(
    'n',
    '<M-d>',
    fn.filetype_command('dap-repl', require('user.util.recent-wins').focus_most_recent, function()
      dap.repl.open()
      vim.api.nvim_set_current_win(vim.fn.win_findbuf(vim.fn.bufnr 'dap-repl')[1] or 0)
    end),
    'DAP: Repl: Toggle Focus'
  )

  map('n', '<M-S-d>', dap.repl.toggle, 'DAP: Repl: Toggle')

  map('n', '<leader>dc', dap.continue, 'DAP: Continue')
  map('n', '<leader>dr', dap.restart, 'DAP: Restart')
  map('n', '<leader>dt', dap.terminate, 'DAP: Terminate')

  map('n', '<leader>db', dap.toggle_breakpoint, 'DAP: Toggle breakpoint')
  map('n', '<leader>de', wrap(dap.set_exception_breakpoints, { 'all' }), 'DAP: Break on exception')
  map('n', '<leader>dB', function()
    dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
  end, 'DAP: Set breakpoint condition')

  map('n', '<leader>di', dap_widgets.hover, 'DAP: Hover variables')

  map('n', '<leader>dK', dap.up, 'DAP: Up')
  map('n', '<leader>dJ', dap.down, 'DAP: Down')

  map('n', '<leader>di', dap_widgets.hover, 'DAP: Hover')
  map('n', '<leader>d?', wrap(dap_widgets.centered_float, dap_widgets.scopes), 'DAP: Scopes')

  map('n', '<leader>dk>', dap.step_out, 'DAP: Step out')
  map('n', '<leader>dl>', dap.step_into, 'DAP: Step into')
  map('n', '<leader>dj>', dap.step_over, 'DAP: Step over')
  map('n', '<leader>dh>', dap.continue, 'DAP: Continue')
end)

return spec
