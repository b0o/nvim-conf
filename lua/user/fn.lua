local fn = {}

function fn.inspect(...)
  for _, v in ipairs({...}) do
    print(vim.inspect(v))
  end
end

function fn.getVisualSelection(mode)
  if mode == nil then
    local modeInfo = vim.api.nvim_get_mode()
    mode = modeInfo.mode
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local cline, ccol = cursor[1], cursor[2]
  local vline, vcol = vim.fn.line('v'), vim.fn.col('v')

  local sline, scol
  local eline, ecol
  if cline == vline then
    if ccol <= vcol then
      sline, scol = cline, ccol
      eline, ecol = vline, vcol
      scol = scol + 1
    else
      sline, scol = vline, vcol
      eline, ecol = cline, ccol
      ecol = ecol + 1
    end
  elseif cline < vline then
    sline, scol = cline, ccol
    eline, ecol = vline, vcol
    scol = scol + 1
  else
    sline, scol = vline, vcol
    eline, ecol = cline, ccol
    ecol = ecol + 1
  end

  if mode == "V" or mode == "CTRL-V" or mode == "\22" then
    scol = 1
    ecol = nil
  end

  local lines = vim.api.nvim_buf_get_lines(0, sline - 1, eline, 0)
  if #lines == 0 then return end

  local startText, endText
  if #lines == 1 then
    startText = string.sub(lines[1], scol, ecol)
  else
    startText = string.sub(lines[1], scol)
    endText = string.sub(lines[#lines], 1, ecol)
  end

  local selection = {startText}
  if #lines > 2 then
    vim.list_extend(selection, vim.list_slice(lines, 2, #lines - 1))
  end
  table.insert(selection, endText)

  return selection
end

function fn.luarun()
  local modeInfo = vim.api.nvim_get_mode()
  if modeInfo.blocking then return end
  local mode = modeInfo.mode

  local text
  if mode == "n" then
    text = vim.api.nvim_get_current_line()
  elseif mode == "v" or mode == "V" or mode == "CTRL-V" or mode == "\22" then
    local selection = fn.getVisualSelection(mode)
    text = table.concat(selection, "\n")
  else
    return
  end

  local loadok, expr = pcall(loadstring, "return " .. text)
  if loadok and expr then
    local msg = "luarun (expr)"
    local evalok, evalResult = pcall(expr)
    if not evalok then error(msg .. " (failed): " .. evalResult) end
    print(msg .. ": "..text)
    print(vim.inspect(evalResult))
    return
  end

  local lines = vim.split(text, "\n")
  lines[#lines] = "return " .. lines[#lines]

  local blockexpr
  loadok, blockexpr = pcall(loadstring, table.concat(lines, "\n"))
  if loadok and blockexpr then
    local msg = "luarun (block-expr)"
    local evalok, blockexprResult = pcall(blockexpr)
    if not evalok then error(msg .. " (failed): " .. blockexprResult) end
    print(msg .. ": "..text)
    print(vim.inspect(blockexprResult))
    return
  end

  local block, errmsg
  loadok, block, errmsg = pcall(loadstring, text)
  if not loadok then error(errmsg) end

  local msg = "luarun (block)"
  local blockok, blockResult = pcall(block)
  if not blockok then error(msg .. " failed: " .. blockResult) end

  print(msg .. ": "..text)
  print(vim.inspect(blockResult))
end

return fn
