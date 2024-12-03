local cmp = require 'cmp'
local feedkeys = require 'cmp.utils.feedkeys'
local keymap = require 'cmp.utils.keymap'

local xk = require('user.keys').xk

local wincfg = vim.tbl_extend('force', cmp.config.window.bordered(), {
  winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None',
})

local function wrap(fn, ...)
  local args = { ... }
  return function() return fn(unpack(args)) end
end

-- Select item next/prev, taking into account whether the cmp window is
-- top-down or bottoom-up so that the movement is always in the same direction.
local select_item_smart = function(dir, opts)
  return function(fallback)
    opts = opts or { behavior = cmp.SelectBehavior.Select }
    fallback = opts.fallback or fallback
    if cmp.visible() then
      ---@diagnostic disable-next-line: invisible
      if cmp.core.view.custom_entries_view:is_direction_top_down() then
        ({ next = cmp.select_next_item, prev = cmp.select_prev_item })[dir](opts)
      else
        ({ prev = cmp.select_next_item, next = cmp.select_prev_item })[dir](opts)
      end
    elseif vim.bo.ft == 'dap-repl' then
      feedkeys.call(keymap.t(({ next = '<Down>', prev = '<Up>' })[dir]), 'i', false)
    else
      fallback()
    end
  end
end

cmp.setup {
  window = {
    completion = wincfg,
    documentation = wincfg,
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    expandable_indicator = true,
    format = function(entry, vim_item)
      vim_item.menu = ({
        cmdline = ' Cmd',
      })[entry.source.name] or entry.source.name
      local sym = require('lspkind').symbolic(vim_item.kind)
      if sym == '' then
        sym = '∅'
      end
      vim_item.menu = (vim_item.menu or '') .. '->' .. (vim_item.kind or '')
      vim_item.kind = ' ' .. sym .. ' '
      return vim_item
    end,
  },
  sources = {},
  enabled = function() return vim.bo.buftype ~= 'prompt' end,
}

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline {
    ['<C-z>'] = { c = false },
    ['<C-n>'] = { c = select_item_smart('next', { fallback = wrap(feedkeys.call, keymap.t '<Down>', 'n') }) },
    ['<C-p>'] = { c = select_item_smart('prev', { fallback = wrap(feedkeys.call, keymap.t '<Up>', 'n') }) },
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
  },
  sources = {
    { name = 'buffer' },
  },
})

local function handle_tab_complete(direction)
  return function()
    if vim.api.nvim_get_mode().mode == 'c' and cmp.get_selected_entry() == nil then
      local text = vim.fn.getcmdline()
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
    ['<C-n>'] = { c = select_item_smart('next', { fallback = wrap(feedkeys.call, keymap.t '<Down>', 'n') }) },
    ['<C-p>'] = { c = select_item_smart('prev', { fallback = wrap(feedkeys.call, keymap.t '<Up>', 'n') }) },
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
  sources = cmp.config.sources {
    { name = 'cmdline' },
  },
})
