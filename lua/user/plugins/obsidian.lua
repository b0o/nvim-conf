local private = require 'user.private'

---@type LazySpec[]
return {
  {
    'epwalsh/obsidian.nvim',
    dev = true,
    -- version = '*',
    event = {
      ('BufReadPre %s/**.md'):format(private.obsidian_vault.path),
      ('BufNewFile %s/**.md'):format(private.obsidian_vault.path),
    },
    cmd = {
      'ObsidianBacklinks',
      'ObsidianDailies',
      'ObsidianExtractNote',
      'ObsidianFollowLink',
      'ObsidianLink',
      'ObsidianLinkNew',
      'ObsidianLinks',
      'ObsidianNew',
      'ObsidianOpen',
      'ObsidianPasteImg',
      'ObsidianQuickSwitch',
      'ObsidianRename',
      'ObsidianSearch',
      'ObsidianTags',
      'ObsidianTemplate',
      'ObsidianTitles',
      'ObsidianToday',
      'ObsidianTomorrow',
      'ObsidianWorkspace',
      'ObsidianYesterday',
    },
    config = function()
      vim.o.conceallevel = 1

      require('obsidian').setup {
        workspaces = {
          private.obsidian_vault,
        },
        completion = {
          nvim_cmp = true,
          min_chars = 1,
        },
        templates = {
          subdir = 'Meta/Templates',
          date_format = '%Y-%m-%d',
          time_format = '%H:%M',
          substitutions = {},
        },
        daily_notes = {
          folder = 'Journal',
          date_format = '%Y/%Y-%m/%Y-%m-%d',
          template = 'JournalNvim.md',
        },
      }

      vim.cmd.delcommand 'Rename'
      vim.cmd.cabbrev { 'Rename', 'ObsidianRename' }

      very_lazy(function()
        local maputil = require 'user.util.map'
        local map = maputil.map
        local ft = maputil.ft

        map('n', { '<C-f><C-f>', '<C-f>o', '<C-f><C-o>' }, '<Cmd>ObsidianTitles<Cr>', 'Obsidian: Search Titles')

        map('n', '<C-p>', function()
          vim.api.nvim_feedkeys(':Obsidian', 't', false)
          vim.defer_fn(require('cmp').complete, 0)
        end, ':Obsidian')

        ft('markdown', function(bufmap)
          bufmap('n', '<C-]>', function()
            if require('obsidian').util.cursor_on_markdown_link() then
              return '<Cmd>ObsidianFollowLink<CR>'
            else
              return '<C-]>'
            end
          end, { expr = true, desc = 'Obsidian: Follow Link' })
        end)
      end)
    end,
  },
}
