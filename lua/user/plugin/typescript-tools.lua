require('typescript-tools').setup {
  on_attach = function(client, bufnr)
    require('twoslash-queries').attach(client, bufnr)
    require('user.lsp').on_attach(client, bufnr)
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
