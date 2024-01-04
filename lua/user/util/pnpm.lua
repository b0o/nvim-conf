-- Originally based on https://github.com/lukahartwig/pnpm.nvim
-- Copyright 2023 Maddison Hellstrom
-- Copyright 2023 Luka Hartwig
-- MIT License
local Path = require 'plenary.path'

local M = {}

local cache = { workspaces = {} }

local function cwd()
  return Path:new(vim.loop.cwd())
end

M.get_workspace_package_paths = function(root_dir)
  root_dir = root_dir:absolute()
  if not cache.workspaces[root_dir] then
    local handle = io.popen 'pnpm ls --recursive --depth -1 --parseable'
    if handle == nil then
      return
    end
    local paths = {}
    for path in handle:lines() do
      table.insert(paths, Path:new(path))
    end
    handle:close()
    cache.workspaces[root_dir] = paths
  end
  return vim.deepcopy(cache.workspaces[root_dir])
end

M.get_pnpm_root_path = function(start_path)
  local ws = vim.fs.find('pnpm-workspace.yaml', {
    path = start_path:absolute(),
    upward = true,
    type = 'file',
  })[1]
  if ws == nil then
    return
  end
  return Path:new(ws):parent()
end

M.get_package_info = function(path, opts)
  opts = opts or {}
  opts.root = opts.root and Path:new(opts.root) or nil
  path = Path:new(path)
  local package_json = (path / 'package.json'):read()
  local package_meta = vim.fn.json_decode(package_json)
  local root = opts.root and path:absolute() == opts.root:absolute()
  local current = path:absolute() == cwd():absolute()
  local focused = not root
    and opts.focused_path
    and vim.startswith(Path:new(opts.focused_path):absolute(), path:absolute())
  local relative_path = string.sub(path:absolute(), #opts.root:absolute() + 2)
  return {
    name = package_meta.name,
    path = path,
    relative_path = relative_path,
    focused = focused,
    current = current,
    root = root,
  }
end

M.clear_cache = function()
  cache.workspaces = {}
end

M.get_workspace_info = function(opts)
  opts = opts or {}
  opts.focused_path = opts.focused_path and Path:new(opts.focused_path) or nil
  if opts.refresh then
    M.clear_cache()
  end
  local root_dir = M.get_pnpm_root_path(opts.focused_path)
  if root_dir == nil then
    return
  end
  local paths = M.get_workspace_package_paths(root_dir)
  if paths == nil then
    return
  end
  local res = {
    root = nil,
    focused = nil,
    packages = {},
  }
  for _, path in ipairs(paths) do
    local package = M.get_package_info(path, {
      focused_path = opts.focused_path,
      root = root_dir,
    })
    table.insert(res.packages, package)
    if package.root then
      res.root = package
      if not res.focused then
        res.focused = package
      end
    end
    if package.focused then
      res.focused = package
    end
  end
  return res
end

return M
