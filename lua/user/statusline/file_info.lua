local colors = require 'user.colors'

local fn = vim.fn
local bo = vim.bo
local api = vim.api

local M = {}

-- Get the names of all current listed buffers
local function get_current_filenames()
  local listed_buffers = vim.tbl_filter(function(bufnr)
    return bo[bufnr].buflisted and api.nvim_buf_is_loaded(bufnr)
  end, api.nvim_list_bufs())

  return vim.tbl_map(api.nvim_buf_get_name, listed_buffers)
end

-- Get unique name for the current buffer
local function get_unique_filename(filename, shorten)
  local filenames = vim.tbl_filter(function(filename_other)
    return filename_other ~= filename
  end, get_current_filenames())

  if shorten then
    filename = fn.pathshorten(filename)
    filenames = vim.tbl_map(fn.pathshorten, filenames)
  end

  -- Reverse filenames in order to compare their names
  filename = string.reverse(filename)
  filenames = vim.tbl_map(string.reverse, filenames)

  local index

  -- For every other filename, compare it with the name of the current file char-by-char to
  -- find the minimum index `i` where the i-th character is different for the two filenames
  -- After doing it for every filename, get the maximum value of `i`
  if next(filenames) then
    index = math.max(unpack(vim.tbl_map(function(filename_other)
      for i = 1, #filename do
        -- Compare i-th character of both names until they aren't equal
        if filename:sub(i, i) ~= filename_other:sub(i, i) then
          return i
        end
      end
      return 1
    end, filenames)))
  else
    index = 1
  end

  -- Iterate backwards (since filename is reversed) until a "/" is found
  -- in order to show a valid file path
  while index <= #filename do
    if filename:sub(index, index) == '/' then
      index = index - 1
      break
    end

    index = index + 1
  end

  return string.reverse(string.sub(filename, 1, index))
end

function M.file_info(component, opts)
  local filename
  if opts.filetypes_override_name then
    local filetype = api.nvim_buf_get_option(0, 'filetype')
    if opts.filetypes_override_name[filetype] then
      filename = opts.filetypes_override_name[filetype]
    elseif vim.tbl_contains(opts.filetypes_override_name, filetype) then
      filename = filetype
    end
  end
  if filename == nil then
    filename = api.nvim_buf_get_name(0)
    local _type = opts.type or 'base-only'

    if _type == 'short-path' then
      filename = fn.pathshorten(filename)
    elseif _type == 'base-only' then
      filename = fn.fnamemodify(filename, ':t')
    elseif _type == 'relative' then
      filename = fn.fnamemodify(filename, ':~:.')
    elseif _type == 'relative-short' then
      filename = fn.pathshorten(fn.fnamemodify(filename, ':~:.'))
    elseif _type == 'unique' then
      filename = get_unique_filename(filename)
    elseif _type == 'unique-short' then
      filename = get_unique_filename(filename, true)
    elseif _type ~= 'full-path' then
      filename = fn.fnamemodify(filename, ':t')
    end
  end

  local extension = fn.fnamemodify(filename, ':e')
  local readonly_str

  local icon

  -- Avoid loading nvim-web-devicons if an icon is provided already
  if not component.icon then
    local icon_str, icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })

    icon = { str = icon_str }

    if opts.colored_icon == nil or opts.colored_icon then
      icon.hl = { fg = icon_color }
    end
  end

  if filename == '' then
    filename = 'unnamed'
  end

  if bo.readonly then
    readonly_str = opts.file_readonly_icon or '🔒'
  else
    readonly_str = ''
  end

  local content = {
    str = string.format(' %s%s ', readonly_str, filename),
  }

  if bo.modified then
    icon = {
      str = opts.file_modified_icon or '',
      hl = {
        fg = opts.active and colors.hydrangea,
        bg = colors.deep_licorice,
      },
    }
  end

  return content.str, icon
end

M.hl = function(base)
  return function()
    return vim.tbl_extend('force', {
      style = vim.api.nvim_buf_get_option(0, 'modified') and 'italic' or nil,
    }, base)
  end
end

require('user.statusline.providers').register('user_file_info', M.file_info)

return M
