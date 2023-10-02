local lsp_status = require 'lsp-status'
local lsp_format = require 'lsp-format'
local user_lsp_status = require 'user.statusline.lsp'
local nvim_cmp_lsp = require 'cmp_nvim_lsp'
local fn = require 'user.fn'
local root_pattern = require('lspconfig.util').root_pattern
local Debounce = require 'user.util.debounce'

local M = {
  fmt_on_save_enabled = false,
  border = { { '╭' }, { '─' }, { '╮' }, { '│' }, { '╯' }, { '─' }, { '╰' }, { '│' } },
  signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' },
  on_attach_called = false,
}

local format_timeout = 30000

M.format = function(opts)
  vim.lsp.buf.format(vim.tbl_extend('force', {
    timeout_ms = format_timeout,
    async = false,
  }, opts or {}))
end

M.range_formatting = function(opts, ...)
  return vim.lsp.buf.range_formatting(vim.tbl_extend('force', { timeout_ms = format_timeout }, opts or {}), ...)
end

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
  'prismals',
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
        completion = {
          callSnippet = 'Replace',
        },
        diagnostics = {
          globals = {
            -- Mapx.nvim globals
            'map',
            'nmap',
            'vmap',
            'xmap',
            'smap',
            'omap',
            'imap',
            'lmap',
            'cmap',
            'tmap',
            'noremap',
            'nnoremap',
            'vnoremap',
            'xnoremap',
            'snoremap',
            'onoremap',
            'inoremap',
            'lnoremap',
            'cnoremap',
            'tnoremap',
            'mapbang',
            'noremapbang',

            -- Mulberry BDD
            'Describe',
            'It',
            'Expect',
            'Which',
          },
        },
        telemetry = {
          enable = false,
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
        schemaStore = { enabled = true },
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
  -- ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = M.border }),
  ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = M.border }),
  ['window/showMessage'] = function(_, result, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local lvl = ({ 'ERROR', 'WARN', 'INFO', 'DEBUG' })[result.type]
    vim.notify(result.message, lvl, {
      title = 'LSP | ' .. client.name,
      timeout = 10000,
      keep = function()
        return lvl == 'ERROR' or lvl == 'WARN'
      end,
    })
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

---- lewis6991/hover.nvim
local hover_config = {
  init = function()
    require 'hover.providers.lsp'
    require 'hover.providers.gh'
    require 'hover.providers.man'
  end,
  preview_opts = {
    border = M.border,
  },
  preview_window = false,
  title = false,
}

local no_format_on_save_fts = {
  'gitcommit',
}

local function on_attach(client, bufnr)
  ---@diagnostic disable-next-line: redundant-parameter
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  user_lsp_status.on_attach(client, bufnr)

  ---@diagnostic disable-next-line: redundant-parameter
  if not vim.tbl_contains(no_format_on_save_fts, vim.api.nvim_buf_get_option(bufnr, 'filetype')) then
    lsp_format.on_attach(client, bufnr)
  end
  if client.server_capabilities.codeActionProvider then
    local augid = vim.api.nvim_create_augroup('user_lsp_code_actions', { clear = true })
    local cal_dbounce = Debounce(M.code_action_listener, { threshold = 500 })
    vim.api.nvim_create_autocmd('CursorHold', {
      buffer = bufnr,
      group = augid,
      callback = function(...)
        cal_dbounce(...)
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
  require('hover').setup(hover_config)
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

M.code_actions = {}
function M.code_action_listener()
  local bufnr = vim.api.nvim_get_current_buf()
  local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
  local params = vim.lsp.util.make_range_params()
  params.context = context
  pcall(vim.lsp.buf_request, bufnr, 'textDocument/codeAction', params, function(err, actions, result)
    if err or not result or not result.bufnr then
      return
    end
    M.code_actions[result.bufnr] = M.code_actions[result.bufnr] or {}
    M.code_actions[result.bufnr][result.client_id] = actions and #actions or 0
    M.code_actions[result.bufnr].count = nil
    local count = 0
    for _, sub_count in pairs(M.code_actions[result.bufnr]) do
      count = count + sub_count
    end
    M.code_actions[result.bufnr].count = count
  end)
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
  lsp_format.setup {
    typescript = {
      exclude = { 'typescript-tools' },
    },
    typescriptreact = {
      exclude = { 'typescript-tools' },
    },
    javascript = {
      exclude = { 'typescript-tools' },
    },
    javascriptreact = {
      exclude = { 'typescript-tools' },
    },
  }
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
    lsp_status.register_progress()
    lsp_status.config { current_function = false }
  end
end

lsp_init()

return M
