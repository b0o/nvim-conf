-- TODO: Use packer set_handler extension rather than manually manipulating the plugin table
-- SEE: :help packer-extending

-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer = require 'packer'

local M = {}

M.lazymods = {}
-- lazymods are lazily loaded packages that load a config file inside
-- lua/user/plugin/ on load.
-- Should not be called directly.
local function use_lazymod(p)
  p = vim.deepcopy(p)
  assert(not p.config, "user.plugins.use(): properties 'config' and 'lazymod' are mutually exclusive")

  local lazymod = p.lazymod
  p.lazymod = nil

  local t = type(lazymod)
  assert(
    vim.tbl_contains({ 'boolean', 'string', 'table' }, t),
    "user.plugins.use(): property 'lazymod' should be a boolean, string, or table"
  )

  local short_name = require('packer.util').get_plugin_short_name { p[1] }

  if lazymod == true then
    lazymod = { short_name }
  elseif type(lazymod) == 'string' then
    lazymod = { lazymod }
  end

  if not lazymod.module_pattern and lazymod.mod ~= false then
    local mod_escaped = string.gsub(lazymod.mod or lazymod[1], '[%^%$%(%)%%%.%[%]%*%+%?%-]', '%%%1')
    lazymod.module_pattern = {
      '^' .. mod_escaped .. '$',
      '^' .. mod_escaped .. '%.',
    }
  end

  p.module = lazymod.module or {}
  if type(p.module) == 'string' then
    p.module = { p.module }
  end

  p.module_pattern = lazymod.module_pattern or {}
  if type(p.module_pattern) == 'string' then
    p.module_pattern = { p.module_pattern }
  end

  if #p.module == 0 then
    p.module = nil
  end
  if #p.module_pattern == 0 then
    p.module_pattern = nil
  end

  local _config = p.config -- save the original config function

  p.config = function(name, conf) -- This callback is what will be compiled by packer
    local mod = require('user.packer').lazymods[name]
    if mod and mod.config then
      mod.config(name, conf, mod)
    end
  end

  M.lazymods[short_name] = {
    plugin = p,
    config = function(...) -- This callback will not be compiled by packer
      pcall(require, 'user.plugin.' .. lazymod[1])
      if _config then
        if type(_config) == 'string' then
          _config = loadstring(_config)
        end
        assert(type(_config) == 'function', "user.plugins.use(): expected 'config' to be a string or function")
        _config(...)
      end
    end,
  }

  return p
end

-- Same as packer.use() but:
-- - merges any extra tables on top of the plugin conf table
-- - truncates uselocal-style semi-relative paths like
--   b0o/mapx.nvim/worktree/current which to allow quickly swapping between use
--   and uselocal
-- - supports lazymods, see use_lazymod above
M.use = function(p, ...)
  if type(p) ~= 'table' then
    p = { p }
  end
  p = #{ ... } > 0 and vim.tbl_extend('force', p, ...) or p
  if not string.match(p[1], '^.?.?/') then
    local path = vim.split(p[1], '/')
    if #path > 2 then
      p[1] = table.concat(vim.list_slice(path, 1, 2), '/')
    end
  end
  if not p.disable then
    if p.conf then
      assert(not p.config, "user.plugins.use(): options 'config' and 'conf' are mutually exclusive")
      p.config = ("require('user.plugin.%s')"):format(p.conf)
      p.conf = nil
    end
    if p.lazymod then
      p = use_lazymod(p)
    end
  end
  packer.use(p)
end

-- Uselocal uses a plugin found inside $GIT_PROJECTS_DIR with the
-- shortname of the plugin as the subdirectory name. If more than two relative
-- path components are present, the extra ones refer to the path within the
-- plugin directory
-- For example, uselocal{ 'b0o/mapx.nvim/worktree/current' } resolves to
-- $GIT_PROJECTS_DIR/mapx.nvim/worktree/current.
M.uselocal = function(p, ...)
  local git_projects_dir = os.getenv 'GIT_PROJECTS_DIR'
  if git_projects_dir == nil then
    vim.notify('plugins.uselocal: missing environment variable: GIT_PROJECTS_DIR', vim.log.levels.ERROR)
    return
  end
  if type(p) ~= 'table' then
    p = { p }
  end
  local extend = #{ ... } > 0 and vim.tbl_extend('force', {}, ...) or {}
  if not string.match(p[1], '^.?.?/') then
    local path = vim.split(p[1], '/')
    extend.as = p.as or path[2]
    local realpath = git_projects_dir .. '/' .. table.concat(vim.list_slice(path, 2), '/')
    extend[1] = realpath
  end
  M.use(p, extend)
end

-- Same as use() but sets {disable=true}
---@diagnostic disable-next-line: unused-local,unused-function
M.xuse = function(p)
  return M.use(p, { disable = true })
end

-- Same as uselocal() but sets {disable=true}
---@diagnostic disable-next-line: unused-local,unused-function
M.xuselocal = function(p)
  return M.uselocal(p, { disable = true })
end

packer.init {
  max_jobs = tonumber(vim.fn.system 'nproc') or 8,
}

return setmetatable(M, {
  __index = function(self, k)
    local v = rawget(self, k)
    return v ~= nil and v or packer[k]
  end,
})
