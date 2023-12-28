---- stevearc/oil.nvim
local oil = require 'oil'

oil.setup {
  default_file_exporer = true,
  view_options = {
    show_hidden = true,
  },
  float = {
    padding = 2,
    max_width = 100,
    max_height = 40,
    override = function(conf)
      return vim.tbl_deep_extend('force', conf, {
        zindex = 80,
      })
    end,
  },
  skip_confirm_for_simple_edits = true,
  keymaps = {
    ['<M-u>'] = 'actions.parent',
    ['<M-i>'] = 'actions.select',
    ['<C-v>'] = 'actions.select_vsplit',
    ['<C-x>'] = 'actions.select_split',
    ['<C-s>'] = {
      callback = function()
        oil.save()
      end,
      desc = 'Oil: Save',
      mode = { 'n', 'i', 'v' },
    },
    ['Q'] = {
      callback = function()
        local modified = vim.bo.modified
        if modified then
          local choice = vim.fn.confirm('Save changes?', '&Save\n&Discard\n&Cancel', 3)
          if choice == 1 then
            oil.save()
          elseif choice == 2 then
            oil.discard_all_changes()
          else
            return
          end
        end
        oil.close()
      end,
      desc = 'Oil: Close',
      mode = { 'n' },
    },
  },
}
