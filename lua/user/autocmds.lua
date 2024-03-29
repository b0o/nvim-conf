local fn = require 'user.fn'
local Debounce = require 'user.util.debounce'

local augid = vim.api.nvim_create_augroup('user', { clear = true })
local autocmd = function(event, opts)
  return vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', { group = augid }, opts))
end

-- Set local highlight overrides on non-current windows
autocmd({ 'WinNew', 'WinLeave' }, {
  callback = function(event)
    if vim.bo[event.buf].filetype == 'NvimTree' then
      return
    end
    vim.cmd [[setlocal winhl=CursorLine:CursorLineNC,CursorLineNr:CursorLineNrNC]]
  end,
})
autocmd('WinEnter', {
  callback = function(event)
    if vim.bo[event.buf].filetype == 'NvimTree' then
      return
    end
    vim.cmd [[setlocal winhl=]]
  end,
})

local recent_wins = fn.require_on_call_rec 'user.util.recent-wins'
local rwins_cursormoved_autocmd, rwins_modechanged_autocmd
local update_recent_wins = Debounce(function()
  pcall(vim.api.nvim_del_autocmd, rwins_cursormoved_autocmd)
  pcall(vim.api.nvim_del_autocmd, rwins_modechanged_autocmd)
  recent_wins.update()
end, { threshold = 500, mode = 'rolling' })
autocmd('WinLeave', {
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

------ Filetypes
-- vitest snapshots
autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '**/__snapshots__/*.ts.snap', '**/__snapshots__/*.js.snap' },
  command = 'set filetype=jsonc',
})

------ Plugins

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
