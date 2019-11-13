""" vim-airline.vim
" configuration for the plugin vim-airline/vim-airline

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_mode_map = {
    \ '__'     : '-',
    \ 'c'      : 'C',
    \ 'i'      : 'I',
    \ 'ic'     : 'I',
    \ 'ix'     : 'I',
    \ 'n'      : 'N',
    \ 'multi'  : 'M',
    \ 'ni'     : 'N',
    \ 'no'     : 'N',
    \ 'R'      : 'R',
    \ 'Rv'     : 'R',
    \ 's'      : 'S',
    \ 'S'      : 'S',
    \ ''     : 'S',
    \ 't'      : 'T',
    \ 'v'      : 'V',
    \ 'V'      : 'V',
    \ ''     : 'V',
    \ }

let g:airline_powerline_fonts   = 1
let g:airline_detect_spell      = 0
let g:airline_inactive_collapse = 0
let g:airline_exclude_preview   = 1

let s:sym = {
  \   'err':           '✖ ',
  \   'warn':          ' ',
  \   'off':           ' ',
  \   'on':            ' ',
  \   'wait':          'ﳁ ',
  \   'left_sep':      '',
  \   'left_alt_sep':  '',
  \   'right_sep':     '',
  \   'right_alt_sep': '',
  \   'branch':        '',
  \   'readonly':      '',
  \   'crypt':         '🔒',
  \   'linenr':        '☰',
  \   'maxlinenr':     '',
  \   'notexists':     'Ɇ',
  \   'whitespace':    'Ξ',
  \ }

let g:airline_left_sep           = s:sym.left_sep
let g:airline_left_alt_sep       = s:sym.left_alt_sep
let g:airline_right_sep          = s:sym.right_sep
let g:airline_right_alt_sep      = s:sym.right_alt_sep
let g:airline_symbols.branch     = "" "s:sym.branch
let g:airline_symbols.readonly   = s:sym.readonly
let g:airline_symbols.crypt      = s:sym.crypt
let g:airline_symbols.linenr     = s:sym.linenr
let g:airline_symbols.maxlinenr  = s:sym.maxlinenr
let g:airline_symbols.notexists  = "" "s:sym.notexists
let g:airline_symbols.whitespace = s:sym.whitespace

let g:airline#extensions#disable_rtp_load = 1
let g:airline_extensions = ['ale', 'tabline', 'branch', 'hunks']

let g:airline#extensions#ale#enabled      = 1
let g:airline#extensions#tabline#enabled  = 1
let g:airline#extensions#branch#enabled   = 1
let g:airline#extensions#hunks#enabled    = 1

let g:airline#extensions#ale#error_symbol      = s:sym.err
let g:airline#extensions#ale#warning_symbol    = s:sym.warn
let g:airline#extensions#ale#show_line_numbers = 0

let g:airline#extensions#tabline#exclude_preview   = 1
let g:airline#extensions#tabline#show_buffers      = 0
let g:airline#extensions#tabline#show_splits       = 0
let g:airline#extensions#tabline#show_tab_count    = 0
" let g:airline#extensions#tabline#excludes          = [g:LanguageClientPreviewBufName]
let g:airline#extensions#tabline#tab_nr_type       = 1
let g:airline#extensions#tabline#show_tab_type     = 0
let g:airline#extensions#tabline#buf_label_first   = 0
let g:airline#extensions#tabline#tab_min_count     = 2
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#overflow_marker   = ' … '
let g:airline#extensions#tabline#fnamemod          = ':t'

let g:airline#extensions#hunks#non_zero_only = 1
" let g:airline#extensions#hunks#hunk_symbols  = ['+', '~', '-']
let s:uid = expand("$UID")

function! Airline_sudo()
  if s:uid == 0
    return " "
  endif
  return ""
endfunction

function! Airline_file_no_term()
  if expand("%") == ""
    return "[New File]"
  endif
  if match(expand("%"), "term://") == 0
    return "Term"
  endif
  return fnamemodify(expand("%"), ":~:.")
endfunction

let s:languageclient_syms = [s:sym.off, s:sym.on, s:sym.wait]

let s:languageclient_state = 0
let s:languageclient_state_ft = ""
function! s:languageclient_refresh()
  if !exists("b:languageclient_state")
    let b:languageclient_state = 0
  end
  if b:languageclient_state > 0
    let l:lc_status = g:LanguageClient_serverStatus()
    if l:lc_status == 0
      let b:languageclient_state = 1
    elseif l:lc_status == 1
      let b:languageclient_state = 2
    end
    let s:languageclient_state = b:languageclient_state
  end
endfunction

" TODO: This doesn't work too well with multiple LC instances per vim instance
function! s:languageclient_fn(state, ...)
  let l:opts = {
  \   "global":    v:false,
  \   "exclusive": v:false,
  \ }
  if a:0 > 0
    let l:opts = extend(l:opts, a:1)
  end
  call s:languageclient_refresh()
  let l:state = b:languageclient_state
  if l:opts.global == v:true
    if l:opts.exclusive == v:true && (
    \    s:languageclient_state == b:languageclient_state
    \ || s:languageclient_state_ft != &ft
    \ )
      return ""
    end
    let l:state = s:languageclient_state
  end
  if a:state == l:state
    return s:languageclient_syms[a:state]
  endif
  return ""
endfunction

function! Airline_languageclient_off()
  return s:languageclient_fn(0)
endfunction
function! Airline_languageclient_on()
  return s:languageclient_fn(1)
endfunction
function! Airline_languageclient_on_elsewhere()
  return s:languageclient_fn(1, { "global": v:true, "exclusive": v:true })
endfunction
function! Airline_languageclient_wait()
  return s:languageclient_fn(2, { "global": v:true })
endfunction

function! s:hunks_fn(type, ...)
  let l:prefix = ""
  let l:suffix = ""
  if len(a:000) == 1
    let [l:prefix] = a:000
  elseif len(a:000) == 2
    let [l:prefix, l:suffix] = a:000
  end
  let l:hunks = airline#extensions#hunks#get_raw_hunks()
  let l:n = l:hunks[a:type]
  if l:n > 0
    return l:prefix . l:n . l:suffix
  end
  return ""
endfunction

function! Airline_hunks_add()
  return s:hunks_fn(0, " +", " ")
endfunction
function! Airline_hunks_modify()
  return s:hunks_fn(1, "~", " ")
endfunction
function! Airline_hunks_remove()
  return s:hunks_fn(2, "-")
endfunction

function! AirlineInit()
  let g:airline_symbols.linenr = ''
  let g:airline_symbols.maxlinenr = ''

  call airline#parts#define('sudo', {
        \ 'function': 'Airline_sudo',
        \ 'accent': 'yellow',
        \ })

  call airline#parts#define('file_no_term', {
        \ 'function': 'Airline_file_no_term',
        \ 'accent': 'bold',
        \ })

  call airline#parts#define('languageclient_off', {
        \ 'function': 'Airline_languageclient_off',
        \ })

  call airline#parts#define('languageclient_on', {
        \ 'function': 'Airline_languageclient_on',
        \ 'accent': 'blue',
        \ })

  call airline#parts#define('languageclient_on_elsewhere', {
        \ 'function': 'Airline_languageclient_on_elsewhere',
        \ 'accent': 'purple',
        \ })

  call airline#parts#define('languageclient_wait', {
        \ 'function': 'Airline_languageclient_wait',
        \ 'accent': 'yellow',
        \ })

  call airline#parts#define('hunks_add', {
        \ 'function': 'Airline_hunks_add',
        \ 'accent': 'green',
        \ })

  call airline#parts#define('hunks_modify', {
        \ 'function': 'Airline_hunks_modify',
        \ 'accent': 'yellow',
        \ })

  call airline#parts#define('hunks_remove', {
        \ 'function': 'Airline_hunks_remove',
        \ 'accent': 'red',
        \ })

  let g:airline_section_a = airline#section#create(
        \ ['mode', 'crypt', 'paste', 'iminsert'])
  let g:airline_section_b = airline#section#create(
        \ ['%{TSServername()}'])
  let g:airline_section_c = airline#section#create(
        \ ['sudo', 'file_no_term', '%m ', 'branch', 'hunks_add', 'hunks_modify', 'hunks_remove'])
  let g:airline_section_gutter = airline#section#create(
        \ ['readonly', '%='])
  let g:airline_section_x = airline#section#create(
        \ ['languageclient_on', 'languageclient_on_elsewhere', 'languageclient_wait', 'filetype'])
  let g:airline_section_y = airline#section#create(
        \ ['%{tagbar#currenttag("%s","", "s")}'])
  let g:airline_section_z = airline#section#create(
        \ ['%n ', '%3p%%%4l/%L:%-3v '])

  let g:airline#extension#default#layout = [
        \ [ 'a', 'b', 'c', ''],
        \ [ 'x', 'y', 'z', 'warning', 'error' ]
        \ ]
endfunction

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

function! Airline_LanguageClient_state_change(state)
  let b:languageclient_state = a:state
  let s:languageclient_state_ft = &ft
endfunction

augroup Airline_config
  autocmd!
  autocmd User LanguageClientStarted call Airline_LanguageClient_state_change(1)
  autocmd User LanguageClientStopped call Airline_LanguageClient_state_change(0)
  autocmd User AirlineAfterInit call AirlineInit()
augroup END
