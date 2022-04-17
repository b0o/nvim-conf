" Copyright (C) 2019-2022 Maddison Hellstrom <maddy@na.ai>
"
" Vim script based on https://github.com/arcticicestudio/nord-vim
" Copyright (C) 2016-2019 Arctic Ice Studio <development@arcticicestudio.com>
" Copyright (C) 2016-2019 Sven Greb <development@svengreb.de>

" Project: Lavi Vim
" Repository: https://github.com/b0o/nvim-conf
" License: MIT

if v:version > 580
  hi clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = 'lavi'
let g:lavi_vim_version='0.1.0'
set background=dark

let g:lavi_gui = {}

let g:lavi_gui[0]  = '#463E57' " background

let g:lavi_gui[1]  = '#2F2A38' " normal black
let g:lavi_gui[2]  = '#4C435C' " medium black
let g:lavi_gui[3]  = '#8977A8' " bright black

let g:lavi_gui[4]  = '#FFF1E0' " foreground
let g:lavi_gui[5]  = '#EEE6FF' " normal white
let g:lavi_gui[6]  = '#ffffff' " bright white

let g:lavi_gui[7]  = '#3FC4C4' " normal cyan
let g:lavi_gui[8]  = '#2BEDC0' " bright cyan

let g:lavi_gui[9]  = '#80BDFF' " normal blue
let g:lavi_gui[10] = '#7583FF' " bright blue

let g:lavi_gui[11] = '#FF87A5' " normal red
let g:lavi_gui[12] = '#F2637E' " bright red

let g:lavi_gui[13] = '#FFD080' " normal yellow
let g:lavi_gui[14] = '#7CF89C' " normal green
let g:lavi_gui[15] = '#B98AFF' " normal magenta

let g:lavi_gui[16] = '#B891FF'

" Extended
let g:lavi_gui[17] = '#ff9969' " normal orange
let g:lavi_gui[18]  = '#3F3650'
let g:lavi_gui[19]  = '#9385F8'
let g:lavi_gui[20]  = '#222032'

let g:lavi_gui["3_bright"] = '#7E7490'
let g:lavi_gui_3_bright = g:lavi_gui["3_bright"]

let g:lavi_term = {}

let g:lavi_term[0]  = 'NONE'
let g:lavi_term[1]  = '0'
let g:lavi_term[2]  = 'NONE'
let g:lavi_term[3]  = '8'
let g:lavi_term[4]  = 'NONE'
let g:lavi_term[5]  = '7'
let g:lavi_term[6]  = '15'
let g:lavi_term[7]  = '14'
let g:lavi_term[8]  = '6'
let g:lavi_term[9]  = '4'
let g:lavi_term[10] = '12'
let g:lavi_term[11] = '1'
let g:lavi_term[12] = '11'
let g:lavi_term[13] = '3'
let g:lavi_term[14] = '2'
let g:lavi_term[15] = '5'
let g:lavi_term[16] = 'NONE'

let g:colors_gui = g:lavi_gui
let g:colors_term = g:lavi_term

if !exists('g:lavi_bold')
  let g:lavi_bold = 1
endif

let s:bold = 'bold,'
if g:lavi_bold == 0
  let s:bold = ''
endif

if !exists('g:lavi_italic')
  if has('gui_running') || $TERM_ITALICS ==? 'true'
    let g:lavi_italic = 1
  else
    let g:lavi_italic = 0
  endif
endif

let s:italic = 'italic,'
if g:lavi_italic == 0
  let s:italic = ''
endif

let s:underline = 'underline,'
if ! get(g:, 'lavi_underline', 1)
  let s:underline = 'NONE,'
endif

let s:italicize_comments = ''
if exists('g:lavi_italic_comments')
  if g:lavi_italic_comments == 1
    let s:italicize_comments = s:italic . s:bold
  endif
endif

function! s:logWarning(msg)
  echohl WarningMsg
  echomsg 'lavi: warning: ' . a:msg
  echohl None
endfunction

if !exists('g:lavi_uniform_diff_background')
  let g:lavi_uniform_diff_background = 0
endif

if !exists('g:lavi_cursor_line_number_background')
  let g:lavi_cursor_line_number_background = 0
endif

if !exists('g:lavi_cursor_line_sign_background')
  let g:lavi_cursor_line_sign_background = 0
endif

if !exists('g:lavi_bold_vertical_split_line')
  let g:lavi_bold_vertical_split_line = 0
endif

function! s:hi(group, guifg, guibg, ctermfg, ctermbg, attr, guisp)
  if a:guifg !=# ''
    exec 'hi ' . a:group . ' guifg=' . a:guifg
  endif
  if a:guibg !=# ''
    exec 'hi ' . a:group . ' guibg=' . a:guibg
  endif
  if a:ctermfg !=# ''
    exec 'hi ' . a:group . ' ctermfg=' . a:ctermfg
  endif
  if a:ctermbg !=# ''
    exec 'hi ' . a:group . ' ctermbg=' . a:ctermbg
  endif
  if a:attr !=# ''
    exec 'hi ' . a:group . ' gui=' . a:attr . ' cterm=' . substitute(a:attr, 'undercurl', s:underline, '')
  endif
  if a:guisp !=# ''
    exec 'hi ' . a:group . ' guisp=' . a:guisp
  endif
endfunction

"+---------------+
"+ UI Components +
"+---------------+
"+--- Attributes ---+
call s:hi('Bold', '', '', '', '', s:bold, '')
call s:hi('Italic', '', '', '', '', s:italic, '')
call s:hi('Underline', '', '', '', '', s:underline, '')

"+--- Editor ---+
call s:hi('ColorColumn', '', g:lavi_gui[1], 'NONE', g:lavi_term[1], '', '')
call s:hi('Cursor', '', g:lavi_gui[4], '', 'NONE', '', '')
call s:hi('CursorLine', '', g:lavi_gui[18], 'NONE', g:lavi_term[1], 'NONE', '')
call s:hi('CursorLineNC', '', g:lavi_gui[1], 'NONE', g:lavi_term[1], 'NONE', '')
call s:hi('Error', g:lavi_gui[0], g:lavi_gui[11], '', g:lavi_term[11], '', '')
call s:hi('iCursor', g:lavi_gui[0], g:lavi_gui[4], '', 'NONE', '', '')
call s:hi('LineNr', g:lavi_gui[3], '', g:lavi_term[3], 'NONE', '', '')
call s:hi('MatchParen', g:lavi_gui[8], g:lavi_gui[3], g:lavi_term[8], g:lavi_term[3], '', '')
call s:hi('NonText', g:lavi_gui[2], '', g:lavi_term[3], '', '', '')
call s:hi('Normal', g:lavi_gui[4], '', 'NONE', 'NONE', '', '')
call s:hi('NormalNC', g:lavi_gui[4], g:lavi_gui[20], 'NONE', 'NONE', '', '')
call s:hi('PMenu', g:lavi_gui[4], g:lavi_gui[2], 'NONE', g:lavi_term[1], 'NONE', '')
call s:hi('PmenuSbar', g:lavi_gui[4], g:lavi_gui[2], 'NONE', g:lavi_term[1], '', '')
call s:hi('PMenuSel', g:lavi_gui[8], g:lavi_gui[3], g:lavi_term[8], g:lavi_term[3], '', '')
call s:hi('PmenuThumb', g:lavi_gui[8], g:lavi_gui[3], 'NONE', g:lavi_term[3], '', '')
call s:hi('SpecialKey', g:lavi_gui[3], '', g:lavi_term[3], '', '', '')
call s:hi('SpellBad', '', '', '', '', 'undercurl', '')
call s:hi('SpellCap', '', '', '', '', 'undercurl', '')
call s:hi('SpellLocal', '', '', '', '', 'undercurl', '')
call s:hi('SpellRare', '', '', '', '', 'undercurl', '')
call s:hi('Visual', '', g:lavi_gui[2], '', g:lavi_term[1], '', '')
call s:hi('VisualNOS', '', g:lavi_gui[2], '', g:lavi_term[1], '', '')
"+- Neovim Support -+
call s:hi('healthError', g:lavi_gui[11], g:lavi_gui[1], g:lavi_term[11], g:lavi_term[1], '', '')
call s:hi('healthSuccess', g:lavi_gui[14], g:lavi_gui[1], g:lavi_term[14], g:lavi_term[1], '', '')
call s:hi('healthWarning', g:lavi_gui[13], g:lavi_gui[1], g:lavi_term[13], g:lavi_term[1], '', '')
call s:hi('TermCursorNC', '', g:lavi_gui[1], '', g:lavi_term[1], '', '')

"+- Vim 8 Terminal Colors -+
if has('terminal')
  let g:terminal_ansi_colors = [
  \   g:lavi_gui[1],
  \   g:lavi_gui[11],
  \   g:lavi_gui[14],
  \   g:lavi_gui[13],
  \   g:lavi_gui[9],
  \   g:lavi_gui[15],
  \   g:lavi_gui[8],
  \   g:lavi_gui[5],
  \   g:lavi_gui[3],
  \   g:lavi_gui[11],
  \   g:lavi_gui[14],
  \   g:lavi_gui[13],
  \   g:lavi_gui[9],
  \   g:lavi_gui[15],
  \   g:lavi_gui[7],
  \   g:lavi_gui[6]
  \ ]
endif

"+- Neovim Terminal Colors -+
if has('nvim')
  let g:terminal_color_0 = g:lavi_gui[1]
  let g:terminal_color_1 = g:lavi_gui[11]
  let g:terminal_color_2 = g:lavi_gui[14]
  let g:terminal_color_3 = g:lavi_gui[13]
  let g:terminal_color_4 = g:lavi_gui[9]
  let g:terminal_color_5 = g:lavi_gui[15]
  let g:terminal_color_6 = g:lavi_gui[8]
  let g:terminal_color_7 = g:lavi_gui[5]
  let g:terminal_color_8 = g:lavi_gui[3]
  let g:terminal_color_9 = g:lavi_gui[11]
  let g:terminal_color_10 = g:lavi_gui[14]
  let g:terminal_color_11 = g:lavi_gui[13]
  let g:terminal_color_12 = g:lavi_gui[9]
  let g:terminal_color_13 = g:lavi_gui[15]
  let g:terminal_color_14 = g:lavi_gui[7]
  let g:terminal_color_15 = g:lavi_gui[6]
endif

"+--- Gutter ---+
call s:hi('CursorColumn', '', g:lavi_gui[1], 'NONE', g:lavi_term[1], '', '')
if g:lavi_cursor_line_number_background == 0
  call s:hi('CursorLineNr', g:lavi_gui[4], '', 'NONE', '', '', '')
  call s:hi('CursorLineNrNC', g:lavi_gui[4], '', 'NONE', '', '', '')
else
  call s:hi('CursorLineNr', g:lavi_gui[6], g:lavi_gui[19], 'NONE', g:lavi_term[10], '', '')
  call s:hi('CursorLineNrNC', g:lavi_gui[4], g:lavi_gui[0], 'NONE', g:lavi_term[0], '', '')
endif
call s:hi('Folded', g:lavi_gui[3], g:lavi_gui[1], g:lavi_term[3], g:lavi_term[1], s:bold, '')
call s:hi('FoldColumn', g:lavi_gui[3], 'NONE', g:lavi_term[3], 'NONE', '', '')
call s:hi('SignColumn', g:lavi_gui[1], 'NONE', g:lavi_term[1], 'NONE', '', '')

"+--- Navigation ---+
call s:hi('Directory', g:lavi_gui[8], '', g:lavi_term[8], 'NONE', '', '')

"+--- Prompt/Status ---+
call s:hi('EndOfBuffer', g:lavi_gui[1], '', g:lavi_term[1], 'NONE', '', '')
call s:hi('ErrorMsg', g:lavi_gui[4], g:lavi_gui[11], 'NONE', g:lavi_term[11], '', '')
call s:hi('ModeMsg', g:lavi_gui[4], '', '', '', '', '')
call s:hi('MoreMsg', g:lavi_gui[4], '', '', '', '', '')
call s:hi('Question', g:lavi_gui[4], '', 'NONE', '', '', '')
call s:hi('StatusLine', g:lavi_gui[8], g:lavi_gui[3], g:lavi_term[8], g:lavi_term[3], 'NONE', '')
call s:hi('StatusLineNC', g:lavi_gui[4], g:lavi_gui[3], 'NONE', g:lavi_term[3], 'NONE', '')
call s:hi('StatusLineTerm', g:lavi_gui[8], g:lavi_gui[3], g:lavi_term[8], g:lavi_term[3], 'NONE', '')
call s:hi('StatusLineTermNC', g:lavi_gui[4], g:lavi_gui[3], 'NONE', g:lavi_term[3], 'NONE', '')
call s:hi('WarningMsg', g:lavi_gui[0], g:lavi_gui[13], g:lavi_term[1], g:lavi_term[13], '', '')
call s:hi('WildMenu', g:lavi_gui[8], g:lavi_gui[1], g:lavi_term[8], g:lavi_term[1], '', '')

"+--- Search ---+
call s:hi('IncSearch', g:lavi_gui[6], g:lavi_gui[10], g:lavi_term[6], g:lavi_term[10], s:underline, '')
call s:hi('Search', g:lavi_gui[1], g:lavi_gui[7], g:lavi_term[1], g:lavi_term[8], 'NONE', '')

"+--- Tabs ---+
call s:hi('TabLine', g:lavi_gui[4], g:lavi_gui[1], 'NONE', g:lavi_term[1], 'NONE', '')
call s:hi('TabLineFill', g:lavi_gui[4], g:lavi_gui[1], 'NONE', g:lavi_term[1], 'NONE', '')
call s:hi('TabLineSel', g:lavi_gui[8], g:lavi_gui[3], g:lavi_term[8], g:lavi_term[3], 'NONE', '')

"+--- Window ---+
call s:hi('Title', g:lavi_gui[4], '', 'NONE', '', 'NONE', '')

if g:lavi_bold_vertical_split_line == 0
  call s:hi('VertSplit', g:lavi_gui[2], '', g:lavi_term[3], 'NONE', 'NONE', '')
else
  call s:hi('VertSplit', g:lavi_gui[2], g:lavi_gui[1], g:lavi_term[3], g:lavi_term[1], 'NONE', '')
endif

"+----------------------+
"+ Language Base Groups +
"+----------------------+
call s:hi('Boolean', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('Character', g:lavi_gui[14], '', g:lavi_term[14], '', '', '')
call s:hi('Comment', g:lavi_gui["3_bright"], '', g:lavi_term[3], '', s:italicize_comments, '')
call s:hi('Conditional', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('Constant', g:lavi_gui[4], '', 'NONE', '', '', '')
call s:hi('Define', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('Delimiter', g:lavi_gui[6], '', g:lavi_term[6], '', '', '')
call s:hi('Exception', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('Float', g:lavi_gui[15], '', g:lavi_term[15], '', '', '')
call s:hi('Function', g:lavi_gui[8], '', g:lavi_term[8], '', '', '')
call s:hi('Identifier', g:lavi_gui[4], '', 'NONE', '', 'NONE', '')
call s:hi('Include', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('Keyword', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('Label', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('Number', g:lavi_gui[15], '', g:lavi_term[15], '', '', '')
call s:hi('Operator', g:lavi_gui[9], '', g:lavi_term[9], '', 'NONE', '')
call s:hi('PreProc', g:lavi_gui[9], '', g:lavi_term[9], '', 'NONE', '')
call s:hi('Repeat', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('Special', g:lavi_gui[4], '', 'NONE', '', '', '')
call s:hi('SpecialChar', g:lavi_gui[13], '', g:lavi_term[13], '', '', '')
call s:hi('SpecialComment', g:lavi_gui[8], '', g:lavi_term[8], '', s:italicize_comments, '')
call s:hi('Statement', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('StorageClass', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('String', g:lavi_gui[14], '', g:lavi_term[14], '', '', '')
call s:hi('Structure', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('Tag', g:lavi_gui[4], '', '', '', '', '')
call s:hi('Todo', g:lavi_gui[13], 'NONE', g:lavi_term[13], 'NONE', '', '')
call s:hi('Type', g:lavi_gui[9], '', g:lavi_term[9], '', 'NONE', '')
call s:hi('Typedef', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
hi! link Macro Define
hi! link PreCondit PreProc

"+-----------+
"+ Languages +
"+-----------+
call s:hi('asciidocAttributeEntry', g:lavi_gui[10], '', g:lavi_term[10], '', '', '')
call s:hi('asciidocAttributeList', g:lavi_gui[10], '', g:lavi_term[10], '', '', '')
call s:hi('asciidocAttributeRef', g:lavi_gui[10], '', g:lavi_term[10], '', '', '')
call s:hi('asciidocHLabel', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('asciidocListingBlock', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('asciidocMacroAttributes', g:lavi_gui[8], '', g:lavi_term[8], '', '', '')
call s:hi('asciidocOneLineTitle', g:lavi_gui[8], '', g:lavi_term[8], '', '', '')
call s:hi('asciidocPassthroughBlock', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
call s:hi('asciidocQuotedMonospaced', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('asciidocTriplePlusPassthrough', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link asciidocAdmonition Keyword
hi! link asciidocAttributeRef markdownH1
hi! link asciidocBackslash Keyword
hi! link asciidocMacro Keyword
hi! link asciidocQuotedBold Bold
hi! link asciidocQuotedEmphasized Italic
hi! link asciidocQuotedMonospaced2 asciidocQuotedMonospaced
hi! link asciidocQuotedUnconstrainedBold asciidocQuotedBold
hi! link asciidocQuotedUnconstrainedEmphasized asciidocQuotedEmphasized
hi! link asciidocURL markdownLinkText

call s:hi('awkCharClass', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('awkPatterns', g:lavi_gui[9], '', g:lavi_term[9], '', s:bold, '')
hi! link awkArrayElement Identifier
hi! link awkBoolLogic Keyword
hi! link awkBrktRegExp SpecialChar
hi! link awkComma Delimiter
hi! link awkExpression Keyword
hi! link awkFieldVars Identifier
hi! link awkLineSkip Keyword
hi! link awkOperator Operator
hi! link awkRegExp SpecialChar
hi! link awkSearch Keyword
hi! link awkSemicolon Delimiter
hi! link awkSpecialCharacter SpecialChar
hi! link awkSpecialPrintf SpecialChar
hi! link awkVariables Identifier

call s:hi('cIncluded', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link cOperator Operator
hi! link cPreCondit PreCondit

call s:hi('cmakeGeneratorExpression', g:lavi_gui[10], '', g:lavi_term[10], '', '', '')

hi! link csPreCondit PreCondit
hi! link csType Type
hi! link csXmlTag SpecialComment

call s:hi('cssAttributeSelector', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('cssDefinition', g:lavi_gui[7], '', g:lavi_term[7], '', 'NONE', '')
call s:hi('cssIdentifier', g:lavi_gui[7], '', g:lavi_term[7], '', s:underline, '')
call s:hi('cssStringQ', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link cssAttr Keyword
hi! link cssBraces Delimiter
hi! link cssClassName cssDefinition
hi! link cssColor Number
hi! link cssProp cssDefinition
hi! link cssPseudoClass cssDefinition
hi! link cssPseudoClassId cssPseudoClass
hi! link cssVendor Keyword

call s:hi('dosiniHeader', g:lavi_gui[8], '', g:lavi_term[8], '', '', '')
hi! link dosiniLabel Type

call s:hi('dtBooleanKey', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('dtExecKey', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('dtLocaleKey', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('dtNumericKey', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('dtTypeKey', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link dtDelim Delimiter
hi! link dtLocaleValue Keyword
hi! link dtTypeValue Keyword

if g:lavi_uniform_diff_background == 0
  call s:hi('DiffAdd', g:lavi_gui[14], '', g:lavi_term[14], 'NONE', 'inverse', '')
  call s:hi('DiffChange', g:lavi_gui[13], '', g:lavi_term[13], 'NONE', 'inverse', '')
  call s:hi('DiffDelete', g:lavi_gui[11], '', g:lavi_term[11], 'NONE', 'inverse', '')
  call s:hi('DiffText', g:lavi_gui[9], '', g:lavi_term[9], 'NONE', 'inverse', '')
else
  call s:hi('DiffAdd', g:lavi_gui[14], g:lavi_gui[1], g:lavi_term[14], g:lavi_term[1], '', '')
  call s:hi('DiffChange', g:lavi_gui[13], g:lavi_gui[1], g:lavi_term[13], g:lavi_term[1], '', '')
  call s:hi('DiffDelete', g:lavi_gui[11], g:lavi_gui[1], g:lavi_term[11], g:lavi_term[1], '', '')
  call s:hi('DiffText', g:lavi_gui[9], g:lavi_gui[1], g:lavi_term[9], g:lavi_term[1], '', '')
endif
" Legacy groups for official git.vim and diff.vim syntax
hi! link diffAdded DiffAdd
hi! link diffChanged DiffChange
hi! link diffRemoved DiffDelete

call s:hi('gitconfigVariable', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')

call s:hi('goBuiltins', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link goConstants Keyword

call s:hi('helpBar', g:lavi_gui[3], '', g:lavi_term[3], '', '', '')
call s:hi('helpHyperTextJump', g:lavi_gui[8], '', g:lavi_term[8], '', s:underline, '')

call s:hi('htmlArg', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('htmlLink', g:lavi_gui[4], '', '', '', 'NONE', 'NONE')
hi! link htmlBold Bold
hi! link htmlEndTag htmlTag
hi! link htmlItalic Italic
hi! link htmlH1 markdownH1
hi! link htmlH2 markdownH1
hi! link htmlH3 markdownH1
hi! link htmlH4 markdownH1
hi! link htmlH5 markdownH1
hi! link htmlH6 markdownH1
hi! link htmlSpecialChar SpecialChar
hi! link htmlTag Keyword
hi! link htmlTagN htmlTag

call s:hi('javaDocTags', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link javaCommentTitle Comment
hi! link javaScriptBraces Delimiter
hi! link javaScriptIdentifier Keyword
hi! link javaScriptNumber Number

call s:hi('jsonKeyword', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')

call s:hi('lessClass', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link lessAmpersand Keyword
hi! link lessCssAttribute Delimiter
hi! link lessFunction Function
hi! link cssSelectorOp Keyword

hi! link lispAtomBarSymbol SpecialChar
hi! link lispAtomList SpecialChar
hi! link lispAtomMark Keyword
hi! link lispBarSymbol SpecialChar
hi! link lispFunc Function

hi! link luaFunc Function

call s:hi('markdownBlockquote', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('markdownCode', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('markdownCodeDelimiter', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('markdownFootnote', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('markdownId', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('markdownIdDeclaration', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('markdownH1', g:lavi_gui[8], '', g:lavi_term[8], '', '', '')
call s:hi('markdownLinkText', g:lavi_gui[8], '', g:lavi_term[8], '', '', '')
call s:hi('markdownUrl', g:lavi_gui[4], '', 'NONE', '', 'NONE', '')
hi! link markdownBold Bold
hi! link markdownBoldDelimiter Keyword
hi! link markdownFootnoteDefinition markdownFootnote
hi! link markdownH2 markdownH1
hi! link markdownH3 markdownH1
hi! link markdownH4 markdownH1
hi! link markdownH5 markdownH1
hi! link markdownH6 markdownH1
hi! link markdownIdDelimiter Keyword
hi! link markdownItalic Italic
hi! link markdownItalicDelimiter Keyword
hi! link markdownLinkDelimiter Keyword
hi! link markdownLinkTextDelimiter Keyword
hi! link markdownListMarker Keyword
hi! link markdownRule Keyword
hi! link markdownHeadingDelimiter Keyword

call s:hi('perlPackageDecl', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')

call s:hi('phpClasses', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('phpDocTags', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link phpDocCustomTags phpDocTags
hi! link phpMemberSelector Keyword

call s:hi('podCmdText', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('podVerbatimLine', g:lavi_gui[4], '', 'NONE', '', '', '')
hi! link podFormat Keyword

hi! link pythonBuiltin Type
hi! link pythonEscape SpecialChar

call s:hi('rubyConstant', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('rubySymbol', g:lavi_gui[6], '', g:lavi_term[6], '', s:bold, '')
hi! link rubyAttribute Identifier
hi! link rubyBlockParameterList Operator
hi! link rubyInterpolationDelimiter Keyword
hi! link rubyKeywordAsMethod Function
hi! link rubyLocalVariableOrMethod Function
hi! link rubyPseudoVariable Keyword
hi! link rubyRegexp SpecialChar

call s:hi('rustAttribute', g:lavi_gui[10], '', g:lavi_term[10], '', '', '')
call s:hi('rustEnum', g:lavi_gui[7], '', g:lavi_term[7], '', s:bold, '')
call s:hi('rustMacro', g:lavi_gui[8], '', g:lavi_term[8], '', s:bold, '')
call s:hi('rustModPath', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('rustPanic', g:lavi_gui[9], '', g:lavi_term[9], '', s:bold, '')
call s:hi('rustTrait', g:lavi_gui[7], '', g:lavi_term[7], '', s:italic, '')
hi! link rustCommentLineDoc Comment
hi! link rustDerive rustAttribute
hi! link rustEnumVariant rustEnum
hi! link rustEscape SpecialChar
hi! link rustQuestionMark Keyword

call s:hi('sassClass', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('sassId', g:lavi_gui[7], '', g:lavi_term[7], '', s:underline, '')
hi! link sassAmpersand Keyword
hi! link sassClassChar Delimiter
hi! link sassControl Keyword
hi! link sassControlLine Keyword
hi! link sassExtend Keyword
hi! link sassFor Keyword
hi! link sassFunctionDecl Keyword
hi! link sassFunctionName Function
hi! link sassidChar sassId
hi! link sassInclude SpecialChar
hi! link sassMixinName Function
hi! link sassMixing SpecialChar
hi! link sassReturn Keyword

hi! link shCmdParenRegion Delimiter
hi! link shCmdSubRegion Delimiter
hi! link shDerefSimple Identifier
hi! link shDerefVar Identifier

hi! link sqlKeyword Keyword
hi! link sqlSpecial Keyword

call s:hi('vimAugroup', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('vimMapRhs', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('vimNotation', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link vimFunc Function
hi! link vimFunction Function
hi! link vimUserFunc Function

call s:hi('xmlAttrib', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('xmlCdataStart', g:lavi_gui["3_bright"], '', g:lavi_term[3], '', s:bold, '')
call s:hi('xmlNamespace', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link xmlAttribPunct Delimiter
hi! link xmlCdata Comment
hi! link xmlCdataCdata xmlCdataStart
hi! link xmlCdataEnd xmlCdataStart
hi! link xmlEndTag xmlTagName
hi! link xmlProcessingDelim Keyword
hi! link xmlTagName Keyword

call s:hi('yamlBlockMappingKey', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link yamlBool Keyword
hi! link yamlDocumentStart Keyword

"+----------------+
"+ Plugin Support +
"+----------------+
"+--- UI ---+
" ALE
" > w0rp/ale
call s:hi('ALEWarningSign', g:lavi_gui[13], '', g:lavi_term[13], '', '', '')
call s:hi('ALEErrorSign' , g:lavi_gui[11], '', g:lavi_term[11], '', '', '')
call s:hi('ALEWarning' , g:lavi_gui[13], '', g:lavi_term[13], '', 'undercurl', '')
call s:hi('ALEError' , g:lavi_gui[11], '', g:lavi_term[11], '', 'undercurl', '')

" Coc
" > neoclide/coc
call s:hi('CocWarningSign', g:lavi_gui[13], '', g:lavi_term[13], '', '', '')
call s:hi('CocErrorSign' , g:lavi_gui[11], '', g:lavi_term[11], '', '', '')
call s:hi('CocInfoSign' , g:lavi_gui[8], '', g:lavi_term[8], '', '', '')
call s:hi('CocHintSign' , g:lavi_gui[10], '', g:lavi_term[10], '', '', '')

" GitGutter
" > airblade/vim-gitgutter
call s:hi('GitGutterAdd', g:lavi_gui[14], '', g:lavi_term[14], '', '', '')
call s:hi('GitGutterChange', g:lavi_gui[13], '', g:lavi_term[13], '', '', '')
call s:hi('GitGutterChangeDelete', g:lavi_gui[11], '', g:lavi_term[11], '', '', '')
call s:hi('GitGutterDelete', g:lavi_gui[11], '', g:lavi_term[11], '', '', '')

" Signify
" > mhinz/vim-signify
call s:hi('SignifySignAdd', g:lavi_gui[14], '', g:lavi_term[14], '', '', '')
call s:hi('SignifySignChange', g:lavi_gui[13], '', g:lavi_term[13], '', '', '')
call s:hi('SignifySignChangeDelete', g:lavi_gui[11], '', g:lavi_term[11], '', '', '')
call s:hi('SignifySignDelete', g:lavi_gui[11], '', g:lavi_term[11], '', '', '')

" fugitive.vim
" > tpope/vim-fugitive
call s:hi('gitcommitDiscardedFile', g:lavi_gui[11], '', g:lavi_term[11], '', '', '')
call s:hi('gitcommitUntrackedFile', g:lavi_gui[11], '', g:lavi_term[11], '', '', '')
call s:hi('gitcommitSelectedFile', g:lavi_gui[14], '', g:lavi_term[14], '', '', '')

" davidhalter/jedi-vim
call s:hi('jediFunction', g:lavi_gui[4], g:lavi_gui[3], '', g:lavi_term[3], '', '')
call s:hi('jediFat', g:lavi_gui[8], g:lavi_gui[3], g:lavi_term[8], g:lavi_term[3], s:underline.s:bold, '')

" NERDTree
" > scrooloose/nerdtree
call s:hi('NERDTreeExecFile', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link NERDTreeDirSlash Keyword
hi! link NERDTreeHelp Comment

" CtrlP
" > ctrlpvim/ctrlp.vim
hi! link CtrlPMatch Keyword
hi! link CtrlPBufferHid Normal

" vim-plug
" > junegunn/vim-plug
call s:hi('plugDeleted', g:lavi_gui[11], '', '', g:lavi_term[11], '', '')

" vim-signature
" > kshenoy/vim-signature
call s:hi('SignatureMarkText', g:lavi_gui[8], '', g:lavi_term[8], '', '', '')

"+--- Languages ---+
" Haskell
" > neovimhaskell/haskell-vim
call s:hi('haskellPreProc', g:lavi_gui[10], '', g:lavi_term[10], '', '', '')
call s:hi('haskellType', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
hi! link haskellPragma haskellPreProc

" JavaScript
" > pangloss/vim-javascript
call s:hi('jsGlobalNodeObjects', g:lavi_gui[8], '', g:lavi_term[8], '', s:italic, '')
hi! link jsBrackets Delimiter
hi! link jsFuncCall Function
hi! link jsFuncParens Delimiter
hi! link jsThis Keyword
hi! link jsNoise Delimiter
hi! link jsPrototype Keyword
hi! link jsRegexpString SpecialChar

" Markdown
" > plasticboy/vim-markdown
call s:hi('mkdCode', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')
call s:hi('mkdFootnote', g:lavi_gui[8], '', g:lavi_term[8], '', '', '')
call s:hi('mkdRule', g:lavi_gui[10], '', g:lavi_term[10], '', '', '')
call s:hi('mkdLineBreak', g:lavi_gui[9], '', g:lavi_term[9], '', '', '')
hi! link mkdBold Bold
hi! link mkdItalic Italic
hi! link mkdString Keyword
hi! link mkdCodeStart mkdCode
hi! link mkdCodeEnd mkdCode
hi! link mkdBlockquote Comment
hi! link mkdListItem Keyword
hi! link mkdListItemLine Normal
hi! link mkdFootnotes mkdFootnote
hi! link mkdLink markdownLinkText
hi! link mkdURL markdownUrl
hi! link mkdInlineURL mkdURL
hi! link mkdID Identifier
hi! link mkdLinkDef mkdLink
hi! link mkdLinkDefTarget mkdURL
hi! link mkdLinkTitle mkdInlineURL
hi! link mkdDelimiter Keyword

" Vimwiki
" > vimwiki/vimwiki
if !exists('g:vimwiki_hl_headers') || g:vimwiki_hl_headers == 0
  for s:i in range(1,6)
    call s:hi('VimwikiHeader'.s:i, g:lavi_gui[8], '', g:lavi_term[8], '', s:bold, '')
  endfor
else
  let s:vimwiki_hcolor_guifg = [g:lavi_gui[7], g:lavi_gui[8], g:lavi_gui[9], g:lavi_gui[10], g:lavi_gui[14], g:lavi_gui[15]]
  let s:vimwiki_hcolor_ctermfg = [g:lavi_term[7], g:lavi_term[8], g:lavi_term[9], g:lavi_term[10], g:lavi_term[14], g:lavi_term[15]]
  for s:i in range(1,6)
    call s:hi('VimwikiHeader'.s:i, s:vimwiki_hcolor_guifg[s:i-1] , '', s:vimwiki_hcolor_ctermfg[s:i-1], '', s:bold, '')
  endfor
endif

call s:hi('VimwikiLink', g:lavi_gui[8], '', g:lavi_term[8], '', s:underline, '')
hi! link VimwikiHeaderChar markdownHeadingDelimiter
hi! link VimwikiHR Keyword
hi! link VimwikiList markdownListMarker

" YAML
" > stephpy/vim-yaml
call s:hi('yamlKey', g:lavi_gui[7], '', g:lavi_term[7], '', '', '')

call s:hi('GitSignsAdd', g:lavi_gui[14], '', g:lavi_term[14], '', '', '')
" call s:hi('GitSignsAddNr')
" call s:hi('GitSignsAddLn')

call s:hi('GitSignsChange', g:lavi_gui[13], '', g:lavi_term[13], '', '', '')
" call s:hi('GitSignsChangeNr')
" call s:hi('GitSignsChangeLn')

call s:hi('GitSignsDelete', g:lavi_gui[11], '', g:lavi_term[11], '', '', '')
" call s:hi('GitSignsDeleteNr')
" call s:hi('GitSignsDeleteLn')

call s:hi('MarkSignHL', g:lavi_gui[16], '', 'NONE', g:lavi_term[16], s:italic, '')
call s:hi('MarkSignNumHL', g:lavi_gui[4], '', 'NONE', '', s:bold . s:italic, '')
