print 'required test.lua'

-- local M
-- M = setmetatable({}, {
--   __index = function(_, k)
--     print('index', k)
--     return M
--   end,
--   __call = function(_, ...)
--     print('call', ...)
--     return M
--   end,
-- })
--
-- return M

return {
  foo = {
    bar = {
      qux = print,
    },
  },
}
