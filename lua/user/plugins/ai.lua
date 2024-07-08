require('user.util.lazy').after_load('noice.nvim', function()
  require('user.ai').setup {
    default_copilot = vim.g.ActiveCopilot or 'supermaven',
    autostart = true,
  }
end)

---@type LazySpec[]
return {
  'zbirenbaum/copilot.lua',
  'supermaven-inc/supermaven-nvim',
}
