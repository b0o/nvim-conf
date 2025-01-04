local ok, private = require 'user.private'
if not ok then
  vim.notify('failed to load lua/user/private.lua', vim.log.levels.WARN)
  private = {}
end

---@cast private PrivateConfig
return private
