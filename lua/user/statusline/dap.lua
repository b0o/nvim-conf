local M = {}

local icons = {
  status = ' ﴫ ',
}

function M.status_clients()
  return function()
    local udap = package.loaded['user.dap']
    if not udap then
      return ''
    end
    local session = require('dap').session()
    return session ~= nil and session.config ~= nil and session.config.type or '', icons.status
  end
end

local register = require('user.statusline.providers').register

register('dap_clients', M.status_clients())

return M
