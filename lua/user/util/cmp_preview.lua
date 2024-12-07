---@class CompletionLine
---@field kind_icon string
---@field label string
---@field detail string
---@field kind string

---@class HighlightInfo
---@field group string
---@field start_col number
---@field end_col number

---@class FormattedResult
---@field text string
---@field highlights table<string, HighlightInfo>
---@field current_pos number

---@class PreviewState
---@field win number|nil
---@field buf number|nil
---@field keymaps { lhs: string, buffer: number }[]
---@field augroup string|nil

---@class ColumnWidths
---@field kind_icon number
---@field label number
---@field detail number
---@field kind number

---@class ColumnSpacing
---@field icon_left_padding number
---@field icon_right_padding number
---@field label_right_padding number
---@field kind_left_padding number

---@class CompletionModule
---@field trigger function
---@field enable_highlight boolean
local M = {
  enable_highlight = true,
}

---Get symbol from lspkind if available, fallback to dot if not
---@param kind string
---@return string
local function get_lspkind_symbol(kind)
  local status_ok, lspkind = pcall(require, 'lspkind')
  if status_ok then
    return lspkind.symbolic(kind) or '●'
  end
  return '●'
end

local function ensure_highlights()
  ---@type table<string, table>
  local highlights = {
    CmpNormal = { link = 'Normal' },
    CmpBorder = { link = 'FloatBorder' },
    CmpSel = { link = 'PmenuSel' },
    CmpItemAbbr = { link = 'Pmenu' },
    CmpItemKindDefault = { link = 'Special' },
  }

  for name, val in pairs(highlights) do
    if vim.fn.hlexists(name) == 0 then
      vim.api.nvim_set_hl(0, name, val)
    end
  end
end

ensure_highlights()

---@param kind number|nil
---@return string
local function get_kind_highlight_group(kind)
  if not kind then
    return 'CmpItemAbbr'
  end

  local kind_name = vim.lsp.protocol.CompletionItemKind[kind]
  if not kind_name then
    return 'CmpItemAbbr'
  end

  kind_name = kind_name:gsub('[^%w]', '')
  local specific_hl = 'CmpItemKind' .. kind_name
  if vim.fn.hlexists(specific_hl) == 1 then
    return specific_hl
  end

  return 'CmpItemAbbr'
end

---@type PreviewState
local preview_state = {
  win = nil,
  buf = nil,
  keymaps = {},
  augroup = nil,
}

---@param lines CompletionLine[]
---@param window_width number
---@return ColumnWidths, ColumnSpacing
local function calculate_column_widths(lines, window_width)
  local widths = {
    kind_icon = 0,
    label = 0,
    detail = 0,
    kind = 0,
  }

  for _, line in ipairs(lines) do
    widths.kind_icon = math.max(widths.kind_icon, vim.fn.strdisplaywidth(line.kind_icon))
    widths.label = math.max(widths.label, vim.fn.strdisplaywidth(line.label))
    widths.detail = math.max(widths.detail, vim.fn.strdisplaywidth(line.detail))
    widths.kind = math.max(widths.kind, vim.fn.strdisplaywidth(line.kind))
  end

  local ICON_LEFT_PADDING = 1
  local ICON_RIGHT_PADDING = 1
  local LABEL_MAX_WIDTH = 16
  local LABEL_RIGHT_PADDING = 1
  local KIND_LEFT_PADDING = 1

  widths.label = math.min(LABEL_MAX_WIDTH, widths.label)

  local fixed_width = ICON_LEFT_PADDING
    + widths.kind_icon
    + ICON_RIGHT_PADDING
    + widths.label
    + LABEL_RIGHT_PADDING
    + KIND_LEFT_PADDING
    + widths.kind

  local detail_available = window_width - fixed_width
  widths.detail = math.min(widths.detail, detail_available)

  return widths,
    {
      icon_left_padding = ICON_LEFT_PADDING,
      icon_right_padding = ICON_RIGHT_PADDING,
      label_right_padding = LABEL_RIGHT_PADDING,
      kind_left_padding = KIND_LEFT_PADDING,
    }
end

---@param line CompletionLine
---@param widths ColumnWidths
---@param spacing ColumnSpacing
---@param window_width number
---@return FormattedResult
local function format_completion_line(line, widths, spacing, window_width)
  local result = {
    text = '',
    highlights = {},
    current_pos = 0,
  }

  ---@param text string
  ---@param highlight_key string|nil
  ---@param highlight_group string|nil
  ---@return number
  local function append(text, highlight_key, highlight_group)
    local start_pos = #result.text
    result.text = result.text .. text
    local display_width = vim.fn.strdisplaywidth(text)

    if highlight_key then
      result.highlights[highlight_key] = {
        group = highlight_group,
        start_col = start_pos,
        end_col = start_pos + #text,
      }
    end

    result.current_pos = result.current_pos + display_width
    return result.current_pos
  end

  ---@param count number
  local function append_space(count)
    local spaces = string.rep(' ', count)
    result.text = result.text .. spaces
    result.current_pos = result.current_pos + count
  end

  append_space(spacing.icon_left_padding)
  append(line.kind_icon, 'kind_icon')
  append_space(spacing.icon_right_padding)

  local truncated_label = line.label
  if vim.fn.strdisplaywidth(truncated_label) > 16 then
    truncated_label = vim.fn.strcharpart(truncated_label, 0, 15) .. '…'
  end
  local padded_label = truncated_label .. string.rep(' ', widths.label - vim.fn.strdisplaywidth(truncated_label))
  append(padded_label, 'label', 'CmpItemAbbr')
  append_space(spacing.label_right_padding)

  if #line.detail > 0 then
    local detail = line.detail
    if vim.fn.strdisplaywidth(detail) > widths.detail then
      detail = vim.fn.strcharpart(detail, 0, widths.detail - 1) .. '…'
    end
    append(detail, 'detail', 'CmpItemKind')
  end

  local current_width = vim.fn.strdisplaywidth(result.text)
  local kind_start = window_width - widths.kind
  local padding_needed = kind_start - current_width

  if padding_needed > 0 then
    append_space(padding_needed)
  end

  append(line.kind, 'kind', 'CmpItemKindDefault')

  return result
end

---@param lines CompletionLine[]
---@param opts { width: number }
---@param completion_items table[]
---@return number bufnr
local function format_completion_window(lines, opts, completion_items)
  local buf = vim.api.nvim_create_buf(false, true)
  local window_width = opts.width

  local widths, spacing = calculate_column_widths(lines, window_width)

  local formatted_lines = {}
  local highlights = {}

  for i, line in ipairs(lines) do
    local formatted = format_completion_line(line, widths, spacing, window_width)
    table.insert(formatted_lines, formatted.text)

    highlights[i] = formatted.highlights

    if highlights[i].kind_icon then
      highlights[i].kind_icon.group = get_kind_highlight_group(completion_items[i].kind)
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, formatted_lines)

  if M.enable_highlight then
    for line_num, line_highlights in ipairs(highlights) do
      for _, highlight in pairs(line_highlights) do
        vim.api.nvim_buf_add_highlight(buf, -1, highlight.group, line_num - 1, highlight.start_col, highlight.end_col)
      end
    end
  end

  return buf
end

---@param direction "up"|"down"
local function scroll_preview(direction)
  if not preview_state.win or not vim.api.nvim_win_is_valid(preview_state.win) then
    return
  end

  local delta = direction == 'down' and 1 or -1
  local win = preview_state.win --[[ @as number ]]
  local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  local height = vim.api.nvim_win_get_height(win)
  local buf_height = vim.api.nvim_buf_line_count(preview_state.buf)

  local top = view.topline
  top = top + delta
  top = math.max(top, 1)
  top = math.min(top, buf_height - height + 1)

  vim.defer_fn(function()
    vim.api.nvim_win_call(win, function() vim.fn.winrestview { topline = top, lnum = top } end)
  end, 0)
end

---@return boolean
local function is_cursor_in_preview()
  if not preview_state.win or not vim.api.nvim_win_is_valid(preview_state.win) then
    return false
  end
  local cursor_win = vim.api.nvim_get_current_win()
  return cursor_win == preview_state.win
end

local function cleanup_preview()
  if is_cursor_in_preview() then
    return
  end

  if preview_state.augroup then
    vim.api.nvim_del_augroup_by_name(preview_state.augroup)
    preview_state.augroup = nil
  end

  for _, keymap in ipairs(preview_state.keymaps) do
    vim.keymap.del('n', keymap.lhs, { buffer = keymap.buffer })
  end
  preview_state.keymaps = {}

  if preview_state.win and vim.api.nvim_win_is_valid(preview_state.win) then
    vim.api.nvim_win_close(preview_state.win, true)
  end
  if preview_state.buf and vim.api.nvim_buf_is_valid(preview_state.buf) then
    vim.api.nvim_buf_delete(preview_state.buf, { force = true })
  end
  preview_state.win = nil
  preview_state.buf = nil
end

---@param line string
---@return string
local function get_line_indentation(line) return line:match '^%s*' end

---@param node TSNode
---@param bufnr number
---@param cursor number[]
---@return string
local function get_completion_text(node, bufnr, cursor)
  local completion_text = vim.treesitter.get_node_text(node, bufnr)
  local parent = node:parent()

  if parent and (parent:type():match 'attribute' or parent:type():match 'member_expression') then
    local parent_text = vim.treesitter.get_node_text(parent, bufnr)
    local object_node = parent:field('object')[1]
    if object_node then
      local object_end = select(2, object_node:end_())
      if cursor[2] <= object_end then
        completion_text = vim.treesitter.get_node_text(object_node, bufnr)
      else
        completion_text = parent_text
      end
    end
  end

  return completion_text
end

---@param current_name string|nil
---@return string
local function generate_temp_name(current_name)
  if current_name and current_name ~= '' then
    local dir = vim.fn.fnamemodify(current_name, ':h')
    local ext = vim.fn.fnamemodify(current_name, ':e')
    return dir .. '/temp_completion_buffer_' .. os.time() .. '.' .. ext
  end
  return vim.fn.getcwd() .. '/temp_completion_buffer_' .. os.time()
end

---@param bufnr number
---@param completion_text string
---@param indent string
---@param cursor number[]
---@return number
local function setup_temp_buffer(bufnr, completion_text, indent, cursor)
  local temp_bufnr = vim.api.nvim_create_buf(false, true)

  vim.bo[temp_bufnr].buftype = 'nofile'
  vim.bo[temp_bufnr].bufhidden = 'hide'
  vim.bo[temp_bufnr].swapfile = false
  vim.bo[temp_bufnr].buflisted = false

  for _, option in ipairs { 'filetype', 'tabstop', 'shiftwidth', 'expandtab' } do
    local value = vim.bo[bufnr][option]
    if value then
      vim.bo[temp_bufnr][option] = value
    end
  end

  local current_name = vim.api.nvim_buf_get_name(bufnr)
  local temp_name = generate_temp_name(current_name)
  vim.api.nvim_buf_set_name(temp_bufnr, temp_name)

  local all_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local source_lines = {}

  for i, l in ipairs(all_lines) do
    if i == cursor[1] then
      table.insert(source_lines, l)
      table.insert(source_lines, indent .. completion_text .. '.')
    else
      table.insert(source_lines, l)
    end
  end

  vim.api.nvim_buf_set_lines(temp_bufnr, 0, -1, false, source_lines)
  return temp_bufnr
end

---@param temp_bufnr number
---@param cursor number[]
---@param indent string
---@param completion_text string
---@param callback fun(items: table[])
local function request_completions(temp_bufnr, cursor, indent, completion_text, callback)
  local temp_win = vim.api.nvim_open_win(temp_bufnr, false, {
    relative = 'editor',
    width = 1,
    height = 1,
    row = 0,
    col = 0,
    style = 'minimal',
    noautocmd = true,
  })

  local clients = vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
  for _, client in pairs(clients) do
    vim.lsp.buf_attach_client(temp_bufnr, client.id)
  end

  vim.defer_fn(function()
    local params = {
      textDocument = vim.lsp.util.make_text_document_params(temp_bufnr),
      position = {
        line = cursor[1],
        character = #(indent .. completion_text .. '.'),
      },
      context = {
        triggerKind = vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter,
        triggerCharacter = '.',
      },
    }

    vim.lsp.buf_request_all(temp_bufnr, 'textDocument/completion', params, function(responses)
      if vim.api.nvim_win_is_valid(temp_win) then
        vim.api.nvim_win_close(temp_win, true)
      end
      if vim.api.nvim_buf_is_valid(temp_bufnr) then
        vim.api.nvim_buf_delete(temp_bufnr, { force = true })
      end

      if not responses or vim.tbl_count(responses) == 0 then
        vim.notify('No completion responses received', vim.log.levels.INFO)
        return
      end

      local all_items = {}
      for _, resp in pairs(responses) do
        if resp.result then
          local items = resp.result.items or resp.result
          vim.list_extend(all_items, items)
        end
      end

      callback(all_items)
    end)
  end, 100)
end

local function setup_preview_keymaps()
  local current_buf = vim.api.nvim_get_current_buf()
  local keymap_opts = { buffer = current_buf, silent = true }

  vim.keymap.set('n', '<C-j>', function() scroll_preview 'down' end, keymap_opts)
  vim.keymap.set('n', '<C-k>', function() scroll_preview 'up' end, keymap_opts)

  table.insert(preview_state.keymaps, { lhs = '<C-j>', buffer = current_buf })
  table.insert(preview_state.keymaps, { lhs = '<C-k>', buffer = current_buf })
end

---Run a callback with autocommands temporarily disabled
---@param callback function The callback to run
---@return any The return value from the callback
local function noautocmd(callback)
  local eventignore = vim.o.eventignore
  vim.o.eventignore = 'all'
  local result = callback()
  vim.defer_fn(function() vim.o.eventignore = eventignore end, 0)
  return result
end

---Triggers the completion window
M.trigger = function()
  if preview_state.win and vim.api.nvim_get_current_win() == preview_state.win then
    vim.wo[preview_state.win].cursorline = false
    noautocmd(function() vim.cmd 'wincmd p' end)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local bufnr = vim.api.nvim_get_current_buf()

  local line = vim.api.nvim_buf_get_lines(bufnr, cursor[1] - 1, cursor[1], false)[1]
  local indent = get_line_indentation(line)

  local parser = vim.treesitter.get_parser(bufnr)
  if not parser then
    vim.notify('No parser available for buffer', vim.log.levels.WARN)
    return
  end

  local root = parser:parse()[1]:root()
  local node = root:named_descendant_for_range(cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2])
  if not node then
    vim.notify('No node found at cursor position', vim.log.levels.WARN)
    return
  end

  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if #clients == 0 then
    vim.notify('No LSP clients found for buffer', vim.log.levels.ERROR)
    return
  end

  local completion_text = get_completion_text(node, bufnr, cursor)

  local temp_bufnr = setup_temp_buffer(bufnr, completion_text, indent, cursor)
  request_completions(temp_bufnr, cursor, indent, completion_text, function(all_items)
    if not all_items or #all_items == 0 then
      vim.notify(string.format('No completions found for "%s"', completion_text), vim.log.levels.INFO)
      return
    end

    ---@type CompletionLine[]
    local lines = {}
    for _, item in ipairs(all_items) do
      local kind = require('blink.cmp.types').CompletionItemKind[item.kind] or 'Unknown'
      local kind_icon = ' ' .. get_lspkind_symbol(kind) .. '  '
      table.insert(lines, {
        kind_icon = kind_icon,
        label = item.label,
        detail = item.detail or '',
        kind = kind,
      })
    end

    if preview_state.win and vim.api.nvim_win_is_valid(preview_state.win) then
      vim.api.nvim_set_current_win(preview_state.win)
      return
    end

    cleanup_preview()

    ---@type table
    local opts = {
      relative = 'cursor',
      row = 1,
      col = 0,
      width = 80,
      height = math.min(#lines, 10),
      style = 'minimal',
      border = 'rounded',
      title = completion_text,
      title_pos = 'center',
    }

    local buf = format_completion_window(lines, opts, all_items)
    preview_state.buf = buf

    local win = vim.api.nvim_open_win(buf, false, opts)
    preview_state.win = win

    vim.wo[win].wrap = false
    vim.wo[win].cursorline = false
    vim.wo[win].winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None'

    preview_state.augroup = 'CmpPreview' .. win
    local augroup = vim.api.nvim_create_augroup(preview_state.augroup, { clear = true })

    vim.api.nvim_create_autocmd('WinEnter', {
      group = augroup,
      callback = function()
        if vim.api.nvim_get_current_win() == win then
          vim.wo[win].cursorline = true
        end
      end,
      buffer = buf,
    })

    vim.api.nvim_create_autocmd('WinLeave', {
      group = augroup,
      callback = function(args)
        if vim.api.nvim_get_current_win() == win then
          vim.wo[win].cursorline = false
        end
      end,
      buffer = buf,
    })

    setup_preview_keymaps()

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      group = augroup,
      callback = function()
        if not is_cursor_in_preview() and preview_state.win and vim.api.nvim_win_is_valid(preview_state.win) then
          vim.api.nvim_win_close(preview_state.win, true)
          return true
        end
        return false
      end,
      buffer = vim.api.nvim_get_current_buf(),
    })

    vim.api.nvim_create_autocmd('WinClosed', {
      group = augroup,
      callback = function(args)
        if tonumber(args.match) == preview_state.win then
          cleanup_preview()
          return true
        end
        return false
      end,
    })
  end)
end

return M
