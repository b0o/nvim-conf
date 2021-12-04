---- VonHeikemen/fine-cmdline.nvim
require('fine-cmdline').setup({
  popup = {
    position = {
      row = '90%',
      col = '50%',
    },
    size = {
      width = '60%',
    },
    border = {
      style = 'rounded',
      highlight = 'FloatBorder',
    },
    win_options = {
      winhighlight = 'Normal:Normal',
    },
  },
  hooks = {
  --   before_mount = function(input)
  --     -- code
  --   end,
  --   after_mount = function(input)
  --     -- code
  --   end,
    set_keymaps = function()
      require'user.mappings'.fine_cmdline()
    end
  }
})
