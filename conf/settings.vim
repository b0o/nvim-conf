""" settings.vim
""" general vanilla vim settings

" Enable all filetype detection modes
filetype on
filetype plugin on
filetype indent on

" spelling
set spell
set spellfile=$cfgd/spellfile.utf-8.add

" search
set ignorecase " ignore case when searching
set smartcase " don't ignore case if user types an uppercase letter
set hlsearch " keep matches highlighted after searching
set incsearch " show matches while typing
set magic " change set of special search characters
set inccommand=nosplit " when typing a :s/foo/bar/g command, show live preview
set shortmess-=S " show search count message

" indentation
set tabstop=2

" history
set undofile " save undo history to a file
set undodir=$cache/undo " set undo directory

" backup
set backup
set backupdir=$data/backup

" timing
" set notimeout " don't timeout when entering multi-keystroke mappings
set timeoutlen=1000 " used by vim-which-key as timeout before showing guide popup

" every 100ms nothing is typed, trigger CursorHold event
" (which is used by plugins for re-rendering themselves)
" TODO: this causes register selection via "<register> to be cleared before
" being able to enter the next command
set updatetime=100
set matchtime=2 " show matching parens/brackets for 200ms

" clipboard
set clipboard+=unnamedplus " Enable yanking between vim sessions and system

if exists('$WAYLAND_DISPLAY')
  " Wayland clipboard provider that strips carriage returns (GTK3 issue).
  " This is needed because currently there's an issue where GTK3 applications on
  " Wayland contain carriage returns at the end of the lines (this is a root
  " issue that needs to be fixed).
  " See also:
  " - https://github.com/neovim/neovim/issues/10223#issuecomment-521952122
  " - https://github.com/neovim/neovim/issues/10223
  " - https://bugzilla.mozilla.org/show_bug.cgi?id=1547595
  " - https://gitlab.gnome.org/GNOME/gtk/-/issues/2307
  let g:clipboard = {
        \   'name': 'wayland-strip-carriage',
        \   'copy': {
        \      '+': 'wl-copy --foreground --type text/plain',
        \      '*': 'wl-copy --foreground --type text/plain --primary',
        \    },
        \   'paste': {
        \      '+': {-> systemlist('wl-paste | sed -e "s/\r$//"')},
        \      '*': {-> systemlist('wl-paste --primary | sed -e "s/\r$//"')},
        \   },
        \   'cache_enabled': 1,
        \ }
endif

" buffers/tabs
set switchbuf=usetab,newtab

" splitting behavior
set splitright " default vertical splits to open on right
set splitbelow " default horizontal splits to open on bottom

" insert mode behavior
" set backspace=indent,eol,start " allow backspacing over indents, eols, and start of lines
" set breakindent " see |'breakindent'|
" set textwidth=100 " max line length before automatically hard-wrapping
" set formatoptions+=c " auto-hard-wrap comments

" command mode behavior
set wildchar=<Tab>

" folding
set foldmethod=marker
set foldlevel=1

" misc
set modeline " always parse modelines when loading files

function! ConcealSetup()
  if !has('conceal')
    return
  endif
  set conceallevel=2
  set concealcursor=n
  nnoremap <silent> <leader>cl :call ToggleConcealLevel()<cr>
  nnoremap <silent> <leader>cc :call ToggleConcealCursor()<cr>
endfunction

" conceal/concealcursor
call ConcealSetup()

let mapleader = "\<space>"
let maplocalleader = ','
