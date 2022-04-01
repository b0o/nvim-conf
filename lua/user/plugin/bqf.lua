---- kevinhwang91/nvim-bqf
local M = {}

local loaded_preview_bufs = {}

local function cleanup_preview_bufs(qwinid)
  for _, buf in ipairs(loaded_preview_bufs[qwinid]) do
    if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_buf_get_option(buf, "modified") then
      goto continue
    end
    vim.api.nvim_buf_delete(buf, { unload = false })
    ::continue::
  end
  loaded_preview_bufs[qwinid] = nil
end

local traps = {}
local function trap_cleanup(qwinid)
  if traps[qwinid] then
    return
  end
  traps[qwinid] = true
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(qwinid),
    callback = function()
      cleanup_preview_bufs(qwinid)
      traps[qwinid] = nil
    end,
    once = true,
    desc = "Clean up quickfix preview buffers",
  })
end

local function register_preview_buf(qwinid, fbufnr)
  loaded_preview_bufs[qwinid] = loaded_preview_bufs[qwinid] or {}
  table.insert(loaded_preview_bufs[qwinid], fbufnr)
  trap_cleanup(qwinid)
end

local fugitive_pv_timer
local preview_fugitive = function(bufnr, qwinid, bufname)
  local is_loaded = vim.api.nvim_buf_is_loaded(bufnr)
  if fugitive_pv_timer and fugitive_pv_timer:get_due_in() > 0 then
    fugitive_pv_timer:stop()
    fugitive_pv_timer = nil
  end
  fugitive_pv_timer = vim.defer_fn(function()
    if not is_loaded then
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd(('do fugitive BufReadCmd %s'):format(bufname))
      end)
    end
    require('bqf.preview.handler').open(qwinid, nil, true)
    local fbufnr = require('bqf.preview.session').floatBufnr()
    vim.api.nvim_buf_set_option(fbufnr, 'filetype', 'git')
    register_preview_buf(qwinid, bufnr)
  end, is_loaded and 0 or 60)
  return true
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
