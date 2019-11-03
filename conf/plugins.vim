""" plugins.vim
""" plugin manager setup

" add dein to rtp
set runtimepath+=~/.config/nvim/dein.vim

" Add dein plugins
if dein#load_state('~/.config/nvim/dein')
  call dein#begin('~/.config/nvim/dein')

  " Let dein manage itself
  call dein#add('~/.config/nvim/dein.vim')

  " Dependencies
  call dein#add('mattn/webapi-vim')
  call dein#add('tomtom/vimtlib')
  call dein#disable('xolox/vim-misc')

  " Interface
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')

  " Editing & Motion
  call dein#add('machakann/vim-swap')
  call dein#add('chaoren/vim-wordmotion')
  call dein#add('mg979/vim-visual-multi')
  call dein#add('tomtom/tcomment_vim')
  call dein#add('kana/vim-textobj-user')
  call dein#add('kana/vim-textobj-line')
  call dein#add('tpope/vim-repeat')
  call dein#add('tpope/vim-surround')
  call dein#add('tpope/vim-abolish')
  call dein#add('tpope/vim-speeddating')
  call dein#add('AndrewRadev/splitjoin.vim')
  call dein#add('matze/vim-move')
  call dein#add('andymass/vim-matchup')

  " Project Management
  call dein#add('editorconfig/editorconfig-vim')

  " Git
  call dein#add('tpope/vim-fugitive')
  call dein#add('airblade/vim-gitgutter')
  call dein#add('christoomey/vim-conflicted')

  " Auto Completion, linting, etc
  call dein#add('w0rp/ale')
  call dein#add('Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' })
  call dein#add('Shougo/neco-syntax')
  call dein#add('Shougo/neco-vim')

  " Snippets
  call dein#add('SirVer/ultisnips')
  call dein#add('honza/vim-snippets')

  " ctags
  call dein#disable('lyuts/vim-rtags')

  " multi-language completions
  call dein#add('autozimu/LanguageClient-neovim', {
    \ 'rev': 'next',
    \ 'build': 'bash -c "./install.sh > /tmp/LanguageClient-neovim_build.log 2> /tmp/LanguageClient-neovim_build.err.log"',
    \ })

  " JavaScript
  call dein#add('pangloss/vim-javascript')
  call dein#add('mxw/vim-jsx')
  call dein#add('styled-components/vim-styled-components')

  " jq
  call dein#add('vito-c/jq.vim')

  " CSS/Sass/Haml
  call dein#add('hail2u/vim-css3-syntax')

  " Elixir
  call dein#disable('elixir-editors/vim-elixir')
  call dein#disable('slashmili/alchemist.vim')

  call dein#add('fatih/vim-go')
  call dein#add('zchee/deoplete-go', {
    \ 'build': 'make',
    \ })

  " Haskell
  call dein#disable('eagletmt/ghcmod-vim')
  call dein#disable('eagletmt/neco-ghc')
  call dein#add('neovimhaskell/haskell-vim')

  " OCaml/Reason (See also rtp modification at bottom of file for merlin plugin)
  call dein#add('reasonml-editor/vim-reason-plus')
  call dein#add('Akin909/vim-dune')

  " Perl5/6
  call dein#add('vim-perl/vim-perl6')

  " YAML
  call dein#add('stephpy/vim-yaml')

  " NGINX
  call dein#add('chr4/nginx.vim')

  " i3/sway configuration files
  call dein#add('mboughaba/i3config.vim')
  call dein#add('aouelete/sway-vim-syntax')

  " Documentation/reference
  call dein#add('alx741/vinfo')

  " Writing, Todos, and Notetaking
  call dein#add('jceb/vim-orgmode')
  call dein#add('junegunn/goyo.vim')

  " General Utility
  call dein#add('majutsushi/tagbar')
  call dein#add('Shougo/denite.nvim')
  call dein#add('chrisbra/Recover.vim')
  call dein#add('ap/vim-css-color')
  call dein#add('KabbAmine/vCoolor.vim')
  call dein#add('mattn/gist-vim')
  call dein#add('tpope/vim-eunuch')

  " Themes
  call dein#add('arcticicestudio/nord-vim')
  call dein#add('chriskempson/base16-vim')

  " Vim Plugin Development
  call dein#add('tpope/vim-scriptease')

  " Local plugins
  call dein#local('~/.config/nvim/bundle', {}, [
        \ 'b0o/builder.vim',
        \ 'b0o/quicktemplate.vim',
        \ 'b0o/betwixt.vim',
        \ ])

  call dein#end()
  call dein#save_state()
endif

" Merlin is a plugin for OCaml completion
" It is managed by opam, not dein, so we manually add it to our RTP
let s:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute "set rtp+=" . s:opamshare . "/merlin/vim"
