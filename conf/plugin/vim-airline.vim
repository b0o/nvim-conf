""" vim-airline.vim
" configuration for the plugin vim-airline/vim-airline

let g:airline_powerline_fonts   = 1
let g:airline_detect_spell      = 0
let g:airline_inactive_collapse = 0

let g:airline_extensions = []

function! FileNoTerm()
  if expand("%") == ""
    return "[New File]"
  endif
  if match(expand("%"), "term://") == 0
    return "Term"
  endif
  return fnamemodify(expand("%"), ":~:.")
endfunction

function! AirlineInit()
  let g:airline_symbols.linenr = ''
  let g:airline_symbols.maxlinenr = ''

  call airline#parts#define('fileNoTerm', {
        \ 'function': 'FileNoTerm',
        \ 'accent': 'bold',
        \ })

  let g:airline_section_a = airline#section#create(
        \ ['mode', 'crypt', 'paste', 'iminsert'])
  let g:airline_section_b = airline#section#create(
        \ ['%{ShortServername()}'])
  let g:airline_section_c = airline#section#create(
        \ ['fileNoTerm', '%m'])
  let g:airline_section_gutter = airline#section#create(
        \ ['readonly', '%='])
  let g:airline_section_x = airline#section#create(
        \ ['filetype'])
  let g:airline_section_y = airline#section#create(
        \ ['%{tagbar#currenttag("%s","", "s")}'])
  let g:airline_section_z = airline#section#create(
        \ ['%n ', '%3p%%%4l/%L:%-3v '])

  let g:airline#extension#default#layout = [
        \ [ 'a', 'b', 'c' ],
        \ [ 'x', 'y', 'z', 'warning', 'error' ]
        \ ]

endfunction
autocmd User AirlineAfterInit call AirlineInit()

let g:airline#extensions#default#section_truncate_width = {
      \ 'a':       10,
      \ 'b':       10,
      \ 'c':       10,
      \ 'x':       50,
      \ 'y':       50,
      \ 'z':       50,
      \ 'warning': 80,
      \ 'error':   80,
      \ }
