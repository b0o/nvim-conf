""" haskell-vim.vim
" configuration for the plugin neovimhaskell/haskell-vim

" Disable haskell-vim omnifunc
let g:haskellmode_completion_ghc = 0

augroup haskellOmniFunc
  autocmd!
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
augroup END
