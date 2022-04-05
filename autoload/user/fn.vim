" paste register without overwriting with the original selection
let g:restore_reg = ''
function! user#fn#pasteRestore()
  let g:restore_reg = @"
  return "p@=user#fn#restoreRegister()\<cr>"
endfunction
function! user#fn#restoreRegister()
  let @" = g:restore_reg
  if &clipboard ==# 'unnamed'
    let @* = g:restore_reg
  elseif &clipboard ==# 'unnamedplus'
    let @+ = g:restore_reg
  endif
  return ''
endfunction

" function to be called upon entering a terminal buffer
function! user#fn#termEnter(insert)
  setlocal nospell
  if get(g:, 'termenter_disable', 0) == 1
    return
  end
  if a:insert == 1
    startinsert
  else
    stopinsert
  endif
endfunction

" open a terminal window, where 'count' is number of rows and 'insert' specifies whether term
" should start in insert or normal mode
function! user#fn#openTerm(args, count, insert, bang)
  let params = split(a:args)
  let cmd = a:bang ? 'tabnew' : 'new'
  let cmd = a:count ? a:count . cmd : cmd
  exe cmd
  exe 'terminal' a:args
  call user#fn#termEnter(a:insert)
endfunction

" Run one command if the current tabpage is empty, otherwise run a different
function! user#fn#tabcmd(if_not_empty, if_empty, ...)
  let l:cmd = a:if_not_empty
  if len(tabpagebuflist()) == 1 && bufname('%') ==# '' && getline(1) ==# ''
    let l:cmd = a:if_empty
  endif
  exec printf(cmd, join(a:000, ' '))
endfunction

" Open or create a tab at the given tab index
function! user#fn#tabnm(n)
  try
    exec 'tabn ' . a:n
  catch
    $tabnew
  endtry
endfunction

function! user#fn#closeBufWins(bufid)
  for l:w in win_findbuf(a:bufid)
    let l:cfg = nvim_win_get_config(l:w)
    " XXX: don't close floating wins
    if has_key(l:cfg, 'relative') && l:cfg.relative !=# ''
      continue
    endif
    call nvim_win_close(l:w, 0)
  endfor
endfunction

" close current window:
"   | active window is loclist  -> lclose
"   | active window is quickfix -> cclose
"   | _ -> lclose + cclose + q
function! user#fn#closeWin()
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
    if has_key(l:wi.variables, 'lc_hover_for_win') && l:wi.variables.lc_hover_for_win == l:curwin
      call nvim_win_close(l:w, 0)
      break
    endif
  endfor
endfunction

" reload vim configuration
if !exists('*ReloadConfig')
  function! user#fn#reloadConfig()
    echom 'Reload configuration...'
    source $nvim_cfg
  endfunction
endif

function! user#fn#reloadConfigFile(bang, file)
  let l:f = expand('%:p')
  if len(a:file) > 0
    " simplify and strip any leading . / .. from path
    let l:f = substitute(simplify(a:file), '^\(\.\{1,2}\|\/\)*\/', '', '')
    " resolve path relative to configuration directory
  endif

  " let l:loaded = split(execute("scriptnames"), "\n"))
  let l:loaded = map(split(execute('scriptnames'), "\n"), { _, v -> resolve(expand(split(v, " ")[1])) })

  echom 'l:f "' . l:f . '"...' . '(bang: ' . a:bang . ')'

  for l:rp in map(split(&runtimepath, ','), { _, v -> resolve(expand(v)) })
    let l:f = resolve(l:rp . '/' . l:f)
    if index(l:loaded, l:f) >= 0
      echom 'found: ' . l:f
    endif
  endfor


  " echom 'Reload configuration file "' . l:f . '"...' . '(bang: ' . a:bang . ')'
  " exec 'runtime ' . l:f
  " source $cfg
endfunction

" interleave two same-sized contiguous blocks
" https://vi.stackexchange.com/questions/4575/merge-blocks-by-interleaving-lines
function! user#fn#interleave()
  " retrieve last selected area position and size
  let start = line('.')
  execute "normal! gvo\<esc>"
  let end = line('.')
  let [start, end] = sort([start, end], 'n')
  let size = (end - start + 1) / 2
  " and interleave!
  for i in range(size - 1)
    execute (start + size + i). 'm' .(start + 2 * i)
  endfor
endfunction

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! user#fn#appendModeline()
  let l:modeline = printf(' vim: set ts=%d sw=%d tw=%d %set :',
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
  let l:modeline = substitute(&commentstring, '%s', l:modeline, '')
  call append(line('$'), l:modeline)
endfunction

" Jump to first scratch window visible in current tab, or create it.
" This is useful to accumulate results from successive operations.
" Global function that can be called from other scripts.
function! user#fn#goScratch()
  let done = 0
  for i in range(1, winnr('$'))
    execute i . 'wincmd w'
    if &buftype ==? 'nofile'
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
function! s:matcher(hits, match, linenums, subline)
  if !empty(a:match)
    let prefix = a:linenums ? printf('%3d  ', a:subline) : ''
    call add(a:hits, prefix . a:match)
  endif
  return a:match
endfunction

" Append line numbers for lines in match to given list.
function! s:matchLineNums(numlist, match)
  let newlinecount = len(substitute(a:match, '\n\@!.', '', 'g'))
  if a:match =~# "\n$"
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
function! user#fn#getMatches(line1, line2, pattern, wholelines, linenums)
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
    let rep = '/\=s:matchLineNums(numlist, submatch(0))/e'
  else
    let rep = '/\=s:matcher(hits, submatch(0), a:linenums, line("."))/e'
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
function! user#fn#copyMatches(bang, line1, line2, args, wholelines)
  let l = matchlist(a:args, '^\%(\([a-zA-Z"*+-]\)\%($\|\s\+\)\)\?\(.*\)')
  let reg = empty(l[1]) ? '+' : l[1]
  let pattern = empty(l[2]) ? @/ : l[2]
  let hits = user#fn#getMatches(a:line1, a:line2, pattern, a:wholelines, a:bang)
  let msg = 'No non-empty matches'
  if !empty(hits)
    if reg ==# '-'
      call user#fn#goScratch()
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

" Get Buffer info as JSON (useful for external scripts utilizing neovim-remote)
function! user#fn#bufinfoJSON()
  function! s:filterFuncrefs(i, elem)
    return type(a:elem) != v:t_func
  endfunction
  let l:bufs = getbufinfo()
  let l:i = 0
  for l:buf in l:bufs
    call filter(l:buf.variables, function('s:filterFuncrefs'))
    let l:bufs[l:i].variables = l:buf.variables
    let l:i += 1
  endfor
  return json_encode(l:bufs)
endfunction

" open a file in a new vim instance
function! user#fn#launchVimInstance(...)
  let l:paths = join(a:000, ' ')
  exec 'silent! !$TERMINAL -e /usr/bin/env nvim ' . l:paths
endfunction

" move the current window to a new terminal instance
function! user#fn#windowToNewTerminal()
  let l:quit = 0
  let l:path = expand('%:p')
  if l:path ==# ''
    echom 'No file in buffer'
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
  call user#fn#launchVimInstance(l:path)
  if l:quit == 1
    confirm quit!
  endif
endfunction

function! s:split_cmdline(cmdline, cmdpos)
  let l:res = [
    \   (' ' . a:cmdline)[:a:cmdpos - 1][1:],
    \   (' ' . a:cmdline)[a:cmdpos - 1:][1:]
    \ ]
  return l:res
endfunction

" emacs-style word-wise movement/deletion in command-line mode
function! user#fn#cmdlineMoveWord(dir, del)
  let l:cmdline = getcmdline()
  let l:cmdpos = getcmdpos()
  let l:pat = '^\s*\W*\S\{-}\($\|\w\@<=\([^a-zA-Z0-9]\|\s\|\>\)\@<=\)'
  if a:dir == 1
    let l:cl = s:split_cmdline(cmdline, cmdpos)
    let l:cmdline_r_post = substitute(l:cl[1], l:pat, '', '')
    if a:del == 1
      let l:cmdline_new = l:cl[0] . l:cmdline_r_post
      return l:cmdline_new
    else
      let l:cmdlen_r = len(l:cl[1])
      let l:cmdlen_r_post = len(l:cmdline_r_post)
      let l:cmdlen_r_diff = l:cmdlen_r - l:cmdlen_r_post
      let l:newcmdpos = l:cmdpos + l:cmdlen_r_diff
      call setcmdpos(l:newcmdpos)
      return l:cmdline
    endif
  elseif a:dir == -1
    let l:cmdline_rev = join(reverse(split(l:cmdline, '.\@=')), '')
    let l:cmdpos_rev = len(l:cmdline) - l:cmdpos + 2
    let l:cl_rev = s:split_cmdline(cmdline_rev, cmdpos_rev)
    let l:cmdline_rev_r_post = substitute(l:cl_rev[1], l:pat, '', '')
    let l:cmdlen_rev_r = len(l:cl_rev[1])
    let l:cmdlen_rev_r_post = len(l:cmdline_rev_r_post)
    let l:cmdlen_rev_r_diff = l:cmdlen_rev_r - l:cmdlen_rev_r_post
    let l:newcmdpos = l:cmdpos - l:cmdlen_rev_r_diff
    call setcmdpos(l:newcmdpos)
    if a:del == 1
      let l:cmdline_rev_new = l:cl_rev[0] . l:cmdline_rev_r_post
      let l:cmdline_new = join(reverse(split(l:cmdline_rev_new, '.\@=')), '')
      return l:cmdline_new
    else
      return l:cmdline
    endif
  endif
  throw 'invalid direction ' . a:dir
endfunction

function! user#fn#manSectionMove(direction, mode, count)
  norm! m'
  if a:mode ==# 'v'
    norm! gv
  endif
  let i = 0
  while i < a:count
    let i += 1
    " saving current position
    let line = line('.')
    let col  = col('.')
    let pos = search('^\a\+', 'W'.a:direction)
    " if there are no more matches, return to last position
    if pos == 0
      call cursor(line, col)
      return
    endif
  endwhile
endfunction
