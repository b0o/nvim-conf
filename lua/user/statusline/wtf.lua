local wtf = require 'wtf'

local M = {}

function M.wtf()
  return wtf.get_status()
end

local register = require('user.statusline.providers').register

register('wtf', M.wtf)

return M
