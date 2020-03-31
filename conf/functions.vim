""" functions.vim
""" function definitions

"" dein helper functions
function! PluginClean()
  call map(dein#check_clean(), "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endfunction
command! PluginClean call PluginClean()

function! PluginInstall()
  call PluginClean()
  call dein#install()
endfunction
command! PluginInstall call PluginInstall()

function! PluginUpdate()
  call PluginClean()
  call dein#update()
endfunction
command! PluginUpdate call PluginUpdate()

function! s:plugin_mgr_headless_init()
  let g:dein#install_progress_type = 'echo'
  let g:dein#install_message_type = 'echo'
endfunction

function! PluginCleanHeadless()
  call s:plugin_mgr_headless_init()
  try
    call PluginClean()
    echo "\n"
  catch
    echo "an error was encountered"
    cquit
  endtry
endfunction

function! PluginInstallHeadless()
  call s:plugin_mgr_headless_init()
  try
    call dein#install()
    echo "\n"
  catch
    echo "an error was encountered"
    cquit
  endtry
endfunction

function! PluginUpdateHeadless()
  call s:plugin_mgr_headless_init()
  try
    call dein#update()
    echo "\n"
  catch
    echo "an error was encountered"
    cquit
  endtry
endfunction

" paste register without overwriting with the original selection
let s:restore_reg = ""
function! PasteRestore()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
function! RestoreRegister()
  let @" = s:restore_reg
  if &clipboard == "unnamed"
    let @* = s:restore_reg
  endif
  return ''
endfunction

" function to be called upon entering a terminal buffer
func! TermEnter(insert)
  setlocal nospell
  if a:insert == 1
    startinsert
  else
    stopinsert
  endif
endfunc

" open a terminal window, where 'count' is number of rows and 'insert' specifies whether term
" should start in insert or normal mode
function! OpenTerm(args, count, insert)
  let params = split(a:args)

  let cmd = 'new'
  let cmd = a:count ? a:count . cmd : cmd
  exe cmd

  exe 'terminal' a:args
  call TermEnter(a:insert)
endfunction
command! -count -nargs=* Term  call OpenTerm(<q-args>, <count>, 1)
command! -count -nargs=* NTerm call OpenTerm(<q-args>, <count>, 0)

" open help in full-window view. If current buffer is not empty, open a new tab
function! HelpTab(...)
  let cmd = 'tab help %s'
  if bufname('%') == "" && getline(1) == ""
    let cmd = 'help %s | only'
  endif
  exec printf(cmd, join(a:000, ' '))
endfunction
command! -nargs=* -complete=help H call HelpTab(<q-args>)

" Open or create a tab at the given tab index
function! Tabnm(n)
  try
    exec "tabn " . a:n
  catch
    $tabnew
  endtry
endfunction

" close current window:
"   | active window is loclist  -> lclose
"   | active window is quickfix -> cclose
"   | _ -> lclose + cclose + q
function! CloseWin()
  let l:win = getwininfo(win_getid())[0]
  let l:ret = 0
  if l:win.loclist == 1
    lclose
    let l:ret = 1
  endif
  if l:win.quickfix == 1
    cclose
    let l:ret = 1
  endif
  if l:ret == 1
    return
  endif
  lclose
  cclose
  let l:curwin = nvim_get_current_win()
  confirm q
  let l:tabwins = nvim_tabpage_list_wins(0)
  for l:w in l:tabwins
    let l:wis = getwininfo(l:w)
    if len(l:wis) == 0
      continue
    endif
    let l:wi = l:wis[0]
    if has_key(l:wi.variables, "lc_hover_for_win") && l:wi.variables.lc_hover_for_win == l:curwin
      call nvim_win_close(l:w, 0)
      break
    endif
  endfor
endfunction
command! CloseWin call CloseWin()

" reload vim configuration
if !exists('*ReloadConfig')
  function! ReloadConfig()
    echom 'Reload configuration...'
    source $cfg
  endfunction
  command! ReloadConfig call ReloadConfig()
endif

" interleave two same-sized contiguous blocks
" https://vi.stackexchange.com/questions/4575/merge-blocks-by-interleaving-lines
function! Interleave()
  " retrieve last selected area position and size
  let start = line(".")
  execute "normal! gvo\<esc>"
  let end = line(".")
  let [start, end] = sort([start, end], "n")
  let size = (end - start + 1) / 2
  " and interleave!
  for i in range(size - 1)
    execute (start + size + i). 'm' .(start + 2 * i)
  endfor
endfunction

" toggle conceallevel
function! ToggleConcealLevel()
  if !has('conceal')
    return
  endif
  if &conceallevel
    setlocal conceallevel=0
  else
    setlocal conceallevel=2
  endif
  set conceallevel
endfunction

" toggle concealcursor
function! ToggleConcealCursor()
  if !has('conceal')
    return
  endif
  if &concealcursor != ""
    set concealcursor=
  else
    set concealcursor=n
  endif
  set concealcursor
endfunction

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
  let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
  let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  call append(line("$"), l:modeline)
endfunction

" titlestring servername helper
function! TSServername()
  let n = matchstr(v:servername, '\c\(\/.*\/\)\zs\(.*\)\ze')
  return substitute(n, ".*__", "", "")
endfunction

" titlestring modified helper
function! TSModified()
  return &modified ? "[*]" : ""
endfunction

" titlestring tabs helper
function! TSTabs()
  let l:tabs = split(execute("silent tabs"), "\n")
  call filter(l:tabs, {idx, val -> match(val, "^Tab page \\d*$") == 0})
  if len(l:tabs) > 1
    return "[+" . (len(l:tabs) - 1) . "]"
  endif
  return ""
endfunction

" Jump to first scratch window visible in current tab, or create it.
" This is useful to accumulate results from successive operations.
" Global function that can be called from other scripts.
function! GoScratch()
  let done = 0
  for i in range(1, winnr('$'))
    execute i . 'wincmd w'
    if &buftype == 'nofile'
      let done = 1
      break
    endif
  endfor
  if !done
    new
    setlocal buftype=nofile bufhidden=hide noswapfile
  endif
endfunction

" Append match, with line number as prefix if wanted.
function! s:Matcher(hits, match, linenums, subline)
  if !empty(a:match)
    let prefix = a:linenums ? printf('%3d  ', a:subline) : ''
    call add(a:hits, prefix . a:match)
  endif
  return a:match
endfunction

" Append line numbers for lines in match to given list.
function! s:MatchLineNums(numlist, match)
  let newlinecount = len(substitute(a:match, '\n\@!.', '', 'g'))
  if a:match =~ "\n$"
    let newlinecount -= 1  " do not copy next line after newline
  endif
  call extend(a:numlist, range(line('.'), line('.') + newlinecount))
  return a:match
endfunction

" Return list of matches for given pattern in given range.
" If 'wholelines' is 1, whole lines containing a match are returned.
" This works with multiline matches.
" Work on a copy of buffer so unforeseen problems don't change it.
" Global function that can be called from other scripts.
function! GetMatches(line1, line2, pattern, wholelines, linenums)
  let savelz = &lazyredraw
  set lazyredraw
  let lines = getline(1, line('$'))
  new
  setlocal buftype=nofile bufhidden=delete noswapfile
  silent put =lines
  1d
  let hits = []
  let sub = a:line1 . ',' . a:line2 . 's/' . escape(a:pattern, '/')
  if a:wholelines
    let numlist = []  " numbers of lines containing a match
    let rep = '/\=s:MatchLineNums(numlist, submatch(0))/e'
  else
    let rep = '/\=s:Matcher(hits, submatch(0), a:linenums, line("."))/e'
  endif
  silent execute sub . rep . (&gdefault ? '' : 'g')
  close
  if a:wholelines
    let last = 0  " number of last copied line, to skip duplicates
    for lnum in numlist
      if lnum > last
        let last = lnum
        let prefix = a:linenums ? printf('%3d  ', lnum) : ''
        call add(hits, prefix . getline(lnum))
      endif
    endfor
  endif
  let &lazyredraw = savelz
  return hits
endfunction

" Copy search matches to a register or a scratch buffer.
" If 'wholelines' is 1, whole lines containing a match are returned.
" Works with multiline matches. Works with a range (default is whole file).
" Search pattern is given in argument, or is the last-used search pattern.
function! CopyMatches(bang, line1, line2, args, wholelines)
  let l = matchlist(a:args, '^\%(\([a-zA-Z"*+-]\)\%($\|\s\+\)\)\?\(.*\)')
  let reg = empty(l[1]) ? '+' : l[1]
  let pattern = empty(l[2]) ? @/ : l[2]
  let hits = GetMatches(a:line1, a:line2, pattern, a:wholelines, a:bang)
  let msg = 'No non-empty matches'
  if !empty(hits)
    if reg == '-'
      call GoScratch()
      normal! G0m'
      silent put =hits
      " Jump to first line of hits and scroll to middle.
      ''+1normal! zz
    else
      execute 'let @' . reg . ' = join(hits, "\n") . "\n"'
    endif
    let msg = 'Number of matches: ' . len(hits)
  endif
  redraw  " so message is seen
  echo msg
endfunction
command! -bang -nargs=? -range=% CopyMatches call CopyMatches(<bang>0, <line1>, <line2>, <q-args>, 0)
command! -bang -nargs=? -range=% CopyLines call CopyMatches(<bang>0, <line1>, <line2>, <q-args>, 1)

" Get Buffer info as JSON (useful for external scripts utilizing neovim-remote)
func! BufinfoJSON()
  func! s:filterFuncrefs(i, elem)
    return type(a:elem) != v:t_func
  endfunc
  let l:bufs = getbufinfo()
  let l:i = 0
  for l:buf in l:bufs
    call filter(l:buf.variables, function('s:filterFuncrefs'))
    let l:bufs[l:i].variables = l:buf.variables
    let l:i += 1
  endfor
  return json_encode(l:bufs)
endfunc

" open a file in a new vim instance
func! LaunchVimInstance(...)
  let l:paths = join(a:000, " ")
  " exec "silent! !nohup st -x st.nvim -c st_EDITOR zsh -c 'cd $HOME;. $HOME/.zshrc;$HOME/bin/nvim " . l:paths . "' >/dev/null 2>&1 &"
  exec "silent! !swaymsg exec \"alacritty -e zsh -c 'cd $HOME;. $HOME/.zshrc;$HOME/bin/nvim " . l:paths . "'\""
endfunc
command! -count -nargs=* LaunchVimInstance  call LaunchVimInstance(<q-args>)

" convert the current tab to a new vim instance
func! TabToNewWindow()
  let l:quit = 0
  let l:path = expand("%:p")
  if l:path == ""
    echom "No file in buffer"
    return
  endif
  if &modified
    echom 'Write file before moving to new window?'
    echohl ErrorMsg | echom 'Unsaved changes will be lost!' | echohl None
    while 1
        let choice = inputlist(['1: Yes', '2: No', '3: Cancel'])
        if choice > 3
            redraw!
            echohl WarningMsg | echo 'Please enter a number between 1 and 3' | echohl None
            continue
        elseif choice == 0 || choice == 3
            return
        elseif choice == 1
            write
        endif
        break
    endwhile
  endif
  try
    confirm pclose!
    confirm close!
  catch
    echom 'This is the last window. Quit vim after opening new window?'
    while 1
        let choice = inputlist(['1: Yes', '2: No', '3: Cancel'])
        if choice > 3
            redraw!
            echohl WarningMsg | echo 'Please enter a number between 1 and 3' | echohl None
            continue
        elseif choice == 0 || choice == 3
            return
        elseif choice == 1
          let l:quit = 1
        endif
        confirm enew!
        break
    endwhile
  endtry

  call LaunchVimInstance(l:path)
  if l:quit == 1
    confirm quit!
  endif
endfunc
