local on_attach = require('user.lsp').on_attach

require('typescript-tools').setup {
  on_attach = on_attach,
  settings = {
    separate_diagnostic_server = true,
    publish_diagnostic_on = 'insert_leave',
  },
}
