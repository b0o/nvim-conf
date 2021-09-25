-- Re-compile Packer on write plugins.lua
vim.cmd(string.format(
  [[
  augroup Packer
    autocmd!
    autocmd BufWritePost %s call luaeval('%s')
  augroup END
]],
  vim.fn.stdpath 'config' .. '/lua/user/plugins.lua',
  [[vim.cmd("redraw!") and print("packer.compile()") and require"packer".compile()]]
))

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup END
]]

-- Ensure the title is set immediately on load instead of whenever a file is
-- loaded/changed/written
vim.cmd [[
  augroup SetTitle
    autocmd!
    autocmd VimEnter * set title
  augroup END
]]

-- Enter insert mode when entering a terminal buffer
vim.cmd [[
  augroup term
    autocmd!
    autocmd BufEnter  term://* call user#fn#termEnter(1)
    autocmd TermClose term://* call user#fn#closeBufWins(expand('<abuf>'))
  augroup END
]]

vim.cmd [[
  augroup commentary_opts
    autocmd!
    autocmd FileType * let b:commentary_startofline = 1
  augroup END
]]

vim.cmd [[
  augroup nvim_tree_highlights
    autocmd!
    autocmd FileType NvimTree lua _G.nvim_tree_highlights()
  augroup END
]]

-- vim.cmd([[
--   augroup ManMaps
--     autocmd!
--     autocmd FileType man lua vim_man_mapfn(vim.api.nvim_get_current_buf())
--   augroup END
-- ]])
