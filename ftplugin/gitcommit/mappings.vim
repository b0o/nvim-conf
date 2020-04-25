" mappings for gitcommit files

" navigate between important sections of a gitcommit file
function! s:navigateFile(dir)
  let l:flags = 'sW'
  if a:dir == -1
    let l:flags .= 'b'
  endif
  if search('^\(# Please enter the commit message for your changes. Lines starting\)\|\(diff --git\)', l:flags) == 0
    if a:dir == 1
      normal! G
    else
       normal! gg
    endif
  else
     normal! zt
  endif
endfunction

nnoremap <silent> <buffer> ]]      :call <SID>navigateFile(1)<CR>
nnoremap <silent> <buffer> [[      :call <SID>navigateFile(-1)<CR>

nnoremap <silent> <buffer> <Tab>   :call <SID>navigateFile(1)<CR>
nnoremap <silent> <buffer> <S-Tab> :call <SID>navigateFile(-1)<CR>
