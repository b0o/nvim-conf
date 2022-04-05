local M = {}

local fn = require 'user.fn'

local augid = vim.api.nvim_create_augroup('user', { clear = true })
local autocmd = function(event, opts)
  return vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', { group = augid }, opts))
end

-- Set local highlight overrides on non-current windows
autocmd('WinNew,WinLeave', { command = [[setlocal winhl=CursorLine:CursorLineNC,CursorLineNr:CursorLineNrNC]] })
autocmd('WinEnter', { command = [[setlocal winhl=]] })

-- Keep track of recent windows
autocmd('WinLeave', {
  callback = function()
    require('user.util.recent-wins').update()
  end,
})

-- Set global variable g:nvim_focused to true when neovim is focused
autocmd('FocusGained', {
  callback = function()
    vim.g.nvim_focused = true
  end,
})

-- Set global variable g:nvim_focused to false when neovim loses focus
autocmd('FocusLost', {
  callback = function()
    vim.g.nvim_focused = false
  end,
})

-- Ensure the title is set immediately on load instead of whenever a file is loaded/changed/written
autocmd('VimEnter', { command = [[set title]] })

-- Highlight on yank
autocmd('TextYankPost', { callback = vim.highlight.on_yank })

-- Enter insert mode when entering a terminal buffer
autocmd('TermOpen', { command = [[setlocal scrolloff=0]] })

-- Enter insert mode when entering a terminal buffer
autocmd('BufEnter', { pattern = 'term://*', command = [[call user#fn#termEnter(1)]] })

-- Automatically close terminal windows when the terminal process exits
autocmd('TermClose', { pattern = 'term://*', command = [[call user#fn#closeBufWins(expand('<abuf>'))]] })

------ Plugins

---- wbthomason/packer.nvim
-- Re-compile Packer on write plugins.lua
autocmd('BufWritePost', {
  pattern = vim.fn.stdpath 'config' .. '/lua/user/plugins.lua',
  callback = function()
    vim.schedule(require('user.fn').packer_compile)
  end,
})

-- Notify after Packer compilation
autocmd('User', {
  pattern = 'PackerCompileDone',
  callback = function()
    vim.notify 'Packer configuration recompiled'
  end,
})

---- kyazdani42/nvim-tree.lua
-- Automatically close the tab/vim when nvim-tree is the last window
autocmd('BufEnter', {
  nested = true,
  callback = function()
    if
      #vim.api.nvim_tabpage_list_wins(0) == 1
      and vim.fn.bufname() == 'NvimTree_' .. vim.api.nvim_get_current_tabpage()
    then
      vim.api.nvim_win_close(0, false)
    end
  end,
})

---- TimUntersberger/neogit
-- Refresh Neogit when Fugitive changes something
autocmd('User', {
  pattern = 'FugitiveChanged',
  callback = function()
    local neogit = package.loaded.neogit
    if neogit then
      neogit.dispatch_refresh()
    end
  end,
})

return M
