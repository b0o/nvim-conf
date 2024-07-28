local api = vim.api
local M = {}

local config = {
  default_lens = 'add comments to explain the code',
  window_position = 'below', -- or "above"
  default_register = '+',
  height = 10,
  diff_mode = true,
}

local groq_client

local lens_win, lens_buf, lens_content
local win_prev_winline = {}

local function get_window_row_normal_mode(params)
  local win = params.win
  local win_info = params.win_info
  local height = params.height
  local offset = params.offset
  local borders = params.borders
  local winline = params.winline

  local row
  local maybe_below = winline + offset
  local maybe_above = winline - height - borders - 1 - offset
  if
    (win_prev_winline[win] and win_prev_winline[win] < winline and maybe_above + borders >= 0)
    or maybe_below + height + borders >= win_info.height
  then
    row = maybe_above
  else
    row = maybe_below
  end

  win_prev_winline[win] = winline

  return row
end

local function get_window_row_visual_mode(params)
  local height = params.height
  local offset = params.offset
  local borders = params.borders

  local top_line = vim.fn.line 'w0'

  local cursor_line = vim.fn.line '.'
  local other_end_line = vim.fn.line 'v'

  local other_end_direction = other_end_line < cursor_line and 'above' or 'below'
  local target_line = other_end_line - top_line

  local row
  if other_end_direction == 'above' then
    row = target_line - height - offset - borders
    if row < 0 then
      row = 0
    end
  else
    row = target_line + offset + 1
  end

  return row
end

local function get_window_position()
  local win = api.nvim_get_current_win()
  local win_info = vim.fn.getwininfo(win)[1]
  local win_width = win_info.width

  local height = config.height
  local offset = 1
  local borders = 2

  local leftmost = win_info.wincol <= 1
  local rightmost = win_info.wincol + win_width >= vim.o.columns - 1

  local mode = api.nvim_get_mode().mode
  local row

  if mode:match '^[vV\22]' then
    row = get_window_row_visual_mode {
      win = win,
      win_info = win_info,
      height = height,
      offset = offset,
      borders = borders,
    }
  else
    row = get_window_row_normal_mode {
      win = win,
      win_info = win_info,
      height = height,
      offset = offset,
      borders = borders,
      winline = vim.fn.winline(),
    }
  end

  local opts = {
    relative = 'win',
    width = win_width,
    height = height,
    row = row,
    col = -1,
    style = 'minimal',
    border = {
      not leftmost and '├' or '',
      '─',
      not rightmost and '┤' or '',
      not rightmost and '│' or '',
      not rightmost and '┤' or '',
      '─',
      not leftmost and '├' or '',
      not leftmost and '│' or '',
    },
  }

  return opts
end

local function get_visual_range()
  local cursor_line = vim.fn.line '.'
  local other_end_line = vim.fn.line 'v'
  local start_line = math.min(cursor_line, other_end_line)
  local end_line = math.max(cursor_line, other_end_line)
  return start_line, end_line
end

local function strip_markdown_fence(text)
  local start_fence, language = text:match '^(%s*```(%w*)%s*\n)'
  local end_fence = text:match '\n%s*```%s*$'
  if start_fence and end_fence then
    local content = text:sub(#start_fence + 1, -#end_fence - 1)
    if not content:find '```' then
      return content, language
    end
  end
  return text, nil
end

local function get_current_text()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match '^[vV\22]' then
    local cursor_line = vim.fn.line '.'
    local other_end_line = vim.fn.line 'v'
    local start_line = math.min(cursor_line, other_end_line)
    local end_line = math.max(cursor_line, other_end_line)
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    return lines
  elseif mode:match '^[iI]' then
    return nil
  else
    return { vim.api.nvim_get_current_line() }
  end
end

local function get_diff_patch(old_lines, new_lines)
  local temp_file_old = vim.fn.tempname()
  local temp_file_new = vim.fn.tempname()
  vim.fn.writefile(old_lines, temp_file_old)
  vim.fn.writefile(new_lines, temp_file_new)
  local diff = vim.fn.systemlist('diff -u ' .. temp_file_old .. ' ' .. temp_file_new)
  vim.fn.delete(temp_file_old)
  vim.fn.delete(temp_file_new)
  return vim.iter(diff):skip(3):totable()
end

local function create_or_update_lens_window(content)
  if lens_win and api.nvim_win_is_valid(lens_win) then
    api.nvim_win_set_config(lens_win, get_window_position())
  else
    lens_buf = api.nvim_create_buf(false, true)
    lens_win = api.nvim_open_win(lens_buf, false, get_window_position())
    vim.wo[lens_win].wrap = true
    vim.wo[lens_win].conceallevel = 2
    vim.wo[lens_win].foldenable = false
    vim.bo[lens_buf].filetype = config.diff_mode and 'diff' or vim.bo[0].filetype
  end

  if content ~= nil then
    local lines = type(content) == 'string' and vim.split(content, '\n') or content
    lens_content = lines
    if config.diff_mode then
      api.nvim_buf_set_lines(lens_buf, 0, -1, false, get_diff_patch(get_current_text(), lines))
    else
      api.nvim_buf_set_lines(lens_buf, 0, -1, false, lines)
    end
  end
end

local function update_lens()
  local text = table.concat(get_current_text(), '\n')
  local prompt = config.default_lens

  local metadata = {
    filetype = vim.bo.filetype,
    bufname = vim.api.nvim_buf_get_name(0),
    position = vim.api.nvim_win_get_cursor(0),
  }

  groq_client.chat.completions.create {
    -- model = 'llama-3.1-8b-instant',
    model = 'llama-3.1-70b-versatile',
    -- model = 'llama-3.1-405b-reasoning',
    messages = {
      {
        role = 'system',
        content = string.format(
          'You are an assistant that provides insights about code. Your response should be a code snippet, nothing else. IMPORTANT: Do not include markdown a code fence. Include the entire modified code snippet in your response.\n\nMetadata: %s',
          vim.json.encode(metadata)
        ),
      },
      { role = 'user', content = string.format('Instructions: %s\n\nCode:\n\n%s', prompt, text) },
    },
    on_success = function(response)
      local content = response.choices[1].message.content
      if content then
        content = strip_markdown_fence(content)
        create_or_update_lens_window(content)
      end
    end,
    on_error = function(err)
      vim.notify('Error updating lens: ' .. err, vim.log.levels.ERROR)
    end,
  }
end

function M.close_lens()
  if lens_win and api.nvim_win_is_valid(lens_win) then
    api.nvim_win_close(lens_win, true)
  end
  lens_win = nil
end

function M.toggle_lens()
  if lens_win and api.nvim_win_is_valid(lens_win) then
    M.close_lens()
  else
    local new_lens = vim.fn.input('llens: ', config.default_lens)
    if new_lens == '' then
      return
    end
    config.default_lens = new_lens
    update_lens()
  end
end

function M.apply_lens()
  if not lens_buf then
    return
  end
  M.close_lens()

  local content = vim.deepcopy(lens_content)
  table.insert(content, '')

  local mode = api.nvim_get_mode().mode

  if mode:match '^[vV\22]' then
    local range_start, range_end = get_visual_range()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    api.nvim_buf_set_lines(0, range_start - 1, range_end, false, content)
    vim.schedule(function()
      vim.api.nvim_buf_set_mark(0, '<', range_start, 0, {})
      vim.api.nvim_buf_set_mark(0, '>', range_start + #content - 2, 0, {})
      vim.cmd [[normal! gv]]
    end)
  else
    local line = api.nvim_win_get_cursor(0)[1] - 1
    api.nvim_buf_set_lines(0, line, line + 1, false, content)
  end
end

function M.copy_lens_to_register(register)
  if not lens_buf then
    return
  end
  vim.fn.setreg(register, lens_content)
  vim.notify(string.format('Lens content copied to register %s', register), vim.log.levels.INFO)
end

function M.increase_height()
  config.height = config.height + 1
  create_or_update_lens_window()
end

function M.decrease_height()
  config.height = config.height - 1
  create_or_update_lens_window()
end

function M.scroll_down()
  if not lens_win or not api.nvim_win_is_valid(lens_win) then
    return
  end
  local lens_cursor = api.nvim_win_get_cursor(lens_win)
  local new_cursor = { lens_cursor[1] + 1, lens_cursor[2] }
  if new_cursor[1] > vim.api.nvim_buf_line_count(lens_buf) then
    new_cursor[1] = vim.api.nvim_buf_line_count(lens_buf)
  end
  vim.api.nvim_win_set_cursor(lens_win, new_cursor)
end

function M.scroll_up()
  if not lens_win or not api.nvim_win_is_valid(lens_win) then
    return
  end
  local lens_cursor = api.nvim_win_get_cursor(lens_win)
  local new_cursor = { lens_cursor[1] - 1, lens_cursor[2] }
  if new_cursor[1] < 1 then
    new_cursor[1] = 1
  end
  vim.api.nvim_win_set_cursor(lens_win, new_cursor)
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
  groq_client = require('user.ai.groq').client { api_key = config.groq_api_key }

  vim.keymap.set({ 'n', 'x' }, '<leader>lt', M.toggle_lens, { desc = 'Toggle lens' })
  vim.keymap.set({ 'n', 'x' }, '<leader>la', M.apply_lens, { desc = 'Apply lens' })
  vim.keymap.set({ 'n', 'x' }, '<leader>lc', function()
    M.copy_lens_to_register(config.default_register)
  end, { desc = 'Copy lens to default register' })
  vim.keymap.set({ 'n', 'x' }, '<M-=>', M.increase_height, { desc = 'Increase lens height' })
  vim.keymap.set({ 'n', 'x' }, '<M-->', M.decrease_height, { desc = 'Decrease lens height' })
  vim.keymap.set({ 'n', 'x' }, '<C-M-down>', M.scroll_down, { desc = 'Scroll lens down' })
  vim.keymap.set({ 'n', 'x' }, '<C-M-up>', M.scroll_up, { desc = 'Scroll lens up' })
end

return M
