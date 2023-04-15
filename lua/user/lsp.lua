local lsp_status = require 'lsp-status'
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
local format_on_save_timeout = 2000

M.format = function(opts)
  return vim.lsp.buf.format(vim.tbl_extend('force', { timeout_ms = format_timeout }, opts or {}))
end

M.range_formatting = function(opts, ...)
  return vim.lsp.buf.range_formatting(vim.tbl_extend('force', { timeout_ms = format_timeout }, opts or {}), ...)
end

local lsp_servers = {
  {
    'bashls',
    cmd_env = { SHELLCHECK_PATH = '' },
  },
  -- 'ccls',
  {
    'clangd',
    filetypes = {
      'c',
      'cpp',
      'objc',
      'objcpp',
      'cuda',
      -- 'proto' -- clangd doesn't seem to work with proto files
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
  --   'denols', -- TODO: Prevent denols from starting in NodeJS projects
  'dockerls',
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
      format = true,
      -- nodePath = '',
      onIgnoredFiles = 'off',
      packageManager = 'npm',
      quiet = false,
      rulesCustomizations = {},
      run = 'onType',
      -- useESLintClass = false,
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
  -- 'graphql',
  'hie',
  'html',
  {
    'jsonls',
    formatting = false,
    -- cmd = {
    --   'node',
    --   '/usr/lib/code/extensions/json-language-features/server/dist/node/jsonServerMain.js',
    --   '--stdio',
    -- },
    commands = {
      Format = {
        function()
          M.range_formatting({}, { 0, 0 }, { vim.fn.line '$', 0 })
        end,
      },
    },
    settings = fn.lazy_table(function()
      return {
        json = { schemas = require('schemastore').json.schemas() },
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
    'pylsp',
    cmd = {
      'pylsp',
      '-vvvv',
      '--log-file',
      vim.fn.stdpath 'cache' .. '/pylsp.log',
    },
    settings = {
      pylsp = {
        plugins = {
          pylint = {
            enabled = true,
            args = {
              '-j0',
              '--load-plugins=pylint_paths',
              '--extension-pkg-whitelist=pygame', -- SEE: https://stackoverflow.com/questions/50569453/why-does-it-say-that-module-pygame-has-no-init-member
              '--generated-members=from_json,query,capnp', -- SEE: https://stackoverflow.com/questions/56844378/pylint-no-member-issue-but-code-still-works-vscode
            },
            executable = 'pylint', -- SEE: https://github.com/python-lsp/python-lsp-server/issues/251
          },
          yapf = { enabled = true },
          flake8 = { enabled = true },
          rope = { enabled = true },
          pylsp_mypy = { enabled = false },
          autopep8 = { enabled = false },
          pycodestyle = { enabled = false },
          pydocstyle = { enabled = false },
          pyflakes = { enabled = false },
        },
      },
    },
  },
  {
    'rescriptls',
    cmd = {
      'node',
      '--inspect',
      (function()
        if vim.env.GIT_PROJECTS_DIR then
          return vim.env.GIT_PROJECTS_DIR .. '/rescript-vscode/server/out/server.js'
        end
        return vim.fn.stdpath 'data' .. '/site/pack/packer/start/vim-rescript/server/out/server.js'
      end)(),
      '--stdio',
    },
  },
  'rust_analyzer',
  'rnix',
  'sqls',
  {
    'lua_ls',
    cmd = {
      'lua-language-server',
      '-E',
      '/usr/lib/lua-language-server/main.lua',
      '--logpath="' .. vim.fn.stdpath 'cache' .. '/lua-language-server/log"',
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
        -- experimental = {
        --   classRegex = {
        --     'tw`([^`]*)', -- tw`...`
        --     'tw="([^"]*)', -- <div tw="..." />
        --     'tw={"([^"}]*)', -- <div tw={"..."} />
        --     'tw\\.\\w+`([^`]*)', -- tw.xxx`...`
        --     'tw\\(.*?\\)`([^`]*)', -- tw(Component)`...`
        --   },
        -- },
        includeLanguages = {
          typescript = 'javascript',
          typescriptreact = 'javascript',
        },
      },
    },
  },
  {
    'tsserver',
    formatting = false,
    settings = {
      diagnostics = {
        ignoredCodes = {
          7016, -- "Could not find a declaration file for module..."
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
        -- schemaStore = { enabled = true, url = 'www.schemastore.org/api/json/catalog.json?test=5678' },
        -- schemaStore = {},
        -- schemaStore = { url = 'www.schemastore.org/api/json/catalog.json?test=5678' },
        -- schemas = {
        --   ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json?test=1234'] = {
        --     '**/docker-compose.yml',
        --     '**/docker-compose.yaml',
        --     '**/docker-compose.*.yml',
        --     '**/docker-compose.*.yaml',
        --     '**/compose.yml',
        --     '**/compose.yaml',
        --     '**/compose.*.yml',
        --     '**/compose.*.yaml',
        --   },
        -- },
      },
      -- http = { proxy = 'http://localhost:9210' },
    },
  },
}

local fmt_triggers = {
  default = 'BufWritePre',
  sh = 'BufWritePost',
}

local lsp_handlers = {
  ['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
      source = 'if_many',
      severity = vim.diagnostic.severity.ERROR,
      -- severity = { min = vim.diagnostic.severity.ERROR },
    },
    signs = true,
    underline = true,
    update_in_insert = false,
  }),
  ['textDocument/definition'] = function(_, result)
    if result == nil or vim.tbl_isempty(result) then
      print 'Definition not found'
      return nil
    end
    local function jumpto(loc)
      local split_cmd = vim.uri_from_bufnr(0) == loc.targetUri and 'split' or 'tabnew'
      vim.cmd(split_cmd)
      vim.lsp.util.jump_to_location(loc)
    end

    if vim.tbl_islist(result) then
      jumpto(result[1])
      if #result > 1 then
        vim.fn.setqflist(vim.lsp.util.locations_to_items(result))
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
    vim.notify({ result.message }, lvl, {
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
    -- Require providers
    require 'hover.providers.lsp'
    require 'hover.providers.gh'
    -- require 'hover.providers.gh_user'
    -- require('hover.providers.jira')
    require 'hover.providers.man'
    -- require 'hover.providers.dictionary'
  end,
  preview_opts = {
    -- border = nil,
    border = M.border,
  },
  -- Whether the contents of a currently open hover window should be moved
  -- to a :h preview-window when pressing the hover keymap.
  preview_window = false,
  title = false,
}

local function on_attach(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    M.set_fmt_on_save(true, true)
  end
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  user_lsp_status.on_attach(client, bufnr)
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
  require('null-ls').setup(vim.tbl_extend('force', require 'user.plugin.null-ls', { on_attach = on_attach }))
  require('lsp_signature').setup(lsp_signature_config)
  require('hover').setup(hover_config)
  --require('packer').loader('trouble.nvim', false)
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

local function on_exit(code, signal, id)
  user_lsp_status.on_exit(code, signal, id)
end

local no_format_on_save_fts = {
  'gitcommit',
}

-- Enables/disables format on save
-- If val is nil, format on save is toggled
-- If silent is not false, a message will be displayed
function M.set_fmt_on_save(val, silent)
  M.fmt_on_save_enabled = val ~= nil and val or not M.fmt_on_save_enabled
  local augid = vim.api.nvim_create_augroup('user_lsp_fmt_on_save', { clear = true })
  if M.fmt_on_save_enabled then
    vim.api.nvim_create_autocmd(fmt_triggers[vim.o.filetype] or fmt_triggers.default, {
      callback = function()
        if vim.tbl_contains(no_format_on_save_fts, vim.bo.filetype) then
          return
        end
        M.format { timeout_ms = format_on_save_timeout }
      end,
      group = augid,
    })
  end
  if not silent then
    print('Format on save ' .. (M.fmt_on_save_enabled and 'enabled' or 'disabled') .. '.')
  end
end

function M.peek_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/definition', params, function(_, result)
    if result == nil or vim.tbl_isempty(result) then
      return nil
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
    local count = 0
    for _, sub_count in ipairs(M.code_actions[result.bufnr]) do
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
      plugins = true,
    },
  }
end

local function lsp_init()
  setup_neodev()
  vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
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
      name = lsp[1]
      if lsp.formatting == false then
        lsp.formatting = nil
        opts.on_attach = function(client, ...)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          return on_attach_wrapper(client, ...)
        end
      end
      for k, v in pairs(lsp) do
        if k ~= 1 then
          opts[k] = v
        end
      end
    else
      name = lsp
    end
    if name == 'typescript' or name == 'tsserver' then
      require('typescript').setup {
        disable_commands = false,
        debug = false,
        go_to_source_definition = {
          fallback = true,
        },
        server = opts,
      }
      return
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
