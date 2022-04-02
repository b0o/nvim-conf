---- nvim-telescope/telescope.nvim
local t = require 'telescope'
local ta = require 'telescope.actions'
local tb = require 'telescope.builtin'
local tx = t.extensions

local m = require 'user.mappings'

local M = {}

t.setup {
  defaults = {
    -- layout_strategy = 'flex',
    layout_config = {
      scroll_speed = 2,
      preview_cutoff = 50,
      preview_width = 0.6,
    },
    mappings = {
      i = {
        [m.xk['<C-S-f>']] = ta.close,
        ['<C-f>'] = ta.close,
        ['<M-n>'] = ta.cycle_history_next,
        ['<M-p>'] = ta.cycle_history_prev,
        ['<C-j>'] = ta.preview_scrolling_down,
        ['<C-k>'] = ta.preview_scrolling_up,
      },
      n = {
        [m.xk['<C-S-f>']] = ta.close,
        ['<C-f>'] = ta.close,
        ['<M-n>'] = ta.cycle_history_next,
        ['<M-p>'] = ta.cycle_history_prev,
        ['<C-n>'] = ta.move_selection_next,
        ['<C-p>'] = ta.move_selection_previous,
        ['<C-j>'] = ta.preview_scrolling_down,
        ['<C-k>'] = ta.preview_scrolling_up,
      },
    },
  },
}

local extensions_loaded = false
local function load_extensions()
  if extensions_loaded then
    return
  end

  t.load_extension 'windows'
  t.load_extension 'aerial'
  t.load_extension 'git_worktree'
  t.load_extension 'gh'

  extensions_loaded = true
end

local _cmds = {}

-- Try to run git_files first, if not in a git directory then run the standard
-- find_files.
_cmds.smart_files = function()
  if not pcall(tb.git_files) then
    tb.find_files { hidden = true }
  end
end

_cmds.tags = function()
  tb.tags { only_current_buffer = true }
end

_cmds.builtin = function()
  load_extensions()
  tb.builtin { include_extensions = true }
end

M.cmds = setmetatable(_cmds, {
  __index = function(self, k)
    local v = rawget(self, k)
    if v then
      return v
    end
    if not tb[k] then
      load_extensions()
    end
    return tb[k]
  end,
})

return M
