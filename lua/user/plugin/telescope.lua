---- nvim-telescope/telescope.nvim
local t = require 'telescope'
local ta = require 'telescope.actions'
local tb = require 'telescope.builtin'

local fn = require 'user.fn'
local m = require 'user.mappings'

local M = {}

local dbounced_show_builtins = require('user.util.debounce').make(function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'm', false)
  M.cmds.builtin()
end, { threshold = vim.o.timeoutlen - 1 })

local select_or_show_builtins = function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc><C-f>', true, true, true), 'm', false)
  dbounced_show_builtins()
end

t.setup {
  defaults = {
    layout_config = {
      scroll_speed = 2,
      preview_cutoff = 50,
      -- preview_width = 0.6, -- TODO: breaks floatwins
    },
    mappings = {
      i = {
        [m.xk['<C-S-f>']] = ta.close,
        ['<C-f>'] = select_or_show_builtins,
        ['<M-n>'] = ta.cycle_history_next,
        ['<M-p>'] = ta.cycle_history_prev,
        ['<C-j>'] = ta.preview_scrolling_down,
        ['<C-k>'] = ta.preview_scrolling_up,
        ['<C-d>'] = false,
      },
      n = {
        [m.xk['<C-S-f>']] = ta.close,
        ['<C-f>'] = dbounced_show_builtins:ref(),
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
  for _, ext in ipairs(require('user.packer').telescope_exts) do
    if not rawget(t.extensions, ext) then
      t.load_extension(ext)
    end
  end
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

M.cmds = setmetatable({}, {
  __index = function(self, k)
    local v = rawget(self, k) or _cmds[k] or tb[k]
    if not v then
      t.load_extension(k)
      v = rawget(t.extensions, k)
      if v and v[k] then
        v = v[k]
      end
    end
    -- This convoluted mess allows a call to any property or descendant
    -- property of M.cmds to be wrapped in a function that cancels the
    -- debounced show_builtins function
    if type(v) == 'table' or type(v) == 'function' then
      local cb = function(func, ...)
        dbounced_show_builtins:cancel()
        func(...)
      end
      if type(v) == 'table' then
        return fn.on_call_rec(v, cb)
      end
      return function(...)
        return cb(v, ...)
      end
    end
    return v
  end,
})

return M
