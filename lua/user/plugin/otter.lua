local M = {}

local otter = require 'otter'
local keeper = require 'otter.keeper'
local extensions = require 'otter.tools.extensions'

-- If you want to use an injected language that's not in Otter's
-- default list, you can add it here. Otherwise, you may get an error
-- at runtime for unknown languages.
extensions.glsl = 'glsl'

otter.setup {
  buffers = {
    set_filetype = true,
  },
}

-- Wrapper that checks if the current buffer has a tree-sitter parser and
-- has injected languages. If so, it activates the injected languages and
-- then runs the action via otter. Otherwise, it runs the action via vim.lsp.buf.
-- If all the injected languages are already activated, it does not re-activate
-- them.
-- Example usage:
-- ```lua
-- vim.api.nvim_set_keymap('n', 'K', function()
--   lsp_action('hover')
-- end)
-- ```
M.lsp_action = function(action_name)
  local injected = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr)
  local function do_action()
    if #injected > 0 and keeper._otters_attached[bufnr] then
      otter['ask_' .. action_name]()
    else
      vim.lsp.buf[action_name]()
    end
  end
  if not parser then
    do_action()
    return
  end
  for _, node in pairs(parser:children()) do
    table.insert(injected, node:lang())
  end
  if #injected == 0 then
    do_action()
    return
  end
  local langs = keeper._otters_attached[bufnr] and keeper._otters_attached[bufnr].languages or {}
  for _, lang in ipairs(injected) do
    if not vim.tbl_contains(langs, lang) then
      vim.notify(vim.inspect(injected))
      otter.activate(injected)
      vim.defer_fn(function()
        do_action()
      end, 0)
      return
    end
  end
  do_action()
end

return M
