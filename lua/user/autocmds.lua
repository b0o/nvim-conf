local M = {}

local fn = require 'user.fn'

local augid = vim.api.nvim_create_augroup('user', { clear = true })
local autocmd = function(event, opts)
  return vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', { group = augid }, opts))
end

-- Set local highlight overrides on non-current windows
autocmd({ 'WinNew', 'WinLeave' }, { command = [[setlocal winhl=CursorLine:CursorLineNC,CursorLineNr:CursorLineNrNC]] })
autocmd('WinEnter', { command = [[setlocal winhl=]] })

autocmd('WinLeave', {
  callback = function()
    require('user.util.recent-wins').update()
  end,
})

autocmd('FocusGained', {
  callback = function()
    vim.g.nvim_focused = true
  end,
})
autocmd('FocusLost', {
  callback = function()
    vim.g.nvim_focused = false
  end,
})

autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
})
autocmd('TermOpen', { command = [[setlocal scrolloff=0]] })
autocmd('BufEnter', { pattern = 'term://*', command = [[call user#fn#termEnter(1)]] })
autocmd('TermClose', { pattern = 'term://*', command = [[call user#fn#closeBufWins(expand('<abuf>'))]] })

------ Plugins

---- wbthomason/packer.nvim
autocmd('BufWritePost', {
  pattern = vim.fn.stdpath 'config' .. '/lua/user/plugins.lua',
  callback = function()
    vim.schedule(require('user.fn').packer_compile)
  end,
})

autocmd('User', {
  pattern = 'PackerCompileDone',
  callback = function()
    vim.notify 'Packer configuration recompiled'
  end,
})

---- kyazdani42/nvim-tree.lua
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
