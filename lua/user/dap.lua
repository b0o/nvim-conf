local dap = require 'dap'

local M = {
  launchers = {},
  closers = {},
}

---- Lua
local lua_conf = {
  host = '127.0.0.1',
  port = 57801,
  log = false,
}
dap.configurations.lua = {
  {
    type = 'nlua',
    request = 'attach',
    name = 'Attach to running Neovim instance',
    host = lua_conf.host,
    port = lua_conf.port,
  },
}
dap.adapters.nlua = function(callback, config)
  callback { type = 'server', host = config.host, port = config.port }
end
M.nlua_launch = function()
  require('osv').launch(lua_conf)
end
M.launchers.nlua = function()
  --   require('osv').launch(lua_conf)
  local terminal = (os.getenv 'TERMINAL') or 'alacritty'
  local cmd = {
    terminal,
    '-e',
    'nvim',
    '--cmd',
    'set noswapfile',
    '-c',
    'lua require"user.dap".nlua_launch()',
    '+' .. vim.fn.getcurpos()[2],
    vim.fn.expand '%:p',
  }
  M.job = vim.fn.jobstart(cmd)
  vim.wait(500, function()
    vim.fn.system(('nc -z %s %d'):format(lua_conf.host, lua_conf.port))
    return vim.v.shell_error == 0
  end)
  vim.cmd 'sleep 500m'
end
M.closers.nlua = function()
  require('osv').stop()
end

-- Chrome
local js_chrome_conf = {
  port = 9222,
}
dap.adapters.chrome = {
  type = 'executable',
  command = 'node',
  args = { os.getenv 'GIT_PROJECTS_DIR' .. '/vscode-chrome-debug/out/src/chromeDebug.js' },
}
dap.configurations.javascript = {
  {
    type = 'chrome',
    request = 'attach',
    program = '${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    port = js_chrome_conf.port,
    webRoot = '${workspaceFolder}',
  },
}
M.launchers.chrome = function()
  vim.fn.system('lsof -i :' .. js_chrome_conf.port)
  if vim.v.shell_error == 0 then
    print 'Already started'
    return
  end
  local cmd = {
    'chromium',
    '--user-data-dir=$XDG_CONFIG_HOME/chromium-dap',
    '--remote-debugging-port=' .. js_chrome_conf.port,
    '--auto-open-devtools-for-tabs ',
  }
  if os.getenv 'WAYLAND_DISPLAY' then
    vim.list_extend(cmd, {
      '--enable-features=UseOzonePlatform',
      '--ozone-platform=wayland',
    })
  end

  local html = [[
    <html>
      <head>
        <title>Debug Adapter</title>
        <style>
          body{
            color: #ffffff;
            background: #111111;
          }
        </style>
      </head>
      <body>
        <h1>Debug Adapter</h1>
        <script src="http://localhost:19222/const-try.js"></script>
      </body>
    </html>
  ]]

  table.insert(cmd, ('"data:text/html;base64,%s"'):format(require('base64').encode(html)))
  M.job = vim.fn.jobstart(cmd)
end

local is_attached = false

dap.listeners.before['event_initialized']['user'] = function()
  if not is_attached then
    require('user.mappings').on_dap_attach()
    is_attached = true
  end
end

dap.listeners.after['event_exited']['user'] = function()
  if is_attached then
    require('user.mappings').on_dap_detach()
    is_attached = false
  end
end

dap.listeners.after['event_terminated']['user'] = function()
  if is_attached then
    require('user.mappings').on_dap_detach()
    is_attached = false
  end
end

function M.launch(ft)
  if not dap.configurations[ft] then
    print('No DAP configurations found for ' .. ft)
    return
  end
  for _, config in ipairs(dap.configurations[ft]) do
    if config.type and M.launchers[config.type] then
      M.launchers[config.type]()
    end
    dap.run(config)
  end
end

function M.close(ft)
  if not dap.configurations[ft] then
    print('No DAP configurations found for ' .. ft)
    return
  end
  for _, config in ipairs(dap.configurations[ft]) do
    if config.type and M.launchers[config.type] then
      M.closers[config.type]()
    end
  end
  dap.disconnect { restart = false, terminateDebuggee = false }
  dap.close()
  if M.job then
    vim.fn.jobstop(M.job)
  end
end

return M
