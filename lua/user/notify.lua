local M = {}

---- rcarriga/nvim-notify
require('notify').setup {
  render = 'default',
  background_colour = '#252137',
  stages = 'slide',
  on_open = function(win)
    vim.api.nvim_win_set_config(win, { zindex = 500 })
  end,
}

M.notify = function(msg, lvl, opts)
  lvl = lvl or vim.log.levels.INFO
  local lvls = vim.log.levels
  local keep = function()
    return true
  end
  local _opts = ({
    [lvls.TRACE] = { timeout = 500 },
    [lvls.DEBUG] = { timeout = 500 },
    [lvls.INFO] = { timeout = 1000 },
    [lvls.WARN] = { timeout = 10000 },
    [lvls.ERROR] = { timeout = 10000, keep = keep },
  })[lvl]
  opts = vim.tbl_extend('force', _opts or {}, opts or {})
  if vim.g.nvim_focused then
    local ok, notify = pcall(require, 'notify')
    if not ok then
      vim.defer_fn(function()
        vim.notify(msg, lvl, opts)
      end, 100)
      return
    end
    return notify.notify(msg, lvl, opts)
  else
    -- SEE: https://github.com/simrat39/desktop-notify.nvim/issues/4
    ---@diagnostic disable-next-line: redundant-parameter
    return require('desktop-notify').notify(msg, lvl, opts)
  end
end

return M
