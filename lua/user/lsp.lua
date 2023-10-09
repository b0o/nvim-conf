local user_lsp_status = require 'user.statusline.lsp'
local nvim_cmp_lsp = require 'cmp_nvim_lsp'
local fn = require 'user.fn'
local root_pattern = require('lspconfig.util').root_pattern
local ui = require 'user.ui'

local methods = vim.lsp.protocol.Methods

local M = {
  fmt_on_save_enabled = false,
  border = ui.border,
  signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' },
  on_attach_called = false,
  inlay_hints_enabled_global = false,
  inlay_hints_enabled = {},
}

local lsp_servers = {
  {
    'bashls',
    cmd_env = { SHELLCHECK_PATH = '' },
  },
  {
    'clangd',
    filetypes = {
      'c',
      'cpp',
      'objc',
      'objcpp',
      'cuda',
    },
  },
  'cmake',
  {
    'cssls',
    settings = {
      css = { validate = false },
      scss = { validate = false },
      less = { validate = false },
    },
  },
  {
    'dockerls',
    formatting = false,
  },
  'dotls',
  {
    'eslint',
    cmd = { 'vscode-eslint-language-server-local', '--stdio' },
    root_dir = root_pattern(
      'eslint.config.js',
      '.eslintrc',
      '.eslintrc.js',
      '.eslintrc.cjs',
      '.eslintrc.yaml',
      '.eslintrc.yml',
      '.eslintrc.json',
      'package.json'
    ),
    settings = {
      experimentalUseFlatConfig = true,
      codeAction = {
        disableRuleComment = {
          enable = true,
          location = 'separateLine',
        },
        showDocumentation = {
          enable = true,
        },
      },
      codeActionOnSave = {
        enable = false,
        mode = 'all',
      },
      format = false,
      onIgnoredFiles = 'off',
      packageManager = 'npm',
      quiet = false,
      rulesCustomizations = {},
      run = 'onType',
      validate = 'on',
      workingDirectory = {
        mode = 'location',
      },
    },
  },
  {
    'gopls',
    formatting = false,
  },
  'hie',
  'html',
  {
    'jsonls',
    formatting = false,
    commands = {
      Format = {
        function()
          M.range_formatting({}, { 0, 0 }, { vim.fn.line '$', 0 })
        end,
      },
    },
    settings = fn.lazy_table(function()
      return {
        json = {
          schemas = require('schemastore').json.schemas(),
        },
        validate = { enable = true },
      }
    end),
  },
  {
    'ocamllsp',
    root_dir = root_pattern('*.opam', 'esy.json', 'package.json', '.git', '.merlin'),
  },
  {
    'pyright',
    formatting = false,
  },
  {
    'ruff_lsp',
    hover = false,
  },
  'rust_analyzer',
  'rnix',
  -- 'sqls',
  {
    'lua_ls',
    cmd = {
      'lua-language-server',
      '-E',
      '/usr/lib/lua-language-server/main.lua',
      '--metapath="' .. vim.fn.stdpath 'cache' .. '/lua-language-server/meta"',
    },
    settings = {
      Lua = {
        telemetry = {
          enable = false,
        },
        workspace = {
          checkThirdParty = false,
        },
      },
    },
  },
  {
    'tailwindcss',
    root_dir = root_pattern(
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.ts',
      'postcss.config.js',
      'postcss.config.ts'
    ),
    settings = {
      scss = {
        validate = false,
      },
      editor = {
        quickSuggestions = { strings = true },
        autoClosingQuotes = 'always',
      },
      tailwindCSS = {
        experimental = {
          classRegex = {
            [[[\S]*ClassName="([^"]*)]], -- <MyComponent containerClassName="..." />
            [[[\S]*ClassName={"([^"}]*)]], -- <MyComponent containerClassName={"..."} />
            [[[\S]*ClassName={"([^'}]*)]], -- <MyComponent containerClassName={'...'} />
          },
        },
        includeLanguages = {
          typescript = 'javascript',
          typescriptreact = 'javascript',
        },
      },
    },
  },
  'vimls',
  {
    'yamlls',
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        schemaStore = {
          enable = true,
          -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
          url = '',
        },
        schemas = require('schemastore').yaml.schemas(),
      },
    },
  },
  'zls',
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
    if vim.tbl_islist(result) then
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

---- ray-x/lsp_signature.nvim
local lsp_signature_config = {
  zindex = 99, -- Keep signature popup below the completion PUM
  bind = false,
  floating_window = false, -- Disable by default, use toggle_key to enable
  hint_enable = false,
  toggle_key = '<M-s>',
}

local function on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  user_lsp_status.on_attach(client, bufnr)

  -- Enable inlay hints if the client supports it.
  -- Credit @MariaSolOs:
  -- https://github.com/MariaSolOs/dotfiles/blob/8607ace4af5eb2e9001b3f14870c2ffc937f4dcd/.config/nvim/lua/lsp.lua#L118
  if client.supports_method(methods.textDocument_inlayHint) then
    local inlay_hints_group = vim.api.nvim_create_augroup('InlayHints', { clear = true })

    -- Initial inlay hint display.
    if M.inlay_hints_enabled[bufnr] == nil then
      M.inlay_hints_enabled[bufnr] = M.inlay_hints_enabled_global
    end
    vim.lsp.inlay_hint(bufnr, M.inlay_hints_enabled[bufnr])

    vim.api.nvim_create_autocmd('InsertEnter', {
      group = inlay_hints_group,
      buffer = bufnr,
      callback = function()
        if M.inlay_hints_enabled[bufnr] then
          vim.lsp.inlay_hint(bufnr, false)
        end
      end,
    })
    vim.api.nvim_create_autocmd('InsertLeave', {
      group = inlay_hints_group,
      buffer = bufnr,
      callback = function()
        if M.inlay_hints_enabled[bufnr] then
          vim.lsp.inlay_hint(bufnr, true)
        end
      end,
    })
  end

  vim.schedule(function()
    require('user.mappings').on_lsp_attach(bufnr)
  end)
end

local function on_first_attach()
  require('null-ls').setup(vim.tbl_extend('force', require 'user.plugin.null-ls', {
    on_attach = on_attach,
  }))
  require('lsp_signature').setup(lsp_signature_config)
end

local function on_attach_wrapper(...)
  if not M.on_attach_called then
    -- selene: allow(mismatched_arg_count)
    ---@diagnostic disable-next-line: redundant-parameter
    on_first_attach(...)
    M.on_attach_called = true
  end
  return on_attach(...)
end

M.on_attach = on_attach_wrapper

local function on_exit(code, signal, id)
  user_lsp_status.on_exit(code, signal, id)
end

function M.peek_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/definition', params, function(_, result)
    if result == nil or vim.tbl_isempty(result) then
      return
    end
    vim.lsp.util.preview_location(result[1])
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
  bufnr = fn.resolve_bufnr(bufnr)
  if status == nil then
    status = not M.inlay_hints_enabled[bufnr]
  end
  M.inlay_hints_enabled[bufnr] = status
  vim.lsp.inlay_hint(bufnr, status)
end

local function setup_neodev()
  require('neodev').setup {
    library = {
      vimruntime = true,
      types = true,
      plugins = { 'neotest' },
    },
  }
end

local function lsp_init()
  setup_neodev()
  vim.lsp.set_log_level(vim.lsp.log_levels.WARN)
  for k, v in pairs(lsp_handlers) do
    vim.lsp.handlers[k] = v
  end
  for type, icon in pairs(M.signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
  end
  local capabilities = nvim_cmp_lsp.default_capabilities()
  local lspconfig = require 'lspconfig'
  for _, lsp in ipairs(lsp_servers) do
    local opts = {
      on_attach = on_attach_wrapper,
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
        opts.on_attach = function(client, ...)
          client.server_capabilities.documentFormattingProvider = lsp.formatting
          client.server_capabilities.documentRangeFormattingProvider = lsp.formatting
          return on_attach_wrapper(client, ...)
        end
        lsp.formatting = nil
      end
      if lsp.hover ~= nil then
        opts.on_attach = function(client, ...)
          client.server_capabilities.hoverProvider = lsp.hover
          return on_attach_wrapper(client, ...)
        end
        lsp.hover = nil
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

lsp_init()

return M
