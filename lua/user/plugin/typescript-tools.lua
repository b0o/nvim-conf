---@type Map<integer, Map<integer, boolean>> client -> (bufnr -> attached)
local attached = {}

require('typescript-tools').setup {
  on_attach = function(client, bufnr)
    ---TODO: https://github.com/pmizio/typescript-tools.nvim/issues/208
    if attached[client.id] and attached[client.id][bufnr] then
      return
    end
    if not attached[client.id] then
      attached[client.id] = {}
    end
    require('twoslash-queries').attach(client, bufnr)
    require('user.lsp').on_attach(client, bufnr)
    attached[client.id][bufnr] = true
  end,
  settings = {
    separate_diagnostic_server = true,
    publish_diagnostic_on = 'insert_leave',
    tsserver_file_preferences = {
      includeCompletionsForModuleExports = true,

      -- inlay hints
      includeInlayParameterNameHints = 'literals',
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayVariableTypeHintsWhenTypeMatchesName = false,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
    tsserver_format_options = {
      allowIncompleteCompletions = false,
      allowRenameOfImportPath = false,
    },
  },
}
