local M = {}

local format_on_save = true

function M.set_format_on_save(val)
  format_on_save = val
  vim.notify('Format on save ' .. (val and 'enabled' or 'disabled'))
end

function M.toggle_format_on_save() M.set_format_on_save(not format_on_save) end

---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
M.formatters = {}

M.formatters_by_ft = {
  cmake = { 'gersemi' },

  glsl = { 'clang_format' },

  go = { 'gofmt', 'goimports' },

  lua = { 'stylua' },

  nix = { 'nixfmt' },

  -- python = { 'isort', 'black' },

  javascript = { 'dprint' },
  javascriptreact = { 'dprint' },
  typescript = { 'dprint' },
  typescriptreact = { 'dprint' },

  dockerfile = { 'dprint' },
  json = { 'dprint' },
  jsonc = { 'dprint' },
  markdown = {
    'dprint' --[[ , 'injected' ]],
  },
  -- TODO: Use dprint when MDX is supported: https://github.com/dprint/dprint-plugin-markdown/issues/93
  mdx = { 'prettierd' },
  -- rust = { 'dprint' },
  toml = { 'dprint' },

  css = { 'prettierd', 'stylelint' },
  graphql = { 'prettierd' },
  html = { 'prettierd' },
  less = { 'prettierd' },
  scss = { 'prettierd' },
  yaml = { 'prettierd' },
  xml = { 'prettierd' },

  sh = { 'shfmt', 'shellharden' },
  bash = { 'shfmt', 'shellharden' },
  zsh = { 'shfmt', 'shellharden' },
}

---@param name string
---@param tbl conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride
---@param setup? boolean
function M.extend_formatter(name, tbl, setup)
  if not M.formatters[name] then
    M.formatters[name] = require('conform.formatters.' .. name)
  end
  M.formatters[name] = vim.tbl_deep_extend('force', M.formatters[name], tbl)
  if setup == nil or setup == true then
    M.setup()
  end
end

---@param ft string
---@param formatter conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride
---@param setup? boolean
function M.set_formatter(ft, formatter, setup)
  M.formatters[ft] = formatter
  if setup == nil or setup == true then
    M.setup()
  end
end

---@param tbl table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
---@param merge? boolean
---@param setup? boolean
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

function M.setup()
  require('conform').setup {
    log_level = vim.log.levels.DEBUG,
    notify_on_error = true,
    format_on_save = function()
      if format_on_save then
        return {
          timeout_ms = 5000,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters = M.formatters,
    formatters_by_ft = M.formatters_by_ft,
  }
end

return M
