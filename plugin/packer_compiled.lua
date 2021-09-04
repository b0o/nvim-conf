-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/maddy/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?.lua;/home/maddy/.cache/nvim/packer_hererocks/2.0.5/share/lua/5.1/?/init.lua;/home/maddy/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?.lua;/home/maddy/.cache/nvim/packer_hererocks/2.0.5/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/maddy/.cache/nvim/packer_hererocks/2.0.5/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/LuaSnip"
  },
  ["Recover.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/Recover.vim"
  },
  ["base16-vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/base16-vim"
  },
  ["editorconfig.nvim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/editorconfig.nvim"
  },
  ["extended-scrolloff.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/extended-scrolloff.vim"
  },
  ["gist-vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/gist-vim"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["i3config.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/i3config.vim"
  },
  ["impatient.nvim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/impatient.nvim"
  },
  ["lightline.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/lightline.vim"
  },
  ["mapx.lua"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/mapx.lua"
  },
  ["nvim-compe"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/nvim-compe"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects"
  },
  ["onedark.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/onedark.vim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["shellcheck-extras.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/shellcheck-extras.vim"
  },
  ["splitjoin.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/splitjoin.vim"
  },
  tabular = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/tabular"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["textobj-word-column.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/textobj-word-column.vim"
  },
  undotree = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/undotree"
  },
  ["vCoolor.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vCoolor.vim"
  },
  ["vim-abolish"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-abolish"
  },
  ["vim-buffest"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-buffest"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-commentary"
  },
  ["vim-conflicted"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-conflicted"
  },
  ["vim-dune"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-dune"
  },
  ["vim-eunuch"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-eunuch"
  },
  ["vim-expand-region"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-expand-region"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-gutentags"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-gutentags"
  },
  ["vim-hexokinase"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-hexokinase"
  },
  ["vim-man"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-man"
  },
  ["vim-matchup"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-matchup"
  },
  ["vim-move"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-move"
  },
  ["vim-relativize"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-relativize"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-repeat"
  },
  ["vim-rescript"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-rescript"
  },
  ["vim-rhubarb"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-rhubarb"
  },
  ["vim-shot-f"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-shot-f"
  },
  ["vim-speeddating"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-speeddating"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-textobj-fold"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-textobj-fold"
  },
  ["vim-textobj-indent"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-textobj-indent"
  },
  ["vim-textobj-line"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-textobj-line"
  },
  ["vim-textobj-user"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-textobj-user"
  },
  ["vim-tmux-navigator"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-tmux-navigator"
  },
  ["vim-visual-increment"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-visual-increment"
  },
  ["vim-visual-multi"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-visual-multi"
  },
  ["vim-windowswap"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-windowswap"
  },
  ["vim-wordmotion"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vim-wordmotion"
  },
  vinfo = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vinfo"
  },
  ["vista.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/vista.vim"
  },
  ["visual-split.vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/visual-split.vim"
  },
  ["webapi-vim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/webapi-vim"
  },
  ["which-key.nvim"] = {
    loaded = true,
    path = "/home/maddy/.local/share/nvim/site/pack/packer/start/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
