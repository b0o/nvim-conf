-- See https://gist.github.com/b0o/59a46ecfdb1196312da0c92273b56aa8
-- for more details.
local M = {}

local otter = require 'otter'
local keeper = require 'otter.keeper'
---@type table<string, string> @ Filetype to extension mapping
local extensions = require 'otter.tools.extensions'

-- filetype -> extension mappings
-- If you want to use an injected language that's not in Otter's
-- default list, you can add it here. If it's not in the list,
-- and you don't add it here, the lsp_action wrapper won't work for
-- that language.
extensions.glsl = 'glsl'
extensions.json = 'json'
extensions.lua = 'lua'
extensions.typescript = 'ts'
extensions.tsx = 'tsx'
extensions.jsx = 'jsx'
extensions.javascript = 'js'

-- If you want to ignore a filetype, you can add it here.
-- the table key is the parent filetype, and the table value
-- can be true (to completely ignore the parent filetype) or
-- a list of injected filetypes to ignore for that parent.
local ignore = {
  mdx = {
    'html',
  },
}

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
--   vim.api.nvim_set_keymap('n', 'K', function()
--     lsp_action('hover')
--   end)
M.lsp_action = function(action_name)
  local injected = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local function do_action()
    if #injected > 0 and keeper._otters_attached[bufnr] then
      otter['ask_' .. action_name]()
    else
      vim.lsp.buf[action_name]()
    end
  end
  local ignore_fts = ignore[vim.bo.filetype]
  if ignore_fts == true then
    do_action()
    return
  end
  local parser = vim.treesitter.get_parser(bufnr)
  if not parser then
    do_action()
    return
  end
  for _, node in pairs(parser:children()) do
    local lang = node:lang()
    local ok = true
    ok = ok and extensions[lang] ~= nil
    ok = ok and not vim.tbl_contains(ignore_fts or {}, lang)
    if ok then
      table.insert(injected, lang)
    end
  end
  if #injected == 0 then
    do_action()
    return
  end
  local langs = keeper._otters_attached[bufnr] and keeper._otters_attached[bufnr].languages or {}
  for _, lang in ipairs(injected) do
    if not vim.tbl_contains(langs, lang) then
      vim.notify('Activating Otter for ' .. table.concat(injected, ', '))
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
