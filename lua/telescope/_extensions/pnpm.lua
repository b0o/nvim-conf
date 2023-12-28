local Path = require 'plenary.path'

local t = require 'telescope'
local ta = require 'telescope.actions'
local tb = require 'telescope.builtin'
local tf = require 'telescope.finders'
local tp = require 'telescope.pickers'
local ts = require 'telescope.sorters'
local tv = require 'telescope.previewers'

local action_state = require 'telescope.actions.state'

local M = {}

local padRight = function(s, len)
  return s .. string.rep(' ', len - #s)
end

function M.workspace_packages(opts)
  opts = opts or {}
  local info = require('user.util.pnpm').get_workspace_info {
    focused_path = Path:new(opts.focused_path or vim.api.nvim_buf_get_name(0)),
    refresh = opts.refresh,
  }
  if not info then
    return
  end
  local max_path_len = 0
  for _, package in ipairs(info.packages) do
    max_path_len = math.max(max_path_len, #package.relative_path)
  end
  tp.new(opts, {
    prompt_title = 'Pnpm packages',
    finder = tf.new_table {
      results = info.packages,
      entry_maker = function(entry)
        local status_icon = ' '
        if entry.focused then
          status_icon = ''
        elseif entry.current then
          status_icon = '•'
        end
        local kind_icon = ' '
        if entry.root then
          kind_icon = ''
        end
        return {
          value = entry,
          display = table.concat({
            kind_icon,
            status_icon,
            '/' .. padRight(entry.relative_path, max_path_len),
            entry.name or vim.fs.basename(entry.relative_path),
          }, ' '),
          ordinal = (entry.name or '') .. ' ' .. entry.relative_path,
          path = entry.path:absolute(),
          name = entry.name or vim.fs.basename(entry.relative_path),
        }
      end,
    },
    previewer = tv.new_termopen_previewer {
      dyn_title = function(_, entry)
        return 'Package ' .. entry.name
      end,
      get_command = function(entry)
        return {
          'eza',
          '--color=always',
          '-T',
          '--group-directories-first',
          '--git-ignore',
          '-I',
          '.git',
          '-L2',
          entry.path,
        }
      end,
    },
    sorter = ts.get_fzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      -- find files in package
      ta.select_default:replace(function()
        local entry = action_state.get_selected_entry().value
        ta.close(prompt_bufnr)
        vim.schedule(function()
          M.workspace_package_files {
            focused_path = entry.path,
          }
        end)
      end)
      -- reload pnpm workspace info
      map({ 'i', 'n' }, '<C-r>', function()
        ta.close(prompt_bufnr)
        vim.schedule(function()
          M.workspace_packages {
            focused_path = info.focused.path,
            refresh = true,
          }
        end)
      end)
      -- cd to package
      map({ 'i', 'n' }, '<C-i>', function()
        local entry = action_state.get_selected_entry().value
        ta.close(prompt_bufnr)
        vim.api.nvim_set_current_dir(entry.path:absolute())
      end)
      return true
    end,
  }):find()
end

function M.workspace_package_files(opts)
  opts = opts or {}
  local info = require('user.util.pnpm').get_workspace_info {
    focused_path = Path:new(opts.focused_path or vim.api.nvim_buf_get_name(0)),
    refresh = opts.refresh,
  }
  if not info then
    vim.notify('No workspace PNPM workspace detected', vim.log.levels.WARN)
    return
  end
  return tb.find_files(vim.tbl_extend('force', opts or {}, {
    prompt_title = 'Pnpm Workspace Package ' .. (info.focused.name or ('/' .. info.focused.relative_path)),
    cwd = info.focused.path:absolute(),
    attach_mappings = function(_, map)
      -- select a different package
      map({ 'i', 'n' }, '<C-o>', function(prompt_bufnr)
        ta.close(prompt_bufnr)
        vim.schedule(function()
          M.workspace_packages {
            focused_path = info.focused.path,
          }
        end)
      end)
      -- reload pnpm workspace info
      map({ 'i', 'n' }, '<C-r>', function(prompt_bufnr)
        ta.close(prompt_bufnr)
        vim.schedule(function()
          M.workspace_package_files {
            focused_path = info.focused.path,
            refresh = true,
          }
        end)
      end)
      return true
    end,
  }))
end

return t.register_extension {
  exports = {
    workspace_packages = M.workspace_packages,
    workspace_package_files = M.workspace_package_files,
  },
}
