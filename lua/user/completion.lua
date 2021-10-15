---- hrsh7th/nvim-cmp.
local cmp = require 'cmp'
local luasnip = require 'luasnip'

local function has_words_before()
  if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

local function feedkeys(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noselect',
    get_trigger_characters = function(trigger_characters)
      return vim.tbl_filter(function(char)
        return char ~= ' '
      end, trigger_characters)
    end,
  },
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = require('lspkind').presets.default[vim_item.kind] .. ' ' .. vim_item.kind
      vim_item.menu = ({
        buffer = '[Buffer]',
        calc = '[Calc]',
        look = '[Look]',
        luasnip = '[LuaSnip]',
        nvim_lsp = '[LSP]',
        path = '[Path]',
        spell = '[Spell]',
        tmux = '[Tmux]',
        treesitter = '[treesitter]',
      })[entry.source.name]
      return vim_item
    end,
  },
  mapping = {
    ['<C-j>'] = cmp.mapping.scroll_docs(-4),
    ['<C-k>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-x><C-x>'] = cmp.mapping.complete(),
    ['<Cr>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        feedkeys('<C-n>', 'n')
      elseif luasnip.expand_or_jumpable() then
        feedkeys('<Plug>luasnip-expand-or-jump', '')
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        feedkeys('<C-p>', 'n')
      elseif luasnip.jumpable(-1) then
        feedkeys('<Plug>luasnip-jump-prev', '')
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'treesitter' },
    { name = 'buffer' },
    { name = 'tmux' },
    { name = 'path' },
    { name = 'calc' },
    { name = 'spell' },
    --     { name = 'look' },
  },
}
