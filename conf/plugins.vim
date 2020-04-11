""" plugins.vim
""" plugin manager setup

" dein paths
let s:dein_dir = $cfgd . '/dein'
let s:dein_plg = $cfgd . '/dein.vim'

" dein configuration options
let g:dein#install_progress_type = 'none' " displayed in airline
let g:dein#install_message_type = 'none'

" add dein to rtp
execute 'set runtimepath+=' . s:dein_plg

" show dein progress in statusline before airline is loaded
set statusline=%f\ %{dein#get_progress()}\ %h%w%m%r\ %=%(%l,%c%V\ %=\ %P%)

" Add dein plugins
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " Let dein manage itself
  call dein#add(s:dein_plg)

  " Dependencies
  call dein#add('mattn/webapi-vim')
  call dein#add('tomtom/vimtlib')
  call dein#add('b0o/builder.vim')
  " call dein#disable('xolox/vim-misc')

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
  call dein#add('kana/vim-textobj-fold')
  call dein#add('tpope/vim-repeat')
  call dein#add('tpope/vim-surround')
  call dein#add('tpope/vim-abolish')
  call dein#add('tpope/vim-speeddating')
  call dein#add('AndrewRadev/splitjoin.vim')
  call dein#add('matze/vim-move')
  call dein#add('andymass/vim-matchup')

  " Style
  call dein#add('editorconfig/editorconfig-vim')

  " Git
  call dein#add('tpope/vim-fugitive')
  call dein#add('airblade/vim-gitgutter')
  call dein#add('christoomey/vim-conflicted')

  " Auto Completion, linting, etc
  " call dein#add('w0rp/ale')
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/neco-syntax')
  call dein#add('Shougo/neco-vim')

  " Snippets
  call dein#add('SirVer/ultisnips')
  call dein#add('honza/vim-snippets')

  " tags
  call dein#disable('lyuts/vim-rtags')
  call dein#add('majutsushi/tagbar')
  call dein#add('liuchengxu/vista.vim')

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

  " Golang
  call dein#add('fatih/vim-go')
  call dein#add('deoplete-plugins/deoplete-go', {
    \ 'build': 'bash -c "make > /tmp/deoplete_go-neovim_build.log 2> /tmp/deoplete_go-neovim_build.err.log"',
    \ })
  call dein#add('b0o/quicktemplate.vim', { 'depends': 'b0o/builder.vim' })

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

  " Markdown
  call dein#add('tpope/vim-markdown')
  " call dein#add('plasticboy/vim-markdown')

  " NGINX
  call dein#add('chr4/nginx.vim')

  " Jupyter
  " call dein#add('hisaknown/jupyterkernel.vim')

  " i3/sway configuration files
  call dein#add('mboughaba/i3config.vim')
  call dein#add('aouelete/sway-vim-syntax')

  " Documentation/reference
  call dein#add('alx741/vinfo')

  " Writing, Todos, and Notetaking
  call dein#add('jceb/vim-orgmode')
  call dein#add('junegunn/goyo.vim')

  " Colors
  call dein#add('ap/vim-css-color')
  call dein#add('KabbAmine/vCoolor.vim')

  " General Utility
  call dein#add('Shougo/denite.nvim')
  call dein#add('chrisbra/Recover.vim')
  call dein#add('mattn/gist-vim')
  call dein#add('mattn/calendar-vim')
  call dein#add('tpope/vim-eunuch')
  call dein#add('Shougo/vinarise.vim')
  call dein#add('liuchengxu/vim-clap', { 'hook_post_update': 'Clap install-binary' })
  call dein#add('pechorin/any-jump.vim')
  call dein#add('inkarkat/vim-SyntaxRange')
  call dein#add('rbong/vim-buffest')
  " call dein#add('glacambre/firenvim', { 'hook_post_update': 'call firenvim#install(0)' })

  " file management
  call dein#add('preservim/nerdtree')
  call dein#add('jistr/vim-nerdtree-tabs')
  call dein#add('Xuyuanp/nerdtree-git-plugin')

  " Themes
  call dein#add('arcticicestudio/nord-vim')
  call dein#add('chriskempson/base16-vim')

  " Vim Plugin Development
  call dein#add('tpope/vim-scriptease')
  call dein#add('junegunn/vader.vim')

  " Local plugins
  call dein#local('~/.config/nvim/bundle', {}, [
    \ 'dense-analysis/ale'
    \ ])
  " \ 'b0o/jupyterkernel.vim'
  " \ 'b0o/builder.vim',
  " \ 'b0o/quicktemplate.vim',
  " \ 'b0o/betwixt.vim',

  call dein#end()
  call dein#save_state()
endif

if $UID != 0
  " Merlin is a plugin for OCaml completion
  " It is managed by opam, not dein, so we manually add it to our RTP
  let s:opamshare = substitute(system('opam config var share'),'\n$','','''')
  execute 'set runtimepath+=' . s:opamshare . '/merlin/vim'
endif
