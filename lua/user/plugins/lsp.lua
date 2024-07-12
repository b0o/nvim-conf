local servers = function()
  local root_pattern = require('lspconfig.util').root_pattern
  return {
    'astro',
    {
      'mdx_analyzer',
      filetypes = { 'mdx' },
      init_options = {
        typescript = {
          tsdk = require('user.private').mdx_tsdk,
        },
      },
    },
    'bashls',
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
    'emmet_language_server',
    {
      'eslint',
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
    'glsl_analyzer',
    {
      'gopls',
      formatting = false,
    },
    'hie',
    'html',
    {
      'jsonls',
      on_attach = function(client, bufnr)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        if filename:match '%.ts%.snap$' or filename:match '%.js%.snap$' then
          vim.defer_fn(function()
            vim.lsp.buf_detach_client(bufnr, client.id)
            vim.diagnostic.enable(false, { bufnr = bufnr })
          end, 0)
          return false
        end
      end,
      settings = require('user.util.lazy').table(function()
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
      'ruff',
      hover = false,
    },
    'rust_analyzer',
    'rnix',
    {
      'lua_ls',
      settings = {
        Lua = {
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
    'taplo',
    {
      'tsserver',
      enabled = false,
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
end

local maputil = require 'user.util.map'
local recent_wins = require 'user.util.recent-wins'
local fn = require 'user.fn'

local user_lsp = lazy_require 'user.util.lsp'
local trouble = lazy_require 'trouble'

local map = maputil.map
local wrap = maputil.wrap

local conform = lazy_require 'conform'
local user_conform = lazy_require 'user.conform'

very_lazy(function()
  local attach_grimoire = function()
    vim.lsp.start {
      name = 'grimoire-ls',
      cmd = { vim.env.GIT_PROJECTS_DIR .. '/grimoire-ls/.venv/bin/python', '-m', 'grimoire_ls.run' },
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      root_dir = vim.fn.getcwd(),
    }
  end

  vim.api.nvim_create_user_command('GrimoireLs', attach_grimoire, { desc = 'Attach Grimoire LSP' })

  map('n', '<leader>lif', '<Cmd>LspInfo<Cr>', 'LSP: Show LSP information')
  map('n', '<leader>lr', '<Cmd>LspRestart<Cr>', 'LSP: Restart LSP')
  map('n', '<leader>ls', '<Cmd>LspStart<Cr>', 'LSP: Start LSP')
  map('n', '<leader>lS', '<Cmd>LspStop<Cr>', 'LSP: Stop LSP')
end)

local on_first_attach = function()
  local function get_trouble_win()
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      if vim.bo[bufnr].filetype == 'trouble' then
        return winid
      end
    end
  end

  map('n', '<M-S-t>', function()
    local winid = get_trouble_win()
    if winid then
      trouble.close { mode = 'diagnostics' }
    else
      trouble.open { mode = 'diagnostics' }
      recent_wins.focus_most_recent()
    end
  end, { desc = 'Trouble: Toggle' })

  map(
    'n',
    '<M-t>',
    fn.filetype_command(
      'trouble',
      recent_wins.focus_most_recent,
      wrap(trouble.open, { mode = 'diagnostics', focus = true })
    ),
    'Trouble: Toggle Focus'
  )

  map('n', '<leader>lii', user_lsp.set_inlay_hints_global, 'LSP: Toggle inlay hints')
  map('n', '<leader>lie', wrap(user_lsp.set_inlay_hints_global, true), 'LSP: Enable inlay hints')
  map('n', '<leader>lid', wrap(user_lsp.set_inlay_hints_global, false), 'LSP: Disable inlay hints')

  map('nx', '<localleader>F', wrap(conform.format, { lsp_fallback = true }), 'LSP: Format')

  map(
    'n',
    { '<localleader>S', '<localleader>ss' },
    user_conform.toggle_format_on_save,
    'Conform: Toggle format on save'
  )
  map('n', '<localleader>se', wrap(user_conform.set_format_on_save, true), 'Conform: Enable format on save')
  map('n', '<localleader>sd', wrap(user_conform.set_format_on_save, false), 'Conform: Disable format on save')
end

local on_attach = function(_, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.b[bufnr].user_lsp_attached then
    return
  end
  vim.b[bufnr].user_lsp_attached = true

  local bufmap = maputil.buf(bufnr)

  bufmap('n', '<localleader>ii', wrap(user_lsp.set_inlay_hints, 0), 'LSP: Toggle inlay hints for buffer')
  bufmap('n', '<localleader>ie', wrap(user_lsp.set_inlay_hints, 0, true), 'LSP: Enable inlay hints for buffer')
  bufmap('n', '<localleader>id', wrap(user_lsp.set_inlay_hints, 0, false), 'LSP: Disable inlay hints for buffer')

  bufmap('n', '<localleader>gD', vim.lsp.buf.declaration, 'LSP: Goto declaration')
  bufmap('n', { '<localleader>gd', 'gd' }, '<Cmd>Glance definitions<Cr>', 'LSP: Glance definitions')
  bufmap('n', '<localleader>gi', '<Cmd>Glance implementations<Cr>', 'LSP: Glance implementation')
  bufmap('n', '<localleader>gt', '<Cmd>Glance type_definitions<Cr>', 'LSP: Glance type definitions')
  bufmap('n', '<localleader>gr', '<Cmd>Glance references<Cr>', 'LSP: Glance references')

  bufmap('n', '<localleader>wa', vim.lsp.buf.add_workspace_folder, 'LSP: Add workspace folder')
  bufmap('n', '<localleader>wr', vim.lsp.buf.remove_workspace_folder, 'LSP: Rm workspace folder')

  bufmap('n', '<localleader>wl', function()
    fn.inspect(vim.lsp.buf.list_workspace_folders())
  end, 'LSP: List workspace folders')

  bufmap('n', '<localleader>R', function()
    require 'inc_rename' -- Force lazy.nvim to load inc_rename
    return ':IncRename ' .. vim.fn.expand '<cword>'
  end, { silent = false, expr = true, desc = 'LSP: Rename' })

  local code_actions = lazy_require('actions-preview').code_actions
  bufmap('nx', { '<localleader>A', '<localleader>ca' }, code_actions, 'LSP: Code action')

  local function goto_diag(dir)
    return function(sev)
      return function()
        local opts = {
          float = true,
          severity = vim.diagnostic.severity[sev],
        }

        if dir == 'first' or dir == 'last' then
          opts.wrap = false
          if dir == 'first' then
            opts.pos = { 1, -1 }
            opts.count = 1
          else
            opts.pos = { vim.api.nvim_buf_line_count(0) - 1, 99999 }
            opts.count = -1
          end
        elseif dir == 'prev' then
          opts.count = -1
        elseif dir == 'next' then
          opts.count = 1
        else
          error('Invalid direction: ' .. dir)
        end

        vim.diagnostic.jump(opts)
      end
    end
  end
  local diag_prev = goto_diag 'prev'
  local diag_next = goto_diag 'next'
  local diag_first = goto_diag 'first'
  local diag_last = goto_diag 'last'

  bufmap('n', '<localleader>ds', vim.diagnostic.show, 'LSP: Show diagnostics')
  bufmap('n', { '<localleader>dt', '<localleader>T' }, trouble.toggle, 'LSP: Toggle Trouble')

  bufmap('n', '<localleader>dd', function()
    local enabled = vim.diagnostic.is_enabled { bufnr = 0 }
    vim.diagnostic.enable(not enabled, { bufnr = 0 })
    vim.notify('Diagnostics ' .. (enabled and 'disabled' or 'enabled'))
  end, 'LSP: Toggle Diagnostic')

  bufmap('n', '[d', diag_prev(), 'LSP: Goto prev diagnostic')
  bufmap('n', ']d', diag_next(), 'LSP: Goto next diagnostic')
  bufmap('n', '[h', diag_prev 'HINT', 'LSP: Goto prev hint')
  bufmap('n', ']h', diag_next 'HINT', 'LSP: Goto next hint')
  bufmap('n', '[i', diag_prev 'INFO', 'LSP: Goto prev info')
  bufmap('n', ']i', diag_next 'INFO', 'LSP: Goto next info')
  bufmap('n', '[w', diag_prev 'WARN', 'LSP: Goto prev warning')
  bufmap('n', ']w', diag_next 'WARN', 'LSP: Goto next warning')
  bufmap('n', '[e', diag_prev 'ERROR', 'LSP: Goto prev error')
  bufmap('n', ']e', diag_next 'ERROR', 'LSP: Goto next error')

  bufmap('n', '[D', diag_first(), 'LSP: Goto first diagnostic')
  bufmap('n', ']D', diag_last(), 'LSP: Goto last diagnostic')
  bufmap('n', '[H', diag_first 'HINT', 'LSP: Goto first hint')
  bufmap('n', ']H', diag_last 'HINT', 'LSP: Goto last hint')
  bufmap('n', '[I', diag_first 'INFO', 'LSP: Goto first info')
  bufmap('n', ']I', diag_last 'INFO', 'LSP: Goto last info')
  bufmap('n', '[W', diag_first 'WARN', 'LSP: Goto first warning')
  bufmap('n', ']W', diag_last 'WARN', 'LSP: Goto last warning')
  bufmap('n', '[E', diag_first 'ERROR', 'LSP: Goto first error')
  bufmap('n', ']E', diag_last 'ERROR', 'LSP: Goto last error')

  bufmap('n', '<localleader>dr', function()
    vim.diagnostic.reset(nil, 0)
  end, 'LSP: Reset diagnostics (buffer)')

  bufmap(
    'n',
    { [[<localleader>so]], [[<leader>so]] },
    lazy_require('user.telescope').cmds.lsp_document_symbols,
    'LSP: Telescope symbol search'
  )

  bufmap('n', '<localleader>hs', vim.lsp.buf.signature_help, 'LSP: Signature help')
  bufmap('n', '<M-S-i>', user_lsp.peek_definition, 'LSP: Peek definition')

  --- Find the diagnostic float window for the current window
  ---@param source_win? number @the window to use as the source window, or nil for the current window
  ---@return number|nil @the diagnostic float window, or nil if none is found
  local find_diagnostic_float = function(source_win)
    source_win = require('user.util.api').resolve_winnr(source_win)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local winconfig = vim.api.nvim_win_get_config(win)
      local w = vim.w[win]
      if
        winconfig.relative == 'win'
        and (w.line or w.cursor or w.buffer)
        and (source_win == nil or winconfig.win == source_win)
      then
        return win
      end
    end
  end

  --- If a diagnostic float is open, focus it
  --- Otherwise, hover over the symbol under the cursor
  local hover = function()
    local win = vim.api.nvim_get_current_win()
    local diag_win = find_diagnostic_float(win)
    if diag_win then
      map('n', '<M-i>', function()
        vim.api.nvim_win_close(diag_win, true)
      end, { buffer = vim.api.nvim_win_get_buf(diag_win) })
      vim.api.nvim_set_current_win(diag_win)
      return
    end
    vim.lsp.buf.hover()
  end

  bufmap('ni', '<M-i>', hover, 'LSP: Hover or focus diagnostic')
end

---@type LazySpec[]
return {
  {
    'neovim/nvim-lspconfig',
    cmd = { 'LspInfo', 'LspStart', 'LspStop', 'LspRestart', 'LspLog' },
    event = 'VeryLazy',
    config = function()
      user_lsp.setup {
        servers = servers(),
        on_attach = on_attach,
        on_first_attach = on_first_attach,
      }
    end,
  },
  {
    'stevearc/conform.nvim',
    config = function()
      require('user.conform').setup()
    end,
    event = 'BufWritePre',
  },
  {
    'onsails/lspkind-nvim',
    config = function()
      require('lspkind').init {
        symbol_map = {
          Type = '',
          Copilot = '',
        },
      }
    end,
  },
  {
    'jmbuhr/otter.nvim',
    enabled = false,
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      require('user.otter').setup()
    end,
  },
  'b0o/schemastore.nvim',
  'aznhe21/actions-preview.nvim',
  {
    'smjonas/inc-rename.nvim',
    cmd = { 'IncRename' },
    opts = {},
  },
  {
    'DNLHC/glance.nvim',
    config = function()
      local glance = require 'glance'
      local actions = glance.actions
      ---@diagnostic disable-next-line: missing-fields
      glance.setup {
        zindex = 200,
        mappings = {
          list = {
            ['<C-n>'] = actions.next,
            ['<C-p>'] = actions.previous,
            ['<Down>'] = actions.next,
            ['<Up>'] = actions.previous,
            ['<Tab>'] = actions.next_location,
            ['<S-Tab>'] = actions.previous_location,
            ['<C-j>'] = actions.preview_scroll_win(-1),
            ['<C-k>'] = actions.preview_scroll_win(1),
            ['<C-d>'] = actions.preview_scroll_win(-5),
            ['<C-u>'] = actions.preview_scroll_win(5),
            ['<C-v>'] = actions.jump_vsplit,
            ['<C-x>'] = actions.jump_split,
            ['<C-t>'] = actions.jump_tab,
            ['<M-w>'] = function()
              local win = require('window-picker').pick_window()
              if not win or not vim.api.nvim_win_is_valid(win) then
                return
              end
              actions.jump {
                cmd = function()
                  vim.api.nvim_set_current_win(win)
                end,
              }
            end,
            ['<M-a>'] = actions.enter_win 'preview',
          },
          preview = {
            ['<Esc>'] = actions.close,
            ['<M-a>'] = actions.enter_win 'list',
          },
        },
      }
    end,
    cmd = 'Glance',
  },
  {
    -- 'pmizio/typescript-tools.nvim',
    -- TODO: Revert once https://github.com/pmizio/typescript-tools.nvim/pull/267 is merged
    'notomo/typescript-tools.nvim',
    branch = 'fix-deprecated',
    enabled = true,
    ft = {
      'typescript',
      'javascript',
      'typescriptreact',
      'javascriptreact',
    },
    opts = {
      on_attach = function(client, bufnr)
        require('twoslash-queries').attach(client, bufnr)
        user_lsp.on_attach(client, bufnr)
      end,
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = 'insert_leave',
        tsserver_file_preferences = {
          includeCompletionsForModuleExports = true,

          -- inlay hints
          includeInlayParameterNameHints = 'literals',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        tsserver_format_options = {
          allowIncompleteCompletions = false,
          allowRenameOfImportPath = false,
        },
      },
    },
  },
  {
    'marilari88/twoslash-queries.nvim',
    dev = true,
    opts = { multi_line = true },
    ft = {
      'typescript',
      'javascript',
      'typescriptreact',
      'javascriptreact',
    },
  },
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble', 'TroubleClose', 'TroubleRefresh', 'TroubleToggle' },
    opts = {},
  },
}
