local nvim_lsp = require'lspconfig'
local lsp_status = require'lsp-status'

lsp_status.register_progress()

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  lsp_status.on_attach(client)
  _G.nvim_lsp_mapfn(bufnr)
end

local capabilities = vim.tbl_extend('keep',
  vim.lsp.protocol.make_client_capabilities(),
  lsp_status.capabilities,
  { textDocument = { completion = { completionItem = {
    snippetSupport = true,
    resolveSupport = {
      properties = {
        'documentation',
        'detail',
        'additionalTextEdits',
      },
    },
  }}}}
)

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

local servers = {
  'bashls',
  'ccls',
  'cssls',
  {
    'efm',
    init_options = { documentFormatting = true },
    cmd = {"efm-langserver", "-loglevel", "5"},
    settings = {
      rootMarkers = {".git/"},
      languages = {
        lua = {
          { formatCommand = "lua-format -i", formatStdin = true }
        }
      }
    },
    filetypes = { "lua" },
  },
  'denols',
  'dockerls',
  'dotls',
  'gopls',
  'graphql',
  'hie',
  'html',
  {
    'jsonls',
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line('$'),0})
        end
      }
    }
  },
  'ocamllsp',
  'rls',
  {
    'rescriptls',
    cmd = {
      'node',
      vim.fn.stdpath('data') .. '/site/pack/packer/start/vim-rescript/server/out/server.js',
      '--stdio'
    },
  },
  'rnix',
  'tailwindcss',
  'tsserver',
  'pylsp',
  'sqls',
  {
    'sumneko_lua',
    cmd = {
      '/usr/lib/lua-language-server/lua-language-server',
      '-E', '/usr/share/lua-language-server/main.lua',
      '--logpath="' .. vim.fn.stdpath('cache') .. '/lua-language-server/log"',
      '--metapath="' .. vim.fn.stdpath('cache') .. '/lua-language-server/meta"',
    },
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = runtime_path,
        },
        diagnostics = {
          globals = {
            'vim',
            -- mapx.lua:
            'map', 'nmap', 'vmap', 'xmap', 'smap', 'omap', 'imap', 'lmap', 'cmap', 'tmap',
            'noremap', 'nnoremap', 'vnoremap', 'xnoremap', 'snoremap', 'onoremap',
            'inoremap', 'lnoremap', 'cnoremap', 'tnoremap', 'mapbang', 'noremapbang',
          },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file('', true),
        },
        -- Do not send telemetry data
        telemetry = {
          enable = false,
        },
      },
    },
  },
  'vimls',
  'yamlls',
}

for _, lsp in ipairs(servers) do
  local opts = {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = capabilities,
  }
  local name = lsp
  if type(lsp) == 'table' then
    name = lsp[1]
    for k, v in pairs(lsp) do
      if k ~= 1 then
        opts[k] = v
      end
    end
  else
    name = lsp
  end
  if not nvim_lsp[name] then
    error('LSP: Server not found: ' .. name)
  end
  nvim_lsp[name].setup(opts)
end

-- TODO
require'lspsaga'.init_lsp_saga{
  use_saga_diagnostic_sign = true,
  error_sign = '',
  warn_sign = '',
  hint_sign = '',
  infor_sign = '',
  dianostic_header_icon = '   ',
  code_action_icon = ' ',
  code_action_prompt = {
    enable = true,
    sign = true,
    sign_priority = 20,
    virtual_text = true,
  },
  finder_definition_icon = '  ',
  finder_reference_icon = '  ',
  max_preview_lines = 10, -- preview lines of lsp_finder and definition preview
  finder_action_keys = {
    open = 'o', vsplit = 's',split = 'i',quit = 'q',scroll_down = '<C-f>', scroll_up = '<C-b>' -- quit can be a table
  },
  code_action_keys = {
    quit = 'q',exec = '<CR>'
  },
  rename_action_keys = {
    quit = '<C-c>',exec = '<CR>'  -- quit can be a table
  },
  definition_preview_icon = '  ',
  -- "single" "double" "round" "plus",
  border_style = "single",
  rename_prompt_prefix = '➤',
  -- if you don't use nvim-lspconfig you must pass your server name and,
  -- the related filetypes into this table, like
  -- server_filetype_map = {metals = {'sbt', 'scala'}},
  server_filetype_map = {},
}
