""" settings.vim
""" general vanilla vim settings

" Enable all filetype detection modes
filetype on
filetype plugin on
filetype indent on

" spelling
set spell
set spellfile=~/.spellfile.vim.utf-8.add

" search
set ignorecase " ignore case when searching
set smartcase " don't ignore case if user types an uppercase letter
set hlsearch " keep matches highlighted after searching
set incsearch " show matches while typing
set magic " change set of special search characters
set inccommand=nosplit " when typing a :s/foo/bar/g command, show live preview

" indentation
set tabstop=2

" history
set undofile " save undo history to a file
set undodir=~/.cache/nvim/undo " set undo directory

" timing
set notimeout " don't timeout when entering multi-keystroke mappings
" every 100ms nothing is typed, trigger CursorHold event
" (which is used by plugins for re-rendering themselves)
set updatetime=100
set matchtime=2 " show matching parens/brackets for 200ms

" clipboard
set clipboard+=unnamedplus " Enable yanking between vim sessions and system

" splitting behavior
set splitright " default vertical splits to open on right
set splitbelow " default horizontal splits to open on bottom

" insert mode behavior
set backspace=indent,eol,start " allow backspacing over indents, eols, and start of lines
set breakindent " see |'breakindent'|
set textwidth=100 " max line length before automatically hard-wrapping
set formatoptions+=c " auto-hard-wrap comments

" command mode behavior
set wildchar=<Tab>
set wildmode=list:longest,list:full

" misc
set modeline " always parse modelines when loading files
set nofoldenable " disable folding by default

if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

let mapleader = "\<space>"
let maplocalleader = "\<M-space>"
