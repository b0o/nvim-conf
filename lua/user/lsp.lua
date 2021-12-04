local lsp_status = require 'lsp-status'
local user_lsp_status = require 'user.statusline.lsp'
local nvim_cmp_lsp = require 'cmp_nvim_lsp'
local fn = require 'user.fn'

local M = {
  fmtOnSaveEnabled = false,
  border = { { '╭' }, { '─' }, { '╮' }, { '│' }, { '╯' }, { '─' }, { '╰' }, { '│' } },
  signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' },
}

local luals_conf = vim.tbl_extend(
  'keep',
  { 'sumneko_lua' },
  require('lua-dev').setup {
    library = {
      vimruntime = true,
      types = true,
      plugins = true,
    },
    lspconfig = {
      cmd = {
        'lua-language-server',
        '-E',
        '/usr/lib/lua-language-server/main.lua',
        '--logpath="' .. vim.fn.stdpath 'cache' .. '/lua-language-server/log"',
        '--metapath="' .. vim.fn.stdpath 'cache' .. '/lua-language-server/meta"',
      },
      settings = {
        Lua = {
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
  }
)

local lsp_servers = {
  'bashls',
  'ccls',
  'cssls',
  --   'denols', -- TODO: Prevent denols from starting in NodeJS projects
  'dockerls',
  'dotls',
  {
    'gopls',
    formatting = false,
  },
  'graphql',
  'hie',
  'html',
  {
    'jsonls',
    formatting = false,
    cmd = {
      'node',
      '/usr/lib/code/extensions/json-language-features/server/dist/node/jsonServerMain.js',
      '--stdio',
    },
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line '$', 0 })
        end,
      },
    },
    settings = fn.lazyTable(function()
      return {
        json = { schemas = require('schemastore').json.schemas() },
      }
    end),
  },
  'null-ls',
  'ocamllsp',
  {
    'pylsp',
    cmd = {
      'pylsp',
      '-v',
      '--log-file',
      vim.fn.stdpath 'cache' .. '/pylsp.log',
    },
    settings = {
      pylsp = {
        plugins = {
          pylint = { enabled = true },
          yapf = { enabled = true },

          pycodestyle = { enabled = false },
          autopep8 = { enabled = false },
          pydocstyle = { enabled = false },
        },
      },
    },
  },
  {
    'rescriptls',
    cmd = {
      'node',
      vim.fn.stdpath 'data' .. '/site/pack/packer/start/vim-rescript/server/out/server.js',
      '--stdio',
    },
  },
  'rls',
  'rnix',
  'sqls',
  luals_conf,
  {
    'tsserver',
    formatting = false,
  },
  'vimls',
  'yamlls',
}

local fmtTriggers = {
  default = 'BufWritePre',
  sh = 'BufWritePost',
}

local lsp_handlers = {
  ['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = { source = 'if_many' },
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

  ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = M.border }),
  ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = M.border }),
}

---- onsails/lspkind-nvim
local lspkind_config = {}

---- ray-x/lsp_signature.nvim
local lsp_signature_config = {
  zindex = 99, -- Keep signature popup below the completion PUM
}

---- folke/trouble.nvim
local trouble_config = {
  auto_open = true,
  auto_close = true,
}

local function on_attach(client, bufnr)
  if client.resolved_capabilities.document_formatting then
    M.setFmtOnSave(true, true)
  end
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  user_lsp_status.on_attach(client)
  vim.schedule(function()
    require('user.mappings').on_lsp_attach(bufnr)
  end)
end

local function on_exit(code, signal, id)
  user_lsp_status.on_exit(code, signal, id)
end

-- Enables/disables format on save
-- If val is nil, format on save is toggled
-- If silent is not false, a message will be displayed
function M.setFmtOnSave(val, silent)
  M.fmtOnSaveEnabled = type(val) == 'boolean' and val or not M.fmtOnSaveEnabled
  local au = {
    'augroup LspFmtOnSave',
    'autocmd!',
  }
  if M.fmtOnSaveEnabled then
    table.insert(
      au,
      ('autocmd %s <buffer> lua vim.lsp.buf.formatting_sync()'):format(
        fmtTriggers[vim.o.filetype] or fmtTriggers.default
      )
    )
  end
  table.insert(au, 'augroup END')
  vim.cmd(table.concat(au, '\n'))
  if silent ~= true then
    print('Format on save ' .. (M.fmtOnSaveEnabled and 'enabled' or 'disabled') .. '.')
  end
end

function M.peekDefinition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/definition', params, function(_, result)
    if result == nil or vim.tbl_isempty(result) then
      return nil
    end
    vim.lsp.util.preview_location(result[1])
  end)
end

function M.code_action_listener()
  local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
  local params = vim.lsp.util.make_range_params()
  params.context = context
  vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, actions, result)
    if err or not result or not result.bufnr then
      return
    end
    vim.fn.sign_unplace('user_lsp', { buffer = result.bufnr })
    if
      not actions
      or #actions == 0
      or not result.params
      or not result.params.range
      or not result.params.range.start
      or not result.params.range.start.line
    then
      return
    end
    vim.fn.sign_place(1, 'user_lsp', 'DiagnosticSignInfo', result.bufnr, {
      lnum = result.params.range.start.line + 1,
    })
  end)
end

local function lsp_init()
  vim.lsp.set_log_level 'info'
  for k, v in ipairs(lsp_handlers) do
    vim.lsp.handlers[k] = v
  end

  for type, icon in pairs(M.signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
  end

  require('null-ls').config(require 'user.plugin.null-ls')
  require('lspkind').init(lspkind_config)
  require('lsp_signature').setup(lsp_signature_config)
  require('trouble').setup(trouble_config)

  lsp_status.register_progress()
  local capabilities = nvim_cmp_lsp.update_capabilities(lsp_status.capabilities)

  local lspconfig = require 'lspconfig'

  for _, lsp in ipairs(lsp_servers) do
    local opts = {
      on_attach = on_attach,
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
          client.resolved_capabilities.document_formatting = false
          client.resolved_capabilities.document_range_formatting = false
          return on_attach(client, ...)
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
    if not lspconfig[name] then
      error('LSP: Server not found: ' .. name)
    end
    lspconfig[name].setup(opts)
  end
end

lsp_init()

return M
