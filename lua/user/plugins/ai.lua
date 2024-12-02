require('user.util.lazy').after_load('noice.nvim', function()
  if package.loaded['leetcode'] or vim.g.ActiveCopilot == 'disabled' then
    return
  end
  require('user.ai').setup {
    default_copilot = vim.g.ActiveCopilot or 'supermaven',
    autostart = true,
  }
end)

---@type LazySpec[]
return {
  {
    'zbirenbaum/copilot.lua',
    enabled = false,
  },
  {
    'github/copilot.vim',
    enabled = false,
    init = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_filetypes = {
        yaml = true,
        markdown = true,
        help = true,
        gitcommit = true,
        gitrebase = true,
        hgcommit = true,
        svn = true,
        cvs = true,
        oil = false,
      }
    end,
    cmd = { 'GHCopilot' },
  },
  'supermaven-inc/supermaven-nvim',
  {
    'yetone/avante.nvim',
    dev = true,
    cmd = {
      'AvanteAsk',
      'AvanteChat',
      'AvanteEdit',
      'AvanteBuild',
      'AvanteClear',
      'AvanteFocus',
      'AvanteToggle',
      'AvanteRefresh',
      'AvanteShowRepoMap',
      'AvanteSwitchProvider',
    },
    keys = {
      {
        '<leader>aa',
        function() require('avante.api').ask() end,
        mode = { 'v', 'n' },
      },
      {
        '<leader>ae',
        vim.schedule_wrap(function() require('avante.api').edit() end),
        mode = 'v',
        desc = 'Avante: Edit',
      },
      '<leader>ap',
      '<M-m>',
      '<M-S-m>',
    },
    build = 'make',
    config = function()
      local fn = require 'user.fn'
      local recent_wins = require 'user.util.recent-wins'
      local maputil = require 'user.util.map'
      local map = maputil.map
      local private = require 'user.private'

      vim.env.ANTHROPIC_API_KEY = private.anthropic_api_key
      vim.env.CEREBRAS_API_KEY = private.cerebras_api_key
      vim.env.GROQ_API_KEY = private.groq_api_key

      require('avante').setup {
        ---@type "openai" | "claude" | "azure"  | "copilot" | "cohere"
        provider = 'claude',
        auto_suggestions_provider = 'cerebras',
        claude = {
          endpoint = 'https://api.anthropic.com',
          model = 'claude-3-5-sonnet-20241022',
          temperature = 0,
          max_tokens = 4096,
        },
        vendors = {
          groq = {
            __inherited_from = 'openai',
            api_key_name = 'GROQ_API_KEY',
            endpoint = 'https://api.groq.com/openai/v1/',
            model = 'llama-3.2-90b-text-preview',
          },
          cerebras = {
            __inherited_from = 'openai',
            api_key_name = 'CEREBRAS_API_KEY',
            endpoint = 'https://api.cerebras.ai/v1/',
            model = 'llama3.1-70b',
          },
        },
        behaviour = {
          auto_suggestions = false,
          auto_set_highlight_group = true,
          auto_set_keymaps = true,
          auto_apply_diff_after_generation = false,
          support_paste_from_clipboard = false,
        },
        dual_boost = {
          enabled = false,
          first_provider = 'groq',
          second_provider = 'claude',
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
          position = 'bottom',
          wrap = true, -- similar to vim.o.wrap
          width = 30, -- default % based on available width
          sidebar_header = {
            align = 'center', -- left, center, right for title
            rounded = true,
          },
          ask = {
            floating = true,
            focus_on_apply = 'theirs',
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
          autojump = true,
          override_timeoutlen = 1000,
        },
      }

      map('n', '<leader>ap', function()
        local providers = {
          'claude',
          'groq',
          'cerebras',
        }
        local provider = require('avante.config').provider
        local idx = vim.iter(ipairs(providers)):find(function(_, e) return e == provider end)
        if idx == nil then
          idx = 1
        else
          idx = idx + 1
        end
        if idx > #providers then
          idx = 1
        end
        local new_provider = providers[idx]
        -- silence notifications so we can display our own
        local notify = vim.notify
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.notify = function(msg, opts)
          local level = (type(opts) == 'table' and opts.level)
            or (type(opts) == 'number' and opts)
            or vim.log.levels.INFO
          if level and level > vim.log.levels.INFO then
            notify(msg, opts)
            return
          end
        end
        require('avante.api').switch_provider(new_provider)
        vim.notify = notify
        vim.notify('Switched to ' .. new_provider, { title = 'Avante' })
      end, 'Avante: Switch Provider')

      map(
        'n',
        '<M-m>',
        fn.filetype_command({ 'Avante', 'AvanteInput' }, recent_wins.focus_most_recent, function()
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'AvanteInput' then
              vim.api.nvim_set_current_win(win)
              return
            end
          end
          require('avante.api').ask { floating = false }
        end),
        'Avante: Toggle Focus'
      )

      map('n', '<M-S-m>', function()
        local winid = (vim.bo.filetype ~= 'AvanteInput' and vim.bo.filetype ~= 'Avante')
            and vim.api.nvim_get_current_win()
          or nil
        if require('avante').is_sidebar_open() then
          require('avante').close_sidebar()
          return
        end
        require('avante.api').ask { floating = false }
        if winid ~= nil then
          vim.defer_fn(function()
            vim.cmd [[stopinsert]]
            vim.api.nvim_set_current_win(winid)
          end, 0)
        end
      end, 'Avante: Ask')
    end,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'stevearc/dressing.nvim',
      'MunifTanjim/nui.nvim',
      {
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
    },
  },
}
