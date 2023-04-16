local easypick = require 'easypick'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local xk = require('user.mappings').xk

local find_first_include = function(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:find '^#include' then
      return i
    end
  end
  return nil
end

local insert_action = function(current_line)
  return function(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local orig_win_id = picker.original_win_id
    local orig_bufnr = vim.api.nvim_win_get_buf(orig_win_id)

    local entry = action_state.get_selected_entry()
    local include = entry.include
    if include == nil then
      return
    end

    local target_line = not current_line and find_first_include(orig_bufnr) or nil
    if target_line ~= nil then
      target_line = target_line - 1
    else
      target_line = vim.api.nvim_win_get_cursor(orig_win_id)[1] - 1
    end

    actions.close(prompt_bufnr)

    vim.api.nvim_buf_set_lines(orig_bufnr, target_line, target_line, false, { include })
  end
end

easypick.setup {
  pickers = {
    {
      name = 'headers',
      command = vim.fn.stdpath 'config' .. '/scripts/findheaders.py -f json',
      previewer = easypick.previewers.default(),
      action = function(_, map)
        map({ 'n', 'i' }, '<C-a>', insert_action(false))
        map({ 'n', 'i' }, xk [[<C-S-a>]], insert_action(true))
        map({ 'n', 'i' }, '<C-y>', function(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          local include = entry.include
          if include == nil then
            return
          end
          actions.close(prompt_bufnr)
          vim.fn.setreg('+', include)
          vim.notify({ 'Copied', include }, vim.log.levels.INFO)
        end)
        return true
      end,

      entry_maker = function(line)
        local entry = vim.fn.json_decode(line)
        if entry == nil or type(entry) ~= 'table' or entry.include_dir == nil or entry.header_file == nil then
          return {
            value = line,
            ordinal = line,
            display = line,
          }
        end
        local full_path = entry.include_dir .. '/' .. entry.header_file
        return {
          value = full_path,
          ordinal = full_path,
          display = entry.header_file,
          path = full_path,
          include = '#include <' .. entry.header_file .. '>',
        }
      end,
    },
  },
}
