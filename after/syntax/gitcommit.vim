syn match gitcommitOverflowWarn ".*\%<70v."  contained containedin=gitcommitFirstLine nextgroup=gitcommitOverflow     contains=@Spell
syn match gitcommitSummary      "^.*\%<51v." contained containedin=gitcommitFirstLine nextgroup=gitcommitOverflowWarn contains=@Spell
hi link gitcommitOverflowWarn SpecialChar
hi link gitcommitOverflow     Comment
