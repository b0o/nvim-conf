---- jose-elias-alvarez/null-ls.nvim
local null_ls = require 'null-ls'

local sources = {
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
    {
      'selene',
      diagnostics_format = '[#{c}] #{m} https://kampfkarren.github.io/selene/lints/#{c}.html',
      cwd = function()
        return vim.fs.dirname(vim.fs.find({ 'selene.toml' }, { upward = true, path = vim.api.nvim_buf_get_name(0) })[1])
          or vim.fn.stdpath 'config'
      end,
    },
    'stylelint',
  },
  code_actions = {
    require 'none-ls-shellcheck.code_actions',
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
    debug = true,
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
