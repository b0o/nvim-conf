---- hrsh7th/nvim-cmp.
local cmp = require 'cmp'
local feedkeys = require 'cmp.utils.feedkeys'
local keymap = require 'cmp.utils.keymap'
local luasnip = require 'luasnip'
local lspkind = require 'lspkind'
local xk = require('user.mappings').xk

local wincfg = vim.tbl_extend('force', cmp.config.window.bordered(), {
  winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None',
})

-- Select item next/prev, taking into account whether the cmp window is
-- top-down or bottoom-up so that the movement is always in the same direction.
local select_item_smart = function(dir, opts)
  return function(fallback)
    if cmp.visible() then
      opts = opts or { behavior = cmp.SelectBehavior.Select }
      if cmp.core.view.custom_entries_view:is_direction_top_down() then
        ({ next = cmp.select_next_item, prev = cmp.select_prev_item })[dir](opts)
      else
        ({ prev = cmp.select_next_item, next = cmp.select_prev_item })[dir](opts)
      end
    else
      fallback()
    end
  end
end

local set_hl = function(r, g, b)
  local color = string.format('%02x%02x%02x', r, g, b)
  local group = 'CmpColor' .. color
  local opts = { bg = '#' .. color }
  if vim.fn.hlID(group) < 1 then
    vim.api.nvim_set_hl(0, group, opts)
  end
  return group
end

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
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
  window = {
    completion = wincfg,
    documentation = wincfg,
  },
  view = {
    entries = { name = 'custom', selection_order = 'bottom_up' },
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, vim_item)
      vim_item.menu = ({
        cmdline = ' Cmd',
        nvim_lsp = ' LSP',
        otter = ' Ott',
        treesitter = '  TS',
        luasnip = 'Snip',
        nvim_lua = ' Lua',
        buffer = ' Buf',
        path = 'Path',
        git = ' Git',
        tmux = 'Tmux',
      })[entry.source.name] or entry.source.name
      local sym = lspkind.symbolic(vim_item.kind)
      if sym == '' then
        sym = '∅'
      end
      local doc = entry.completion_item.documentation
      if vim_item.kind == 'Color' and type(doc) == 'string' then
        local ok, _, r, g, b = doc:find 'rgba?%((%d+), (%d+), (%d+)'
        if ok then
          vim_item.kind_hl_group = set_hl(r, g, b)
          sym = ' '
        end
      end
      vim_item.menu = (vim_item.menu or '') .. '->' .. (vim_item.kind or '')
      vim_item.kind = ' ' .. sym .. ' '
      return vim_item
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = select_item_smart 'next',
    ['<C-p>'] = select_item_smart 'prev',
    ['<C-k>'] = cmp.mapping.scroll_docs(-4),
    ['<C-j>'] = cmp.mapping.scroll_docs(4),
    ['<C-g>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<C-c>'] = function(fallback)
      if cmp.visible() then
        cmp.confirm { select = true }
        cmp.complete()
      else
        fallback()
      end
    end,
    [xk [[<C-S-a>]]] = function()
      if cmp.visible() then
        cmp.close()
      else
        cmp.complete()
      end
    end,
    [xk [[<C-.>]]] = {
      i = function()
        if cmp.visible() then
          local selected = cmp.core.view:get_selected_entry() or cmp.core.view:get_first_entry()
          if selected and selected:get_kind() == require('cmp.types').lsp.CompletionItemKind.Snippet then
            cmp.confirm { select = true }
            return
          end
        end
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          luasnip.jump(1)
        end
      end,
      s = function()
        luasnip.jump(1)
      end,
    },
    [xk [[<C-S-.>]]] = {
      i = function()
        if cmp.visible() then
          cmp.close()
        end
        luasnip.jump(-1)
      end,
      s = function()
        luasnip.jump(-1)
      end,
    },
    [xk [[<C-M-.>]]] = {
      i = function()
        luasnip.jump(1)
      end,
      s = function()
        luasnip.jump(1)
      end,
    },
    [xk [[<C-M-S-.>]]] = {
      i = function()
        luasnip.jump(-1)
      end,
      s = function()
        luasnip.jump(-1)
      end,
    },
    ['<C-l>'] = function()
      if cmp.visible() then
        cmp.confirm { select = true }
        return
      end
      cmp.complete {
        config = {
          sources = {
            { name = 'emmet_vim' },
          },
        },
      }
      cmp.select_next_item()
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'otter' },
  }, {
    { name = 'nvim_lua' },
  }, {
    { name = 'tmux', keyword_length = 5 },
    { name = 'treesitter' },
    { name = 'buffer', keyword_length = 5 },
  }),
}

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline {
    ['<C-n>'] = { c = select_item_smart('next', {}) },
    ['<C-p>'] = { c = select_item_smart('prev', {}) },
  },
  sources = {
    { name = 'buffer' },
    { name = 'tmux' },
    { name = 'nvim_lsp' },
    { name = 'treesitter' },
  },
})

local function handle_tab_complete(direction)
  return function()
    if vim.api.nvim_get_mode().mode == 'c' and cmp.get_selected_entry() == nil then
      local text = vim.fn.getcmdline()
      ---@diagnostic disable-next-line: param-type-mismatch
      local expanded = vim.fn.expandcmd(text)
      if expanded ~= text then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-U>', true, true, true) .. expanded, 'n', false)
        cmp.complete()
      elseif cmp.visible() then
        direction()
      else
        cmp.complete()
      end
    else
      if cmp.visible() then
        direction()
      else
        cmp.complete()
      end
    end
  end
end

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline {
    ['<Tab>'] = { c = handle_tab_complete(cmp.select_next_item) },
    ['<S-Tab>'] = { c = handle_tab_complete(cmp.select_prev_item) },
    ['<C-n>'] = { c = select_item_smart('next', {}) },
    ['<C-p>'] = { c = select_item_smart('prev', {}) },
    ['<C-e>'] = { c = cmp.mapping.close() },
    [xk '<C-S-n>'] = {
      c = function()
        cmp.close()
        feedkeys.call(keymap.t '<Down>', 'n')
        cmp.complete()
      end,
    },
    [xk '<C-S-p>'] = {
      c = function()
        cmp.close()
        feedkeys.call(keymap.t '<Up>', 'n')
        cmp.complete()
      end,
    },
    [xk [[<C-S-a>]]] = {
      c = function()
        if cmp.visible() then
          cmp.close()
        else
          cmp.complete()
        end
      end,
    },
  },
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

-- Set configuration for specific filetype.
---@diagnostic disable-next-line: undefined-field
cmp.setup.filetype({ 'gitcommit', 'NeogitCommitMessage' }, {
  sources = cmp.config.sources({
    { name = 'git' },
  }, {
    { name = 'buffer' },
  }),
})

require('cmp_git').setup {
  remotes = { 'upstream', 'origin', 'b0o' },
  github = {
    issues = {
      filter = 'all',
      limit = 250,
      state = 'all',
      format = {
        label = function(_, issue)
          local icon = ({
            open = '',
            closed = '',
          })[string.lower(issue.state)]
          return string.format('%s #%d: %s', icon, issue.number, issue.title)
        end,
      },
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
      format = {
        label = function(_, pr)
          local icon = ({
            open = '',
            closed = '',
          })[string.lower(pr.state)]
          return string.format('%s #%d: %s', icon, pr.number, pr.title)
        end,
      },
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
      -- selene: allow(unused_variable)
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.git:get_commits(callback, params, trigger_char)
      end,
    },
    {
      debug_name = 'github_issues',
      trigger_character = '#',
      -- selene: allow(unused_variable)
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.github:get_issues(callback, git_info, trigger_char)
      end,
    },
    {
      debug_name = 'github_pulls',
      trigger_character = '!',
      -- selene: allow(unused_variable)
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.github:get_pull_requests(callback, git_info, trigger_char)
      end,
    },
    {
      debug_name = 'github_mentions',
      trigger_character = '@',
      -- selene: allow(unused_variable)
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.github:get_mentions(callback, git_info, trigger_char)
      end,
    },
    {
      debug_name = 'gitlab_issues',
      trigger_character = '#',
      -- selene: allow(unused_variable)
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.gitlab:get_issues(callback, git_info, trigger_char)
      end,
    },
    {
      debug_name = 'gitlab_mentions',
      trigger_character = '@',
      -- selene: allow(unused_variable)
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.gitlab:get_mentions(callback, git_info, trigger_char)
      end,
    },
    {
      debug_name = 'gitlab_mrs',
      trigger_character = '!',
      -- selene: allow(unused_variable)
      ---@diagnostic disable-next-line: unused-local
      action = function(sources, trigger_char, callback, params, git_info)
        return sources.gitlab:get_merge_requests(callback, git_info, trigger_char)
      end,
    },
  },
}
