---- numToStr/Comment.nvim
local state = {}

local ts_context_commentstring_pre_hook =
  require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()

require('Comment').setup {
  pre_hook = function(ctx, ...)
    -- If comment was triggered in visual mode, save the visual selection so it can be re-selected in post_hook
    if ctx.cmotion >= 3 and ctx.cmotion <= 5 then
      local c = vim.api.nvim_win_get_cursor(0)
      local m = {
        vim.api.nvim_buf_get_mark(0, '<'),
        vim.api.nvim_buf_get_mark(0, '>'),
      }
      if c[1] == m[1][1] then
        m = { m[2], m[1] }
      end
      state.marks = m
      state.cursor = c
      state.cursor_line_len = #(vim.api.nvim_buf_get_lines(0, c[1] - 1, c[1], true))[1]
    else
      state = {}
    end
    return ts_context_commentstring_pre_hook(ctx, ...) -- Adds support for JSX comments
  end,
  ---@diagnostic disable-next-line: unused-local
  post_hook = function(_ctx)
    vim.schedule(function()
      if state and state.marks and #state.marks > 0 then
        vim.api.nvim_buf_set_mark(0, '<', state.marks[1][1], state.marks[1][2], {})
        vim.api.nvim_buf_set_mark(0, '>', state.marks[2][1], state.marks[2][2], {})
        vim.cmd [[normal gv]]
        local c = state.cursor
        local diff = #(vim.api.nvim_buf_get_lines(0, c[1] - 1, c[1], true))[1] - state.cursor_line_len
        vim.api.nvim_win_set_cursor(0, { state.cursor[1], state.cursor[2] + diff })
        state = {}
      end
    end)
  end,
}

require('Comment.ft').set('capnp', { '#%s' })
require('Comment.ft').set('systemd', { '#%s' })
require('Comment.ft').set('jq', { '#%s' })
