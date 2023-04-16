local easypick = require 'easypick'

easypick.setup {
  pickers = {
    {
      name = 'headers',
      command = vim.fn.stdpath 'config' .. '/scripts/findheaders.py -f json',
      previewer = easypick.previewers.default(),
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
        }
      end,
    },
  },
}
