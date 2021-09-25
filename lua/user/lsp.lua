local lspconfig = require 'lspconfig'
local lsp_status = require 'lsp-status'
local null_ls = require 'null-ls'
local user_lsp_status = require 'user.statusline.lsp'
local nvim_cmp_lsp = require 'cmp_nvim_lsp'

local M = {
  fmtOnSaveEnabled = false,
}

local lua_lsp_conf = require('lua-dev').setup {
  library = {
    vimruntime = true,
    types = true,
    plugins = true,
  },
  lspconfig = {
    cmd = {
      '/usr/lib/lua-language-server/lua-language-server',
      '-E',
      '/usr/share/lua-language-server/main.lua',
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
          },
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },
}
lua_lsp_conf[1] = 'sumneko_lua'

local lsp_servers = {
  'bashls',
  'ccls',
  'cssls',
  'denols',
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
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line '$', 0 })
        end,
      },
    },
  },
  'null-ls',
  'ocamllsp',
  'pylsp',
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
  lua_lsp_conf,
  'tsserver',
  'vimls',
  'yamlls',
}

-- TODO
local null_ls_config = {
  formatting = {
    'eslint_d',
    'gofmt',
    'goimports',
    'nixfmt',
    'prettier',
    'shellharden',
    'shfmt',
    'stylelint',
    'stylua',
    {
      'trim_whitespace',
      filetypes = {},
    },
  },
  diagnostics = {
    'eslint_d',
    'shellcheck',
    'stylelint',
  },
  code_actions = {
    'gitsigns',
  },
}

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
    table.insert(au, 'autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()')
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

local function on_attach(client, bufnr)
  if client.resolved_capabilities.document_formatting then
    M.setFmtOnSave(true, true)
  end
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  user_lsp_status.on_attach(client)
  _G.nvim_lsp_mapfn(bufnr)
end

local function on_exit(code, signal, id)
  user_lsp_status.on_exit(code, signal, id)
end

local function lsp_init()
  local capabilities = nvim_cmp_lsp.update_capabilities(lsp_status.capabilities)

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

local function gen_null_ls_config()
  local cfg = { sources = {} }
  for kind, sources in pairs(null_ls_config) do
    for _, s in ipairs(sources) do
      local name = s
      local opts
      if type(s) == 'table' then
        name = s[1]
        opts = {}
        for k, v in pairs(s) do
          if k ~= 1 then
            opts[k] = v
          end
        end
      end
      local source = null_ls.builtins[kind][name]
      if opts ~= nil then
        source = source.with(opts)
      end
      table.insert(cfg.sources, source)
    end
  end
  return cfg
end

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = { source = 'if_many' },
})

-- Goto Definiton: If target location is in the current buffer, open it in a new split.
-- Otherwise, open it in a new tab.
vim.lsp.handlers['textDocument/definition'] = function(_, result)
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
end

local border = {
  { '╭' },
  { '─' },
  { '╮' },
  { '│' },
  { '╯' },
  { '─' },
  { '╰' },
  { '│' },
}

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = true,
})

local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }

for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

null_ls.config(gen_null_ls_config())
lsp_status.register_progress()
lsp_init()
require('lspkind').init {}

require('lsp_signature').setup {
  zindex = 99, -- Keep signature popup below the completion PUM
}

return M
