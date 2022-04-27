-- TODO: Use packer set_handler extension rather than manually manipulating the plugin table
-- SEE: :help packer-extending
local M = { lazymods = {}, telescope_exts = {} }

local packer = require('user.util.lazy').require_on_call_rec 'packer'

M.install_or_sync = function()
  local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    print('Installing Packer at ' .. install_path)
    vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    print 'Packer has been installed. Please restart Neovim.'
    if vim.fn.input {
      prompt = 'Press ENTER to exit',
      cancelreturn = 'ESC',
    } == '' then
      vim.cmd [[quitall]]
    end
  else
    print 'Installing plugins'
    vim.api.nvim_create_autocmd('User', {
      pattern = 'PackerComplete',
      callback = function()
        print 'Plugins installed. Please restart Neovim.'
        if vim.fn.input {
          prompt = 'Press ENTER to exit',
          cancelreturn = 'ESC',
        } == '' then
          vim.cmd [[quitall]]
        end
      end,
    })
    require 'user.plugins'
    packer.sync()
  end
end

local function escape_module_for_pattern(mod)
  return string.gsub(mod, '[%^%$%(%)%%%.%[%]%*%+%?%-]', '%%%1')
end

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
    local mod_escaped = escape_module_for_pattern(lazymod.mod or lazymod[1])
    lazymod.module_pattern = {
      '^' .. mod_escaped .. '$',
      '^' .. mod_escaped .. '%.',
    }
  end

  p.module = p.module or {}
  p.module = type(p.module) == 'table' and p.module or { p.module }
  vim.list_extend(p.module, lazymod.module or {})
  if type(p.module) == 'string' then
    p.module = { p.module }
  end

  p.module_pattern = p.module_pattern or {}
  p.module_pattern = type(p.module_pattern) == 'table' and p.module_pattern or { p.module_pattern }
  vim.list_extend(p.module_pattern, lazymod.module_pattern or {})
  if type(p.module_pattern) == 'string' then
    p.module_pattern = { p.module_pattern }
  end

  if #p.module == 0 then
    p.module = nil
  end
  if #p.module_pattern == 0 then
    p.module_pattern = nil
  end

  if p.module and #p.module > 0 and p.module_pattern and #p.module_pattern > 0 then
    vim.list_extend(p.module_pattern, vim.tbl_map(escape_module_for_pattern, p.module))
    p.module = nil
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
      pcall(require, 'user.plugin.' .. (lazymod.conf or p.conf or lazymod[1]))
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
    if p.telescope_ext then
      p.module = p.module or {}
      p.module = type(p.module) == 'table' and p.module or { p.module }
      table.insert(p.module, 'telescope._extensions.' .. p.telescope_ext)
      table.insert(M.telescope_exts, p.telescope_ext)
      p.telescope_ext = nil
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
  if type(p) ~= 'table' then
    p = { p }
  end
  local extend = #{ ... } > 0 and vim.tbl_extend('force', {}, ...) or {}
  local path, short_path
  if not string.match(p[1], '^.?.?/') then
    local path_components = vim.split(p[1], '/')
    short_path = path_components[1] .. '/' .. path_components[2]
    extend.as = p.as or path_components[2]
    if vim.env.GIT_PROJECTS_DIR then
      path = vim.env.GIT_PROJECTS_DIR .. '/' .. table.concat(vim.list_slice(path_components, 2), '/')
    end
  end
  if vim.fn.isdirectory(path) then
    extend[1] = path
  elseif short_path then
    extend[1] = short_path
  else
    vim.notify('uselocal: path not found and unable to infer remote: ' .. tostring(p[1]), vim.log.levels.WARN)
    return
  end
  M.use(p, extend)
end

-- xuse disables the plugin
M.xuse = function(p)
  return M.use(p, {
    cond = function()
      return false
    end,
  })
end

-- xuse disables the plugin
M.xuselocal = function(p)
  return M.uselocal(p, {
    cond = function()
      return false
    end,
  })
end

return setmetatable(M, { __index = packer })
