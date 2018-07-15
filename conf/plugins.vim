""" plugins.vim
""" plugin manager setup

" add dein to rtp
set runtimepath+=~/.config/nvim/dein.vim

if dein#load_state('~/.config/nvim/dein')
  call dein#begin('~/.config/nvim/dein')

  " Let dein manage itself
  call dein#add('~/.config/nvim/dein.vim')

  call dein#add('~/.config/nvim/bundles/dein/github.com/Shougo/dein.vim')

  " Interface
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('majutsushi/tagbar')
  call dein#add('junegunn/goyo.vim')

  " Editing & Motion
  call dein#add('chaoren/vim-wordmotion')
  call dein#add('terryma/vim-multiple-cursors')
  call dein#add('tomtom/tcomment_vim', {'depends': 'tomtom/vimtlib'})
  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-textobj-line')
  call dein#add('tpope/vim-repeat')
  call dein#add('tpope/vim-surround')
  call dein#add('tpope/vim-abolish')
  call dein#add('AndrewRadev/splitjoin.vim')
  call dein#add('matze/vim-move')
  call dein#add('andymass/vim-matchup')

  " ctags
  call dein#add('lyuts/vim-rtags')

  " multi-language completions
  call dein#add('autozimu/LanguageClient-neovim', {
    \ 'rev': 'next',
    \ 'build': 'bash install.sh',
    \ })

  " JavaScript
  call dein#add('pangloss/vim-javascript')
  call dein#add('mxw/vim-jsx')
  call dein#add('styled-components/vim-styled-components')

  " CSS/Sass/Haml
  call dein#add('hail2u/vim-css3-syntax')

  " Elixir
  " call dein#add('elixir-editors/vim-elixir')
  " call dein#add('slashmili/alchemist.vim')

  " Golang
  call dein#add('fatih/vim-go')

  " Haskell
  call dein#disable('eagletmt/ghcmod-vim')
  call dein#disable('eagletmt/neco-ghc')
  call dein#add('neovimhaskell/haskell-vim')

  " YAML
  call dein#add('stephpy/vim-yaml')

  " Snippets
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('Shougo/neosnippet-snippets')

  " Git
  call dein#add('airblade/vim-gitgutter')

  " Misc
  call dein#add('Shougo/denite.nvim')
  call dein#add('editorconfig/editorconfig-vim')
  call dein#add('chrisbra/Recover.vim')
  call dein#add('vimwiki/vimwiki')
  call dein#add('ap/vim-css-color')
  call dein#add('KabbAmine/vCoolor.vim')
  call dein#add('mattn/gist-vim', {'depends': 'mattn/webapi-vim'})
  call dein#add('tpope/vim-eunuch')

  " Auto Completion, linting, etc
  call dein#add('w0rp/ale')
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/neco-syntax')
  call dein#add('Shougo/neco-vim')
  call dein#add('zchee/deoplete-go', {'build': 'make'})

  " Themes
  call dein#add('arcticicestudio/nord-vim')
  call dein#add('chriskempson/base16-vim')

  " Vim Plugin Development
  " call dein#add('xolox/vim-reload', {'depends': 'xolox/vim-misc'})
  " call dein#add('gerw/vim-HiLinkTrace')

  " Local plugins
  call dein#local('~/.config/nvim/bundle', {}, [
        \ 'b0o/builder.vim',
        \ 'b0o/quicktemplate.vim',
        \ ])
        " \ 'b0o/vim-HiLinkTrace'

  " Dependencies
  call dein#add('mattn/webapi-vim')
  call dein#add('tomtom/vimtlib')
  " call dein#add('xolox/vim-misc')

  call dein#end()
  call dein#save_state()
endif

""" dein helper functions
function! s:pluginClean()
  call map(dein#check_clean(), "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endfunction

function! s:pluginInstall()
  call s:pluginClean()
  call dein#install()
endfunction

function! s:pluginUpdate()
  call s:pluginClean()
  call dein#update()
endfunction

command! PluginClean call s:pluginClean()
command! PluginInstall call s:pluginInstall()
command! PluginUpdate call s:pluginUpdate()
