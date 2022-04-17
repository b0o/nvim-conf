---- b0o/incline.nvim
require('incline').setup {
  render = function(props)
    local bufname = vim.api.nvim_buf_get_name(props.buf)
    if bufname == '' then
      return '[No name]'
    else
      bufname = vim.fn.fnamemodify(bufname, ':t')
    end
    return bufname
  end,
  debounce_threshold = 30,
  window = {
    width = 'fit',
    placement = { horizontal = 'right', vertical = 'top' },
    margin = {
      horizontal = { left = 1, right = 1 },
      vertical = { bottom = 0, top = 1 },
    },
    padding = { left = 1, right = 1 },
    padding_char = ' ',
    zindex = 100,
  },
  ignore = {
    floating_wins = true,
    unlisted_buffers = true,
    filetypes = {},
    buftypes = 'special',
    wintypes = 'special',
  },
}
