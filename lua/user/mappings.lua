local M = {}

local fn = require 'user.fn'
local xk = require('user.keys').xk
local recent_wins = fn.require_on_call_rec 'user.util.recent-wins'

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
local cutbuf = fn.require_on_call_rec 'user.util.cutbuf'
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

local wrap_visual_selection = fn.require_on_call_rec('user.util.wrap').wrap_visual_selection

map('x', '<M-w>', wrap_visual_selection, 'Wrap selection')
map('n', '<M-S-W>', function()
  vim.cmd [[normal! V]]
  wrap_visual_selection()
end, 'Wrap line')

---- Treesitter
local node_motion = fn.require_on_call_rec('user.util.treesitter').node_motion
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

-- Like 'gf', but if the file doesn't exist, open Telescope with the filename
-- as the default text
-- Credit: justabubble123 on Discord
local function gf_telescope(cmd)
  local file = vim.fn.expand '<cfile>'
  if not file or file == '' then
    return
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  if not vim.loop.fs_stat(file) then
    require('telescope.builtin').find_files { default_text = file }
    return
  end
  vim.cmd((cmd or 'edit') .. ' ' .. file)
end

map('n', 'gf', gf_telescope, 'Go to file under cursor')
map('n', 'gF', gf_telescope, 'Go to file under cursor (new tab)')

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

------ LSP
map('n', '<leader>lif', '<Cmd>LspInfo<Cr>', 'LSP: Show LSP information')
map('n', '<leader>lr', '<Cmd>LspRestart<Cr>', 'LSP: Restart LSP')
map('n', '<leader>ls', '<Cmd>LspStart<Cr>', 'LSP: Start LSP')
map('n', '<leader>lS', '<Cmd>LspStop<Cr>', 'LSP: Stop LSP')

local lsp_attached_bufs
M.on_first_lsp_attach = function()
  ---- trouble.nvim
  local trouble = fn.require_on_call_rec 'trouble'
  local function trouble_get_win()
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local ft = vim.bo[bufnr].filetype
      if ft == 'trouble' then
        return winid
      end
    end
  end

  map('n', '<M-S-t>', function()
    local winid = trouble_get_win()
    if winid then
      trouble.close { mode = 'diagnostics' }
    else
      trouble.open { mode = 'diagnostics' }
      recent_wins.focus_most_recent()
    end
  end, 'Trouble: Toggle')

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

  local user_lsp = fn.require_on_call_rec 'user.lsp'
  map('n', '<leader>lii', user_lsp.set_inlay_hints_global, 'LSP: Toggle inlay hints')
  map('n', '<leader>lie', wrap(user_lsp.set_inlay_hints_global, true), 'LSP: Enable inlay hints')
  map('n', '<leader>lid', wrap(user_lsp.set_inlay_hints_global, false), 'LSP: Disable inlay hints')
end

M.on_lsp_attach = function(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if not lsp_attached_bufs then
    lsp_attached_bufs = {}
    M.on_first_lsp_attach()
  elseif lsp_attached_bufs[bufnr] or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  lsp_attached_bufs[bufnr] = true

  local user_lsp = fn.require_on_call_rec 'user.lsp'
  local trouble = fn.require_on_call_rec 'trouble'
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
  end, 'LSP: Rename')

  local code_actions = fn.require_on_call_rec('actions-preview').code_actions
  bufmap('nx', { '<localleader>A', '<localleader>ca' }, code_actions, 'LSP: Code action')

  local function gotoDiag(dir)
    return function(sev)
      return function()
        local _dir = dir
        local args = {
          enable_popup = true,
          severity = vim.diagnostic.severity[sev],
        }
        if _dir == 'first' or _dir == 'last' then
          args.wrap = false
          if dir == 'first' then
            args.cursor_position = { 1, 1 }
            _dir = 'next'
          else
            args.cursor_position = { vim.api.nvim_buf_line_count(0) - 1, 1 }
            _dir = 'prev'
          end
        end
        vim.diagnostic['goto_' .. _dir](args)
      end
    end
  end
  local prevDiag = gotoDiag 'prev'
  local nextDiag = gotoDiag 'next'
  local firstDiag = gotoDiag 'first'
  local lastDiag = gotoDiag 'last'

  bufmap('n', '<localleader>ds', vim.diagnostic.show, 'LSP: Show diagnostics')
  bufmap('n', { '<localleader>dt', '<localleader>T' }, trouble.toggle, 'LSP: Toggle Trouble')

  bufmap('n', '<localleader>dd', function()
    local enabled = vim.diagnostic.is_enabled { bufnr = 0 }
    vim.diagnostic.enable(not enabled, { bufnr = 0 })
    vim.notify('Diagnostics ' .. (enabled and 'disabled' or 'enabled'))
  end, 'LSP: Toggle Diagnostic')

  bufmap('n', '[d', prevDiag(), 'LSP: Goto prev diagnostic')
  bufmap('n', ']d', nextDiag(), 'LSP: Goto next diagnostic')
  bufmap('n', '[h', prevDiag 'HINT', 'LSP: Goto prev hint')
  bufmap('n', ']h', nextDiag 'HINT', 'LSP: Goto next hint')
  bufmap('n', '[i', prevDiag 'INFO', 'LSP: Goto prev info')
  bufmap('n', ']i', nextDiag 'INFO', 'LSP: Goto next info')
  bufmap('n', '[w', prevDiag 'WARN', 'LSP: Goto prev warning')
  bufmap('n', ']w', nextDiag 'WARN', 'LSP: Goto next warning')
  bufmap('n', '[e', prevDiag 'ERROR', 'LSP: Goto prev error')
  bufmap('n', ']e', nextDiag 'ERROR', 'LSP: Goto next error')

  bufmap('n', '[D', firstDiag(), 'LSP: Goto first diagnostic')
  bufmap('n', ']D', lastDiag(), 'LSP: Goto last diagnostic')
  bufmap('n', '[H', firstDiag 'HINT', 'LSP: Goto first hint')
  bufmap('n', ']H', lastDiag 'HINT', 'LSP: Goto last hint')
  bufmap('n', '[I', firstDiag 'INFO', 'LSP: Goto first info')
  bufmap('n', ']I', lastDiag 'INFO', 'LSP: Goto last info')
  bufmap('n', '[W', firstDiag 'WARN', 'LSP: Goto first warning')
  bufmap('n', ']W', lastDiag 'WARN', 'LSP: Goto last warning')
  bufmap('n', '[E', firstDiag 'ERROR', 'LSP: Goto first error')
  bufmap('n', ']E', lastDiag 'ERROR', 'LSP: Goto last error')

  bufmap('n', '<localleader>dr', function()
    vim.diagnostic.reset(nil, 0)
  end, 'LSP: Reset diagnostics (buffer)')

  bufmap(
    'n',
    { [[<localleader>so]], [[<leader>so]] },
    fn.require_on_call_rec('user.plugin.telescope').cmds.lsp_document_symbols,
    'LSP: Telescope symbol search'
  )

  bufmap('n', '<localleader>hs', vim.lsp.buf.signature_help, 'LSP: Signature help')
  bufmap('n', '<M-S-i>', user_lsp.peek_definition, 'LSP: Peek definition')
  bufmap('ni', '<M-i>', vim.lsp.buf.hover, 'LSP: Hover')
end

------ Plugins
---- b0o/incline.nvim
map('n', '<leader>I', fn.require_on_call_rec('incline').toggle, 'Incline: Toggle')

---- Wansmer/treesj
local treesj = fn.require_on_call_rec 'treesj'
map('n', 'gJ', treesj.toggle, 'Treesj: Toggle')
map('n', 'gsj', treesj.join, 'Treesj: Join')
map('n', 'gss', treesj.split, 'Treesj: Split')

---- numToStr/Comment.nvim
local comment = fn.require_on_call_rec 'Comment.api'
map('n', '<M-/>', comment.toggle.linewise, 'Comment: Toggle')
map('x', '<M-/>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'nx', false)
  comment.toggle.linewise(vim.fn.visualmode())
end, 'Comment: Toggle')

---- nvim-telescope/telescope.nvim
local tu = fn.require_on_call_rec 'user.plugin.telescope'
local tc = tu.cmds

map('n', xk '<C-S-f>', tc.builtin, 'Telescope: Builtins')
map('n', '<C-f>b', tc.buffers, 'Telescope: Buffers')
map('n', { '<C-f>h', '<C-f><C-h>' }, tc.help_tags, 'Telescope: Help tags')

map('n', { '<C-f>a', '<C-f><C-a>' }, tc.live_grep_args, 'Telescope: Live grep')

map('n', '<C-f>F', tc.any_files, 'Telescope: Any Files')
map('n', { '<C-f>o', '<C-f><C-o>' }, tc.oldfiles, 'Telescope: Old files')
map('n', { '<C-f>f', '<C-f><C-f>' }, tc.smart_files, 'Telescope: Files (Smart)')
map('n', { '<C-f>d', '<C-f><C-d>' }, tc.dir_files, 'Telescope: Files (Dir)')
map('n', { '<C-f>w', '<C-f><C-w>' }, wrap(tc.windows, {}), 'Telescope: Windows')
map('n', { '<C-f>i', '<C-f><C-i>' }, '<Cmd>Easypick headers<Cr>', 'Telescope: Includes (headers)')

map('n', { '<C-f>m', '<C-f><C-m>' }, tc.pnpm.workspace_package_files, 'Telescope: Pnpm package files')
map('n', { '<C-f>nf', '<C-f>nn' }, tc.pnpm.workspace_package_files, 'Telescope: Pnpm package files')
map('n', { '<C-f>M', '<C-f>np' }, tc.pnpm.workspace_packages, 'Telescope: Pnpm package')
map('n', { '<C-f>na' }, tc.pnpm.workspace_package_grep, 'Telescope: Pnpm package files grep')

map('n', { '<C-f>t', '<C-f><C-t>' }, tc['todo-comments'], 'Telescope: Todo Comments')

map('n', { '<C-f>r', '<C-f><C-r>' }, tc.resume, 'Telescope: Resume last picker')

map('n', '<C-f>gf', tc.git_files, 'Telescope-Git: Files')

map('n', '<M-f>b', tc.current_buffer_fuzzy_find, 'Telescope-Buffer: Fuzzy find')
map('n', '<M-f>t', tc.tags, 'Telescope-Buffer: Tags')

map('n', '<C-f>A', tc.aerial, 'Telescope-Workspace: Aerial')

---- NeogitOrg/neogit
-- TODO: Use official API if/when merged:
-- https://github.com/NeogitOrg/neogit/pull/865
local git = fn.require_on_call_rec 'neogit.lib.git'
local git_cli = fn.require_on_call_rec 'neogit.lib.git.cli'

local neogit_action = function(popup, action, args)
  return function()
    ---@diagnostic disable-next-line: missing-parameter
    require('plenary.async').run(function()
      require('neogit.popups.' .. popup .. '.actions')[action] {
        state = { env = {} },
        get_arguments = function()
          return args
        end,
      }
    end)
  end
end

local async_action = function(cmd, ...)
  local arg0 = ...
  local args = { select(2, ...) }
  return function()
    ---@diagnostic disable-next-line: missing-parameter
    require('plenary.async').run(function()
      if type(arg0) == 'function' then
        cmd(arg0(unpack(args)))
      else
        cmd(arg0, unpack(args))
      end
    end)
  end
end

local function open_neogit(opts)
  opts = vim.tbl_extend('force', {
    kind = 'vsplit',
    replace = true,
  }, opts or {})
  return function()
    local neogit = require 'neogit'
    if
      opts.replace
      and vim.bo.buftype == ''
      and vim.bo.filetype == ''
      and vim.bo.modified == false
      and vim.api.nvim_buf_line_count(0) == 1
      and vim.fn.getline '.' == ''
    then
      neogit.open { kind = 'replace' }
    else
      neogit.open { kind = opts.kind }
    end
  end
end

map('n', '<leader>gs', open_neogit { kind = 'vsplit' }, 'Neogit')
map('n', '<leader>gg', open_neogit { kind = 'replace' }, 'Neogit (replace)')
map('n', '<leader>G', open_neogit { kind = 'tab', replace = false }, 'Neogit (tab)')

map(
  'n',
  { [[<leader>gA]], [[<leader>gaa]] },
  async_action(function()
    git_cli.add.args('--all').call()
  end),
  'Git: Add all'
)
map(
  'n',
  [[<leader>gaf]],
  async_action(git.index.add, function()
    return { vim.fn.expand '%:p' }
  end),
  'Git: Add file'
)

map('n', '<leader>gC', '<Cmd>Neogit commit<Cr>', 'Neogit: Commit popup')
map('n', '<leader>gcc', neogit_action('commit', 'commit', { '--verbose' }), 'Git: Commit')
map('n', '<leader>gca', neogit_action('commit', 'commit', { '--verbose', '--all' }), 'Git: Commit (all)')
map('n', '<leader>gcA', neogit_action('commit', 'commit', { '--verbose', '--amend' }), 'Git: Commit (amend)')

map('n', '<leader>gl', '<Cmd>Neogit log<Cr>', 'Neogit: Log')

map('n', '<leader>gp', '<Cmd>Neogit push<Cr>', 'Neogit: Push popup')
map('n', '<leader>gP', '<Cmd>Neogit pull<Cr>', 'Neogit: Pull popup')

map('n', '<leader>gR', async_action(git_cli.reset.call), 'Git: Reset')

ft('NeogitStatus', function(bufmap)
  local function neogit_status_buf_item()
    local status = require('neogit.buffers.status').instance()
    if not status then
      return
    end
    local sel = status.buffer.ui:get_item_under_cursor()
    if not sel or not sel.absolute_path then
      return
    end
    return sel
  end
  bufmap('n', '<M-w>', function()
    local item = neogit_status_buf_item()
    if not item then
      return
    end
    local win = require('window-picker').pick_window()
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_buf(win, vim.fn.bufadd(item.absolute_path))
      vim.api.nvim_set_current_win(win)
    end
  end)
  bufmap('n', '<Cr>', function()
    local item = neogit_status_buf_item()
    if not item then
      return
    end
    local prev_win = recent_wins.get_most_recent()
    if not vim.api.nvim_win_is_valid(prev_win or -1) then
      vim.cmd('vsplit ' .. item.name)
    else
      vim.api.nvim_win_set_buf(prev_win, vim.fn.bufadd(item.absolute_path))
    end
  end)
end)

-- lewis6991/gitsigns.nvim
M.on_gistsigns_attach = function(bufnr)
  local function gitsigns_visual_op(op)
    return function()
      return require('gitsigns')[op] { vim.fn.line '.', vim.fn.line 'v' }
    end
  end
  local bufmap = maputil.buf(bufnr)
  local gs = require 'gitsigns'
  bufmap('n', '<leader>hs', gs.stage_hunk, 'Gitsigns: Stage hunk')
  bufmap('n', '<leader>hr', gs.reset_hunk, 'Gitsigns: Reset hunk')
  bufmap('n', '<leader>hu', gs.undo_stage_hunk, 'Gitsigns: Undo stage hunk')
  bufmap('x', '<leader>hs', gitsigns_visual_op 'stage_hunk', 'Gitsigns: Stage selected hunk(s)')
  bufmap('x', '<leader>hr', gitsigns_visual_op 'reset_hunk', 'Gitsigns: Reset selected hunk(s)')
  bufmap('x', '<leader>hu', gitsigns_visual_op 'undo_stage_hunk', 'Gitsigns: Undo stage hunk')
  bufmap('n', '<leader>hS', gs.stage_buffer, 'Gitsigns: Stage buffer')
  bufmap('n', '<leader>hR', gs.reset_buffer, 'Gitsigns: Reset buffer')
  bufmap('n', '<leader>hp', gs.preview_hunk, 'Gitsigns: Preview hunk')
  bufmap('n', '<leader>hb', wrap(gs.blame_line, { full = true }), 'Gitsigns: Blame hunk')
  bufmap('n', '<leader>htb', gs.toggle_current_line_blame, 'Gitsigns: Toggle current line blame')
  bufmap('n', '<leader>hd', gs.diffthis, 'Gitsigns: Diff this')
  bufmap('n', '<leader>htd', gs.toggle_deleted, 'Gitsigns: Toggle deleted')
  bufmap('n', '<leader>hD', wrap(gs.diffthis, '~'), 'Gitsigns: Diff this against last commit')
  bufmap('n', ']c', gs.next_hunk, 'Gitsigns: Next hunk')
  bufmap('n', '[c', gs.prev_hunk, 'Gitsigns: Prev hunk')
  bufmap('xo', 'ih', '<Cmd><C-U>Gitsigns select_hunk<Cr>', '[TextObj] Gitsigns: Inner hunk')
end

-- lukas-reineke/indent-blankline.nvim
---@param mode 'start-outer' | 'start-inner' | 'end-outer' | 'end-inner'
local function goto_scope(mode)
  return function()
    local forward = mode == 'end-outer' or mode == 'end-inner'
    local bufnr = vim.api.nvim_get_current_buf()
    local config = require('ibl.config').get_config(bufnr)
    local start_line = vim.api.nvim_win_get_cursor(0)[1]
    local num_lines = vim.api.nvim_buf_line_count(bufnr)
    local current_line = start_line
    local dest_line
    while true do
      local scope = require('ibl.scope').get(bufnr, config)
      if not scope then
        return
      end
      if mode == 'start-outer' then
        dest_line = scope:start() + 1
      elseif mode == 'start-inner' then
        dest_line = scope:start() + 2
      elseif mode == 'end-outer' then
        dest_line = scope:end_() + 1
      elseif mode == 'end-inner' then
        dest_line = scope:end_()
      end
      if (forward and dest_line > start_line) or (not forward and dest_line < start_line) then
        break
      end
      if mode == 'start-outer' or mode == 'start-inner' then
        current_line = current_line - 1
        if current_line <= 0 then
          vim.notify('No scope start found', vim.log.levels.WARN)
          return
        end
      else
        current_line = current_line + 1
        if current_line > num_lines then
          vim.notify('No scope end found', vim.log.levels.WARN)
          return
        end
      end
      vim.api.nvim_win_set_cursor(0, { current_line, 0 })
    end
    vim.api.nvim_win_set_cursor(0, { dest_line, 0 })
  end
end

map('n', '[s', goto_scope 'start-inner', 'IBL: Scope start (inner)')
map('n', '[S', goto_scope 'start-outer', 'IBL: Scope start (outer)')
map('n', ']s', goto_scope 'end-inner', 'IBL: Scope end (inner)')
map('n', ']S', goto_scope 'end-outer', 'IBL: Scope end (outer)')

-- mbbill/undotree
map('n', '<leader>ut', '<Cmd>UndotreeToggle<Cr>', 'Undotree: Toggle')

-- godlygeek/tabular
map('nx', '<Leader>a', ':Tabularize /', 'Tabularize')

---- KabbAmine/vCoolor.vim
map('n', '<leader>cO', '<Cmd>VCoolor<Cr>', 'Open VCooler color picker')
map('n', '<leader>co', '<Cmd>CccPick<Cr>', 'Open CCC color picker')

------ nvim-neo-tree/neo-tree.nvim & kyazdani42/nvim-tree.lua
---- nvim-neo-tree/neo-tree.nvim
local neotree_mgr = fn.require_on_call_rec 'neo-tree.sources.manager'
local user_neotree = {}
user_neotree.get_state = function()
  return neotree_mgr.get_state 'filesystem' or {}
end
user_neotree.is_visible = function()
  local state = user_neotree.get_state()
  local winid = state.winid or -1
  return vim.api.nvim_win_is_valid(winid), winid
end
local setup_neotree = function()
  map('n', xk '<C-S-\\>', function()
    vim.cmd 'Neotree show toggle'
    vim.schedule(auto_resize.trigger)
  end, 'NeoTree: Toggle')

  map(
    'n',
    xk '<C-\\>',
    fn.filetype_command('neo-tree', recent_wins.focus_most_recent, function()
      vim.cmd 'Neotree focus'
      vim.schedule(auto_resize.trigger)
    end),
    'Nvim-Tree: Toggle Focus'
  )
end

---- kyazdani42/nvim-tree.lua
local function nvim_tree_open_oil(enter)
  return function()
    local oil = require 'oil'
    local tree = require 'nvim-tree.lib'

    local node = tree.get_node_at_cursor()
    local path, is_dir
    if node and node.fs_stat then
      is_dir = node.fs_stat.type == 'directory'
      path = is_dir and enter and node.absolute_path or node.parent.absolute_path
    else
      local base = tree.get_nodes().absolute_path
      is_dir = node.name == '..' or node.name == '.'
      path = enter and node.name == '..' and base .. '/..' or base
    end

    if is_dir and enter then
      oil.toggle_float(path)
      return
    end

    local function bufenter_cb(e, tries)
      if not oil.get_entry_on_line(e.buf, 1) then
        tries = tries or 0
        if tries <= 8 then
          vim.defer_fn(function()
            bufenter_cb(e, tries + 1)
          end, tries * tries)
        end
        return
      end
      for i = 1, vim.api.nvim_buf_line_count(e.buf) do
        local entry = oil.get_entry_on_line(e.buf, i)
        if entry and entry.name == node.name then
          vim.api.nvim_win_set_cursor(0, { i, 0 })
          break
        end
      end
    end

    vim.api.nvim_create_autocmd('BufEnter', {
      once = true,
      pattern = 'oil://*',
      callback = bufenter_cb,
    })

    oil.toggle_float(path)
  end
end

local setup_nvimtree = function()
  map('n', xk '<C-S-\\>', function()
    if require('nvim-tree.view').is_visible() then
      require('nvim-tree.view').close()
    else
      require('nvim-tree.lib').open()
      recent_wins.focus_most_recent()
    end
  end, 'Nvim-Tree: Toggle')

  map(
    'n',
    xk '<C-\\>',
    fn.filetype_command('NvimTree', recent_wins.focus_most_recent, wrap(vim.cmd, [[NvimTreeFocus]])),
    'Nvim-Tree: Toggle Focus'
  )

  ft('NvimTree', function(bufmap)
    local function withSelected(cmd, fmt)
      return function()
        local node = require('nvim-tree.lib').get_node_at_cursor()
        if not node then
          return
        end
        if type(cmd) == 'function' then
          cmd(node)
          return
        end
        local file = node.absolute_path
        vim.cmd(fmt and (cmd):format(file) or ('%s %s'):format(cmd, file))
      end
    end

    bufmap('n', 'ga', withSelected 'Git add', 'Nvim-Tree: Git add')
    bufmap('n', 'gr', withSelected 'Git reset --quiet', 'Nvim-Tree: Git reset')
    bufmap('n', 'gb', withSelected 'tabnew | Git blame', 'Nvim-Tree: Git blame')
    bufmap('n', 'gd', withSelected 'tabnew | Gdiffsplit', 'Nvim-Tree: Git diff')

    bufmap(
      'n',
      'bd',
      withSelected(function(node)
        local bufnr = vim.fn.bufnr(node.absolute_path)
        local wins = require('user.apiutil').buf_get_wins(bufnr)
        if #wins > 0 then
          local ok = vim.fn.confirm('Delete buffer ' .. node.name .. '?', '&Yes\n&No', 2) == 1
          if not ok then
            return
          end
        end
        require('bufdelete').bufdelete(bufnr)
      end),
      'Nvim-Tree: Bdelete'
    )

    bufmap('n', 'i', nvim_tree_open_oil(false), 'Nvim-Tree: Open Oil')
    bufmap('n', '<M-i>', nvim_tree_open_oil(true), 'Nvim-Tree: Open Oil (enter dir)')
  end)
end

local setup_tree = function(use_neotree)
  if use_neotree ~= nil then
    vim.g.UseNeotree = use_neotree
  end
  if vim.g.UseNeotree then
    setup_neotree()
  else
    setup_nvimtree()
  end
end

local toggle_tree = function()
  local tree_foc = false
  local open_nvimtree = false
  local open_neotree = false
  if vim.g.UseNeotree then
    if user_neotree.is_visible() then
      open_nvimtree = true
      if vim.bo.filetype == 'neo-tree' then
        tree_foc = true
      end
      vim.cmd 'Neotree close'
    end
  else
    if package.loaded['nvim-tree'] and require('nvim-tree.view').is_visible() then
      open_neotree = true
      if vim.bo.filetype == 'NvimTree' then
        tree_foc = true
      end
      require('nvim-tree.view').close()
    end
  end

  vim.g.UseNeotree = not vim.g.UseNeotree
  vim.notify('Using ' .. (vim.g.UseNeotree and 'NeoTree' or 'NvimTree'))
  setup_tree()

  if open_nvimtree then
    require('nvim-tree.lib').open()
    if not tree_foc then
      recent_wins.focus_most_recent()
    end
  elseif open_neotree then
    if tree_foc then
      vim.cmd [[Neotree focus]]
    else
      vim.cmd [[Neotree show]]
    end
  end
end

map('n', xk '<C-S-t>', toggle_tree, 'Toggle selected file tree plugin')

setup_tree(false)

-- stevearc/aerial.nvim
local aerial = fn.require_on_index 'aerial'
local aerial_util = fn.require_on_index 'aerial.util'

local function aerial_get_win()
  local active_bufnr = aerial_util.get_aerial_buffer()
  if active_bufnr ~= -1 then
    local active_winid = aerial_util.buf_first_win_in_tabpage(active_bufnr)
    if active_winid then
      return active_winid
    end
  end
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local winbuf = vim.api.nvim_win_get_buf(winid)
    if aerial_util.is_aerial_buffer(winbuf) then
      return winid
    end
  end
end

local function aerial_open(focus)
  if not package.loaded.aerial then
    require 'aerial'
    require('aerial').close() -- force aerial setup
  end
  local winid = aerial_get_win()
  if winid then
    vim.api.nvim_set_current_win(winid)
    return
  end
  if not pcall(require('aerial.backends').get) then
    require('aerial').open()
    if not focus then
      recent_wins.focus_most_recent()
    end
    return
  end

  -- Get width of nvim-tree or neo-tree before opening aerial (sometimes
  -- opening aerial causes file tree windows to get smooshed)
  local nvt_win = package.loaded['nvim-tree'] and require('nvim-tree.view').get_winnr(0)
  local nvt_width
  if nvt_win and vim.api.nvim_win_is_valid(nvt_win) then
    nvt_width = vim.api.nvim_win_get_width(nvt_win)
  end
  local neo_vis, neo_win, neo_width
  if package.loaded['neo-tree'] then
    neo_vis, neo_win = user_neotree.is_visible()
    if neo_vis then
      neo_width = vim.api.nvim_win_get_width(neo_win)
    end
  end

  require('aerial').refetch_symbols()
  require('aerial').open { focus = focus or false }

  -- Reset tree window width in case smooshing occurred
  if nvt_width then
    vim.api.nvim_win_set_width(nvt_win, nvt_width)
  end
  if neo_width then
    vim.api.nvim_win_set_width(neo_win, neo_width)
  end
  auto_resize.trigger()
end

map('n', xk '<M-S-\\>', function()
  if package.loaded.aerial and aerial_get_win() then
    local foc = require('aerial.util').is_aerial_buffer()
    aerial.close()
    if foc then
      recent_wins.focus_most_recent()
    end
  else
    aerial_open()
  end
end, 'Aerial: Toggle')

map(
  'n',
  '<M-\\>',
  fn.filetype_command('aerial', recent_wins.focus_most_recent, wrap(aerial_open, true)),
  'Aerial: Toggle Focus'
)

map(
  'n',
  xk '<C-M-S-\\>',
  fn.filetype_command('aerial', function()
    vim.cmd.AerialClose()
  end, function()
    require('aerial').refetch_symbols()
    vim.cmd.AerialOpen 'float'
  end),
  'Aerial: Open Float'
)

ft('aerial', function(bufmap)
  local function aerial_select(opts)
    local winid = recent_wins.get_most_recent_smart()
    if not vim.api.nvim_win_is_valid(winid or -1) then
      winid = nil
    end
    require('aerial.navigation').select(vim.tbl_extend('force', {
      winid = winid,
    }, opts or {}))
  end

  local function aerial_view(cmd)
    vim.schedule(wrap(aerial_select, { jump = false }))
    return cmd or '\\<Nop>'
  end

  bufmap('n', '<Cr>', aerial_select, 'Aerial: Select item')
  bufmap('n', '<Tab>', aerial_view, 'Aerial: Bring item into view')
  bufmap('n', 'J', wrap(aerial_view, 'j'), 'Aerial: Bring next item into view')
  bufmap('n', 'K', wrap(aerial_view, 'k'), 'Aerial: Bring previous item into view')
end)

---- mfussenegger/nvim-dap
local dap = fn.require_on_call_rec 'dap'
local dap_widgets = fn.require_on_call_rec 'dap.ui.widgets'

map('n', '<leader>D', function()
  if dap.session() then
    require('user.dap').close(vim.bo.filetype)
  else
    require('user.dap').launch(vim.bo.filetype)
  end
end, 'DAP: Toggle session')

map(
  'n',
  '<M-d>',
  fn.filetype_command('dap-repl', recent_wins.focus_most_recent, function()
    dap.repl.open()
    vim.api.nvim_set_current_win(vim.fn.win_findbuf(vim.fn.bufnr 'dap-repl')[1] or 0)
  end),
  'DAP: Repl: Toggle Focus'
)

map('n', '<M-S-d>', dap.repl.toggle, 'DAP: Repl: Toggle')

map('n', '<leader>dc', dap.continue, 'DAP: Continue')
map('n', '<leader>dr', dap.restart, 'DAP: Restart')
map('n', '<leader>dt', dap.terminate, 'DAP: Terminate')

map('n', '<leader>db', dap.toggle_breakpoint, 'DAP: Toggle breakpoint')
map('n', '<leader>de', wrap(dap.set_exception_breakpoints, { 'all' }), 'DAP: Break on exception')
map('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, 'DAP: Set breakpoint condition')

map('n', '<leader>di', dap_widgets.hover, 'DAP: Hover variables')

map('n', '<leader>dK', dap.up, 'DAP: Up')
map('n', '<leader>dJ', dap.down, 'DAP: Down')

map('n', '<leader>di', dap_widgets.hover, 'DAP: Hover')
map('n', '<leader>d?', wrap(dap_widgets.centered_float, dap_widgets.scopes), 'DAP: Scopes')

map('n', '<leader>dk>', dap.step_out, 'DAP: Step out')
map('n', '<leader>dl>', dap.step_into, 'DAP: Step into')
map('n', '<leader>dj>', dap.step_over, 'DAP: Step over')
map('n', '<leader>dh>', dap.continue, 'DAP: Continue')

---- sindrets/winshift.nvim
map('n', '<Leader>M', '<Cmd>WinShift<Cr>', 'WinShift: Start')
map('n', '<Leader>mm', '<Cmd>WinShift<Cr>', 'WinShift: Start')
map('n', '<Leader>ws', '<Cmd>WinShift swap<Cr>', 'WinShift: Swap')

---- mrjones2014/smart-splits.nvim
local smart_splits = fn.require_on_call_rec 'smart-splits'
map('n', '<M-[>', smart_splits.resize_left, 'Resize-Win: Left')
map('n', '<M-]>', smart_splits.resize_right, 'Resize-Win: Right')
map('n', '<M-{>', smart_splits.resize_up, 'Resize-Win: Up')
map('n', '<M-}>', smart_splits.resize_down, 'Resize-Win: Down')

map('n', '<M-h>', smart_splits.move_cursor_left, 'Goto window/pane left')
map('n', '<M-j>', smart_splits.move_cursor_down, 'Goto window/pane down')
map('n', '<M-k>', smart_splits.move_cursor_up, 'Goto window/pane up')
map('n', '<M-l>', smart_splits.move_cursor_right, 'Goto window/pane right')

---- monaqa/dial.nvim
local function dial(dir, mode)
  return function()
    require('dial.map').manipulate(dir, mode)
    if mode == 'visual' or mode == 'gvisual' then
      vim.cmd 'normal! gv'
    end
  end
end
map('n', '<C-a>', dial('increment', 'normal'), 'Dial: Increment')
map('n', '<C-x>', dial('decrement', 'normal'), 'Dial: Decrement')
map('n', 'g<C-a>', dial('increment', 'gnormal'), 'Dial: Increment')
map('n', 'g<C-x>', dial('decrement', 'gnormal'), 'Dial: Decrement')
map('v', '<C-a>', dial('increment', 'visual'), 'Dial: Increment')
map('v', '<C-x>', dial('decrement', 'visual'), 'Dial: Decrement')
map('v', 'g<C-a>', dial('increment', 'gvisual'), 'Dial: Increment')
map('v', 'g<C-x>', dial('decrement', 'gvisual'), 'Dial: Decrement')

---- Wansmer/sibling-swap.nvim
local sibling_swap = fn.require_on_call_rec 'sibling-swap'
map('n', xk '<C-.>', sibling_swap.swap_with_right, 'Sibling-Swap: Swap with right')
map('n', '<F34>', sibling_swap.swap_with_left, 'Sibling-Swap: Swap with left')

---- rgroli/other.nvim
map('n', { '<leader>O', '<leader>oo' }, '<Cmd>Other<Cr>', 'Other: Switch to other file')
map('n', '<leader>os', '<Cmd>OtherSplit<Cr>', 'Other: Open other in split')
map('n', '<leader>ov', '<Cmd>OtherVSplit<Cr>', 'Other: Open other in vsplit')

---- akinsho/nvim-toggleterm.lua
local function toggleterm_open(direction)
  return function()
    local cmd = 'ToggleTerm'
    if direction then
      cmd = cmd .. ' direction=' .. direction
    end
    require('user.util.recent-wins').update()
    vim.cmd(cmd)
  end
end

local toggleterm_smart_toggle = function()
  local terms = require('toggleterm.terminal').get_all()
  if #terms > 0 then
    local term = terms[1]
    local cur_win = vim.api.nvim_get_current_win()
    if term.window == cur_win then
      recent_wins.focus_most_recent()
      return
    end
    local cur_tab = vim.api.nvim_get_current_tabpage()
    if vim.api.nvim_win_is_valid(term.window) then
      if vim.api.nvim_win_get_tabpage(term.window) == cur_tab then
        vim.api.nvim_set_current_win(term.window)
        return
      end
      vim.api.nvim_win_close(term.window, true)
    end
  end
  toggleterm_open()()
end

map('n', xk '<C-M-S-/>', toggleterm_open 'float', 'ToggleTerm: Toggle (float)')
map('t', xk '<C-M-S-/>', [[<C-\><C-n>:ToggleTerm direction=float<Cr>]], 'ToggleTerm: Toggle (float)')
map('n', xk '<M-S-/>', toggleterm_open 'vertical', 'ToggleTerm: Toggle (vertical)')
map('t', xk '<M-S-/>', [[<C-\><C-n>:ToggleTerm direction=vertical<Cr>]], 'ToggleTerm: Toggle (vertical)')
map('n', xk '<C-M-/>', toggleterm_open 'horizontal', 'ToggleTerm: Toggle (horizontal)')
map('t', xk '<C-M-/>', [[<C-\><C-n>:ToggleTerm direction=horizontal<Cr>]], 'ToggleTerm: Toggle (horizontal)')
map('n', xk '<C-/>', toggleterm_smart_toggle, 'ToggleTerm: Smart Toggle')
map('t', xk '<C-/>', toggleterm_smart_toggle, 'ToggleTerm: Smart Toggle')

---- nvim-neotest/neotest
local neotest = fn.require_on_call_rec 'neotest'
local neotest_summary = fn.require_on_call_rec 'neotest.consumers.summary'
map('n', '<leader>nn', neotest.run.run, 'Neotest: Run Nearest Test')
map('n', { '<leader>N', '<leader>nf' }, function()
  neotest.run.run(vim.fn.expand '%')
end, 'Neotest: Run File')

map('n', '[n', wrap(neotest.jump.prev, { status = 'failed' }), 'Neotest: Jump Prev Failed')
map('n', ']n', wrap(neotest.jump.next, { status = 'failed' }), 'Neotest: Jump Next Failed')

map('n', '<M-n>', function()
  neotest_summary.open()
  if vim.bo.filetype == 'neotest-summary' then
    vim.cmd 'wincmd p'
  else
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'neotest-summary' then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end
end, 'Neotest: Open or Focus Summary')

map('n', '<M-S-n>', neotest.summary.toggle, 'Neotest: Toggle Summary')

---- stevearc/conform.nvim
local conform = fn.require_on_call_rec 'conform'
local user_conform = fn.require_on_call_rec 'user.plugin.conform'
map('nx', '<localleader>F', wrap(conform.format, { lsp_fallback = true }), 'LSP: Format')

map('n', { '<localleader>S', '<localleader>ss' }, user_conform.toggle_format_on_save, 'Conform: Toggle format on save')
map('n', '<localleader>se', wrap(user_conform.set_format_on_save, true), 'Conform: Enable format on save')
map('n', '<localleader>sd', wrap(user_conform.set_format_on_save, false), 'Conform: Disable format on save')

---- folke/lazy.nvim
map('n', '<leader>ll', '<Cmd>Lazy<cr>', 'Lazy')

---- folke/noice.nvim
map('n', '<leader>L', '<Cmd>NoiceHistory<cr>', 'Noice: History log')

---- s1n7ax/nvim-window-picker
map('n', '<M-w>', function()
  local win = require('window-picker').pick_window()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  end
end, 'Window Picker: Pick')

---- folke/todo-comments.nvim
local todo_comments = fn.require_on_call_rec 'todo-comments'
map('n', '[t', todo_comments.jump_prev, 'Todo Comments: Previous')
map('n', ']t', todo_comments.jump_next, 'Todo Comments: Next')

---- stevearc/overseer.nvim
local overseer = fn.require_on_call_rec 'overseer'
map('n', '<M-S-o>', wrap(overseer.toggle, { enter = false }), 'Overseer: Toggle')

map(
  'n',
  '<M-o>',
  fn.filetype_command('OverseerList', recent_wins.focus_most_recent, overseer.open),
  'Overseer: Toggle Focus'
)

map('n', '<leader>or', '<cmd>OverseerRun<Cr>', 'Overseer: Run')

---- epwalsh/obsidian.nvim
M.obsidian_on_attach = function()
  map('n', { '<C-f><C-f>', '<C-f>o', '<C-f><C-o>' }, '<Cmd>ObsidianQuickSwitch<Cr>', 'Obsidian: Quick Switch')

  map('n', '<C-p>', function()
    vim.api.nvim_feedkeys(':Obsidian', 't', false)
    vim.defer_fn(require('cmp').complete, 0)
  end, ':Obsidian')

  ft('markdown', function(bufmap)
    bufmap('n', '<C-]>', function()
      if require('obsidian').util.cursor_on_markdown_link() then
        return '<Cmd>ObsidianFollowLink<CR>'
      else
        return '<C-]>'
      end
    end, { expr = true, desc = 'Obsidian: Follow Link' })
  end)
end

---- akinsho/git-conflict.nvim
map('n', '<leader>cc', function()
  local actions = {
    GitConflictCurrent = 'ours',
    GitConflictCurrentLabel = 'ours',
    GitConflictAncestor = 'base',
    GitConflictAncestorLabel = 'base',
    GitConflictIncoming = 'theirs',
    GitConflictIncomingLabel = 'theirs',
  }
  local choose = function(which)
    vim.notify('Choosing ' .. which, vim.log.levels.INFO)
    require('git-conflict').choose(which)
  end
  local line = vim.api.nvim_get_current_line()
  if line == '=======' then
    choose 'both'
    return
  end
  local mark = vim.iter(vim.inspect_pos().extmarks):find(function(e)
    return e.ns == 'git-conflict' and actions[e.opts.hl_group]
  end)
  if not mark then
    vim.notify('No conflict under cursor', vim.log.levels.WARN)
    return
  end
  choose(actions[mark.opts.hl_group])
end, 'Git Conflict: Choose hunk under cursor')

return M
