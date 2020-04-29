""" gitcommit/mappings.vim
" mappings for gitcommit files

" navigate between important sections of a gitcommit file
function! s:navigateFile(dir, coarse)
  let l:i = line('.') + a:dir
  let l:dest = 0

  let l:prevSynName = synIDattr(synID(line('.'), 1, 1), 'name')
  let l:prevMatch = 0
  while (a:dir == 1 && l:i < line('$')) || (a:dir == -1 && l:i > 0)
    let l:synName = synIDattr(synID(l:i, 1, 1), 'name')

    if a:dir == -1
      if l:synName != l:prevSynName && l:prevMatch == 1
        let l:dest = l:i + 1
        break
      endif
    endif

    if l:synName != l:prevSynName &&
      \ ( a:coarse == 1 && (
      \      l:synName ==# 'gitcommitSelected'
      \   || ( l:synName ==# 'diffFile' && synIDattr(synID(l:i - 1, 1, 1), 'name') ==# 'gitcommitComment' )
      \ )
      \ || ( a:coarse == 0 && (
      \      l:synName ==# 'diffLine'
      \   || ( l:synName ==# 'diffFile' && synIDattr(synID(l:i - 1, 1, 1), 'name') ==# 'gitcommitComment' )
      \   || l:synName ==# 'gitcommitUntracked'
      \   || l:synName ==# 'gitcommitDiscarded'
      \   || l:synName ==# 'gitcommitSelected'
      \   || l:synName ==# 'gitcommitUnmerged'
      \   || l:synName ==# 'gitcommitNoChanges'
      \ ) ) )
        if a:dir == 1
          let l:dest = l:i
          break
        endif
        let l:prevMatch = 1
    endif
    let l:i += a:dir
    let l:prevSynName = l:synName
  endwhile

  if l:dest == 0
    if a:dir == 1
      normal! G
    else
       normal! gg
    endif
  else
    call cursor(l:dest, 1)
  endif
  normal! zt
endfunction

nnoremap <silent> <buffer> ]]      :call <SID>navigateFile( 1, 0)<CR>
nnoremap <silent> <buffer> [[      :call <SID>navigateFile(-1, 0)<CR>

nnoremap <silent> <buffer> }       :call <SID>navigateFile( 1, 1)<CR>
nnoremap <silent> <buffer> {       :call <SID>navigateFile(-1, 1)<CR>

nnoremap <silent> <buffer> <Tab>   :call <SID>navigateFile( 1, 0)<CR>
nnoremap <silent> <buffer> <S-Tab> :call <SID>navigateFile(-1, 0)<CR>
