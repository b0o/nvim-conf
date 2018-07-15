""" lh.vim
""" leaderhelper (TODO: Convert this to a plugin)

let g:leaderHelperAutoSubmit = 0

func! s:getMaps(mode, cmd)
  return split(execute(a:mode . "map " . join(a:cmd, "")), "\n")
endfunc

func! s:leaderHelper(mode, cmd)
  if len(a:cmd) == 0
    return []
  endif
  return s:getMaps(a:mode, a:cmd)
endfunc

func! s:leaderHelperExec(cmd)
  echom "exec disabled"
  return
  let l:c = a:cmd
  let l:mode = l:c[0:2]

  let l:c = l:c[3:]
  let l:lhs_end = matchend(l:c, "\\S\\+")
  let l:lhs = l:c[0:l:lhs_end]

  let l:c = l:c[l:lhs_end + 1:]
  let l:flag_end = matchend(l:c, " \\+[ \\*][ &@]")
  let l:flag = l:c[0:l:flag_end - 1]
  let l:rhs = l:c[l:flag_end:]

  let l:rhs = substitute(l:rhs, "<cr>", "\<cr>", "gi")
  let l:rhs = substitute(l:rhs, "<esc>", "\<esc>", "gi")

  try
    call execute("normal " . l:rhs)
  catch
    try
      execute "normal " . l:rhs
    catch
      echom "Error executing command " . l:rhs
    endtry
  endtry
endfunc

func! LeaderHelperPrompt(mode)
  let l:status = []
  echo ">> " . join(l:status, "")
  while 1
    let l:rawchar = getchar()
    let l:char = nr2char(l:rawchar)

    if l:char is# "\<ESC>"
      redraw! | return
    endif

    if l:char is# "\<SPACE>"
      let l:char = "<space>"
    endif

    if l:rawchar is# "\<BS>"
      let l:char = ""
      let l:status = l:status[0:-2]
      redraw! | echo ">> " . join(l:status, "")
      if len(l:status) == 0
        continue
      endif
    endif

    if l:char != ""
      let l:status += [l:char]
    endif

    if l:char is# "\<CR>"
      redraw
      call s:leaderHelperExec(l:maps[-1])
      return
    endif

    let l:maps = s:leaderHelper(a:mode, l:status)

    if g:leaderHelperAutoSubmit == 1 && len(l:maps) == 1
      if l:maps[0] == "No mapping found"
        echo l:maps[0] . ": " . join(l:status, "")
      else
        call s:leaderHelperExec(l:maps[-1])
        redraw!
      endif
      return
    endif

    " let l:maxheight = winheight(0) - 10
    let l:maxheight = 10
    redraw! | echo join(l:maps[:l:maxheight], "\n") | echo ">> " . join(l:status, "")
  endwhile
endfunc

