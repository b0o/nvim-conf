local M = {
  providers = {},
}

function M.register(name, provider)
  M.providers[name] = provider
end

return M
