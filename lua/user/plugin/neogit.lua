local neogit = require 'neogit'

neogit.setup {
  disable_builtin_notifications = true,
  disable_insert_on_commit = true,
  console_timeout = math.huge,
  auto_show_console = false,
  commit_editor = {
    kind = 'floating',
    show_staged_diff = false,
  },
  signs = {
    hunk = { '', '' },
    item = { '', '' },
    section = { '', '' },
  },
  mappings = {
    popup = {
      ['Z'] = false,
      ['<M-s>'] = 'StashPopup',
    },
    finder = {
      ['<esc>'] = false,
    },
    status = {
      ['q'] = 'Close',
      ['K'] = false,
      ['<C-K>'] = 'Untrack',
      ['<cr>'] = false,
      ['<C-Cr>'] = 'GoToFile',
    },
  },
}
local augroup = vim.api.nvim_create_augroup('user.neogit', {})

-- Neogit uses the filetype `NeogitCommitMessage` for the commit message buffer.
-- this causes some problems and has no real benefit, so we switch it back to
-- `gitcommit`.
-- https://github.com/NeogitOrg/neogit/issues/405#issuecomment-1374652332
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'NeogitCommitMessage',
  command = 'silent! set filetype=gitcommit buflisted',
})

-- Unmap <esc> in NeogitLogView
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'NeogitLogView',
  callback = function()
    vim.defer_fn(function()
      vim.api.nvim_buf_del_keymap(0, 'n', '<esc>')
    end, 200)
  end,
})
