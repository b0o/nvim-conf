if exists("b:current_syntax")
  finish
endif

let s:cpo_sav = &cpo
let s:ls  = &ls
let s:ei_sav = &eventignore
set cpo&vim

syn keyword False 0
syn keyword True 1
hi True guifg=lightgreen
hi False guifg=lightred
syn match Term /[a-z]/
hi Term guifg=lightblue
syn match Connective /&&/
syn match Connective /\(&&\)/
syn match Connective /\(&&\|||\)/
syn match Connective /\(&&\|||\|\\\\\)/
syn match Not /!/
syn match Connective /\(&&\|||\|\\\\\|!&\)/
syn match Group /[()]/
hi Connective guifg=pink
hi Not guifg=orange
hi Group guifg=darkgray

let &cpo = s:cpo_sav
unlet! s:cpo_sav
let &ls=s:ls
let &eventignore=s:ei_sav
