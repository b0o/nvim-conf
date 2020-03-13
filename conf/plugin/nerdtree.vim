""" nerdtree.vim
""" configuration for NERDTree and related plugins:
""" - preservim/nerdtree
""" - jistr/vim-nerdtree-tabs
""" - Xuyuanp/nerdtree-git-plugin

""" Settings
let g:NERDTreeMinimalUI = 1


""" Mappings
let g:NERDTreeMapHelp         = "<localleader>?"
let g:NERDTreeMapActivateNode = "e"
let g:NERDTreeMapOpenExpl     = "o"

""" NERDTree-Tabs
let s:nerdtree_tabs_startup_disable_ft = ["help", "man"]
let g:nerdtree_tabs_open_on_gui_startup = 0
let g:nerdtree_tabs_open_on_console_startup = 0
let g:nerdtree_tabs_autofind = 0

function! NERDTreeTabsEnable()
  let g:nerdtree_tabs_open_on_gui_startup = 1
  let g:nerdtree_tabs_open_on_console_startup = 1
  NERDTreeTabsOpen
endfunction

let g:NERDTreeIndicatorMapCustom = {
  \ 'Modified'  : 'M',
  \ 'Staged'    : '+',
  \ 'Untracked' : '?',
  \ 'Renamed'   : 'R',
  \ 'Unmerged'  : '!',
  \ 'Deleted'   : 'x',
  \ 'Dirty'     : '*',
  \ 'Clean'     : '',
  \ 'Ignored'   : 'I',
  \ 'Unknown'   : '??'
  \ }

" function! s:search_reverse()
" endfunction
"
" function! s:nerdtree_setup()
"   call NERDTreeAddKeyMap({
"     \ 'key': '?',
"     \ 'callback': funcref()
"     \ })
" endfunction

augroup nerdtree
  autocmd!
  " autocmd FileType nerdtree call s:nerdtree_setup()
  autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

nnoremap <silent> <leader>N   :NERDTreeTabsToggle<cr>
nnoremap <silent> <leader>nn  :NERDTreeMirrorToggle<cr>
