local codegpt = require 'codegpt'

local M = {}

function M.codegpt_status()
  return codegpt.get_status(), '🤖'
end

local register = require('user.statusline.providers').register

register('codegpt', M.codegpt_status)

return M
