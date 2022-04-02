local M = {}

local fn = require 'user.fn'

-- Re-compile Packer on write plugins.lua
local plugins_conf_path = vim.fn.stdpath 'config' .. '/lua/user/plugins.lua'

fn.tmpl_cmd(
  [[
  augroup user_packer
    autocmd!
    autocmd BufWritePost ${1} lua vim.schedule(require'user.fn'.packer_compile)
    autocmd User PackerCompileDone lua vim.notify("Packer configuration recompiled")
  augroup END
]],
  { plugins_conf_path }
)

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
    " Keep track of recent windows
    autocmd WinLeave * lua require'user.util.recent-wins'.update()
    " Set local highlight overrides on non-current windows
    autocmd WinNew,WinLeave * setlocal winhl=CursorLine:CursorLineNC,CursorLineNr:CursorLineNrNC
    autocmd WinEnter * setlocal winhl=
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
    " automatically close the tab/vim when nvim-tree is the last window
    autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
  augroup END
]]

return M
