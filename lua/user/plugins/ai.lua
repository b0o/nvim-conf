require('user.util.lazy').after_load('noice.nvim', function()
  if package.loaded['leetcode'] then
    return
  end
  require('user.ai').setup {
    default_copilot = vim.g.ActiveCopilot or 'supermaven',
    autostart = true,
  }
end)

---@type LazySpec[]
return {
  'zbirenbaum/copilot.lua',
  'supermaven-inc/supermaven-nvim',
  {
    'David-Kunz/gen.nvim',
    cmd = { 'Gen' },
    opts = {
      -- model = 'llama3',
      model = 'codegemma',
      host = 'localhost',
      port = '11434',
      quit_map = 'q',
      retry_map = '<C-r>',
      show_model = true,
    },
  },
}
