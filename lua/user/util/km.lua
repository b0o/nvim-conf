-- via https://github.com/mikejmcguirk/Neovim-Win10-Lazy/blob/main/lua/mjm/keymap_mod.lua
local M = {}

M.opts = { silent = true }
M.expr_opts = vim.tbl_extend('force', { expr = true }, M.opts)

---@return boolean
M.check_modifiable = function()
  if vim.api.nvim_buf_get_option(0, 'modifiable') then
    return true
  end

  vim.api.nvim_err_writeln "E21: Cannot make changes, 'modifiable' is off"

  return false
end

---@param map string
---@return nil
M.rest_cursor = function(map, options)
  local opts = vim.deepcopy(options or {})

  if opts.mod_check and not M.check_modifiable then
    return
  end

  local cur_view = nil

  if opts.rest_view then
    cur_view = vim.fn.winsaveview()
  end

  local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))

  local status, result = pcall(function()
    vim.cmd('normal! ' .. map)
  end)

  if (not status) and result then
    vim.api.nvim_err_writeln(result)

    return
  end

  vim.api.nvim_win_set_cursor(0, { cur_row, cur_col })

  if cur_view ~= nil then
    vim.fn.winrestview(cur_view)
  end
end

---@param map string
---@return string
M.enter_insert_fix = function(map)
  if string.match(vim.api.nvim_get_current_line(), '^%s*$') then
    return '"_S'
  else
    return map
  end
end

---@return boolean
local find_pairs = function()
  local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))

  if cur_col == 0 then
    return false
  end

  local pairs = {
    { '{', '}' },
    { '[', ']' },
    { '(', ')' },
    { '<', '>' },
    { "'", "'" },
    { '"', '"' },
    { '`', '`' },
  }

  local cur_line = vim.api.nvim_get_current_line()
  -- nvim_win_get_cursor is 0 indexed for columns. Lua is 1 indexed
  local cur_char = cur_line:sub(cur_col, cur_col)

  -- Check if we are in a pair
  local check_pairs = function(char, to_find, to_return)
    for _, pair in ipairs(pairs) do
      if pair[to_find] == char then
        return pair[to_return]
      end
    end

    return nil
  end

  local close_char = check_pairs(cur_char, 1, 2)
  local next_char = cur_line:sub(cur_col + 1, cur_col + 1)

  if close_char == next_char then
    -- buf_set_text is 0 indexed, nvim_win_set_cursor is 1 indexed for rows
    local line_to_set = cur_row - 1
    local start_col = cur_col - 1
    local end_col = cur_col + 1 -- buf_set_text is end-exclusive
    vim.api.nvim_buf_set_text(0, line_to_set, start_col, line_to_set, end_col, { '' })

    vim.api.nvim_win_set_cursor(0, { cur_row, cur_col - 1 })

    return true
  end

  if cur_col == 1 then
    return false
  end

  -- Check if we are directly to the right of a pair
  local open_char = check_pairs(cur_char, 2, 1)

  if open_char == nil then
    return false
  end

  local prev_char = cur_line:sub(cur_col - 1, cur_col - 1)

  if open_char == prev_char then
    local line_to_set = cur_row - 1
    local start_col = cur_col - 2
    local end_col = cur_col
    vim.api.nvim_buf_set_text(0, line_to_set, start_col, line_to_set, end_col, { '' })

    vim.api.nvim_win_set_cursor(0, { cur_row, cur_col - 2 })

    return true
  end

  return false
end

local get_indent = function(line_num)
  -- If Treesitter indent is enabled, the indentexpr will be set to
  -- nvim_treesitter#indent(), so that will be captured here
  local indentexpr = vim.bo.indentexpr

  if indentexpr ~= '' then
    -- Most indent expressions in the Nvim runtime do not take an argument
    --
    -- However, a few of them do take v:lnum as an argument
    -- v:lnum is not updated when nvim_exec2 is called, so it must be updated here
    --
    -- A couple of the runtime expressions take '.' as an argument
    -- This is already updated before nvim_exec2 is called
    --
    -- Other indentexpr options are not guaranteed to be handled properly
    vim.v.lnum = line_num
    local expr_indent_tbl = vim.api.nvim_exec2('echo ' .. indentexpr, { output = true })
    local expr_indent_str = expr_indent_tbl.output
    local expr_indent = tonumber(expr_indent_str)

    return expr_indent
  end

  -- return 0

  local prev_nonblank = vim.fn.prevnonblank(line_num - 1)
  local prev_nonblank_indent = vim.fn.indent(prev_nonblank)

  return prev_nonblank_indent
end

---@return nil
local backspace_blank_line = function()
  -- row is one-indexed, col is 0-indexed
  local start_row, start_col = unpack(vim.api.nvim_win_get_cursor(0))
  local start_indent = get_indent(start_row)

  if start_indent > 0 and start_col > start_indent then
    -- rows in nvim_buf_set_lines are zero indexed
    vim.api.nvim_buf_set_lines(
      0,
      start_row - 1,
      start_row, -- end-exclusive
      false,
      { string.rep(' ', start_indent) }
    )

    return
  end

  vim.api.nvim_del_current_line()
  local cur_row = vim.api.nvim_win_get_cursor(0)[1]

  -- nvim_del_current_line() behaves similarly to the dd motion
  -- It will delete the current line then shift all the text below up a line
  -- This means the cursor will still be on the same line as the deleted text
  -- Therefore, the cursor must be moved to the line above
  ---@return number
  local set_destination_row = function()
    -- Edge cases
    local on_first_row = cur_row == 1
    local already_moved = cur_row ~= start_row -- If you delete the last line

    if on_first_row or already_moved then
      return cur_row
    end

    local dest_row = cur_row - 1
    vim.api.nvim_win_set_cursor(0, { dest_row, 0 })

    return dest_row
  end

  local dest_row = set_destination_row()
  local dest_line = vim.api.nvim_get_current_line()
  local dest_col = #dest_line
  local dest_line_is_empty = string.match(dest_line, '^%s*$')
  local set_row = dest_row - 1 -- nvim_buf_set_text and set_lines are 0 indexed

  if dest_col > 0 and not dest_line_is_empty then
    vim.api.nvim_win_set_cursor(0, { dest_row, dest_col })

    -- check if the line has trailing whitespace
    local trailing_whitespace = string.match(dest_line, '%s+$')

    if trailing_whitespace then
      local dest_line_no_trailing_ws = string.gsub(dest_line, '%s+$', '')
      -- buf_set_lines is end-exclusive, so dest_row is still used as range end
      vim.api.nvim_buf_set_lines(0, set_row, dest_row, false, { dest_line_no_trailing_ws })
      return
    end

    return
  end

  local dest_line_num = vim.fn.line '.'
  local indent = get_indent(dest_line_num)

  if indent == 0 then
    return
  end

  vim.api.nvim_buf_set_lines(0, set_row, dest_row, false, { string.rep(' ', indent) })
  vim.api.nvim_win_set_cursor(0, { dest_row, indent })
end

---@return nil
M.insert_backspace_fix = function()
  local empty_string = string.match(vim.api.nvim_get_current_line(), '^%s*$')

  if not empty_string then
    -- windp/autopairs creates its own backspace mapping if map_bs is enabled
    -- Since map_bs must be disabled there, check for pairs here
    if find_pairs() then
      return
    end

    local key = vim.api.nvim_replace_termcodes('<backspace>', true, false, true)
    vim.api.nvim_feedkeys(key, 'n', true)

    return
  end

  backspace_blank_line()
end

---@param visual string
---@param linewise string
---@return string
M.vertical_motion_fix = function(visual, linewise)
  if vim.v.count == 0 then
    return visual
  else
    return linewise
  end
end

---@return string
M.dd_fix = function()
  if vim.v.count1 <= 1 and vim.api.nvim_get_current_line() == '' then
    return '"_dd'
  else
    return 'dd'
  end
end

---@param backward_objects string[]
---@return nil
M.fix_backward_yanks = function(backward_objects)
  local backward_objects = vim.deepcopy(backward_objects)

  for _, object in ipairs(backward_objects) do
    local main_map = 'y' .. object

    vim.keymap.set('n', main_map, function()
      local main_cmd = vim.v.count1 .. main_map
      M.rest_cursor(main_cmd)
    end, M.default_opts)

    local ext_map = '<leader>y' .. object

    vim.keymap.set('n', ext_map, function()
      local ext_cmd = vim.v.count1 .. '"+' .. main_map
      M.rest_cursor(ext_cmd)
    end, M.default_opts)
  end
end

---@param motions string[]
---@param text_objects string[]
---@param inner_outer string[]
---@return nil
M.demap_text_objects_inout = function(motions, text_objects, inner_outer)
  local motions = vim.deepcopy(motions)
  local text_objects = vim.deepcopy(text_objects)
  local inner_outer = vim.deepcopy(inner_outer)

  for _, motion in pairs(motions) do
    for _, object in pairs(text_objects) do
      for _, in_out in pairs(inner_outer) do
        local normal_map = motion .. in_out .. object
        vim.keymap.set('n', normal_map, '<nop>', M.default_opts)

        local ext_map = '<leader>' .. motion .. in_out .. object
        vim.keymap.set('n', ext_map, '<nop>', M.default_opts)
      end
    end
  end
end

---@param motions string[]
---@param text_objects string[]
---@return nil
M.demap_text_objects = function(motions, text_objects)
  local motions = vim.deepcopy(motions)
  local text_objects = vim.deepcopy(text_objects)

  for _, motion in pairs(motions) do
    for _, object in pairs(text_objects) do
      vim.keymap.set('n', motion .. object, '<nop>', M.default_opts)
      vim.keymap.set('n', '<leader>' .. motion .. object, '<nop>', M.default_opts)
    end
  end
end

---@param text_objects string[]
---@param inner_outer string[]
---@return nil
M.yank_cursor_fixes = function(text_objects, inner_outer)
  local text_objects = vim.deepcopy(text_objects)
  local inner_outer = vim.deepcopy(inner_outer)

  for _, object in pairs(text_objects) do
    for _, in_out in pairs(inner_outer) do
      local main_cmd = 'y' .. in_out .. object

      vim.keymap.set('n', main_cmd, function()
        M.rest_cursor(main_cmd)
      end, M.default_opts)

      local ext_map = '<leader>y' .. in_out .. object
      local ext_cmd = '"+' .. main_cmd

      vim.keymap.set('n', ext_map, function()
        M.rest_cursor(ext_cmd)
      end, M.default_opts)
    end
  end
end

---@param paste_char string
---@return string
M.visual_paste = function(paste_char)
  if not M.check_modifiable() then
    return '<Nop>'
  end

  local cur_mode = vim.api.nvim_get_mode().mode
  local count = vim.v.count1

  if cur_mode == 'V' or cur_mode == 'Vs' then
    return count .. paste_char .. '=`]'
  else
    return 'mz' .. count .. paste_char .. '`z'
  end
end

---@param put_cmd string
---@return nil
M.create_blank_line = function(put_cmd)
  if not M.check_modifiable() then
    return
  end

  local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
  -- Uses a mark so that the cursor sticks with the text the map is called from
  vim.api.nvim_buf_set_mark(0, 'z', cur_row, cur_col, {})

  vim.cmd(put_cmd .. ' =repeat(nr2char(10), v:count1)')
  vim.cmd 'normal! `z'
end

---@param vcount1 number
---@param pos_1 string
---@param pos_2 string
---@param fix_num number
---@param cmd_start string
---@return nil
M.visual_move = function(vcount1, pos_1, pos_2, fix_num, cmd_start)
  if not M.check_modifiable() then
    return
  end

  -- '< and '> are not updated until after leaving Visual Mode
  -- This also updates vim.v.count1, which is why it's passed as a parameter
  vim.cmd [[execute "normal! \<esc>"]]

  local min_count = 1

  local get_to_move = function()
    if vcount1 <= min_count then
      return min_count + fix_num
    else
      return vcount1 - (vim.fn.line(pos_1) - vim.fn.line(pos_2)) + fix_num
    end
  end

  local cmd = cmd_start .. get_to_move()
  vim.cmd(cmd)

  local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))

  vim.cmd 'normal! `]'
  local end_cursor_pos = vim.api.nvim_win_get_cursor(0)
  local end_row = end_cursor_pos[1]
  local end_line = vim.api.nvim_get_current_line()
  local end_col = #end_line
  vim.api.nvim_buf_set_mark(0, 'z', end_row, end_col, {})

  vim.cmd 'normal! `['
  local start_cursor_pos = vim.api.nvim_win_get_cursor(0)
  local start_row = start_cursor_pos[1]
  vim.api.nvim_win_set_cursor(0, { start_row, 0 })

  vim.cmd 'normal! =`z'
  vim.api.nvim_win_set_cursor(0, { cur_row, cur_col })
  vim.cmd 'normal! gv'
end

---@return nil
M.bump_up = function()
  if not M.check_modifiable() then
    return
  end

  local orig_line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local modified_line = orig_line:sub(1, cursor[2]):gsub('%s+$', '')
  vim.api.nvim_set_current_line(modified_line)

  local orig_line_len = #orig_line
  local to_move = orig_line:sub(cursor[2] + 1, orig_line_len):gsub('^%s+', ''):gsub('%s+$', '')
  vim.cmd "put! =''"
  local row = cursor[1] - 1
  vim.api.nvim_buf_set_text(0, row, 0, row, 0, { to_move })
  vim.cmd 'normal! =='
end

---@param chars string
---@return nil
M.put_at_beginning = function(chars)
  if not M.check_modifiable() then
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1] - 1

  local current_line = vim.api.nvim_get_current_line()
  local chars_len = #chars
  local start_chars = current_line:sub(1, chars_len)

  if start_chars ~= chars then
    vim.api.nvim_buf_set_text(0, row, 0, row, 0, { chars })
  else
    local new_line = current_line:sub((chars_len + 1), current_line:len())
    vim.api.nvim_set_current_line(new_line)
  end
end

---@param chars string
---@return nil
M.put_at_end = function(chars)
  if not M.check_modifiable() then
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1] - 1
  local current_line = vim.api.nvim_get_current_line()
  local cline_cleaned = current_line:gsub('%s+$', '')
  local col = #cline_cleaned

  local chars_len = #chars
  local end_chars = cline_cleaned:sub(-chars_len)

  if end_chars ~= chars then
    vim.api.nvim_buf_set_text(0, row, col, row, col, { chars })
  else
    local new_line = cline_cleaned:sub(1, cline_cleaned:len() - chars_len)
    vim.api.nvim_set_current_line(new_line)
  end
end

return M
