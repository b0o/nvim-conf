local M = {}

function M.codegpt_status()
  local codegpt = package.loaded['codegpt']
  if not codegpt then
    return ''
  end
  return codegpt.get_status(), '🤖'
end

local register = require('user.statusline.providers').register

register('codegpt', M.codegpt_status)

return M
