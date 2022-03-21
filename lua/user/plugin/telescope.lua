---- nvim-telescope/telescope.nvim
local t = require 'telescope'
local ta = require 'telescope.actions'
local tb = require 'telescope.builtin'
local tx = t.extensions

local M = {}

t.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-d>'] = false,
        ['<C-u>'] = false,
        ['<M-n>'] = ta.cycle_history_next,
        ['<M-p>'] = ta.cycle_history_next,
      },
    },
  },
}

-- telescope.load_extension 'sessions'
t.load_extension 'windows'
t.load_extension 'git_worktree'
t.load_extension 'aerial'

local _cmds = {}

_cmds.find_files = function()
  tb.find_files { hidden = true }
end

_cmds.tags = function()
  tb.tags { only_current_buffer = true }
end

M.cmds = setmetatable(_cmds, {
  __index = function(self, k)
    local v = rawget(self, k)
    if v ~= nil then
      return v
    end
    -- TODO: args
    if type(tb[k]) == 'function' then
      return function()
        return tb[k]()
      end
    end
    return tb[k]
  end,
})

return M
