if &compatible
  set nocompatible
endif

let $cfg  = expand("<sfile>:p")
let $cfgd = expand("<sfile>:p:h")

let g:nvim_config_files = [
  \   "conf/settings.vim",
  \   "conf/plugins.vim",
  \   "conf/functions.vim",
  \   "conf/interface.vim",
  \   "conf/auto.vim",
  \   "conf/commands.vim",
  \   "conf/mappings.vim",
  \   "conf/lh.vim",
  \   "conf/plugin/ale.vim",
  \   "conf/plugin/denite.vim",
  \   "conf/plugin/deoplete.vim",
  \   "conf/plugin/goyo.vim",
  \   "conf/plugin/gitgutter.vim",
  \   "conf/plugin/haskell-vim.vim",
  \   "conf/plugin/ultisnips.vim",
  \   "conf/plugin/language-client.vim",
  \   "conf/plugin/tagbar.vim",
  \   "conf/plugin/tcomment.vim",
  \   "conf/plugin/vcoolor.vim",
  \   "conf/plugin/vim-airline.vim",
  \   "conf/plugin/vim-go.vim",
  \   "conf/plugin/vim-javascript.vim",
  \   "conf/plugin/vim-jsx.vim",
  \   "conf/plugin/vim-move.vim",
  \   "conf/plugin/vim-orgmode.vim",
  \ ]

func! s:cpath(...)
  return join([$cfgd] + a:000, "/")
endfunc

exec join(map(g:nvim_config_files, { _, c -> "silent! source " . s:cpath(c) }), " | ")
