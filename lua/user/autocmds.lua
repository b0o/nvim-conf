-- Re-compile Packer on write plugins.lua
vim.cmd(string.format(
  [[
  augroup user_packer
    autocmd!
    autocmd BufWritePost %s call luaeval('%s')
  augroup END
]],
  vim.fn.stdpath 'config' .. '/lua/user/plugins.lua',
  [[vim.cmd("redraw!") and print("packer.compile()") and require"packer".compile()]]
))

vim.cmd [[
  augroup user_misc
    autocmd!

    " Highlight on yank
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()

    " Ensure the title is set immediately on load instead of whenever a file is
    " loaded/changed/written
    autocmd VimEnter * set title
  augroup END
]]

-- Enter insert mode when entering a terminal buffer
vim.cmd [[
  augroup user_term
    autocmd!
    autocmd BufEnter  term://* call user#fn#termEnter(1)
    autocmd TermClose term://* call user#fn#closeBufWins(expand('<abuf>'))
  augroup END
]]

vim.cmd [[
  augroup user_commentary
    autocmd!
    autocmd FileType * let b:commentary_startofline = 1
  augroup END
]]

vim.cmd [[
  augroup user_gitsigns
    autocmd!
    " Work around for https://github.com/lewis6991/gitsigns.nvim/issues/264
    autocmd SessionLoadPost * lua vim.defer_fn(require'gitsigns'.refresh, 150)
  augroup END
]]

vim.cmd [[
  augroup user_nvim_tree
    autocmd!
    autocmd FileType NvimTree lua _G.nvim_tree_highlights()
    " Unfocus NvimTree before changing tabs so that tabline titles are more meaningful
    autocmd TabLeave NvimTree wincmd p
  augroup END
]]
