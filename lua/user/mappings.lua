local M = {}

local fn = require 'user.fn'
local lazy = require 'user.util.lazy'
local xk = require('user.keys').xk
local recent_wins = lazy_require 'user.util.recent-wins'

local maputil = require 'user.util.map'
local map = maputil.map
local ft = maputil.ft
local wrap = maputil.wrap

-- Disable C-z suspend
map('nvo', '<C-z>', '<Nop>')
map('nvo', '<C-\\>', '<Nop>')

-- Disable Ex mode
map('n', 'Q', '<Nop>')
map('n', 'gQ', '<Nop>')

-- Disable command-line window
map('n', 'q:', '<Nop>')
map('n', 'q/', '<Nop>')
map('n', 'q?', '<Nop>')

map('n', 'j', function()
  return vim.v.count > 1 and 'j' or 'gj'
end, { expr = true, desc = 'Line down' })

map('n', 'k', function()
  return vim.v.count > 0 and 'k' or 'gk'
end, { expr = true, desc = 'Line up' })

map('nx', 'J', '5j', 'Jump down')
map('nx', 'K', '5k', 'Jump up')
map('nx', '<C-d>', '25j', 'Page down')
map('nx', '<C-u>', '25k', 'Page up')

-- If on a blank line, start insert mode properly indented
map('n', 'i', function()
  if not vim.bo.buftype == 'terminal' and string.match(vim.api.nvim_get_current_line(), '^%s*$') then
    return '"_S'
  else
    return 'i'
  end
end, { expr = true, desc = 'Insert' })

map('nx', '<M-Down>', '<C-e>', 'Scroll view down 1')
map('nx', '<M-Up>', '<C-y>', 'Scroll view up 1')
map('nx', '<M-S-Down>', '5<C-e>', 'Scroll view down 5')
map('nx', '<M-S-Up>', '5<C-y>', 'Scroll view up 5')

map('i', '<M-Down>', '<C-o><C-e>', 'Scroll view down 1')
map('i', '<M-Up>', '<C-o><C-y>', 'Scroll view up 1')
map('i', '<M-S-Down>', '<C-o>5<C-e>', 'Scroll view down 5')
map('i', '<M-S-Up>', '<C-o>5<C-y>', 'Scroll view up 5')

map('n', '<M-b>', 'ge', 'Move to the end of the previous word')

map('n', { 'Q', '<F29>' }, '<Cmd>CloseWin<Cr>', 'Close window')
map('n', 'ZQ', '<Cmd>confirm qall<Cr>', 'Quit all')
map('n', xk '<C-S-w>', '<Cmd>tabclose<Cr>', 'Close tab (except last one)')
map('n', '<leader>H', '<Cmd>hide<Cr>', 'Hide buffer')
map('n', '<C-s>', '<Cmd>w<Cr>', 'Write buffer')

-- quickly enter command mode with substitution commands prefilled
map('n', '<leader>/', ':%s/', { silent = false, desc = 'Substitute' })
map('n', '<leader>?', ':%S/', { silent = false, desc = 'Substitute (rev)' })
map('x', '<leader>/', ':s/', { silent = false, desc = 'Substitute' })
map('x', '<leader>?', ':S/', { silent = false, desc = 'Substitute (rev)' })

-- Buffer-local option toggles
local function map_toggle_locals(keys, opts, vals)
  keys = type(keys) == 'table' and keys or { keys }
  opts = type(opts) == 'table' and opts or { opts }
  vals = vals or { true, false }

  local lhs = vim.tbl_map(function(k)
    return [[<localleader><localleader>]] .. k
  end, keys)

  local rhs = function()
    vim.tbl_map(function(opt)
      local cur = vim.opt_local[opt]:get()
      local target = vals[1]
      for i, v in ipairs(vals) do
        if v == cur then
          if vals[i + 1] ~= nil then
            target = vals[i + 1]
          end
          break
        end
      end
      local msg
      if type(target) == 'boolean' then
        msg = (target and 'Enable ' or 'Disable ') .. opt
      else
        msg = 'Set ' .. opt .. '=' .. target
      end
      vim.notify(msg)
      vim.opt_local[opt] = target
    end, opts)
  end

  map('n', lhs, rhs, 'Toggle ' .. table.concat(opts, ', '))
end

map_toggle_locals({ 'A', 'ar' }, { 'autoread' })
map_toggle_locals({ 'B' }, { 'cursorbind', 'scrollbind' })
map_toggle_locals({ 'bi' }, { 'breakindent' })
map_toggle_locals({ 'C', 'ci' }, { 'copyindent' })
map_toggle_locals({ 'cc' }, { 'concealcursor' }, { '', 'n' })
map_toggle_locals({ 'cl' }, { 'conceallevel' }, { 0, 2 })
map_toggle_locals({ 'cb' }, { 'cursorbind' })
map_toggle_locals({ 'D', 'di' }, { 'diff' })
map_toggle_locals({ 'E', 'et' }, { 'expandtab' })
map_toggle_locals({ 'F', 'fe' }, { 'foldenable' })
map_toggle_locals({ 'L', 'lb' }, { 'linebreak' })
map_toggle_locals({ 'N', 'nn' }, { 'number', 'relativenumber' })
map_toggle_locals({ 'nr', 'rn' }, { 'relativenumber' })
map_toggle_locals({ 'nu' }, { 'number' })
map_toggle_locals({ 'R', 'ru' }, { 'ruler' })
map_toggle_locals({ 'S', 'sg' }, { 'laststatus' }, { 2, 3 })
map_toggle_locals({ 'sp' }, { 'spell' })
map_toggle_locals({ 'sb' }, { 'scrollbind' })
map_toggle_locals({ 'sr' }, { 'shiftround' })
map_toggle_locals({ 'st' }, { 'smarttab' })
map_toggle_locals({ '|' }, { 'cursorcolumn' })
map_toggle_locals({ 'W', 'ww' }, { 'wrap' })

---- Cut/Copy Buffers
local cutbuf = lazy.require 'user.util.cutbuf'
map('n', '<localleader>x', cutbuf.cut, 'cutbuf: cut')
map('n', '<localleader>c', cutbuf.copy, 'cutbuf: copy')
map('n', '<localleader>p', cutbuf.paste, 'cutbuf: paste')
map('n', '<localleader>X', cutbuf.swap, 'cutbuf: swap')

---- Window Management
local auto_resize = require 'user.util.auto-resize'
map('n', '<leader>sa', auto_resize.enable, 'Enable auto-resize')
map('n', '<leader>sA', auto_resize.disable, 'Disable auto-resize')

---- Editing
map('n', 'gi', [[:exec "normal i".nr2char(getchar())."\e"<Cr>]], 'Insert a single character')
map('n', 'ga', [[:exec "normal a".nr2char(getchar())."\e"<Cr>]], 'Insert a single character (append)')

map('x', '>', '>gv', 'Indent')
map('x', '<', '<gv', 'De-Indent')

map('n', '<M-.>', "m'Do<Esc>p`", 'Break line at cursor')
map('n', '<M-,>', "m'DO<Esc>p`", 'Break line at cursor (reverse)')

map('n', 'go', 'o<C-u>', 'Insert on new line without autocomment')
map('n', 'gO', 'O<C-u>', 'Insert on new line above without autocomment')

map('n', 'Y', 'y$', 'Yank until end of line')

map('x', '<leader>y', '"+y', 'Yank to system clipboard')
map('n', '<leader>y', '"+yg_', "Yank 'til EOL to system clipboard")
map('n', '<leader>yy', '"+yy', 'Yank line to system clipboard')
map('n', '<C-y>', [[pumvisible() ? "\<C-y>" : '"+yy']], { expr = true, desc = 'Yank line to system clipboard' })
map('x', '<C-y>', [[pumvisible() ? "\<C-y>" : '"+y']], { expr = true, desc = 'Yank line to system clipboard' })

map('n', '<leader>yp', '<Cmd>let @+ = expand("%:p")<Cr>:echom "Copied " . @+<Cr>', 'Yank file path')
map('n', '<leader>y:', [[<Cmd>let @+=@:<Cr>:echom "Copied '" . @+ . "'"<Cr>]], 'Yank last command')

map('nx', '<C-p>', '"+p', 'Paste from system clipboard')

map('n', '<M-p>', 'a <Esc>p', 'Insert a space and then paste after cursor')
map('n', '<M-P>', 'i <Esc>P', 'Insert a space and then paste before cursor')

map('n', '<C-M-j>', '"dY"dp', 'Duplicate line downwards')
map('n', '<C-M-k>', '"dY"dP', 'Duplicate line upwards')

map('x', '<C-M-j>', '"dy`<"dPjgv', 'Duplicate selection downwards')
map('x', '<C-M-k>', '"dy`>"dpgv', 'Duplicate selection upwards')

local wrap_visual_selection = lazy.require('user.util.wrap').wrap_visual_selection

map('x', '<M-w>', wrap_visual_selection, 'Wrap selection')
map('n', '<M-S-W>', function()
  vim.cmd [[normal! V]]
  wrap_visual_selection()
end, 'Wrap line')

---- Treesitter
local node_motion = lazy.require('user.util.treesitter').node_motion
map('xo', 'n', node_motion, 'Smart select node')
map('n', '<C-M-w>', function()
  node_motion()
  wrap_visual_selection()
end, 'Wrap word')

-- match the indentation of the next line
local function match_indent(dir)
  return function()
    local target_line = vim.fn.search([[\S]], 'nW' .. (dir == -1 and 'bz' or ''))
    if target_line == 0 then
      return
    end
    local cur = vim.api.nvim_win_get_cursor(0)
    local indent = vim.fn.indent(cur[1])
    local new_indent = vim.fn.indent(target_line)
    local text = vim.fn.trim(vim.api.nvim_get_current_line())
    ---@diagnostic disable-next-line: param-type-mismatch
    local new_text = string.rep(' ', new_indent) .. text
    vim.api.nvim_set_current_line(new_text)
    vim.api.nvim_win_set_cursor(0, { cur[1], cur[2] + (new_indent - indent) })
  end
end

map('i', '<M-,>', match_indent(-1), 'Match indent of prev line')
map('i', '<M-.>', match_indent(1), 'Match indent of next line')

-- Clear UI state:
-- - Clear search highlight
-- - Clear command-line
-- - Close floating windows
map('n', [[<Esc>]], function()
  vim.cmd 'nohlsearch'
  if package.loaded['nvim-tree'] then
    require('nvim-tree.actions.node.file-popup').close_popup()
  end
  if package.loaded['cmp'] then
    require('cmp').close()
  end
  if package.loaded['noice'] then
    vim.cmd 'NoiceDismiss'
  end
  fn.close_float_wins {
    '',
    'notify',
    'markdown',
    'aerial',
    'dap-float',
  }
  vim.cmd "echo ''"
end, 'Clear UI')

-- emacs-style motion & editing in insert mode
map('i', '<C-a>', '<Home>', 'Goto beginning of line')
map('i', '<C-e>', '<End>', 'Goto end of line')
map('i', '<C-b>', '<Left>', 'Goto char backward')
map('i', '<C-f>', '<Right>', 'Goto char forward')
map('i', '<M-b>', '<S-Left>', 'Goto word backward')
map('i', '<M-f>', '<S-Right>', 'Goto word forward')
map('i', '<C-d>', '<Delete>', 'Kill char forward')
map('i', '<M-d>', '<C-o>de', 'Kill word forward')
map('i', '<M-Backspace>', '<C-o>dB', 'Kill word backward')
map('i', '<C-k>', '<C-o>D', 'Kill to end of line')

map('i', '<M-h>', '<Left>', 'Move left')
map('i', '<M-j>', '<Down>', 'Move down')
map('i', '<M-k>', '<Up>', 'Move up')
map('i', '<M-l>', '<Right>', 'Move right')

map('i', '<M-a>', '<C-o>_', 'Move to start of line')

-- unicode stuff
map('i', xk "<C-'>", '<C-k>', 'Insert digraph')
map('n', 'gxa', 'ga', 'Show char code in decimal, hexadecimal and octal')

map('i', xk '<C-`>', '<C-o>~<Left>', 'Toggle case')

-- emacs-style motion & editing in command mode
map('c', '<C-a>', '<Home>', 'Goto beginning of line')
map('c', '<C-b>', '<Left>', 'Goto char backward')
map('c', '<C-d>', '<Delete>', 'Kill char forward')
map('c', '<C-f>', '<Right>', 'Goto char forward')
map('c', '<C-g>', '<C-c>', 'Cancel')
map('c', '<C-k>', [[<C-\>e(" ".getcmdline())[:getcmdpos()-1][1:]<Cr>]], 'Kill to end of line')
map('c', '<M-f>', [[<C-\>euser#fn#cmdlineMoveWord( 1, 0)<Cr>]], 'Goto word forward')
map('c', '<M-b>', [[<C-\>euser#fn#cmdlineMoveWord(-1, 0)<Cr>]], 'Goto word backward')
map('c', '<M-d>', [[<C-\>euser#fn#cmdlineMoveWord( 1, 1)<Cr>]], 'Kill word forward')
map('c', '<M-Backspace>', [[<C-\>euser#fn#cmdlineMoveWord(-1, 1)<Cr>]], 'Kill word backward')

map('c', '<M-k>', '<C-k>', 'Insert digraph')

-- See: https://github.com/mhinz/vim-galore#saner-command-line-history
map('c', '<C-p>', [[pumvisible() ? "\<C-p>" : "\<Up>"]], { expr = true, desc = 'History prev' })
map('c', '<C-n>', [[pumvisible() ? "\<C-n>" : "\<Down>"]], { expr = true, desc = 'History next' })
map('c', '<M-/>', [[pumvisible() ? "\<C-y>" : "\<M-/>"]], { expr = true, desc = 'Accept completion suggestion' })

map('c', xk '<C-/>', [[pumvisible() ? "\<C-y>\<Tab>" : nr2char(0x001f)]], {
  expr = true,
  desc = 'Accept completion suggestion & continue',
})

local function cursor_lock(lock)
  return function()
    local win = vim.api.nvim_get_current_win()
    local augid = vim.api.nvim_create_augroup('user_cursor_lock_' .. win, { clear = true })
    if not lock or vim.w.cursor_lock == lock then
      vim.w.cursor_lock = nil
      vim.notify 'Cursor lock disabled'
      return
    end
    local cb = function()
      if vim.w.cursor_lock then
        vim.cmd('silent normal z' .. vim.w.cursor_lock)
      end
    end
    vim.w.cursor_lock = lock
    vim.api.nvim_create_autocmd('CursorMoved', {
      desc = 'Cursor lock for window ' .. win,
      buffer = 0,
      group = augid,
      callback = cb,
    })
    cb()
    vim.notify 'Cursor lock enabled'
  end
end

map('n', '<leader>zt', cursor_lock 't', 'Toggle cursor lock (top)')
map('n', '<leader>zz', cursor_lock 'z', 'Toggle cursor lock (middle)')
map('n', '<leader>zb', cursor_lock 'b', 'Toggle cursor lock (bottom)')

---- Jumplist
map('n', xk '<C-S-o>', wrap(fn.jumplist_jump_buf, -1), 'Jumplist: Go to last buffer')
map('n', xk '<C-S-i>', wrap(fn.jumplist_jump_buf, 1), 'Jumplist: Go to next buffer')

---- Quickfix
map('n', '<M-S-q>', function()
  local winid = vim.fn.getqflist({ winid = 1 }).winid
  if winid and winid ~= 0 then
    vim.api.nvim_win_close(winid, true)
  else
    vim.cmd 'botright copen'
    vim.cmd.wincmd 'p'
  end
end, 'Quickfix: Toggle')

map(
  'n',
  [[<M-q>]],
  fn.filetype_command('qf', recent_wins.focus_most_recent, wrap(vim.cmd, 'botright copen')),
  'Quickfix: Toggle Focus'
)

map('n', ']q', '<Cmd>cnext<Cr>', 'Quickfix: Next')
map('n', '[q', '<Cmd>cprev<Cr>', 'Quickfix: Prev')

ft('qf', function(bufmap)
  bufmap('n', 'dd', function()
    local line = vim.fn.line '.'
    vim.fn.setqflist(
      vim.fn.filter(vim.fn.getqflist(), function(idx)
        return idx ~= line - 1
      end),
      'r'
    )
    vim.fn.setpos('.', { 0, line, 1, 0 })
  end, 'Quickfix: Delete item under cursor')

  bufmap('v', 'd', function()
    vim.schedule(function()
      local start = vim.fn.line "'<"
      local finish = vim.fn.line "'>"
      vim.fn.setqflist(
        vim.fn.filter(vim.fn.getqflist(), function(idx)
          return idx < start - 1 or idx >= finish
        end),
        'r'
      )
      vim.fn.setpos('.', { 0, start, 1, 0 })
    end)
    vim.cmd [[call feedkeys("\<Esc>", 'n')]]
  end, 'Quickfix: Delete selected items')

  bufmap('n', '<Tab>', '<Cr><Cmd>copen<Cr>', 'Quickfix: Jump to item under cursor')

  bufmap('n', '<M-w>', function()
    local sel = vim.fn.getqflist({ id = 0, idx = vim.fn.line '.', items = 0 }).items[1]
    if not sel then
      return
    end
    local win = require('window-picker').pick_window()
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_buf(win, sel.bufnr)
      vim.api.nvim_set_current_win(win)
      vim.api.nvim_win_set_cursor(win, { sel.lnum, sel.col })
    end
  end, 'Quickfix: Jump to item under cursor (pick window)')
end)

---- Tabs
-- Navigate tabs
-- Go to a tab by index; If it doesn't exist, create a new tab
local function tabnm(n)
  return function()
    local tabs = vim.api.nvim_list_tabpages()
    if n > #tabs then
      vim.cmd '$tabnew'
    else
      local tabpage = tabs[n]
      vim.api.nvim_set_current_tabpage(tabpage)
    end
  end
end

map('n', "<M-'>", '<Cmd>tabn<Cr>', 'Tabs: Goto next')
map('n', '<M-;>', '<Cmd>tabp<Cr>', 'Tabs: Goto prev')
map('t', "<M-'>", '<C-\\><C-n>:tabn<Cr>', 'Tabs: Goto next')
map('t', '<M-;>', '<C-\\><C-n>:tabp<Cr>', 'Tabs: Goto prev')
map('n', '<M-S-a>', ':execute "wincmd g\\<Tab>"<Cr>', 'Tabs: Goto last accessed')

map('n', '<M-a>', recent_wins.focus_most_recent, 'Panes: Goto previously focused')
map('n', '<M-x>', recent_wins.flip_recents, 'Panes: Flip the last normal wins')

map('n', '<M-1>', tabnm(1), 'Goto tab 1')
map('n', '<M-2>', tabnm(2), 'Goto tab 2')
map('n', '<M-3>', tabnm(3), 'Goto tab 3')
map('n', '<M-4>', tabnm(4), 'Goto tab 4')
map('n', '<M-5>', tabnm(5), 'Goto tab 5')
map('n', '<M-6>', tabnm(6), 'Goto tab 6')
map('n', '<M-7>', tabnm(7), 'Goto tab 7')
map('n', '<M-8>', tabnm(8), 'Goto tab 8')
map('n', '<M-9>', tabnm(9), 'Goto tab 9')
map('n', '<M-0>', tabnm(10), 'Goto tab 10')

map('n', '<M-">', ':+tabm<Cr>', 'Move tab right')
map('n', '<M-:>', ':-tabm<Cr>', 'Move tab left')

map('n', '<F13>', '<Cmd>tabnew<Cr>', 'Open new tab')

map('t', '<M-h>', '<C-\\><C-n><C-w>h', 'Goto tab left')
map('t', '<M-j>', '<C-\\><C-n><C-w>j', 'Goto tab down')
map('t', '<M-k>', '<C-\\><C-n><C-w>k', 'Goto tab up')
map('t', '<M-l>', '<C-\\><C-n><C-w>l', 'Goto tab right')

map('n', '<leader>sf', wrap(fn.toggle_winfix, 'height'), 'Toggle fixed window height')
map('n', '<leader>sF', wrap(fn.toggle_winfix, 'width'), 'Toggle fixed window width')

map('n', '<leader>s<M-f>', wrap(fn.set_winfix, true, 'height', 'width'), 'Enable fixed window height/width')
map('n', '<leader>s<C-f>', wrap(fn.set_winfix, false, 'height', 'width'), 'Disable fixed window height/width')

-- see also the VSplit plugin mappings below
map('n', '<leader>S', '<Cmd>new<Cr>', 'Split (horiz, new)')
map('n', '<leader>sn', '<Cmd>new<Cr>', 'Split (horiz, new)')
map('n', '<leader>V', '<Cmd>vnew<Cr>', 'Split (vert, new)')
map('n', '<leader>vn', '<Cmd>vnew<Cr>', 'Split (vert, new)')
map('n', '<leader>ss', '<Cmd>split<Cr>', 'Split (horiz, cur)')
map('n', '<leader>st', '<Cmd>split<Cr>', 'Split (horiz, cur)')
map('n', '<leader>vv', '<Cmd>vsplit<Cr>', 'Split (vert, cur)')
map('n', '<leader>vt', '<Cmd>vsplit<Cr>', 'Split (vert, cur)')

-- TODO: Convert to Lua
map('x', '<leader>I', '<Esc>:call user#fn#interleave()<Cr>', 'Interleave two contiguous blocks')

-- PasteRestore
-- paste register without overwriting with the original selectin, use P for original behavior
-- TODO: Convert to Lua
map('x', 'p', 'user#fn#pasteRestore()', { expr = true, desc = 'PasteRestore' })

map('t', xk [[<C-S-n>]], '<C-\\><C-n>', 'Switch to normal mode')
map('t', '<C-n>', '<C-n>', 'Send Ctrl-n')
map('t', '<C-p>', '<C-p>', 'Send Ctrl-p')
map('t', '<M-n>', '<M-n>', 'Send Alt-n')
map('t', '<M-p>', '<M-p>', 'Send Alt-p')

-- TODO: Convert to Lua
map('n', '<Leader>ml', '<Cmd>call AppendModeline()<Cr>', 'Append modeline with current settings')

---- Syntax
map('n', '<leader>hi', '<Cmd>Inspect<Cr>', 'Inspect syntax under cursor')

------ Filetypes
ft('lua', function(bufmap)
  bufmap('nx', '<leader><Enter>', fn.luarun, 'Lua: Eval')
  bufmap('n', '<localleader><Enter>', wrap(fn.luarun, true), 'Lua: Eval file')
  bufmap('nx', '<leader><F12>', "<Cmd>Put lua require'user.fn'.luarun()<Cr>", 'Lua: Eval (Append result to buffer)')
end)

ft({ 'typescriptreact', 'javascriptreact' }, function(bufmap)
  local tailwind_sort = function()
    require('user.util.visual').transform_visual_selection(
      { 'rustywind', '--stdin', '--custom-regex', '(.*)' },
      function(pre)
        -- if the selection includes quotes at the beginning and end, remove them
        local first = pre:sub(0, 1)
        local last = pre:sub(-1)
        if first == last and (first == "'" or first == '"' or first == '`') then
          return pre:sub(2, -2), { first, last }
        end
        return pre
      end,
      function(post, ctx)
        -- if the selection was quoted, re-add the quotes
        if ctx then
          return ctx[1] .. post .. ctx[2]
        end
        return post
      end
    )
  end
  bufmap('x', '<leader>ft', tailwind_sort, 'Tailwind: Sort selection')
  bufmap('n', '<leader>ft', function()
    require('nvim-treesitter.textobjects.select').select_textobject('@string', 'textobjects', 'x')
    tailwind_sort()
  end, 'Tailwind: Sort string under cursor')
end)

ft({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }, function(bufmap)
  bufmap('n', '<leader>ii', '<Cmd>TwoslashQueriesInspect<Cr>', 'TwoSlash: Inspect')
  bufmap('n', '<leader>ir', '<Cmd>TwoslashQueriesRemove<Cr>', 'TwoSlash: Remove')
end)

ft('man', function(bufmap)
  bufmap('n', '<C-]>', function()
    fn.man('', vim.fn.expand '<cword>')
  end, 'Man: Open tag in current buffer')

  bufmap('n', '<M-]>', function()
    fn.man('tab', vim.fn.expand '<cword>')
  end, 'Man: Open tag in new tab')

  bufmap('n', '}', function()
    fn.man('split', vim.fn.expand '<cword>')
  end, 'Man: Open tag in new split')

  -- navigate to next/prev section
  bufmap('n', '[[', ":<C-u>call user#fn#manSectionMove('b', 'n', v:count1)<Cr>", 'Man: Goto prev section')
  bufmap('n', ']]', ":<C-u>call user#fn#manSectionMove('' , 'n', v:count1)<Cr>", 'Man: Goto next section')
  bufmap('x', '[[', ":<C-u>call user#fn#manSectionMove('b', 'v', v:count1)<Cr>", 'Man: Goto prev section')
  bufmap('x', ']]', ":<C-u>call user#fn#manSectionMove('' , 'v', v:count1)<Cr>", 'Man: Goto next section')

  -- navigate to next/prev manpage tag
  bufmap('n', '<Tab>', [[:call search('\(\w\+(\w\+)\)', 's')<Cr>]], 'Man: Goto next tag')
  bufmap('n', '<S-Tab>', [[:call search('\(\w\+(\w\+)\)', 'sb')<Cr>]], 'Man: Goto prev tag')

  -- search from beginning of line (useful for finding command args like -h)
  bufmap('n', 'g/', [[/^\s*\zs]], 'Man: Start BOL search')
end)

---- folke/lazy.nvim
map('n', '<leader>ll', '<Cmd>Lazy<cr>', 'Lazy')

return M
