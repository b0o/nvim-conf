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
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    build = 'make',
    config = function()
      vim.env.ANTHROPIC_API_KEY = require('user.private').anthropic_api_key
      require('avante').setup {
        ---@alias Provider "openai" | "claude" | "azure"  | "copilot" | "cohere" | [string]
        provider = 'claude',
        claude = {
          endpoint = 'https://api.anthropic.com',
          model = 'claude-3-5-sonnet-20240620',
          temperature = 0,
          max_tokens = 4096,
        },
        mappings = {
          ask = '<leader>aa',
          edit = '<leader>ae',
          refresh = '<leader>ar',
          --- @class AvanteConflictMappings
          diff = {
            ours = 'co',
            theirs = 'ct',
            both = 'cb',
            cursor = 'cc',
            next = ']x',
            prev = '[x',
          },
          jump = {
            next = ']]',
            prev = '[[',
          },
          submit = {
            normal = '<CR>',
            insert = '<F12>', -- <C-Cr>
          },
          toggle = {
            debug = '<leader>ad',
            hint = '<leader>ah',
          },
        },
        hints = { enabled = true },
        windows = {
          wrap = true, -- similar to vim.o.wrap
          width = 30, -- default % based on available width
          sidebar_header = {
            align = 'center', -- left, center, right for title
            rounded = true,
          },
        },
        highlights = {
          ---@type AvanteConflictHighlights
          diff = {
            current = 'DiffText',
            incoming = 'DiffAdd',
          },
        },
        --- @class AvanteConflictUserConfig
        diff = {
          debug = false,
          autojump = true,
          ---@type string | fun(): any
          list_opener = 'copen',
        },
      }
    end,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'stevearc/dressing.nvim',
      'MunifTanjim/nui.nvim',
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
}
