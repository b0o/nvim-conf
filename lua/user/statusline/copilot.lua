local M = {}

function M.codegpt_status()
  local copilot = package.loaded['user.plugin.copilot']
  if not copilot then
    return ''
  end
  if not copilot.status or copilot.status == 'Normal' then
    return ''
  end
  if copilot.status == 'InProgress' then
    return 'Thinking...', '🤖'
  end
  if copilot.status == 'Offline' then
    return 'Copilot Offline', ''
  end
  if copilot.status == 'Warning' then
    return 'Copilot Warning', ''
  end
  return ''
end

local register = require('user.statusline.providers').register

register('copilot', M.codegpt_status)

return M
