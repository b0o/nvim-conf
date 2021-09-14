" Copyright (C) 2019-2021 Maddison Hellstrom <maddy@na.ai>
"
" Vim script based on https://github.com/arcticicestudio/nord-vim
" Copyright (C) 2016-2019 Arctic Ice Studio <development@arcticicestudio.com>
" Copyright (C) 2016-2019 Sven Greb <development@svengreb.de>

" Project: fullnight Vim
" Repository: https://github.com/b0o/nvim-conf
" License: MIT

if v:version > 580
  hi clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = 'fullnight'
let g:fullnight_vim_version='0.1.0'
set background=dark

let g:fullnight_gui = {}

let g:fullnight_gui[0]  = '#383A62' " background

let g:fullnight_gui[1]  = '#292A44' " normal black
let g:fullnight_gui[2]  = '#4C435C' " medium black
let g:fullnight_gui[3]  = '#A0A0C5' " bright black

let g:fullnight_gui[4]  = '#F1EFF8' " foreground
let g:fullnight_gui[5]  = '#DCDCE8' " normal white
let g:fullnight_gui[6]  = '#F1EFF8' " bright white

let g:fullnight_gui[7]  = '#CCCCFF' " normal cyan
let g:fullnight_gui[8]  = '#6DFEDF' " bright cyan

let g:fullnight_gui[9]  = '#8EAEE0' " normal blue
let g:fullnight_gui[10] = '#847AFF' " bright blue

let g:fullnight_gui[11] = '#CB4B16' " normal red
let g:fullnight_gui[12] = '#FF79C6' " bright red

let g:fullnight_gui[13] = '#EFE4A1' " normal yellow
let g:fullnight_gui[14] = '#2DE0A7' " normal green
let g:fullnight_gui[15] = '#B891FF' " normal magenta

let g:fullnight_gui[16] = '#B891FF'

" Extended
let g:fullnight_gui[17] = '#ff9969' " normal orange

let g:fullnight_gui["3_bright"] = '#7E7490'
let g:fullnight_gui_3_bright = g:fullnight_gui["3_bright"]

let g:fullnight_term = {}

let g:fullnight_term[0]  = 'NONE'
let g:fullnight_term[1]  = '0'
let g:fullnight_term[2]  = 'NONE'
let g:fullnight_term[3]  = '8'
let g:fullnight_term[4]  = 'NONE'
let g:fullnight_term[5]  = '7'
let g:fullnight_term[6]  = '15'
let g:fullnight_term[7]  = '14'
let g:fullnight_term[8]  = '6'
let g:fullnight_term[9]  = '4'
let g:fullnight_term[10] = '12'
let g:fullnight_term[11] = '1'
let g:fullnight_term[12] = '11'
let g:fullnight_term[13] = '3'
let g:fullnight_term[14] = '2'
let g:fullnight_term[15] = '5'
let g:fullnight_term[16] = 'NONE'

let g:colors_gui = g:fullnight_gui
let g:colors_term = g:fullnight_term

if !exists('g:fullnight_bold')
  let g:fullnight_bold = 1
endif

let s:bold = 'bold,'
if g:fullnight_bold == 0
  let s:bold = ''
endif

if !exists('g:fullnight_italic')
  if has('gui_running') || $TERM_ITALICS ==? 'true'
    let g:fullnight_italic = 1
  else
    let g:fullnight_italic = 0
  endif
endif

let s:italic = 'italic,'
if g:fullnight_italic == 0
  let s:italic = ''
endif

let s:underline = 'underline,'
if ! get(g:, 'fullnight_underline', 1)
  let s:underline = 'NONE,'
endif

let s:italicize_comments = ''
if exists('g:fullnight_italic_comments')
  if g:fullnight_italic_comments == 1
    let s:italicize_comments = s:italic
  endif
endif

function! s:logWarning(msg)
  echohl WarningMsg
  echomsg 'fullnight: warning: ' . a:msg
  echohl None
endfunction

if !exists('g:fullnight_uniform_diff_background')
  let g:fullnight_uniform_diff_background = 0
endif

if !exists('g:fullnight_cursor_line_number_background')
  let g:fullnight_cursor_line_number_background = 0
endif

if !exists('g:fullnight_bold_vertical_split_line')
  let g:fullnight_bold_vertical_split_line = 0
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
call s:hi('ColorColumn', '', g:fullnight_gui[1], 'NONE', g:fullnight_term[1], '', '')
call s:hi('Cursor', '', g:fullnight_gui[4], '', 'NONE', '', '')
call s:hi('CursorLine', '', g:fullnight_gui[1], 'NONE', g:fullnight_term[1], 'NONE', '')
call s:hi('Error', g:fullnight_gui[0], g:fullnight_gui[11], '', g:fullnight_term[11], '', '')
call s:hi('iCursor', g:fullnight_gui[0], g:fullnight_gui[4], '', 'NONE', '', '')
call s:hi('LineNr', g:fullnight_gui[3], '', g:fullnight_term[3], 'NONE', '', '')
call s:hi('MatchParen', g:fullnight_gui[8], g:fullnight_gui[3], g:fullnight_term[8], g:fullnight_term[3], '', '')
call s:hi('NonText', g:fullnight_gui[2], '', g:fullnight_term[3], '', '', '')
call s:hi('Normal', g:fullnight_gui[4], '', 'NONE', 'NONE', '', '')
call s:hi('PMenu', g:fullnight_gui[4], g:fullnight_gui[2], 'NONE', g:fullnight_term[1], 'NONE', '')
call s:hi('PmenuSbar', g:fullnight_gui[4], g:fullnight_gui[2], 'NONE', g:fullnight_term[1], '', '')
call s:hi('PMenuSel', g:fullnight_gui[8], g:fullnight_gui[3], g:fullnight_term[8], g:fullnight_term[3], '', '')
call s:hi('PmenuThumb', g:fullnight_gui[8], g:fullnight_gui[3], 'NONE', g:fullnight_term[3], '', '')
call s:hi('SpecialKey', g:fullnight_gui[3], '', g:fullnight_term[3], '', '', '')
call s:hi('SpellBad', '', '', '', '', 'undercurl', '')
call s:hi('SpellCap', '', '', '', '', 'undercurl', '')
call s:hi('SpellLocal', '', '', '', '', 'undercurl', '')
call s:hi('SpellRare', '', '', '', '', 'undercurl', '')
call s:hi('Visual', '', g:fullnight_gui[2], '', g:fullnight_term[1], '', '')
call s:hi('VisualNOS', '', g:fullnight_gui[2], '', g:fullnight_term[1], '', '')
"+- Neovim Support -+
call s:hi('healthError', g:fullnight_gui[11], g:fullnight_gui[1], g:fullnight_term[11], g:fullnight_term[1], '', '')
call s:hi('healthSuccess', g:fullnight_gui[14], g:fullnight_gui[1], g:fullnight_term[14], g:fullnight_term[1], '', '')
call s:hi('healthWarning', g:fullnight_gui[13], g:fullnight_gui[1], g:fullnight_term[13], g:fullnight_term[1], '', '')
call s:hi('TermCursorNC', '', g:fullnight_gui[1], '', g:fullnight_term[1], '', '')

"+- Vim 8 Terminal Colors -+
if has('terminal')
  let g:terminal_ansi_colors = [
  \   g:fullnight_gui[1],
  \   g:fullnight_gui[11],
  \   g:fullnight_gui[14],
  \   g:fullnight_gui[13],
  \   g:fullnight_gui[9],
  \   g:fullnight_gui[15],
  \   g:fullnight_gui[8],
  \   g:fullnight_gui[5],
  \   g:fullnight_gui[3],
  \   g:fullnight_gui[11],
  \   g:fullnight_gui[14],
  \   g:fullnight_gui[13],
  \   g:fullnight_gui[9],
  \   g:fullnight_gui[15],
  \   g:fullnight_gui[7],
  \   g:fullnight_gui[6]
  \ ]
endif

"+- Neovim Terminal Colors -+
if has('nvim')
  let g:terminal_color_0 = g:fullnight_gui[1]
  let g:terminal_color_1 = g:fullnight_gui[11]
  let g:terminal_color_2 = g:fullnight_gui[14]
  let g:terminal_color_3 = g:fullnight_gui[13]
  let g:terminal_color_4 = g:fullnight_gui[9]
  let g:terminal_color_5 = g:fullnight_gui[15]
  let g:terminal_color_6 = g:fullnight_gui[8]
  let g:terminal_color_7 = g:fullnight_gui[5]
  let g:terminal_color_8 = g:fullnight_gui[3]
  let g:terminal_color_9 = g:fullnight_gui[11]
  let g:terminal_color_10 = g:fullnight_gui[14]
  let g:terminal_color_11 = g:fullnight_gui[13]
  let g:terminal_color_12 = g:fullnight_gui[9]
  let g:terminal_color_13 = g:fullnight_gui[15]
  let g:terminal_color_14 = g:fullnight_gui[7]
  let g:terminal_color_15 = g:fullnight_gui[6]
endif

"+--- Gutter ---+
call s:hi('CursorColumn', '', g:fullnight_gui[1], 'NONE', g:fullnight_term[1], '', '')
if g:fullnight_cursor_line_number_background == 0
  call s:hi('CursorLineNr', g:fullnight_gui[4], '', 'NONE', '', '', '')
else
  call s:hi('CursorLineNr', g:fullnight_gui[4], g:fullnight_gui[1], 'NONE', g:fullnight_term[1], '', '')
endif
call s:hi('Folded', g:fullnight_gui[3], g:fullnight_gui[1], g:fullnight_term[3], g:fullnight_term[1], s:bold, '')
call s:hi('FoldColumn', g:fullnight_gui[3], 'NONE', g:fullnight_term[3], 'NONE', '', '')
call s:hi('SignColumn', g:fullnight_gui[1], 'NONE', g:fullnight_term[1], 'NONE', '', '')

"+--- Navigation ---+
call s:hi('Directory', g:fullnight_gui[8], '', g:fullnight_term[8], 'NONE', '', '')

"+--- Prompt/Status ---+
call s:hi('EndOfBuffer', g:fullnight_gui[1], '', g:fullnight_term[1], 'NONE', '', '')
call s:hi('ErrorMsg', g:fullnight_gui[4], g:fullnight_gui[11], 'NONE', g:fullnight_term[11], '', '')
call s:hi('ModeMsg', g:fullnight_gui[4], '', '', '', '', '')
call s:hi('MoreMsg', g:fullnight_gui[4], '', '', '', '', '')
call s:hi('Question', g:fullnight_gui[4], '', 'NONE', '', '', '')
call s:hi('StatusLine', g:fullnight_gui[8], g:fullnight_gui[3], g:fullnight_term[8], g:fullnight_term[3], 'NONE', '')
call s:hi('StatusLineNC', g:fullnight_gui[4], g:fullnight_gui[3], 'NONE', g:fullnight_term[3], 'NONE', '')
call s:hi('StatusLineTerm', g:fullnight_gui[8], g:fullnight_gui[3], g:fullnight_term[8], g:fullnight_term[3], 'NONE', '')
call s:hi('StatusLineTermNC', g:fullnight_gui[4], g:fullnight_gui[3], 'NONE', g:fullnight_term[3], 'NONE', '')
call s:hi('WarningMsg', g:fullnight_gui[0], g:fullnight_gui[13], g:fullnight_term[1], g:fullnight_term[13], '', '')
call s:hi('WildMenu', g:fullnight_gui[8], g:fullnight_gui[1], g:fullnight_term[8], g:fullnight_term[1], '', '')

"+--- Search ---+
call s:hi('IncSearch', g:fullnight_gui[6], g:fullnight_gui[10], g:fullnight_term[6], g:fullnight_term[10], s:underline, '')
call s:hi('Search', g:fullnight_gui[1], g:fullnight_gui[7], g:fullnight_term[1], g:fullnight_term[8], 'NONE', '')

"+--- Tabs ---+
call s:hi('TabLine', g:fullnight_gui[4], g:fullnight_gui[1], 'NONE', g:fullnight_term[1], 'NONE', '')
call s:hi('TabLineFill', g:fullnight_gui[4], g:fullnight_gui[1], 'NONE', g:fullnight_term[1], 'NONE', '')
call s:hi('TabLineSel', g:fullnight_gui[8], g:fullnight_gui[3], g:fullnight_term[8], g:fullnight_term[3], 'NONE', '')

"+--- Window ---+
call s:hi('Title', g:fullnight_gui[4], '', 'NONE', '', 'NONE', '')

if g:fullnight_bold_vertical_split_line == 0
  call s:hi('VertSplit', g:fullnight_gui[2], '', g:fullnight_term[3], 'NONE', 'NONE', '')
else
  call s:hi('VertSplit', g:fullnight_gui[2], g:fullnight_gui[1], g:fullnight_term[3], g:fullnight_term[1], 'NONE', '')
endif

"+----------------------+
"+ Language Base Groups +
"+----------------------+
call s:hi('Boolean', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('Character', g:fullnight_gui[14], '', g:fullnight_term[14], '', '', '')
call s:hi('Comment', g:fullnight_gui["3_bright"], '', g:fullnight_term[3], '', s:italicize_comments, '')
call s:hi('Conditional', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('Constant', g:fullnight_gui[4], '', 'NONE', '', '', '')
call s:hi('Define', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('Delimiter', g:fullnight_gui[6], '', g:fullnight_term[6], '', '', '')
call s:hi('Exception', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('Float', g:fullnight_gui[15], '', g:fullnight_term[15], '', '', '')
call s:hi('Function', g:fullnight_gui[8], '', g:fullnight_term[8], '', '', '')
call s:hi('Identifier', g:fullnight_gui[4], '', 'NONE', '', 'NONE', '')
call s:hi('Include', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('Keyword', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('Label', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('Number', g:fullnight_gui[15], '', g:fullnight_term[15], '', '', '')
call s:hi('Operator', g:fullnight_gui[9], '', g:fullnight_term[9], '', 'NONE', '')
call s:hi('PreProc', g:fullnight_gui[9], '', g:fullnight_term[9], '', 'NONE', '')
call s:hi('Repeat', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('Special', g:fullnight_gui[4], '', 'NONE', '', '', '')
call s:hi('SpecialChar', g:fullnight_gui[13], '', g:fullnight_term[13], '', '', '')
call s:hi('SpecialComment', g:fullnight_gui[8], '', g:fullnight_term[8], '', s:italicize_comments, '')
call s:hi('Statement', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('StorageClass', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('String', g:fullnight_gui[14], '', g:fullnight_term[14], '', '', '')
call s:hi('Structure', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('Tag', g:fullnight_gui[4], '', '', '', '', '')
call s:hi('Todo', g:fullnight_gui[13], 'NONE', g:fullnight_term[13], 'NONE', '', '')
call s:hi('Type', g:fullnight_gui[9], '', g:fullnight_term[9], '', 'NONE', '')
call s:hi('Typedef', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
hi! link Macro Define
hi! link PreCondit PreProc

"+-----------+
"+ Languages +
"+-----------+
call s:hi('asciidocAttributeEntry', g:fullnight_gui[10], '', g:fullnight_term[10], '', '', '')
call s:hi('asciidocAttributeList', g:fullnight_gui[10], '', g:fullnight_term[10], '', '', '')
call s:hi('asciidocAttributeRef', g:fullnight_gui[10], '', g:fullnight_term[10], '', '', '')
call s:hi('asciidocHLabel', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('asciidocListingBlock', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('asciidocMacroAttributes', g:fullnight_gui[8], '', g:fullnight_term[8], '', '', '')
call s:hi('asciidocOneLineTitle', g:fullnight_gui[8], '', g:fullnight_term[8], '', '', '')
call s:hi('asciidocPassthroughBlock', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
call s:hi('asciidocQuotedMonospaced', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('asciidocTriplePlusPassthrough', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
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

call s:hi('awkCharClass', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('awkPatterns', g:fullnight_gui[9], '', g:fullnight_term[9], '', s:bold, '')
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

call s:hi('cIncluded', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link cOperator Operator
hi! link cPreCondit PreCondit

call s:hi('cmakeGeneratorExpression', g:fullnight_gui[10], '', g:fullnight_term[10], '', '', '')

hi! link csPreCondit PreCondit
hi! link csType Type
hi! link csXmlTag SpecialComment

call s:hi('cssAttributeSelector', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('cssDefinition', g:fullnight_gui[7], '', g:fullnight_term[7], '', 'NONE', '')
call s:hi('cssIdentifier', g:fullnight_gui[7], '', g:fullnight_term[7], '', s:underline, '')
call s:hi('cssStringQ', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link cssAttr Keyword
hi! link cssBraces Delimiter
hi! link cssClassName cssDefinition
hi! link cssColor Number
hi! link cssProp cssDefinition
hi! link cssPseudoClass cssDefinition
hi! link cssPseudoClassId cssPseudoClass
hi! link cssVendor Keyword

call s:hi('dosiniHeader', g:fullnight_gui[8], '', g:fullnight_term[8], '', '', '')
hi! link dosiniLabel Type

call s:hi('dtBooleanKey', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('dtExecKey', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('dtLocaleKey', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('dtNumericKey', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('dtTypeKey', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link dtDelim Delimiter
hi! link dtLocaleValue Keyword
hi! link dtTypeValue Keyword

if g:fullnight_uniform_diff_background == 0
  call s:hi('DiffAdd', g:fullnight_gui[14], '', g:fullnight_term[14], 'NONE', 'inverse', '')
  call s:hi('DiffChange', g:fullnight_gui[13], '', g:fullnight_term[13], 'NONE', 'inverse', '')
  call s:hi('DiffDelete', g:fullnight_gui[11], '', g:fullnight_term[11], 'NONE', 'inverse', '')
  call s:hi('DiffText', g:fullnight_gui[9], '', g:fullnight_term[9], 'NONE', 'inverse', '')
else
  call s:hi('DiffAdd', g:fullnight_gui[14], g:fullnight_gui[1], g:fullnight_term[14], g:fullnight_term[1], '', '')
  call s:hi('DiffChange', g:fullnight_gui[13], g:fullnight_gui[1], g:fullnight_term[13], g:fullnight_term[1], '', '')
  call s:hi('DiffDelete', g:fullnight_gui[11], g:fullnight_gui[1], g:fullnight_term[11], g:fullnight_term[1], '', '')
  call s:hi('DiffText', g:fullnight_gui[9], g:fullnight_gui[1], g:fullnight_term[9], g:fullnight_term[1], '', '')
endif
" Legacy groups for official git.vim and diff.vim syntax
hi! link diffAdded DiffAdd
hi! link diffChanged DiffChange
hi! link diffRemoved DiffDelete

call s:hi('gitconfigVariable', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')

call s:hi('goBuiltins', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link goConstants Keyword

call s:hi('helpBar', g:fullnight_gui[3], '', g:fullnight_term[3], '', '', '')
call s:hi('helpHyperTextJump', g:fullnight_gui[8], '', g:fullnight_term[8], '', s:underline, '')

call s:hi('htmlArg', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('htmlLink', g:fullnight_gui[4], '', '', '', 'NONE', 'NONE')
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

call s:hi('javaDocTags', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link javaCommentTitle Comment
hi! link javaScriptBraces Delimiter
hi! link javaScriptIdentifier Keyword
hi! link javaScriptNumber Number

call s:hi('jsonKeyword', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')

call s:hi('lessClass', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
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

call s:hi('markdownBlockquote', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('markdownCode', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('markdownCodeDelimiter', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('markdownFootnote', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('markdownId', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('markdownIdDeclaration', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('markdownH1', g:fullnight_gui[8], '', g:fullnight_term[8], '', '', '')
call s:hi('markdownLinkText', g:fullnight_gui[8], '', g:fullnight_term[8], '', '', '')
call s:hi('markdownUrl', g:fullnight_gui[4], '', 'NONE', '', 'NONE', '')
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

call s:hi('perlPackageDecl', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')

call s:hi('phpClasses', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('phpDocTags', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link phpDocCustomTags phpDocTags
hi! link phpMemberSelector Keyword

call s:hi('podCmdText', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('podVerbatimLine', g:fullnight_gui[4], '', 'NONE', '', '', '')
hi! link podFormat Keyword

hi! link pythonBuiltin Type
hi! link pythonEscape SpecialChar

call s:hi('rubyConstant', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('rubySymbol', g:fullnight_gui[6], '', g:fullnight_term[6], '', s:bold, '')
hi! link rubyAttribute Identifier
hi! link rubyBlockParameterList Operator
hi! link rubyInterpolationDelimiter Keyword
hi! link rubyKeywordAsMethod Function
hi! link rubyLocalVariableOrMethod Function
hi! link rubyPseudoVariable Keyword
hi! link rubyRegexp SpecialChar

call s:hi('rustAttribute', g:fullnight_gui[10], '', g:fullnight_term[10], '', '', '')
call s:hi('rustEnum', g:fullnight_gui[7], '', g:fullnight_term[7], '', s:bold, '')
call s:hi('rustMacro', g:fullnight_gui[8], '', g:fullnight_term[8], '', s:bold, '')
call s:hi('rustModPath', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('rustPanic', g:fullnight_gui[9], '', g:fullnight_term[9], '', s:bold, '')
call s:hi('rustTrait', g:fullnight_gui[7], '', g:fullnight_term[7], '', s:italic, '')
hi! link rustCommentLineDoc Comment
hi! link rustDerive rustAttribute
hi! link rustEnumVariant rustEnum
hi! link rustEscape SpecialChar
hi! link rustQuestionMark Keyword

call s:hi('sassClass', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('sassId', g:fullnight_gui[7], '', g:fullnight_term[7], '', s:underline, '')
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

call s:hi('vimAugroup', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('vimMapRhs', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('vimNotation', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link vimFunc Function
hi! link vimFunction Function
hi! link vimUserFunc Function

call s:hi('xmlAttrib', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('xmlCdataStart', g:fullnight_gui["3_bright"], '', g:fullnight_term[3], '', s:bold, '')
call s:hi('xmlNamespace', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link xmlAttribPunct Delimiter
hi! link xmlCdata Comment
hi! link xmlCdataCdata xmlCdataStart
hi! link xmlCdataEnd xmlCdataStart
hi! link xmlEndTag xmlTagName
hi! link xmlProcessingDelim Keyword
hi! link xmlTagName Keyword

call s:hi('yamlBlockMappingKey', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link yamlBool Keyword
hi! link yamlDocumentStart Keyword

"+----------------+
"+ Plugin Support +
"+----------------+
"+--- UI ---+
" ALE
" > w0rp/ale
call s:hi('ALEWarningSign', g:fullnight_gui[13], '', g:fullnight_term[13], '', '', '')
call s:hi('ALEErrorSign' , g:fullnight_gui[11], '', g:fullnight_term[11], '', '', '')
call s:hi('ALEWarning' , g:fullnight_gui[13], '', g:fullnight_term[13], '', 'undercurl', '')
call s:hi('ALEError' , g:fullnight_gui[11], '', g:fullnight_term[11], '', 'undercurl', '')

" Coc
" > neoclide/coc
call s:hi('CocWarningSign', g:fullnight_gui[13], '', g:fullnight_term[13], '', '', '')
call s:hi('CocErrorSign' , g:fullnight_gui[11], '', g:fullnight_term[11], '', '', '')
call s:hi('CocInfoSign' , g:fullnight_gui[8], '', g:fullnight_term[8], '', '', '')
call s:hi('CocHintSign' , g:fullnight_gui[10], '', g:fullnight_term[10], '', '', '')

" GitGutter
" > airblade/vim-gitgutter
call s:hi('GitGutterAdd', g:fullnight_gui[14], '', g:fullnight_term[14], '', '', '')
call s:hi('GitGutterChange', g:fullnight_gui[13], '', g:fullnight_term[13], '', '', '')
call s:hi('GitGutterChangeDelete', g:fullnight_gui[11], '', g:fullnight_term[11], '', '', '')
call s:hi('GitGutterDelete', g:fullnight_gui[11], '', g:fullnight_term[11], '', '', '')

" Signify
" > mhinz/vim-signify
call s:hi('SignifySignAdd', g:fullnight_gui[14], '', g:fullnight_term[14], '', '', '')
call s:hi('SignifySignChange', g:fullnight_gui[13], '', g:fullnight_term[13], '', '', '')
call s:hi('SignifySignChangeDelete', g:fullnight_gui[11], '', g:fullnight_term[11], '', '', '')
call s:hi('SignifySignDelete', g:fullnight_gui[11], '', g:fullnight_term[11], '', '', '')

" fugitive.vim
" > tpope/vim-fugitive
call s:hi('gitcommitDiscardedFile', g:fullnight_gui[11], '', g:fullnight_term[11], '', '', '')
call s:hi('gitcommitUntrackedFile', g:fullnight_gui[11], '', g:fullnight_term[11], '', '', '')
call s:hi('gitcommitSelectedFile', g:fullnight_gui[14], '', g:fullnight_term[14], '', '', '')

" davidhalter/jedi-vim
call s:hi('jediFunction', g:fullnight_gui[4], g:fullnight_gui[3], '', g:fullnight_term[3], '', '')
call s:hi('jediFat', g:fullnight_gui[8], g:fullnight_gui[3], g:fullnight_term[8], g:fullnight_term[3], s:underline.s:bold, '')

" NERDTree
" > scrooloose/nerdtree
call s:hi('NERDTreeExecFile', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link NERDTreeDirSlash Keyword
hi! link NERDTreeHelp Comment

" CtrlP
" > ctrlpvim/ctrlp.vim
hi! link CtrlPMatch Keyword
hi! link CtrlPBufferHid Normal

" vim-plug
" > junegunn/vim-plug
call s:hi('plugDeleted', g:fullnight_gui[11], '', '', g:fullnight_term[11], '', '')

" vim-signature
" > kshenoy/vim-signature
call s:hi('SignatureMarkText', g:fullnight_gui[8], '', g:fullnight_term[8], '', '', '')

"+--- Languages ---+
" Haskell
" > neovimhaskell/haskell-vim
call s:hi('haskellPreProc', g:fullnight_gui[10], '', g:fullnight_term[10], '', '', '')
call s:hi('haskellType', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
hi! link haskellPragma haskellPreProc

" JavaScript
" > pangloss/vim-javascript
call s:hi('jsGlobalNodeObjects', g:fullnight_gui[8], '', g:fullnight_term[8], '', s:italic, '')
hi! link jsBrackets Delimiter
hi! link jsFuncCall Function
hi! link jsFuncParens Delimiter
hi! link jsThis Keyword
hi! link jsNoise Delimiter
hi! link jsPrototype Keyword
hi! link jsRegexpString SpecialChar

" Markdown
" > plasticboy/vim-markdown
call s:hi('mkdCode', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
call s:hi('mkdFootnote', g:fullnight_gui[8], '', g:fullnight_term[8], '', '', '')
call s:hi('mkdRule', g:fullnight_gui[10], '', g:fullnight_term[10], '', '', '')
call s:hi('mkdLineBreak', g:fullnight_gui[9], '', g:fullnight_term[9], '', '', '')
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
    call s:hi('VimwikiHeader'.s:i, g:fullnight_gui[8], '', g:fullnight_term[8], '', s:bold, '')
  endfor
else
  let s:vimwiki_hcolor_guifg = [g:fullnight_gui[7], g:fullnight_gui[8], g:fullnight_gui[9], g:fullnight_gui[10], g:fullnight_gui[14], g:fullnight_gui[15]]
  let s:vimwiki_hcolor_ctermfg = [g:fullnight_term[7], g:fullnight_term[8], g:fullnight_term[9], g:fullnight_term[10], g:fullnight_term[14], g:fullnight_term[15]]
  for s:i in range(1,6)
    call s:hi('VimwikiHeader'.s:i, s:vimwiki_hcolor_guifg[s:i-1] , '', s:vimwiki_hcolor_ctermfg[s:i-1], '', s:bold, '')
  endfor
endif

call s:hi('VimwikiLink', g:fullnight_gui[8], '', g:fullnight_term[8], '', s:underline, '')
hi! link VimwikiHeaderChar markdownHeadingDelimiter
hi! link VimwikiHR Keyword
hi! link VimwikiList markdownListMarker

" YAML
" > stephpy/vim-yaml
call s:hi('yamlKey', g:fullnight_gui[7], '', g:fullnight_term[7], '', '', '')
