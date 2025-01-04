local private = require 'user.util.private'

---@type LazySpec[]
return {
  {
    'epwalsh/obsidian.nvim',
    dev = true,
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
        ui = { enable = false },
        workspaces = {
          private.obsidian_vault,
        },
        ---@diagnostic disable-next-line: missing-fields
        completion = { nvim_cmp = false },
        ---@diagnostic disable-next-line: missing-fields
        templates = {
          subdir = 'Meta/Templates',
          date_format = '%Y-%m-%d',
          time_format = '%H:%M',
          substitutions = {},
        },
        ---@diagnostic disable-next-line: missing-fields
        daily_notes = {
          folder = 'Journal',
          date_format = '%Y/%Y-%m/%Y-%m-%d',
          template = 'JournalNvim.md',
        },
      }

      -- HACK: fix error, disable completion.nvim_cmp option, manually register sources
      -- See: https://github.com/epwalsh/obsidian.nvim/issues/770#issuecomment-2557300925
      local cmp = require 'cmp'
      cmp.register_source('obsidian', require('cmp_obsidian').new())
      cmp.register_source('obsidian_new', require('cmp_obsidian_new').new())
      cmp.register_source('obsidian_tags', require('cmp_obsidian_tags').new())

      vim.cmd.delcommand 'Rename'
      vim.cmd.cabbrev { 'Rename', 'ObsidianRename' }

      very_lazy(function()
        local maputil = require 'user.util.map'
        local map = maputil.map
        local ft = maputil.ft

        map('n', '<C-f><C-f>', '<Cmd>ObsidianQuickSwitch<Cr>', 'Obsidian: Quick Switch')
        map('n', { '<C-f>o', '<C-f><C-o>' }, '<Cmd>ObsidianTitles<Cr>', 'Obsidian: Search Titles')

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
