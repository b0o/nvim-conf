if exists("b:current_syntax")
  finish
endif

syn case match

syn keyword     goDirective         package import
syn keyword     goDeclaration       var const

hi def link     goDirective         Statement
hi def link     goDeclaration       Keyword

" Keywords within functions
syn keyword     goStatement         defer go goto return break continue fallthrough
syn keyword     goConditional       if else switch select
syn keyword     goLabel             case default
syn keyword     goRepeat            for range

hi def link     goStatement         Statement
hi def link     goConditional       Conditional
hi def link     goLabel             Label
hi def link     goRepeat            Repeat

" Predefined types
syn keyword     goType              chan map bool string error
syn keyword     goSignedInts        int int8 int16 int32 int64 rune
syn keyword     goUnsignedInts      byte uint uint8 uint16 uint32 uint64 uintptr
syn keyword     goFloats            float32 float64
syn keyword     goComplexes         complex64 complex128

hi def link     goType              Type
hi def link     goSignedInts        Type
hi def link     goUnsignedInts      Type
hi def link     goFloats            Type
hi def link     goComplexes         Type


" Predefined functions and values
syn match       goBuiltins                 /\<\v(append|cap|close|complex|copy|delete|imag|len)\ze\(/
syn match       goBuiltins                 /\<\v(make|new|panic|print|println|real|recover)\ze\(/
syn keyword     goBoolean                  true false
syn keyword     goPredefinedIdentifiers    nil iota

hi def link     goBuiltins                 Keyword
hi def link     goBoolean                  Boolean
hi def link     goPredefinedIdentifiers    goBoolean

" Comments; their contents
syn keyword     goTodo              contained TODO FIXME XXX BUG
syn cluster     goCommentGroup      contains=goTodo
syn region      goComment           start="/\*" end="\*/" contains=@goCommentGroup,@Spell
syn region      goComment           start="//" end="$" contains=goGenerate,@goCommentGroup,@Spell

hi def link     goComment           Comment
hi def link     goTodo              Todo

" Go escapes
syn match       goEscapeOctal       display contained "\\[0-7]\{3}"
syn match       goEscapeC           display contained +\\[abfnrtv\\'"]+
syn match       goEscapeX           display contained "\\x\x\{2}"
syn match       goEscapeU           display contained "\\u\x\{4}"
syn match       goEscapeBigU        display contained "\\U\x\{8}"
syn match       goEscapeError       display contained +\\[^0-7xuUabfnrtv\\'"]+

hi def link     goEscapeOctal       goSpecialString
hi def link     goEscapeC           goSpecialString
hi def link     goEscapeX           goSpecialString
hi def link     goEscapeU           goSpecialString
hi def link     goEscapeBigU        goSpecialString
hi def link     goSpecialString     Special
hi def link     goEscapeError       Error

" Strings and their contents
syn cluster     goStringGroup       contains=goEscapeOctal,goEscapeC,goEscapeX,goEscapeU,goEscapeBigU,goEscapeError
syn region      goString            start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@goStringGroup,@Spell
syn region      goRawString         start=+`+ end=+`+ contains=@Spell

syn match       goFormatSpecifier   /\([^%]\(%%\)*\)\@<=%[-#0 +]*\%(\*\|\d\+\)\=\%(\.\%(\*\|\d\+\)\)*[vTtbcdoqxXUeEfgGsp]/ contained containedin=goString
hi def link     goFormatSpecifier   goSpecialString

hi def link     goString            String
hi def link     goRawString         String

" Characters; their contents
syn cluster     goCharacterGroup    contains=goEscapeOctal,goEscapeC,goEscapeX,goEscapeU,goEscapeBigU
syn region      goCharacter         start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=@goCharacterGroup

hi def link     goCharacter         Character

" Regions
syn region      goBlock             start="{" end="}" transparent fold
syn region      goParen             start='(' end=')' transparent

" Integers
syn match       goDecimalInt        "\<-\=\d\+\%([Ee][-+]\=\d\+\)\=\>"
syn match       goHexadecimalInt    "\<-\=0[xX]\x\+\>"
syn match       goOctalInt          "\<-\=0\o\+\>"
syn match       goOctalError        "\<-\=0\o*[89]\d*\>"

hi def link     goDecimalInt        Integer
hi def link     goHexadecimalInt    Integer
hi def link     goOctalInt          Integer
hi def link     goOctalError        Error
hi def link     Integer             Number

" Floating point
syn match       goFloat             "\<-\=\d\+\.\d*\%([Ee][-+]\=\d\+\)\=\>"
syn match       goFloat             "\<-\=\.\d\+\%([Ee][-+]\=\d\+\)\=\>"

hi def link     goFloat             Float

" Imaginary literals
syn match       goImaginary         "\<-\=\d\+i\>"
syn match       goImaginary         "\<-\=\d\+[Ee][-+]\=\d\+i\>"
syn match       goImaginaryFloat    "\<-\=\d\+\.\d*\%([Ee][-+]\=\d\+\)\=i\>"
syn match       goImaginaryFloat    "\<-\=\.\d\+\%([Ee][-+]\=\d\+\)\=i\>"

hi def link     goImaginary         Number
hi def link     goImaginaryFloat    Float

syn match goExtraType /\<bytes\.\(Buffer\)\>/
syn match goExtraType /\<io\.\(Reader\|ReadSeeker\|ReadWriter\|ReadCloser\|ReadWriteCloser\|Writer\|WriteCloser\|Seeker\)\>/
syn match goExtraType /\<reflect\.\(Kind\|Type\|Value\)\>/
syn match goExtraType /\<unsafe\.Pointer\>/

syn match goSpaceError display " \+\t"me=e-1

syn match goSpaceError display excludenl "\s\+$"

hi def link     goExtraType         Type
hi def link     goSpaceError        Error



" included from: https://github.com/athom/more-colorful.vim/blob/master/after/syntax/go.vim
"
" Comments; their contents
syn keyword     goTodo              contained NOTE
hi def link     goTodo              Todo

syn match goVarArgs /\.\.\./

" match single-char operators:          - + % < > ! & | ^ * =
" and corresponding two-char operators: -= += %= <= >= != &= |= ^= *= ==
syn match goOperator /[-+%<>!&|^*=]=\?/
" match / and /=
syn match goOperator /\/\%(=\|\ze[^/*]\)/
" match two-char operators:               << >> &^
" and corresponding three-char operators: <<= >>= &^=
syn match goOperator /\%(<<\|>>\|&^\)=\?/
" match remaining two-char operators: := && || <- ++ --
syn match goOperator /:=\|||\|<-\|++\|--/
" match ...

hi def link     goPointerOperator   goOperator
hi def link     goVarArgs           goOperator

hi def link     goOperator          Operator

syn match goDeclaration       /\<func\>/ nextgroup=goReceiver,goFunction skipwhite skipnl
syn match goReceiver          /(\(\w\|[ *]\)\+)/ contained nextgroup=goFunction contains=goReceiverVar skipwhite skipnl
syn match goReceiverVar       /\w\+/ nextgroup=goPointerOperator,goReceiverType skipwhite skipnl contained
syn match goPointerOperator   /\*/ nextgroup=goReceiverType contained skipwhite skipnl
syn match goReceiverType      /\w\+/ contained
syn match goFunction          /\w\+/ contained
syn match goFunctionCall      /\w\+\ze(/ contains=GoBuiltins,goDeclaration
hi def link     goFunction          Function
hi def link     goFunctionCall      Type

" Methods;
syn match goMethodCall            /\.\w\+\ze(/hs=s+1
hi def link     goMethodCall        Type

" Fields;
syn match goField                 /\.\w\+\([.\ \n\r\:\)\[,]\)\@=/hs=s+1
hi def link    goField              Identifier

" Structs & Interfaces;
syn match goTypeConstructor      /\<\w\+{/he=e-1
syn match goTypeDecl             /\<type\>/ nextgroup=goTypeName skipwhite skipnl
syn match goTypeName             /\w\+/ contained nextgroup=goDeclType skipwhite skipnl
syn match goDeclType             /\<interface\|struct\>/ skipwhite skipnl
hi def link     goReceiverType      Type
hi def link     goTypeConstructor   Type
hi def link     goTypeName          Type
hi def link     goTypeDecl          Keyword
hi def link     goDeclType          Keyword

" Build Constraints
syn match   goBuildKeyword      display contained "+build"
" Highlight the known values of GOOS, GOARCH, and other +build options.
syn keyword goBuildDirectives   contained
			\ android darwin dragonfly freebsd linux nacl netbsd openbsd plan9
			\ solaris windows 386 amd64 amd64p32 arm armbe arm64 arm64be ppc64
			\ ppc64le mips mipsle mips64 mips64le mips64p32 mips64p32le ppc
			\ s390 s390x sparc sparc64 cgo ignore race

" Other words in the build directive are build tags not listed above, so
" avoid highlighting them as comments by using a matchgroup just for the
" start of the comment.
" The rs=s+2 option lets the \s*+build portion be part of the inner region
" instead of the matchgroup so it will be highlighted as a goBuildKeyword.
syn region  goBuildComment      matchgroup=goBuildCommentStart
			\ start="//\s*+build\s"rs=s+2 end="$"
			\ contains=goBuildKeyword,goBuildDirectives
hi def link goBuildCommentStart Comment
hi def link goBuildDirectives   Type
hi def link goBuildKeyword      PreProc

" One or more line comments that are followed immediately by a "package"
" declaration are treated like package documentation, so these must be
" matched as comments to avoid looking like working build constraints.
" The he, me, and re options let the "package" itself be highlighted by
" the usual rules.
syn region  goPackageComment    start=/\v(\/\/.*\n)+\s*package/
			\ end=/\v\n\s*package/he=e-7,me=e-7,re=e-7
			\ contains=@goCommentGroup,@Spell
hi def link goPackageComment    Comment

" :GoCoverage commands
hi def link goCoverageNormalText Comment

function! s:hi()
  hi def link goSameId Search

  " :GoCoverage commands
  hi def      goCoverageCovered    ctermfg=green guifg=#A6E22E
  hi def      goCoverageUncover    ctermfg=red guifg=#F92672
endfunction

augroup vim-go-hi
  autocmd!
  autocmd ColorScheme * call s:hi()
augroup end
call s:hi()

" Search backwards for a global declaration to start processing the syntax.
"syn sync match goSync grouphere NONE /^\(const\|var\|type\|func\)\>/

" There's a bug in the implementation of grouphere. For now, use the
" following as a more expensive/less precise workaround.
syn sync minlines=500

let b:current_syntax = "go"

" vim: sw=2 ts=2 et
