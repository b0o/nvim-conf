---@type LazySpec[]
return {
  {
    'b0o/lavi.nvim',
    dev = true,
    lazy = false,
    dependencies = { 'rktjmp/lush.nvim' },
    config = function()
      if (vim.env.COLORSCHEME or 'lavi') == 'lavi' then
        vim.cmd.colorscheme 'lavi'
      end
    end,
    cond = function()
      return vim.env.COLORSCHEME == nil or vim.env.COLORSCHEME == 'lavi'
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    config = function()
      require('tokyonight').setup {
        on_highlights = function(hl, c)
          hl.CmpSel = {
            bg = c.bg_visual,
          }
        end,
      }
      vim.cmd.colorscheme 'tokyonight'
    end,
    cond = function()
      return vim.env.COLORSCHEME == 'tokyonight'
    end,
  },
  'kyazdani42/nvim-web-devicons',
  {
    'stevearc/dressing.nvim',
    opts = {},
    event = 'VeryLazy',
  },
  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function()
      local notify = require 'notify'
      ---@diagnostic disable-next-line: missing-fields
      notify.setup {
        top_down = false,
        on_open = function(win)
          vim.api.nvim_win_set_config(win, { zindex = 200 })
        end,
      }
      vim.notify = notify
    end,
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>L', '<Cmd>NoiceHistory<cr>', desc = 'Noice: History log' },
    },
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
        hover = {
          opts = {
            zindex = 200,
          },
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key.plugins.presets').operators['v'] = nil
      require('which-key').setup {}
    end,
  },
  {
    's1n7ax/nvim-window-picker',
    keys = {
      {
        '<M-w>',
        function()
          local win = require('window-picker').pick_window()
          if win and vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
          end
        end,
        desc = 'Window Picker: Pick',
      },
    },
    config = function()
      local colors = require 'user.colors'
      -- Generate fonts with the following shell function:
      -- genfont() {
      --   font="${1:-slant}"
      --   echo -e "-- Font: $font\nreturn {"
      --   for l in {a..z} {0..9} ';'; do
      --     echo "['$l'] = [[\n$(figlet -f "$font" "${l}" | awk NF)]],\n"
      --   done
      --   echo "}"
      -- }
      -- Place them in lua/window-picker/hints/data/<font>.lua
      require('window-picker').setup {
        hint = 'floating-big-letter',
        selection_chars = 'FJDKSLACMRUEIWOQPHTGYVBNZX',
        filter_rules = {
          autoselect_one = false,
          bo = {
            filetype = { 'notify', 'incline' },
            buftype = { 'quickfix' },
          },
        },
        picker_config = {
          floating_big_letter = {
            font = 'slant',
          },
        },
        fg_color = colors.hydrangea,
        show_prompt = false,
      }
    end,
  },
}
