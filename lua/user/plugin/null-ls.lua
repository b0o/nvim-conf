---- jose-elias-alvarez/null-ls.nvim
local null_ls = require 'null-ls'

local sh_filetypes = {
  'sh',
  'bash',
}

local sources = {
  formatting = {
    -- 'eslint',
    --'eslint_d',
    'gofmt',
    'goimports',
    'nixfmt',
    {
      'prettier',
      extra_args = {
        '--plugin',
        'prettier-plugin-tailwindcss',
        '--plugin-search-dir',
        vim.env['XDG_DATA_HOME'] .. '/pnpm/global/5/node_modules',
      },
      filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
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
    -- 'prismaFmt',
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
    {
      'cppcheck',
      args = {
        '--enable=warning,style,performance,portability',
        '--template=gcc',
        '--language=c++',
        '--std=c++20',
        '--suppress=unusedStructMember:*.h',
        '--inline-suppr',
        '$FILENAME',
      },
      filetypes = { 'cpp' },
    },
    -- 'clang_check',
    'cpplint',
    -- {
    --   'eslint',
    --   -- 'eslint_d',
    --   diagnostics_format = '[#{c}] #{m} https://eslint.org/docs/rules/#{c}',
    -- },
    {
      'shellcheck',
      diagnostics_format = '[SC#{c}] #{m} https://github.com/koalaman/shellcheck/wiki/SC#{c}',
      filetypes = sh_filetypes,
    },
    {
      'selene',
      diagnostics_format = '[#{c}] #{m} https://kampfkarren.github.io/selene/lints/#{c}.html',
      extra_args = { '--config', vim.fn.stdpath 'config' .. '/selene.toml' },
      cwd = function()
        return vim.fs.dirname(vim.fs.find({ 'selene.toml' }, { upward = true, path = vim.api.nvim_buf_get_name(0) })[1])
          or vim.fn.stdpath 'config'
      end,
    },
    'stylelint',
  },
  code_actions = {
    {
      'shellcheck',
      filetypes = sh_filetypes,
    },
    -- 'eslint',
    -- 'eslint_d',
    'gitsigns',
  },
}

local ignores = {
  vim.regex [[^\(.\+\.\)\?PKGBUILD$]],
}

local function should_attach(bufnr)
  local bufname = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':t')
  for _, ignore in ipairs(ignores) do
    if type(ignore) == 'userdata' then
      if ignore:match_str(bufname) ~= nil then
        return false
      end
    else
      if bufname == ignore then
        return false
      end
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
