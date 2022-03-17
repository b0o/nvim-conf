-- Re-compile Packer on write plugins.lua
local plugins_conf_path = vim.fn.stdpath 'config' .. '/lua/user/plugins.lua'

vim.cmd(([[
  augroup user_packer
    autocmd!
    autocmd BufWritePost %s lua vim.schedule(require'user.fn'.packer_compile)
    autocmd User PackerCompileDone lua vim.notify("Packer configuration recompiled")
  augroup END
]]):format(plugins_conf_path))

vim.cmd [[
  augroup user_misc
    autocmd!
    " Highlight on yank
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    " Ensure the title is set immediately on load instead of whenever a file is
    " loaded/changed/written
    autocmd VimEnter * set title
    " Set global variable g:nvim_focused to true when neovim is focused
    autocmd FocusGained * let g:nvim_focused = v:true
    " Set global variable g:nvim_focused to false when neovim loses focus
    autocmd FocusLost * let g:nvim_focused = v:false
    " Keep track of recent normal windows
    autocmd WinLeave * lua vim.schedule(require'user.fn'.update_recent_normal_wins)
  augroup END
]]

vim.cmd [[
  augroup user_lsp
    autocmd!
    " Check for code actions on cursorhold
    autocmd CursorHold,CursorHoldI * lua vim.schedule(function() require('user.lsp').code_action_listener() end)
  augroup END
]]

vim.cmd [[
  augroup user_term
    autocmd!
    " Enter insert mode when entering a terminal buffer
    autocmd BufEnter  term://* call user#fn#termEnter(1)
    " Automatically close terminal windows when the terminal process exits
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
  augroup user_nvim_tree
    autocmd!
    " Set up nvim tree highlights when an nvim tree buffer is created
    autocmd FileType NvimTree* ++once lua _G.nvim_tree_highlights()
  augroup END
]]
