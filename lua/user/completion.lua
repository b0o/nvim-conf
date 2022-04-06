---- hrsh7th/nvim-cmp.
local cmp = require 'cmp'
local luasnip = require 'luasnip'
local lspkind = require 'lspkind'

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
    format = lspkind.cmp_format {
      -- mode = 'symbol', -- show only symbol annotations
      -- maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function(entry, vim_item)
        vim_item.menu = ({
          buffer = '[Buffer]',
          calc = '[Calc]',
          cmdline = '[Cmd]',
          cmp_git = '[Git]',
          look = '[Look]',
          luasnip = '[LuaSnip]',
          nvim_lsp = '[LSP]',
          nvim_lua = '[Lua]',
          npm = '[NPM]',
          path = '[Path]',
          spell = '[Spell]',
          tmux = '[Tmux]',
          treesitter = '[TS]',
        })[entry.source.name]
        return vim_item
      end,
    },
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
    { name = 'nvim_lsp' },

    { name = 'treesitter' },
    { name = 'luasnip' },
    { name = 'nvim_lua' },

    { name = 'buffer' },
    -- { name = 'tmux' },
    -- { name = 'cmdline' },

    { name = 'path' },
    -- { name = 'calc' },
    -- { name = 'spell' },
  },
}

cmp.setup.filetype({'gitcommit', 'NeogitCommitMessage'}, {
  sources = {
    { name = 'cmp_git' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'tmux' },
    { name = 'path' },
  },
})

-- Adds icons and hides PRs when searching for issues
local cmp_git_extend_gh_callback = function(callback, kind)
  return function(res, ...)
    local needs_filter = false
    for _, item in ipairs(res.items) do
      if item.extended then
        if item.disabled then
          needs_filter = true
        end
        goto continue
      end
      item.extended = true
      if kind == 'issues' and item.sortText:sub(1, 1) == '1' then
        needs_filter = true
        item.disabled = true
      end
      local icon
      if item.sortText:sub(2, 2) == '0' then
        icon = ' '
      else
        icon = ' '
      end
      item.label = icon .. item.label
      ::continue::
    end
    if needs_filter then
      res.items = vim.tbl_filter(function(item)
        return not item.disabled
      end, res.items)
    end
    return callback(res, ...)
  end
end

require('cmp_git').setup {
  remotes = { 'upstream', 'origin', 'b0o' },
  github = {
    issues = {
      filter = 'all',
      limit = 250,
      state = 'all',
      sort_by = function(issue)
        local kind_rank = issue.pull_request and 1 or 0
        local state_rank = issue.state == 'open' and 0 or 1
        local age = os.difftime(os.time(), require('cmp_git.utils').parse_github_date(issue.updatedAt))
        return string.format('%d%d%010d', kind_rank, state_rank, age)
      end,
      filter_fn = function(trigger_char, issue)
        return string.format('%s %s %s', trigger_char, issue.number, issue.title)
      end,
    },
    mentions = {
      limit = 250,
      sort_by = nil,
      filter_fn = function(trigger_char, mention)
        return string.format('%s %s %s', trigger_char, mention.username)
      end,
    },
    pull_requests = {
      limit = 250,
      state = 'all',
      sort_by = function(pr)
        local state_rank = pr.state == 'open' and 0 or 1
        local age = os.difftime(os.time(), require('cmp_git.utils').parse_github_date(pr.updatedAt))
        return string.format('%d%010d', state_rank, age)
      end,
      filter_fn = function(trigger_char, pr)
        return string.format('%s %s %s', trigger_char, pr.number, pr.title)
      end,
    },
  },
  trigger_actions = {
    {
      debug_name = 'git_commits',
      trigger_character = ':',
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.git:get_commits(callback, params, trigger_char)
      end,
    },
    {
      debug_name = 'github_issues',
      trigger_character = '#',
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.github:get_issues(cmp_git_extend_gh_callback(callback, 'issues'), git_info, trigger_char)
      end,
    },
    {
      debug_name = 'github_pulls',
      trigger_character = '!',
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.github:get_pull_requests(cmp_git_extend_gh_callback(callback, 'pulls'), git_info, trigger_char)
      end,
    },
    {
      debug_name = 'github_mentions',
      trigger_character = '@',
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.github:get_mentions(callback, git_info, trigger_char)
      end,
    },
    {
      debug_name = 'gitlab_issues',
      trigger_character = '#',
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.gitlab:get_issues(callback, git_info, trigger_char)
      end,
    },
    {
      debug_name = 'gitlab_mentions',
      trigger_character = '@',
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.gitlab:get_mentions(callback, git_info, trigger_char)
      end,
    },
    {
      debug_name = 'gitlab_mrs',
      trigger_character = '!',
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.gitlab:get_merge_requests(callback, git_info, trigger_char)
      end,
    },
  },
}
