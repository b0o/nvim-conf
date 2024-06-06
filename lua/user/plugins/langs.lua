local private = require 'user.private'

---@type LazySpec[]
local spec = {
  {
    'aouelete/sway-vim-syntax',
    ft = 'sway',
  },
  {
    'fatih/vim-go',
    ft = 'go',
    config = function()
      vim.g.go_doc_keywordprg_enabled = 0
    end,
  },
  {
    'rgroli/other.nvim',
    cmd = { 'Other', 'OtherTabNew', 'OtherSplit', 'OtherVSplit' },
    config = function()
      local other = require 'other-nvim'

      other.setup {
        mappings = {
          ---- Typescript
          {
            pattern = '(.*).ts$',
            context = 'test',
            target = '%1.test.ts',
          },
          {
            pattern = '(.*).test.ts$',
            context = 'implementation',
            target = '%1.ts',
          },
          {
            pattern = '(.*).d.ts$',
            context = 'declaration-test',
            target = '%1.test-d.ts',
          },
          {
            pattern = '(.*).test%-d.ts$',
            target = {
              {
                context = 'declaration',
                target = '%1.d.ts',
              },
              {
                context = 'implementation',
                target = '%1.ts',
              },
            },
          },
          ---- TSX
          {
            pattern = '(.*).tsx$',
            context = 'test',
            target = '%1.test.tsx',
          },
          {
            pattern = '(.*).test.tsx$',
            context = 'implementation',
            target = '%1.tsx',
          },
          ---- Javascript
          {
            pattern = '(.*).js$',
            context = 'test',
            target = '%1.test.js',
          },
          {
            pattern = '(.*).test.js$',
            context = 'implementation',
            target = '%1.js',
          },
          ---- JSX
          {
            pattern = '(.*).jsx$',
            context = 'test',
            target = '%1.test.jsx',
          },
          {
            pattern = '(.*).test.jsx$',
            context = 'implementation',
            target = '%1.jsx',
          },
          ---- C
          {
            pattern = '(.*).c$',
            context = 'header',
            target = '%1.h',
          },
          {
            pattern = '(.*).h$',
            context = 'implementation',
            target = '%1.c',
          },
          ---- C++
          {
            pattern = '(.*).cpp$',
            context = 'header',
            target = '%1.h',
          },
          {
            pattern = '(.*).h$',
            context = 'implementation',
            target = '%1.cpp',
          },
        },
        keybindings = {
          ['<Cr>'] = 'open_file()',
          ['<Esc>'] = 'close_window()',
          q = 'close_window()',
          o = 'open_file()',
          t = 'open_file_tabnew()',
          v = 'open_file_vs()',
          s = 'open_file_sp()',
          ['<C-t>'] = 'open_file_tabnew()',
          ['<C-v>'] = 'open_file_vs()',
          ['<C-x>'] = 'open_file_sp()',
        },
        hooks = {
          onOpenFile = function(filename, exists)
            if exists then
              local bufnr = vim.fn.bufnr(filename)
              if bufnr > 0 then
                local wins = vim.api.nvim_tabpage_list_wins(0)
                for _, win in ipairs(wins) do
                  if vim.api.nvim_win_get_buf(win) == bufnr then
                    vim.api.nvim_set_current_win(win)
                    return false
                  end
                end
              end
            end
            return true
          end,
        },
        style = {
          border = 'rounded',
          seperator = '│',
          newFileIndicator = '[NEW]',
        },
      }
    end,
  },
  {
    'b0o/blender.nvim',
    dev = true,
    opts = {
      notify = {
        verbosity = 'TRACE',
      },
    },
    cmd = {
      'Blender',
      'BlenderLaunch',
      'BlenderManage',
      'BlenderTest',
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      { 'grapp-dev/nui-components.nvim', dev = false },
      'mfussenegger/nvim-dap',
      'LiadOz/nvim-dap-repl-highlights',
    },
  },
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    event = {
      ('BufReadPre %s/**.md'):format(private.obsidian_vault.path),
      ('BufNewFile %s/**.md'):format(private.obsidian_vault.path),
    },
    cmd = {
      'ObsidianOpen',
      'ObsidianNew',
      'ObsidianQuickSwitch',
      'ObsidianFollowLink',
      'ObsidianBacklinks',
      'ObsidianTags',
      'ObsidianToday',
      'ObsidianYesterday',
      'ObsidianTomorrow',
      'ObsidianDailies',
      'ObsidianTemplate',
      'ObsidianSearch',
      'ObsidianLink',
      'ObsidianLinkNew',
      'ObsidianLinks',
      'ObsidianExtractNote',
      'ObsidianWorkspace',
      'ObsidianPasteImg',
      'ObsidianRename',
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

      local maputil = require 'user.util.map'
      local map = maputil.map
      local ft = maputil.ft

      map('n', { '<C-f><C-f>', '<C-f>o', '<C-f><C-o>' }, '<Cmd>ObsidianQuickSwitch<Cr>', 'Obsidian: Quick Switch')

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
    end,
  },
}

very_lazy(function()
  local maputil = require 'user.util.map'
  local map = maputil.map

  map('n', { '<leader>O', '<leader>oo' }, '<Cmd>Other<Cr>', 'Other: Switch to other file')
  map('n', '<leader>os', '<Cmd>OtherSplit<Cr>', 'Other: Open other in split')
  map('n', '<leader>ov', '<Cmd>OtherVSplit<Cr>', 'Other: Open other in vsplit')
end)

return spec
