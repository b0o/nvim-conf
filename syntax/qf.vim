if exists('b:current_syntax')
    finish
endif

syn match qfFileName /^[^│]*/ nextgroup=qfSeparatorLeft
syn match qfSeparatorLeft /│/ contained nextgroup=qfError,qfWarning,qfInfo,qfNote,qfLineNr
syn match qfSeparatorRight '│' contained nextgroup=qfError,qfWarning,qfInfo,qfNote
syn match qfLineNr /\s*\d\+:\d\+\s*/ contained nextgroup=qfSeparatorRight
syn match qfError / E .*$/ contained
syn match qfWarning / W .*$/ contained
syn match qfInfo / I .*$/ contained
syn match qfNote / [NH] .*$/ contained

hi def link qfFileName Directory
hi def link qfSeparatorLeft NonText
hi def link qfSeparatorRight NonText
hi def link qfLineNr LineNr
hi def link qfError CocErrorSign
hi def link qfWarning CocWarningSign
hi def link qfInfo CocInfoSign
hi def link qfNote CocHintSign

let b:current_syntax = 'qf'
