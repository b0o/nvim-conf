syntax enable

set title " set and update terminal title

" customize terminal title
" note: spaces must be preceded by an escaped backslash (\\)
let g:vim_titlestring    = "[%{TSServername()}]\\ %t%{TSModified()}%{TSTabs()}"
let g:vim_titlestring_hi = "\\ " . g:vim_titlestring . "\\ "

set number " show line numbers
set relativenumber " use relative line numbers (except cursor line)
set signcolumn=yes " always show sign column (column left of line number column)

set cursorline " highlight the current cursor line

set noshowmode " disable native mode display (use airline instead)
set showcmd " show keystrokes in bottom right
set laststatus=2 " Always show status line

set showmatch " highlight matching parens/brackets/etc (see also |matchtime|)

set scrolloff=5 " keep a minimum of 5 lines between cursor and top/bottom of screen

set guicursor=n-v-c:block-Cursor
set guicursor+=n-v-c:blinkon0

set list " Show whitespace
set listchars=eol:⌐,tab:⋅\ ,trail:~,extends:>,precedes:< " specify whitespace display chars

" Neovim-specific Settings
set termguicolors " enable true color mode for terminals that support it

" Fonts
set guifont=InputMono\ Nerd\ Font:h15
let g:Powerline_symbols = 'fancy'

" use g:colorscheme as the colorscheme name, defaulting to nord
" useful cases when launching an instance of vim from within a specifically
" themed terminal window via command-line arguments
if exists("g:colorscheme")
  let s:colorscheme = g:colorscheme
elseif !exists("g:colors_name") || g:colors_name == "default" || g:colors_name == "unknown"
  let s:colorscheme = "lavi"
endif

" set/reset custom colorscheme settings
function! Setcolorscheme()
  " set background=dark
  exec "set titlestring=" . g:vim_titlestring
  if exists("s:colorscheme")
    let g:airline_theme = substitute(s:colorscheme, "-", "_", "")
    try
      exec "colorscheme " . s:colorscheme
    catch
      echom "Error: Unable to set colorscheme " . s:colorscheme . "\n"
    endtry
  endif
  redraw
endfunction

" Highlight the window, for use with dirciple
function! HighlightWindow()
  exec "set titlestring=" . g:vim_titlestring_hi
  if exists("#goyo")
    hi Normal ctermfg=lightgreen guifg=#A3BE8C
  else
    hi LineNr ctermfg=black ctermbg=2 guifg=#000000 guibg=#A3BE8C
    hi CursorLineNr ctermfg=black ctermbg=lightgreen guifg=#000000 guibg=#A3BE8C
  endif
  redraw
endfunction

function! UnHighlightWindow()
  call Setcolorscheme()
endfunction

call Setcolorscheme() " Call Setcolorscheme once on init
