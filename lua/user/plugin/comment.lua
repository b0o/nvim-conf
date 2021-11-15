---- numToStr/Comment.nvim

local state = {}

require('Comment').setup {
  pre_hook = function(ctx)
    if ctx.cmotion >= 3 and ctx.cmotion <= 5 then
      state.marks = {
        vim.api.nvim_buf_get_mark(0, '<'),
        vim.api.nvim_buf_get_mark(0, '>'),
      }
    else
      state.marks = {}
    end
  end,

  post_hook = function(ctx)
    inspect { ctx = ctx, state = state }
    vim.schedule(function()
      if #state.marks > 0 then
        print(1)
        vim.api.nvim_buf_set_mark(0, '<', state.marks[1][1], state.marks[1][2], {})
        vim.api.nvim_buf_set_mark(0, '>', state.marks[2][1], state.marks[2][2], {})
        state.marks = {}
        vim.cmd [[normal gv]]
      end
    end)
  end,
}
