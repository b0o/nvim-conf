---- kevinhwang91/nvim-bqf
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
    vim.api.nvim_buf_set_option(require('bqf.preview.session').float_bufnr(), 'filetype', 'git')
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
