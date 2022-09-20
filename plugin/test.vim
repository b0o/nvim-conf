fu! EchonHL(hlgroup, ...)
    exe ':echohl ' . a:hlgroup
    echon join(a:000)
endfu

fu! GetChar(...)
    if (a:0 == 1)
        echon a:1
    elseif (a:0 == 2)
        call EchonHL(a:1, a:2)
        echohl None
    end
    let c = getchar()
    if (c =~ '^\d\+$')
        let c = nr2char(c)
    end
    return c
endfu
let s:quick_cmd_map = {
\ 'w':       ":w\<CR>",
\ "\<C-F>":  ':Files',
\ "\<A-;>":  'q:":P',
\}

function! s:quick_cmd ()
    " if sneak#is_sneaking()
    "     return ":call sneak#rpt('', 0)\<CR>"
    " end
    echo ''
    let char = GetChar('Info', ':')
    let qmap = get(s:quick_cmd_map, char, ':' . char)
    if !empty(qmap)
        return qmap
    else
        return ':' . char
    end
endfunc

nmap   <expr>   ;    <SID>quick_cmd()

imap ;w <Esc>;w
