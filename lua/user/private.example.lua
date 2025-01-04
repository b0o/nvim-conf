-- Copy this file to lua/user/private.lua and edit it to add your private configuration.
-- lua/user/private.lua is ignored by git.

---@class PrivateConfig
---@field openai_api_key string
---@field groq_api_key string
---@field cerebras_api_key string
---@field anthropic_api_key string
---@field deepinfra_api_key string
---@field obsidian_vault obsidian.workspace.WorkspaceSpec
local M = {}

M.openai_api_key = 'sk-xxxxxxxxxxxxxxxxxxxx'
M.groq_api_key = 'gsk_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
M.cerebras_api_key = 'csk-xxxxxxxxxxxxxxxxxxxx'
M.anthropic_api_key = 'sk-xxxxxxxxxxxxxxxxxxxx'
M.deepinfra_api_key = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
M.obsidian_vault = {
  name = 'name',
  path = '/path/to/obsidian/vault',
}

return M
