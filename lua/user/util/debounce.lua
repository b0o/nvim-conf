local M = {}
local Debounce = {}

Debounce.call = function(self, ...)
  if self.timer and self.timer:get_due_in() > 0 then
    self.timer:stop()
    self.timer = nil
  end
  local args = { ... }
  self.timer = vim.defer_fn(function()
    self:immediate(unpack(args))
  end, self.opts.threshold)
end

Debounce.immediate = function(self, ...)
  if self.timer and self.timer:get_due_in() > 0 then
    self.timer:stop()
    self.timer = nil
  end
  self.fn(...)
end

M.make = function(fn, opts)
  opts = vim.tbl_extend('force', {
    threshold = 100,
  }, opts or {})
  return setmetatable({
    fn = fn,
    opts = opts,
  }, { __index = Debounce, __call = Debounce.call })
end

return M
