---- jose-elias-alvarez/null-ls.nvim
local null_ls = require 'null-ls'

local sh_filetypes = {
  'sh',
  'bash',
}

local sources = {
  formatting = {
    'eslint_d',
    'gofmt',
    'goimports',
    'nixfmt',
    {
      'prettier',
      filetypes = {
        'css',
        'scss',
        'less',
        'html',
        'yaml',
        'markdown',
        'graphql',
        'json',
      },
    },
    {
      'shellharden',
      filetypes = sh_filetypes,
    },
    {
      'shfmt',
      filetypes = sh_filetypes,
    },
    'stylelint',
    'stylua',
    --     {
    --       'trim_whitespace',
    --       filetypes = {},
    --     },
  },
  diagnostics = {
    'eslint_d',
    {
      'shellcheck',
      diagnostics_format = '[SC#{c}] #{m} https://github.com/koalaman/shellcheck/wiki/SC#{c}',
      filetypes = sh_filetypes,
    },
    'stylelint',
  },
  code_actions = {
    {
      'shellcheck',
      filetypes = sh_filetypes,
    },
    'gitsigns',
  },
}

local ignore_files = {
  'PKGBUILD',
}

local function should_attach(bufnr)
  local bufname = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':t')
  for _, ignore in ipairs(ignore_files) do
    if bufname == ignore then
      return false
    end
  end
  return true
end

local function gen_config()
  local cfg = {
    sources = {},
    should_attach = should_attach,
  }
  for kind, _sources in pairs(sources) do
    for _, s in ipairs(_sources) do
      local name = s
      local opts
      if type(s) == 'table' then
        if type(s[1]) == 'string' then
          name = s[1]
          opts = {}
          for k, v in pairs(s) do
            if k ~= 1 then
              opts[k] = v
            end
          end
        else
          name = nil
          opts = s
        end
      end
      local source
      if name ~= nil then
        source = null_ls.builtins[kind][name]
        if opts ~= nil then
          source = source['with'](opts)
        end
      else
        source = opts
      end
      table.insert(cfg.sources, source)
    end
  end
  return cfg
end

return gen_config()
