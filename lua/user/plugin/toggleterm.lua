---- akinsho/nvim-toggleterm.lua
local xk = require('user.keys').xk

---@diagnostic disable-next-line: undefined-field
vim.env.NVIM_LISTEN_ADDRESS_TOGGLETERM = vim.v.servername or nil

require('toggleterm').setup {
  size = function(term)
    if term.direction == 'horizontal' then
      return math.max(15, math.min(50, math.floor(vim.o.lines * 0.33)))
    elseif term.direction == 'vertical' then
      return math.max(80, math.min(120, math.floor(vim.o.columns * 0.2)))
    end
  end,
  open_mapping = xk [[<C-S-/>]],
  on_open = function()
    vim.cmd 'startinsert!'
  end,
  direction = 'float',
  persist_size = false,
  shade_terminals = false,
  float_opts = {
    border = 'curved',
    width = function()
      return math.max(40, math.min(200, math.floor(vim.o.columns * 0.55)))
    end,
    height = function()
      return math.max(30, math.min(100, math.floor(vim.o.lines * 0.55)))
    end,
    zindex = 200,
  },
}
