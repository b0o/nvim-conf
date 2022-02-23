local M = { vmlens = {} }

local hlslens = require 'hlslens'
local hlslens_config
local lens_backup

function M.vmlens.start()
  if hlslens then
    hlslens_config = require 'hlslens.config'
    lens_backup = hlslens_config.override_lens

    hlslens_config.override_lens = function(render, plist, nearest, idx, r_idx)
      local _ = r_idx
      local lnum, col = unpack(plist[idx])
      local text, chunks
      if nearest then
        text = ('[%d/%d]'):format(idx, #plist)
        chunks = { { ' ', 'Ignore' }, { text, 'VM_Extend' } }
      else
        text = ('[%d]'):format(idx)
        chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
      end
      render.set_virt(0, lnum - 1, col - 1, chunks, nearest)
    end

    hlslens.start(true)
  end
end

function M.vmlens.exit()
  if hlslens then
    hlslens_config.override_lens = lens_backup
    hlslens.start(true)
  end
end

vim.cmd [[
  function VM_Start()
    lua require'user.plugin.hlslens'.vmlens.start()
  endfunction
  function VM_Exit()
    lua require'user.plugin.hlslens'.vmlens.exit()
  endfunction
]]

return M
