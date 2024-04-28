---- stevearc/conform.nvim
local M = {}

local conform = require 'conform'

local format_on_save = true

function M.set_format_on_save(val)
  format_on_save = val
  vim.notify('Format on save ' .. (val and 'enabled' or 'disabled'))
end

function M.toggle_format_on_save()
  M.set_format_on_save(not format_on_save)
end

-- -- Makes it possible to write a formatter in Lua
-- -- Formatters can be defined in lua/user/plugin/conform/wrapped.lua
-- local function wrapped_fmt(ft)
--   return {
--     command = 'nvim',
--     args = {
--       '-u',
--       'NORC',
--       '--noplugin',
--       '-Es',
--       '+lua require"user.plugin.conform.wrapped".fmt("' .. ft .. '")',
--     },
--     range_args = function(ctx)
--       return {}
--     end,
--     stdin = true,
--   }
-- end
--
M.formatters = {
  --   -- glsl = function(bufnr, ...)
  --   --   if vim.bo[bufnr].filetype == 'glsl' then
  --   --     return require 'conform.formatters.clang_format'
  --   --   end
  --   --   return wrapped_fmt 'glsl'
  --   -- end,
  --
  --   -- Tee the file to /tmp/test.glsl and stdout
  --   glsl = {
  --     command = 'tee',
  --     args = { '/tmp/test.glsl' },
  --     stdin = true,
  --     range_args = function(_ctx)
  --       return {}
  --     end,
  --   },
}

M.formatters_by_ft = {
  lua = { 'stylua' },

  -- python = { 'isort', 'black' },

  glsl = {
    -- 'glsl',
    'clang_format',
  },

  go = { 'gofmt', 'goimports' },

  nix = { 'nixfmt' },

  javascript = {
    'dprint' --[[ , 'injected' ]],
  },
  javascriptreact = {
    'dprint' --[[ , 'injected' ]],
  },
  typescript = {
    'dprint' --[[ , 'injected' ]],
  },
  typescriptreact = {
    'dprint' --[[ , 'injected' ]],
  },

  dockerfile = { 'dprint' },
  json = { 'dprint' },
  jsonc = { 'dprint' },
  markdown = {
    'dprint' --[[ , 'injected' ]],
  },
  -- I'd prefer dprint, but https://github.com/dprint/dprint-plugin-markdown/issues/93
  mdx = { 'prettierd' },
  rust = { 'dprint' },
  toml = { 'dprint' },

  css = { 'prettierd', 'stylelint' },
  graphql = { 'prettierd' },
  html = { 'prettierd' },
  less = { 'prettierd' },
  scss = { 'prettierd' },
  yaml = { 'prettierd' },

  sh = { 'shfmt', 'shellharden' },
  bash = { 'shfmt', 'shellharden' },
  zsh = { 'shfmt', 'shellharden' },
}

-- function M.set_formatters(tbl, merge)
--   merge = merge == nil and true or merge
--   if merge then
--     M.formatters = vim.tbl_deep_extend('force', M.formatters, tbl)
--   else
--     M.formatters = tbl
--   end
--   M.setup()
-- end

function M.extend_formatter(name, tbl, setup)
  if not M.formatters[name] then
    M.formatters[name] = require('conform.formatters.' .. name)
  end
  M.formatters[name] = vim.tbl_deep_extend('force', M.formatters[name], tbl)
  if setup == nil or setup == true then
    M.setup()
  end
end

function M.set_formatter(ft, formatter, setup)
  M.formatters[ft] = formatter
  if setup == nil or setup == true then
    M.setup()
  end
end

function M.set_formatters_by_ft(tbl, merge, setup)
  merge = merge == nil and true or merge
  if merge then
    M.formatters_by_ft = vim.tbl_deep_extend('force', M.formatters_by_ft, tbl)
  else
    M.formatters_by_ft = tbl
  end
  if setup == nil or setup == true then
    M.setup()
  end
end

local did_setup = false

function M.setup()
  conform.setup {
    log_level = vim.log.levels.DEBUG,
    notify_on_error = true,
    format_on_save = function()
      if format_on_save then
        return {
          timeout_ms = 5000,
          lsp_fallback = true,
        }
      end
    end,
    formatters = M.formatters,
    formatters_by_ft = M.formatters_by_ft,
  }
  did_setup = true
end

if not did_setup then
  M.setup()
end

-- local M = {
--   formatters = {},
-- }
--
-- -- We want to make sure we retain the leading whitespace
-- -- and the indentation of the glsl code. To do this, we preprocess the
-- -- text to guess the indentation level, and also to check if there's
-- -- leading whitespace. Then after formatting, we restore the leading
-- -- whitespace and indentation.
-- --
-- -- To accomplish this, we define a custom formatter that does the
-- -- preprocessing, then calls clang-format, then does the postprocessing.
-- M.formatters.glsl = function(lines)
--   local indent = 0
--   local leading_whitespace = false
--   for _, line in ipairs(lines) do
--     if line:match '^%s*$' then
--       leading_whitespace = true
--     else
--       local line_indent = line:match '^%s*'
--       if line_indent then
--         indent = math.max(indent, #line_indent)
--       end
--     end
--   end
--   local indent_str = string.rep(' ', indent)
--   local formatted = vim.fn.system('clang-format', table.concat(lines, '\n'))
--   if leading_whitespace then
--     formatted = formatted:gsub('^%s*', indent_str)
--   end
--   return '\nfoo\nbar\nbaz'
-- end
--
-- M.fmt = function(ft)
--   local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
--   local formatter = M.formatters[ft]
--   if formatter then
--     local formatted = formatter(lines)
--     vim.uv.fs_write(1, formatted)
--   end
-- end
--
-- return M

return M
