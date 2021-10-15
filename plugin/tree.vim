finish
" This is a re-implementation of kyazdani42/nvim-tree.lua/plugin/tree.vim
" which avoids starting NvimTree until explicitly requested by the user.
if !has('nvim-0.5') || exists('g:loaded_tree_override') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

if get(g:, 'nvim_tree_disable_netrw', 1) == 1
    let g:loaded_netrw = 1
    let g:loaded_netrwPlugin = 1
endif

let s:nvimTreeStarted = 0

function! s:nvimTreeStart()
  if s:nvimTreeStarted == 1 | return | endif
  let s:nvimTreeStarted = 1
  augroup NvimTree
    au!
    if get(g:, 'nvim_tree_hijack_netrw', 1) == 1 && get(g:, 'nvim_tree_disable_netrw', 1) == 0
      silent! autocmd! FileExplorer *
    endif
    au BufWritePost * lua require'nvim-tree'.refresh()
    if get(g:, 'nvim_tree_lsp_diagnostics', 0) == 1
      au User LspDiagnosticsChanged lua require'nvim-tree.diagnostics'.update()
    endif
    au BufEnter * lua require'nvim-tree'.buf_enter()
    if get(g:, 'nvim_tree_auto_close') == 1
      au WinClosed * lua require'nvim-tree'.on_leave()
    endif
    au ColorScheme * lua require'nvim-tree'.reset_highlight()
    au User FugitiveChanged,NeogitStatusRefreshed lua require'nvim-tree'.refresh()
    if get(g:, 'nvim_tree_tab_open') == 1
      au TabEnter * lua require'nvim-tree'.tab_change()
    endif
    au SessionLoadPost * lua require'nvim-tree.view'._wipe_rogue_buffer()
    if get(g:, 'nvim_tree_hijack_cursor', 1) == 1
      au CursorMoved NvimTree lua require'nvim-tree'.place_cursor_on_node()
    endif
    if get(g:, 'nvim_tree_update_cwd') == 1
      au DirChanged * lua require'nvim-tree.lib'.change_dir(vim.loop.cwd())
    endif
  augroup END
endfunction

command! -bar NvimTreeStart call s:nvimTreeStart()

command! NvimTreeOpen NvimTreeStart | lua require'nvim-tree'.open()
command! NvimTreeClose NvimTreeStart | lua require'nvim-tree'.close()
command! NvimTreeToggle NvimTreeStart | lua require'nvim-tree'.toggle()
command! NvimTreeFocus NvimTreeStart | lua require'nvim-tree'.focus()
command! NvimTreeRefresh NvimTreeStart | lua require'nvim-tree'.refresh()
command! NvimTreeClipboard NvimTreeStart | lua require'nvim-tree'.print_clipboard()
command! NvimTreeFindFile NvimTreeStart | lua require'nvim-tree'.find_file(true)
command! -nargs=1 NvimTreeResize NvimTreeStart | lua require'nvim-tree'.resize(<args>)

if get(g:, 'nvim_tree_auto_init', 1) == 1
  call s:nvimTreeStart()
endif

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_tree_override = 1
