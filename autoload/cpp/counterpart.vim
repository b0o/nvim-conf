" get the counterpart for a given c++ file - handles the following extensions:
"   cpp -> h
"   h -> cpp
func! cpp#counterpart#get(filepath)
  let l:ext = fnamemodify(a:filepath, ':e')
  let l:cp = ""

  if l:ext == "cpp"
    let l:cp = "h"

  elseif l:ext == "h"
    let l:cp = "cpp"

  else
    throw "Invalid c++ file extension: " . l:ext
  endif

  return fnamemodify(a:filepath, ':r') . "." . l:cp
endfunc

" edit the counterpart for a given c++ file
" Optionally pass the command to use to edit the file as the second argument,
" default: 'edit'
func! cpp#counterpart#edit(filepath, ...)
  let l:cmd = "edit"
  if len(a:000) > 0
    let l:cmd = a:000[0]
  endif
  let l:fp = cpp#counterpart#get(a:filepath)
  exec l:cmd . " " . l:fp
endfunc
