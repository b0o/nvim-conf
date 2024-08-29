local M = {}

local callbacks = {}

-- Call the callback associated with 'id'
M.callback = function(id, ...)
  return callbacks[id](...)
end

-- Register a global anonymous callback
-- Returns an id that can be passed to fn.callback() to call the function
M.new_callback = function(fn)
  table.insert(callbacks, fn)
  return #callbacks
end

-- Register a vim command
M.command = function(t)
  local c = {}
  for _, e in ipairs(t) do
    if type(e) == 'function' or type(e) == 'table' then
      local replacements = {}
      if type(e) == 'table' and not require('user.fn').is_callable(e) then
        local et = e
        e = table.remove(e, 1)
        for _, r in ipairs(et) do
          local rep = ({
            args = '{ <f-args> }',
            line1 = '<line1>',
            line2 = '<line2>',
            range = '<range>',
            count = '<count>',
            bang = '<q-bang>',
            mods = '<q-mods>',
            reg = '<q-reg>',
          })[r]
          if rep then
            table.insert(replacements, ('%s = %s'):format(r, rep))
          end
        end
      end
      local cb = M.new_callback(e)
      e = ([[lua require'user.util.command'.callback(%d, {%s})]]):format(cb, table.concat(replacements, ','))
    end
    table.insert(c, e)
  end
  vim.cmd('command! ' .. table.concat(c, ' '))
end

-- Register a command-line abbreviation
M.cabbrev = function(a, c)
  vim.cmd(('cabbrev %s %s'):format(a, c))
end

return M
