---- jose-elias-alvarez/null-ls.nvim
local null_ls = require 'null-ls'

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
      },
    },
    'shellharden',
    'shfmt',
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
    },
    'stylelint',
  },
  code_actions = {
    'shellcheck',
    'gitsigns',
  },
}

local function gen_config()
  local cfg = { sources = {} }
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
