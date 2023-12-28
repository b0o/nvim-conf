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
