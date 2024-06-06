local user_lsp_status = require 'user.util.lsp_status'
local nvim_cmp_lsp = require 'cmp_nvim_lsp'

local methods = vim.lsp.protocol.Methods

local M = {
  fmt_on_save_enabled = false,
  on_attach_called = false,
  inlay_hints_enabled_global = false,
  inlay_hints_enabled = {},
}

local lsp_handlers = {
  ['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
      source = 'if_many',
      severity = vim.diagnostic.severity.ERROR,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
  }),
  ['textDocument/definition'] = function(_, result, ctx)
    if result == nil or vim.tbl_isempty(result) then
      print 'Definition not found'
      return nil
    end
    local function jumpto(loc)
      local split_cmd = vim.uri_from_bufnr(0) == loc.targetUri and 'split' or 'tabnew'
      vim.cmd(split_cmd)
      vim.lsp.util.jump_to_location(loc, ctx.client.offset_encoding)
    end
    if vim.islist(result) then
      jumpto(result[1])
      if #result > 1 then
        vim.fn.setqflist(vim.lsp.util.locations_to_items(result, ctx.client.offset_encoding))
        vim.api.nvim_command 'copen'
        vim.api.nvim_command 'wincmd p'
      end
    else
      jumpto(result)
    end
  end,
}

local function on_attach(client, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  user_lsp_status.on_attach(client, bufnr)

  -- Enable inlay hints if the client supports it.
  -- Credit @MariaSolOs:
  -- https://github.com/MariaSolOs/dotfiles/blob/8607ace4af5eb2e9001b3f14870c2ffc937f4dcd/.config/nvim/lua/lsp.lua#L118
  if methods and client.supports_method(methods.textDocument_inlayHint) then
    local inlay_hints_group = vim.api.nvim_create_augroup('InlayHints', { clear = true })

    -- Initial inlay hint display.
    if M.inlay_hints_enabled[bufnr] == nil then
      M.inlay_hints_enabled[bufnr] = M.inlay_hints_enabled_global
    end
    vim.lsp.inlay_hint.enable(M.inlay_hints_enabled[bufnr], { bufnr = bufnr })

    vim.api.nvim_create_autocmd('InsertEnter', {
      group = inlay_hints_group,
      buffer = bufnr,
      callback = function()
        if M.inlay_hints_enabled[bufnr] then
          vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        end
      end,
    })
    vim.api.nvim_create_autocmd('InsertLeave', {
      group = inlay_hints_group,
      buffer = bufnr,
      callback = function()
        if M.inlay_hints_enabled[bufnr] then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end,
    })
  end
end

local function on_first_attach()
  vim.diagnostic.config {
    float = {
      border = 'rounded',
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.HINT] = ' ',
        [vim.diagnostic.severity.INFO] = ' ',
      },
    },
  }
end

M.on_attach = function()
  vim.notify('Error: user.lsp.on_attach: lsp.setup() has not been called yet', vim.log.levels.ERROR)
end

local function on_exit(code, signal, id)
  user_lsp_status.on_exit(code, signal, id)
end

function M.peek_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/definition', params, function(_, results)
    ---@type lsp.Location|lsp.LocationLink|nil
    local location = results and results[1]
    if not location then
      return
    end
    local range = location.range or location.targetRange
    if range then
      local lines = location.range['end'].line - location.range['start'].line + 1
      if lines < 20 then
        range['end'].line = range['start'].line + 20
        range['end'].character = 0
      end
    end
    vim.lsp.util.preview_location(location, { border = 'rounded' })
  end)
end

function M.set_inlay_hints_global(status)
  if status == nil then
    status = not M.inlay_hints_enabled_global
  end
  M.inlay_hints_enabled_global = status
  for bufnr, _ in pairs(M.inlay_hints_enabled) do
    M.set_inlay_hints(bufnr, status)
  end
end

function M.set_inlay_hints(bufnr, status)
  bufnr = require('user.util.api').resolve_bufnr(bufnr)
  if status == nil then
    status = not M.inlay_hints_enabled[bufnr]
  end
  M.inlay_hints_enabled[bufnr] = status
  vim.lsp.inlay_hint.enable(status, { bufnr = bufnr })
end

M.setup = function(config)
  config = config or {}
  local servers = config.servers
  if not servers then
    vim.notify('No lsp_servers specified in config', vim.log.levels.WARN)
    return
  end

  M.on_attach = function(client, bufnr)
    if not M.on_attach_called then
      if config.on_first_attach then
        config.on_first_attach(client, bufnr)
      end
      ---@diagnostic disable-next-line: redundant-parameter
      on_first_attach(client, bufnr)
      M.on_attach_called = true
    end
    if config.on_attach then
      config.on_attach(client, bufnr)
    end
    return on_attach(client, bufnr)
  end

  vim.lsp.set_log_level(vim.lsp.log_levels.WARN)

  for k, v in pairs(lsp_handlers) do
    vim.lsp.handlers[k] = v
  end

  local capabilities = nvim_cmp_lsp.default_capabilities()
  local lspconfig = require 'lspconfig'

  local function is_enabled(server)
    if type(server) == 'table' then
      return server.enabled ~= false
    end
    return true
  end

  for _, lsp in ipairs(vim.tbl_filter(is_enabled, servers)) do
    local opts = {
      on_attach = M.on_attach,
      on_exit = on_exit,
      flags = {
        debounce_text_changes = 150,
      },
      capabilities = capabilities,
    }
    local name = lsp
    if type(lsp) == 'table' then
      ---@diagnostic disable-next-line: cast-local-type
      name = lsp[1]
      if lsp.formatting ~= nil then
        opts.on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = lsp.formatting
          client.server_capabilities.documentRangeFormattingProvider = lsp.formatting
          return M.on_attach(client, bufnr)
        end
        lsp.formatting = nil
      end
      if lsp.hover ~= nil then
        opts.on_attach = function(client, bufnr)
          client.server_capabilities.hoverProvider = lsp.hover
          return M.on_attach(client, bufnr)
        end
        lsp.hover = nil
      end
      if lsp.on_attach ~= nil then
        local lsp_on_attach = lsp.on_attach
        local opts_on_attach = opts.on_attach
        opts.on_attach = function(client, bufnr)
          if lsp_on_attach(client, bufnr) == false then
            return false
          end
          return opts_on_attach(client, bufnr)
        end
        lsp.on_attach = nil
      end
      for k, v in pairs(lsp) do
        if k ~= 1 then
          opts[k] = v
        end
      end
    else
      name = lsp
    end
    if not lspconfig[name] then
      error('LSP: Server not found: ' .. name)
    end
    if type(lspconfig[name].setup) ~= 'function' then
      error('LSP: not a function: ' .. name .. '.setup')
    end
    lspconfig[name].setup(opts)
  end

  vim.cmd [[LspStart]]
end

return M
