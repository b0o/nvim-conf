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
  { 'rcarriga/nvim-dap-ui', dependencies = 'nvim-neotest/nvim-nio' },
  'LiadOz/nvim-dap-repl-highlights',
  'mfussenegger/nvim-dap-python',
  'theHamsta/nvim-dap-virtual-text',
}

very_lazy(function()
  local fn = require 'user.fn'
  local maputil = require 'user.util.map'
  local map = maputil.map
  local wrap = maputil.wrap
  local ft = maputil.ft
  local focus_most_recent = lazy_require('user.util.recent-wins').focus_most_recent

  local dap = lazy_require 'dap'
  local dap_widgets = lazy_require 'dap.ui.widgets'
  local user_dap = lazy_require 'user.dap'

  map('n', '<leader>D', function()
    if dap.session() then
      user_dap.close(vim.bo.filetype)
    else
      user_dap.launch(vim.bo.filetype)
    end
  end, 'DAP: Toggle session')

  map(
    'n',
    '<M-d>',
    fn.filetype_command('dap-repl', focus_most_recent, function()
      local dap_win = vim.fn.win_findbuf(vim.fn.bufnr 'dap-repl')[1]
      if dap_win == nil then
        dap.repl.open()
      end
      dap_win = vim.fn.win_findbuf(vim.fn.bufnr 'dap-repl')[1]
      if dap_win == nil then
        vim.notify('No DAP REPL window found', vim.log.levels.WARN)
        return
      end
      vim.api.nvim_set_current_win(dap_win)
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

  map('n', { '<leader>di', '<C-M-i>' }, dap_widgets.hover, 'DAP: Hover variables')

  map('n', '<leader>dK', dap.up, 'DAP: Up')
  map('n', '<leader>dJ', dap.down, 'DAP: Down')

  map('n', '<leader>di', dap_widgets.hover, 'DAP: Hover')
  map('n', '<leader>d?', wrap(dap_widgets.centered_float, dap_widgets.scopes), 'DAP: Scopes')

  map('n', { '<leader>dh', '<leader>dk' }, dap.step_out, 'DAP: Step out')
  map('n', '<leader>dl', dap.step_into, 'DAP: Step into')
  map('n', '<leader>dj', dap.step_over, 'DAP: Step over')

  ft('dap-repl', function(bufmap, event)
    bufmap('i', '<M-k>', '<C-w>k', 'Goto window up')
    bufmap('i', '<M-j>', '<C-w>j', 'Goto window down')
    bufmap('i', '<M-h>', '<C-w>h', 'Goto window left')
    bufmap('i', '<M-l>', '<C-w>l', 'Goto window right')
    bufmap('i', { '<M-a>', '<M-d>' }, focus_most_recent, 'Focus most recent window')
    bufmap('i', '<M-S-d>', dap.repl.toggle, 'DAP REPL: Close')

    -- scroll to end of buffer when text changes in non-focused dap-repl windows
    vim.api.nvim_buf_attach(event.buf, false, {
      on_lines = vim.schedule_wrap(function()
        local focused_win = vim.api.nvim_get_current_buf()
        local wins = vim.fn.win_findbuf(event.buf)
        for _, win in ipairs(wins) do
          if win ~= focused_win then
            vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(event.buf), 0 })
          end
        end
      end),
    })
  end)

  local dapui = lazy_require 'dapui'
  local float_opts = { width = 100, height = 20 }
  map('n', '<leader>du', dapui.toggle, 'DAP: Toggle UI')
  map('n', '<leader>dov', wrap(dapui.float_element, 'scopes', float_opts), 'DAP: Float scopes (vars)')
  map('n', '<leader>dob', wrap(dapui.float_element, 'breakpoints', float_opts), 'DAP: Float breakpoints')
  map('n', '<leader>dos', wrap(dapui.float_element, 'stacks', float_opts), 'DAP: Float stacks')
  map('n', '<leader>dow', wrap(dapui.float_element, 'watches', float_opts), 'DAP: Float watches')
end)

return spec
