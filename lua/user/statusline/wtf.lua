local M = {}

function M.wtf()
  local wtf = package.loaded['wtf']
  if not wtf then
    return ''
  end
  return wtf.get_status()
end

local register = require('user.statusline.providers').register

register('wtf', M.wtf)

return M
