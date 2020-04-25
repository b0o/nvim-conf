""" init.vim

let $cfg   = expand('<sfile>:p')
let $cfgd  = stdpath('config')
let $data  = stdpath('data')
let $cache = stdpath('cache')

" TODO: use dein to load/manage config files/dirs rather than doing it manually here
let g:nvim_config_files = [
  \   'conf/plugins.vim',
  \   'conf/settings.vim',
  \   'conf/functions.vim',
  \   'conf/mappings.vim',
  \   'conf/auto.vim',
  \   'conf/interface.vim',
  \   'conf/lh.vim',
  \   'conf/plugin/airline.vim',
  \   'conf/plugin/ale.vim',
  \   'conf/plugin/clap.vim',
  \   'conf/plugin/denite.vim',
  \   'conf/plugin/deoplete.vim',
  \   'conf/plugin/gitgutter.vim',
  \   'conf/plugin/go.vim',
  \   'conf/plugin/goyo.vim',
  \   'conf/plugin/haskell-vim.vim',
  \   'conf/plugin/javascript.vim',
  \   'conf/plugin/jsx.vim',
  \   'conf/plugin/language-client.vim',
  \   'conf/plugin/language-client-hover.vim',
  \   'conf/plugin/markdown.vim',
  \   'conf/plugin/move.vim',
  \   'conf/plugin/nerdtree.vim',
  \   'conf/plugin/orgmode.vim',
  \   'conf/plugin/sandwich.vim',
  \   'conf/plugin/tagbar.vim',
  \   'conf/plugin/tcomment.vim',
  \   'conf/plugin/ultisnips.vim',
  \   'conf/plugin/vcoolor.vim',
  \   'conf/plugin/which-key.vim',
  \ ]
" \   'conf/lh.vim'
" \   'conf/plugin/firenvim.vim',

func! s:cpath(...)
  return join([$cfgd] + a:000, '/')
endfunc

exec join(map(g:nvim_config_files, { _, c -> 'source ' . s:cpath(c) }), ' | ')
