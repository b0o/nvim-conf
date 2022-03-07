---- folke/which-key.nvim
require('which-key').setup {
  plugins = {
    spelling = {
      enabled = true,
      suggestions = 30,
    },
  },
  triggers_blacklist = {
    i = { 'j', 'k', "'" },
    v = { 'j', 'k', "'" },
    n = { "'" },
  },
}
