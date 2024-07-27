local Debounce = require 'user.util.debounce'
local win_is_floating = require('user.util.api').win_is_floating

local group = vim.api.nvim_create_augroup('user', { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Set local highlight overrides on non-current windows
autocmd({ 'WinNew', 'WinLeave' }, {
  group = group,
  callback = function(event)
    if win_is_floating(0) then
      return
    end
    local ft = vim.bo[event.buf].filetype
    if ft == 'NvimTree' then
      return
    end
    vim.cmd [[setlocal winhl=CursorLine:CursorLineNC,CursorLineNr:CursorLineNrNC]]
  end,
})
autocmd('WinEnter', {
  group = group,
  callback = function(event)
    if win_is_floating(0) then
      return
    end
    local ft = vim.bo[event.buf].filetype
    if ft == 'NvimTree' then
      return
    end
    vim.cmd [[setlocal winhl=]]
    vim.b.user_winhl = true
  end,
})

local rwins_cursormoved_autocmd, rwins_modechanged_autocmd
local update_recent_wins = Debounce(function()
  pcall(vim.api.nvim_del_autocmd, rwins_cursormoved_autocmd)
  pcall(vim.api.nvim_del_autocmd, rwins_modechanged_autocmd)
  require('user.util.recent-wins').update()
end, { threshold = 500, mode = 'rolling' })

autocmd('WinLeave', {
  group = group,
  callback = function()
    update_recent_wins()
    pcall(vim.api.nvim_del_autocmd, rwins_cursormoved_autocmd)
    pcall(vim.api.nvim_del_autocmd, rwins_modechanged_autocmd)
    local first = true
    rwins_cursormoved_autocmd = autocmd('CursorMoved', {
      callback = function()
        if first then
          first = false
          return
        end
        update_recent_wins:immediate()
      end,
    })
    rwins_modechanged_autocmd = autocmd('ModeChanged', {
      callback = function()
        update_recent_wins:immediate()
      end,
      once = true,
    })
  end,
})

autocmd('FocusGained', {
  group = group,
  callback = function()
    vim.g.nvim_focused = true
  end,
})
autocmd('FocusLost', {
  group = group,
  callback = function()
    vim.g.nvim_focused = false
  end,
})

autocmd('TextYankPost', {
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})
autocmd('TermOpen', {
  group = group,
  command = [[setlocal scrolloff=0]],
})
autocmd('WinEnter', {
  group = group,
  pattern = 'term://*',
  callback = vim.schedule_wrap(function()
    vim.cmd 'startinsert'
  end),
})

------ Plugins

---- kyazdani42/nvim-tree.lua
autocmd('BufEnter', {
  group = group,
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
