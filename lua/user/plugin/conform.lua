---- stevearc/conform.nvim
local M = {}

local format_on_save = true

function M.set_format_on_save(val)
  format_on_save = val
  vim.notify('Format on save ' .. (val and 'enabled' or 'disabled'))
end

function M.toggle_format_on_save()
  M.set_format_on_save(not format_on_save)
end

require('conform').setup {
  notify_on_error = true,
  format_on_save = function()
    if format_on_save then
      return {
        timeout_ms = 500,
        lsp_fallback = true,
      }
    end
  end,

  formatters_by_ft = {
    lua = { 'stylua' },

    python = { 'isort', 'black' },

    go = { 'gofmt', 'goimports' },

    nix = { 'nixfmt' },

    javascript = { 'dprint' },
    javascriptreact = { 'dprint' },
    typescript = { 'dprint' },
    typescriptreact = { 'dprint' },
    dockerfile = { 'dprint' },
    json = { 'dprint' },
    jsonc = { 'dprint' },
    markdown = { 'dprint' },
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
  },
}

return M
