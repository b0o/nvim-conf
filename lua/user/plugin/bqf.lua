---- kevinhwang91/nvim-bqf
local M = {}

local loaded_preview_bufs = {}

local function cleanup_preview_bufs(qwinid)
  for _, buf in ipairs(loaded_preview_bufs[qwinid]) do
    if vim.api.nvim_buf_is_valid(buf) and not vim.api.nvim_buf_get_option(buf, 'modified') then
      vim.api.nvim_buf_delete(buf, { unload = false })
    end
  end
  loaded_preview_bufs[qwinid] = nil
end

local traps = {}
local function trap_cleanup(qwinid)
  if traps[qwinid] then
    return
  end
  traps[qwinid] = true
  vim.api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(qwinid),
    callback = function()
      cleanup_preview_bufs(qwinid)
      traps[qwinid] = nil
    end,
    once = true,
    desc = 'Clean up quickfix preview buffers',
  })
end

local function register_preview_buf(qwinid, fbufnr)
  loaded_preview_bufs[qwinid] = loaded_preview_bufs[qwinid] or {}
  table.insert(loaded_preview_bufs[qwinid], fbufnr)
  trap_cleanup(qwinid)
end

local _preview_fugitive = require('user.util.debounce').make(function(bufnr, qwinid, bufname)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd(('do fugitive BufReadCmd %s'):format(bufname))
    end)
  end
  require('bqf.preview.handler').open(qwinid, nil, true)
  local fbufnr = require('bqf.preview.session').floatBufnr()
  if not fbufnr then
    return
  end
  vim.api.nvim_buf_set_option(fbufnr, 'filetype', 'git')
  register_preview_buf(qwinid, bufnr)
end, { threshold = 60 })

local preview_fugitive = function(bufnr, ...)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    _preview_fugitive:immediate(bufnr, ...)
    return true
  end
  _preview_fugitive(bufnr, ...)
  return false
end

require('bqf').setup {
  preview = {
    should_preview_cb = function(bufnr, qwinid)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname:match '^fugitive://' then
        return preview_fugitive(bufnr, qwinid, bufname)
      end
      return true
    end,
  },
  filter = {
    fzf = {
      extra_opts = { '--bind', 'ctrl-o:toggle-all', '--delimiter', '│' },
    },
  },
}

return M
