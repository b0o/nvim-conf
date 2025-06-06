local private = require 'user.util.private'
local vault = private.obsidian_vault or {}

---@type LazySpec[]
return {
  {
    'obsidian-nvim/obsidian.nvim',
    event = vault.path and {
      ('BufReadPre %s/**.md'):format(vault.path),
      ('BufNewFile %s/**.md'):format(vault.path),
    } or nil,
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

      ---If the current file is a journal, return the date of the journal as a timestamp
      ---Otherwise, return the current timestamp (os.time())
      local journal_date_or_now = function()
        local file = vim.fn.expand '%'
        local match = vim.regex([[Journal/\d\{4}/\d\{4}-\d\{2}/\d\{4}-\d\{2\}-\d\{2}\.md$]]):match_str(file)
        if match == nil then
          return os.time()
        end
        local year, month, day = file:match '(%d+)-(%d+)-(%d+)'
        return os.time { year = year, month = month, day = day }
      end

      require('obsidian').setup {
        ui = { enable = false },
        workspaces = { vault },
        ---@diagnostic disable-next-line: missing-fields
        completion = {
          -- Enables completion using nvim_cmp
          nvim_cmp = false,
          -- Enables completion using blink.cmp
          blink = true,
          -- Trigger completion at 2 chars.
          min_chars = 2,
        },

        ---@diagnostic disable-next-line: missing-fields
        templates = {
          subdir = 'Meta/Templates',
          date_format = '%Y-%m-%d',
          time_format = '%H:%M',
          substitutions = {
            yesterday = function() return os.date('%Y-%m-%d', journal_date_or_now() - 86400) end,
            tomorrow = function() return os.date('%Y-%m-%d', journal_date_or_now() + 86400) end,
            yesterday_journal = function() return os.date('Journal/%Y/%Y-%m/%Y-%m-%d', journal_date_or_now() - 86400) end,
            tomorrow_journal = function() return os.date('Journal/%Y/%Y-%m/%Y-%m-%d', journal_date_or_now() + 86400) end,
            month_abbr = function() return os.date('%b', journal_date_or_now()) end,
            month = function() return os.date('%B', journal_date_or_now()) end,
            year = function() return os.date('%Y', journal_date_or_now()) end,
            weekday = function() return os.date('%A', journal_date_or_now()) end,
            today_human = function() return os.date('%A, %B %d', journal_date_or_now()) end,
            tomorrow_human = function() return os.date('%A, %B %d', journal_date_or_now() + 86400) end,
            yesterday_human = function() return os.date('%A, %B %d', journal_date_or_now() - 86400) end,
          },
        },
        ---@diagnostic disable-next-line: missing-fields
        daily_notes = {
          folder = 'Journal',
          date_format = '%Y/%Y-%m/%Y-%m-%d',
          template = 'JournalNvim.md',
        },
      }

      vim.cmd.delcommand 'Rename'
      vim.cmd.cabbrev { 'Rename', 'ObsidianRename' }
      vim.cmd.cabbrev { 'Today', 'ObsidianToday' }
      vim.cmd.cabbrev { 'Yesterday', 'ObsidianYesterday' }
      vim.cmd.cabbrev { 'Tomorrow', 'ObsidianTomorrow' }
      vim.cmd.cabbrev { 'Daily', 'ObsidianTemplate JournalNvim' }

      very_lazy(function()
        local maputil = require 'user.util.map'
        local map = maputil.map
        local ft = maputil.ft

        map('n', '<C-f><C-f>', '<Cmd>ObsidianQuickSwitch<Cr>', 'Obsidian: Quick Switch')
        map('n', { '<C-f>o', '<C-f><C-o>' }, '<Cmd>ObsidianTitles<Cr>', 'Obsidian: Search Titles')

        ft('markdown', function(bufmap)
          bufmap('n', '<C-]>', function()
            if require('obsidian').util.cursor_on_markdown_link() then
              return '<Cmd>ObsidianFollowLink<CR>'
            else
              return '<C-]>'
            end
          end, { expr = true, desc = 'Obsidian: Follow Link' })

          local find_link = function(dir)
            return function()
              local pat = '\\(\\[\\[[^\\[\\]]\\+\\]\\]\\)\\|\\(\\[.\\+\\](.\\+)\\)'
              local match = vim.fn.search(pat, dir == 1 and 'p' or 'bpz')
              if match == 0 then
                return
              end
              local cursor = vim.api.nvim_win_get_cursor(0)
              if match == 2 then
                vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + 2 })
              elseif match == 3 then
                vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + 1 })
              end
            end
          end

          bufmap('n', '<Tab>', find_link(1), 'Obsidian: Cursor to next link')
          bufmap('n', '<S-Tab>', find_link(-1), 'Obsidian: Cursor to prev link')

          local function find_heading(dir)
            return function()
              local pat = '^#\\+\\s\\+.\\+'
              local match = vim.fn.search(pat, dir == 1 and '' or 'bz')
              if match == 0 then
                return
              end
              local line = vim.api.nvim_get_current_line()
              local col = line:find '[^# ]'
              if col then
                vim.api.nvim_win_set_cursor(0, { vim.fn.line '.', math.max(0, col - 1) })
              end
            end
          end
          bufmap('n', '}', find_heading(1), 'Obsidian: Cursor to next heading')
          bufmap('n', '{', find_heading(-1), 'Obsidian: Cursor to prev heading')
        end)
      end)
    end,
  },
}
