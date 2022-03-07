---- chentau/marks.nvim
local M = {}

local marks = require 'marks'
local mapx = require 'mapx'

marks.setup {
  -- whether to map keybinds or not. default true
  default_mappings = true,
  -- which builtin marks to show. default {}
  builtin_marks = { '<', '>', "'", '"', '^', '.' },
  -- whether movements cycle back to the beginning/end of buffer. default true
  cyclic = true,
  -- whether the shada file is updated after modifying uppercase marks. default false
  force_write_shada = false,
  -- how often (in ms) to redraw signs/recompute mark positions.
  -- higher values will have better performance but may cause visual lag,
  -- while lower values may cause performance penalties. default 150.
  refresh_interval = 250,
  -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
  -- marks, and bookmarks.
  -- can be either a table with all/none of the keys, or a single number, in which case
  -- the priority applies to all marks.
  -- default 10.
  signs = false,

  sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
  -- disables mark tracking for specific filetypes. default {}
  excluded_filetypes = { '', 'Nui', 'TelescopePrompt' },
  -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
  -- sign/virttext. Bookmarks can be used to group together positions and quickly move
  -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
  -- default virt_text is "".
  -- bookmark_0 = {
  --   sign = "⚑",
  --   virt_text = "hello world"
  -- },
  mappings = {},
}

M.get_buf_state = function(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  return marks.mark_state.opt.buf_signs[bufnr]
end

M.set_buf_state = function(bufnr, state)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  marks.mark_state.opt.buf_signs[bufnr] = state
  marks.bookmark_state.opt.buf_signs[bufnr] = state
  marks.refresh(true)
end

local function marks_map(lhs)
  mapx.nnoremap(lhs, function()
    local bufnr = vim.api.nvim_get_current_buf()
    local state = M.get_buf_state(bufnr)
    if not state then
      M.set_buf_state(bufnr, true)
    end
    vim.api.nvim_del_keymap('n', lhs)
    require('which-key').show(lhs)
    if not state then
      M.set_buf_state(bufnr, state)
    end
    marks_map(lhs)
  end, 'Goto mark')
end

marks_map "'"
marks_map '"'

return M
