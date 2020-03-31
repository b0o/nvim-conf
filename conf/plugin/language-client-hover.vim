""" language-client-hover.vim
""" LCHover mini plugin
"""
""" dependencies:
""" - autozimu/LanguageClient-neovim
"""
""" optional dependencies:
""" - tpope/vim-markdown.vim - syntax highlighting for fenced code blocks in Markdown
"""
""" TODO: make this into a *real* plugin :)
"""
""" Author: Maddison Hellstrom <github.com/b0o>
""" License: GPL-3.0
"""
""" This program is free software: you can redistribute it and/or modify
""" it under the terms of the GNU General Public License as published by
""" the Free Software Foundation, either version 3 of the License, or
""" (at your option) any later version.
"""
""" This program is distributed in the hope that it will be useful,
""" but WITHOUT ANY WARRANTY; without even the implied warranty of
""" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
""" GNU General Public License for more details.
"""
""" You should have received a copy of the GNU General Public License
""" along with this program.  If not, see <https://www.gnu.org/licenses/>.

""" user-configurable variables

" Controls whether LCHover is enabled
let g:LCHoverEnabled = v:true

" Controls how LCHover information is output:
" Preview:  A preview window is used to display the output
" Echo:     Output is echoed
let g:LCHoverOutput = 'Preview' " 'Preview' | 'Echo'

" Controls the minimum height of the preview window when not focused:
"   g:LCHoverResize is Never:  this value has no effect
"   g:LCHoverResize is Focus:  this is the minimum height when unfocused.
"   g:LCHoverResize is Always: this value has no effect
let g:LCHoverUnfocusedHeightMin = 2

" Controls the maximum height of the preview window when not focused:
"   g:LCHoverResize is Never:  this is always the height of the preview window.
"   g:LCHoverResize is Focus:  this is the maximum height when unfocused.
"   g:LCHoverResize is Always: this value has no effect
let g:LCHoverUnfocusedHeightMax = 4

" Controls the minimum height of the preview window when focused:
"   g:LCHoverResize is Never:  this value has no effect
"   g:LCHoverResize is Focus:  this is the minimum height when focused.
"   g:LCHoverResize is Always: this is always the minimum height of the preview window.
let g:LCHoverFocusedHeightMin = 2

" Controls the maximum height of the preview window when focused:
"   g:LCHoverResize is Never:  this value has no effect
"   g:LCHoverResize is Focus:  this is the maximum height when focused.
"   g:LCHoverResize is Always: this is always the maximum height of the preview window.
let g:LCHoverFocusedHeightMax = 8

" Controls when to resize the preview window:
" Always: The preview window will always resize to fit the number of lines in
"         the buffer, regardless of focus, based on g:LCHoverFocusedHeightMin
"         and g:LCHoverFocusedHeightMax
" Never:  The preview window height will remain constant, based on g:LCHoverUnfocusedHeightMin
"         and g:LCHoverUnfocusedHeightMax
" Focus:  When unfocused, the preview window height will be based on
"         g:LCHoverUnfocusedHeightMin and g:LCHoverUnfocusedHeightMax.
"         When focused, the preview window height will be based on
"         g:LCHoverFocusedHeightMin and g:LCHoverFocusedHeightMax.
let g:LCHoverResize = 'Focus' " 'Always' | 'Never' | 'Focus'

" Controls whether the preview window will be hidden when the preview buffer is empty
let g:LCHoverHideEmpty = v:false

" Controls when to use markdown to display the response from the language
" server.
"
" Some language servers send responses as markdown strings by default. If this
" is the case, a setting of 'Auto' or 'Always' will maintain the markdown
" formatting. A value of 'Never' will try to strip out code fences and display
" the result directly
"
" If the language server sends a non-markdown response and the value of this
" setting is 'Auto' or 'Never', the language server's original filetype will be preserved.
" If the value of this setting is 'Always', the language server's response
" will be wrapped in fenced code blocks and the filetype will be set to
" 'markdown'
let g:LCHoverMarkdown = 'Always' " 'Auto' | 'Always' | 'Never'

" If the preview buffer filetype is markdown, this variable controls whether
" the window will be automatically scrolled down 1 line to avoid the code
" fence
" For example, if the preview buffer contents are the following, the cursor
" will be placed on line 2.
" ``` go
" Println calls Output to print to the standard logger.
" func log.Println(v ...interface{})
" ```
" This ensures that, if the preview buffer height is less than the number of
" lines in the buffer, the top line will be the first line inside the fenced
" code block
let g:LCHoverMarkdownAutoscroll = v:true

" Controls the commands that are executed when a preview window/buffer is
" created. This is useful for disabling plugins which may attempt to lint or
" parse code buffers, such as ALE and LanguageClient itself
"
" Array items are arrays consisting of the vim command as the first element,
" followed by arguments to the command as additional elements
let g:LCHoverBufferCommands = [
  \   [ 'let', 'w:airline_disabled=1'       ],
  \   [ 'let', 'b:ale_enabled=0'            ],
  \   [ 'let', 'b:languageclient_enabled=0' ],
  \ ]

""" plugin state
" TODO: use w:lc_hover_for_win to create a separate LCHover window for each
" source window
let s:state = {
  \ 'orig_preview_height': v:null,
  \ 'status': 0,
  \ 'cleared': v:false,
  \ 'moved': v:false,
  \ 'lastline': v:null,
  \ 'focus': v:false,
  \ 'filetype': v:null,
  \ 'bufname': v:null,
  \ 'bufnr': -1,
  \ 'serverStatus': v:false,
  \ 'locked': v:false,
  \ }

""" Public Functions

function! LCHoverEnable()
  if !g:LCHoverEnabled
    let g:LCHoverEnabled = 1
    call s:enableHover()
    echo 'LCHover enabled'
  else
    echo 'LCHover is already enabled'
  endif
endfunction
command! LCHoverEnable call LCHoverEnable()

function! LCHoverDisable()
  if g:LCHoverEnabled
    let g:LCHoverEnabled = 0
    call s:disableHover()
    echo 'LCHover disabled'
  else
    echo 'LCHover is already disabled'
  endif
endfunction
command! LCHoverDisable call LCHoverDisable()

" toggle the state of LCHover
function! LCHoverToggle()
  if g:LCHoverEnabled
    call LCHoverDisable()
  else
    call LCHoverEnable()
  endif
endfunction
command! LCHoverToggle call LCHoverToggle()

""" internal logic

function! s:buf_get_wins(bufnr)
  let l:ret = {}
  let l:ret.bufnr = a:bufnr
  let l:ret.wins = win_findbuf(a:bufnr)
  let l:ret.tabpagenr = tabpagenr()
  let l:ret.visibleWinid = -1
  let l:ret.tabwins = {}
  for l:win in l:ret.wins
    let l:ret.tabwins[l:win] = win_id2tabwin(l:win)[0]
    if l:ret.tabwins[l:win] == l:ret.tabpagenr
      let l:ret.visibleWinid = l:win
    endif
  endfor
  return l:ret
endfunction

function! g:LCHover_statusline()
  let l:statusline = 'LCHover'
  if s:state.filetype != v:null
    let l:statusline .= '[' . s:state.filetype . ']'
  endif
  if s:state.locked
    let l:statusline .= ' '
  endif
  return l:statusline
endfunction

" Example:
"   min:    2  2  2  2
"   max:    6  6  6  6
"   n:      5  7  1  3
"   return: 5  6  2  3
function! s:clamp(min, max, n)
  if a:n < a:min
    return a:min
  elseif a:n > a:max
    return a:max
  endif
  return a:n
endfunction

" handle user events
function! s:LCHover_handleEvent(event)
  " Event:           Clear | Focus | Unfocus | Update
  " g:LCHoverResize: Always | Never | Focus
  "
  " g:LCHoverResize: Always
  " Event:              | Clear | Focus | Unfocus | Update |
  " FocusedHeightMax    |       |   +   |    +    |    +   |
  " FocusedHeightMin    |   =   |   -   |    -    |    -   |
  " UnfocusedHeightMax  |       |       |         |        |
  " UnfocusedHeightMin  |       |       |         |        |
  "
  " g:LCHoverResize: Never
  " Event:              | Clear | Focus | Unfocus | Update |
  " FocusedHeightMax    |       |       |         |        |
  " FocusedHeightMin    |       |       |         |        |
  " UnfocusedHeightMax  |   =   |   =   |    =    |    =   |
  " UnfocusedHeightMin  |       |       |         |        |
  "
  " g:LCHoverResize: Focus
  " Event:              | Clear | Focus | Unfocus | Update |
  " FocusedHeightMax    |       |   +   |         |        |
  " FocusedHeightMin    |       |   -   |         |        |
  " UnfocusedHeightMax  |       |       |    +    |    +   |
  " UnfocusedHeightMin  |   =   |       |    -    |    -   |
  "
  " Legend:
  "  +  upper bound
  "  -  lower bound
  "  =  exact value

  if s:state.locked | return | endif

  let l:buf_wins = s:buf_get_wins(s:state.bufnr)
  if l:buf_wins.visibleWinid == -1
    return
  endif

  let l:nlines = nvim_buf_line_count(s:state.bufnr)
  let l:md = v:false

  if g:LCHoverMarkdownAutoscroll && nvim_buf_get_option(s:state.bufnr, 'filetype') ==? 'markdown'
    let l:nlines -= 2
    let l:md = v:true
  endif

  let l:height = l:nlines

  if g:LCHoverResize ==? 'Always'
    if index(['Focus', 'Unfocus', 'Update', 'Clear'], a:event) != -1
      let l:height = s:clamp(g:LCHoverFocusedHeightMin, g:LCHoverFocusedHeightMax, l:nlines)
    elseif a:event ==? 'Clear'
      let l:height = g:LCHoverFocusedHeightMin
    endif
  elseif g:LCHoverResize ==? 'Never'
    let l:height = g:LCHoverUnfocusedHeightMax
  elseif g:LCHoverResize ==? 'Focus'
    if index(['Unfocus', 'Update'], a:event) != -1
      let l:height = s:clamp(g:LCHoverUnfocusedHeightMin, g:LCHoverUnfocusedHeightMax, l:nlines)
    elseif a:event ==? 'Clear'
      let l:height = g:LCHoverUnfocusedHeightMin
    elseif a:event ==? 'Focus'
      let l:height = s:clamp(g:LCHoverFocusedHeightMin, g:LCHoverFocusedHeightMax, l:nlines)
    endif
  endif

  try
    call nvim_win_set_height(l:buf_wins.visibleWinid, l:height)
  catch | endtry

  if l:md
    try
      " emulate '2Gzt' (frame window with buffer line 2 on the top line) - to hide
      " the upper markdown code fence
      call nvim_win_set_cursor(l:buf_wins.visibleWinid, [s:clamp(0, l:nlines + 2, l:height + 1), 0])
      call nvim_win_set_cursor(l:buf_wins.visibleWinid, [2, 0])
  catch | endtry
  endif
endfunction

function! s:LCHover_createBuffer()
  let l:cmds = g:LCHoverBufferCommands + [
    \   [ 'setlocal',
    \     'nomodifiable',
    \     'statusline=%!g:LCHover_statusline()',
    \     'filetype=markdown',
    \     'buftype=nofile',
    \     'noswapfile',
    \     'nonumber',
    \     'norelativenumber',
    \     'nomodeline',
    \     'conceallevel=3',
    \     'concealcursor=niv',
    \     'nolist',
    \   ],
    \ ]
  " TODO: scrolloff doesn't yet have global-local support in NeoVim.
  " See: https://github.com/neovim/neovim/pull/11854
  "      https://github.com/vim/vim/commit/375e3390078e740d3c83b0c118c50d9a920036c7
  " \     'scrolloff=0',
  let l:cmds += [
    \   [ 'let',
    \     'w:lc_hover_for_win=' . nvim_get_current_win(),
    \   ],
    \ ]
  let l:cmdStr = join(map(l:cmds, { k, c -> join(c, "\\ ") }), '|')
  if s:state.filetype != v:null
    let s:state.bufname = '__LCHover_' . s:state.filetype . '__'
  else
    let s:state.bufname = '__LCHover__'
  endif
  exec 'silent! pedit! +' . l:cmdStr . ' ' . s:state.bufname
  let s:state.bufnr = bufnr(s:state.bufname)
  call nvim_buf_set_keymap(s:state.bufnr, 'n', '<C-l>', 'g:LCHoverToggleLock()', {'expr': v:true})
endfunction

function! g:LCHoverToggleLock()
  let s:state.locked = !s:state.locked
endfunction

function! g:LCHoverCb(res)
  let s:state.filetype = &filetype
  " If we get a valid response with non-empty result, display it
  if   type(a:res) == v:t_dict        && has_key(a:res, 'result')
  \ && type(a:res.result) == v:t_dict && has_key(a:res.result, 'contents')
    let l:msg = []
    if type(a:res.result.contents) == v:t_dict && type(a:res.result.contents.value) == v:t_string
      let l:msg += split(a:res.result.contents.value, "\n")
    elseif type(a:res.result.contents) == v:t_list
      for l:item in a:res.result.contents
        if type(l:item) == v:t_dict && type(l:item.value) == v:t_string
          let l:msg += split(l:item.value, "\n")
        endif
      endfor
    endif
    if len(l:msg) > 0
      if g:LCHoverOutput ==? 'Preview'
        let l:buf_wins = s:buf_get_wins(s:state.bufnr)
        if l:buf_wins.visibleWinid == -1
          call s:LCHover_createBuffer()
        endif
        if g:LCHoverMarkdown ==? 'Always'
          if ! ( type(a:res.result.contents) ==? v:t_dict && has_key(a:res.result.contents, 'kind') && a:res.result.contents.kind ==? 'markdown' )
            let l:msg = ['``` ' . &filetype] + l:msg + ['```']
          endif
        endif
        call s:LCHover_set_lines(l:msg)
      else
        echohl Keyword | echo join(l:msg, "\n") | echohl None
      endif
      let s:state.cleared = 0
      let s:state.moved = 0
      return
    endif
  endif

  " Clear output
  if s:state.cleared == 0
    if g:LCHoverOutput ==? 'Preview'
      if g:LCHoverHideEmpty
        silent! pclose
      else
        if s:state.bufnr != -1
          call s:LCHover_set_lines([])
        endif
      endif
    else
      echo ''
    endif
    let s:state.cleared = 1
    let s:state.moved = 0
  endif
endfunction

function! s:LCHover_set_lines(lines)
  if s:state.locked | return | endif
  let l:event = 'Update'
  if len(a:lines) == 0
    let l:event = 'Clear'
  endif
  call nvim_buf_set_option(s:state.bufnr, 'modifiable', v:true)
  call nvim_buf_set_lines(s:state.bufnr, 0, -1, v:false, a:lines)
  call s:LCHover_handleEvent(l:event)
  call nvim_buf_set_option(s:state.bufnr, 'modifiable', v:false)
endfunction

function! s:LCHover() abort
    let l:params = {
      \ 'filename':  LSP#filename(),
      \ 'text':      LSP#text(),
      \ 'line':      LSP#line(),
      \ 'character': LSP#character(),
      \ 'handle':    v:false,
      \ }
    return LanguageClient#Call('textDocument/hover', l:params, function('LCHoverCb'))
endfunction

function! LCHoverAliveCb(res)
  let s:state.serverStatus = a:res.result
  if s:state.serverStatus == v:true
    call s:LCHover()
  endif
endfunction

function! s:hold()
  let l:line = getline(line('.'))
  let l:pos = join(getpos('.'), ',')
  if s:state.moved == 1 && g:LCHoverEnabled == 1
    \ && (l:line != s:state.lastline || l:pos != s:state.lastpos)
    let s:state.lastline = l:line
    let s:state.lastpos = l:pos
    try
      call LanguageClient#isAlive(function('LCHoverAliveCb'))
    catch | endtry
  endif
endfunction

function! s:moved()
  let l:buf_wins = s:buf_get_wins(s:state.bufnr)
  let l:currWinid = win_getid()
  let l:lines = []
  if s:state.bufnr != -1
    let l:lines = nvim_buf_get_lines(s:state.bufnr, 0, -1, 0)
  endif
  if l:buf_wins.visibleWinid == l:currWinid " Preview window is selected
    if s:state.focus == 0 " Trigger focus event
      call s:LCHover_handleEvent('Focus')
      let s:state.focus = 1
    endif
    let s:state.moved = 0
    return
  endif

  if s:state.focus == 1 " Trigger unfocus event
    call s:LCHover_handleEvent('Unfocus')
    let s:state.focus = 0
  endif
  let s:state.moved = 1
endfunction

function! s:enableHover()
  if g:LCHoverEnabled == 0 || s:state.status == 1
    return
  endif
  let s:state.status = 1
  if g:LCHoverFocusedHeightMin >= 0
    let s:state.orig_preview_height = &previewheight
    exec 'set previewheight=' . g:LCHoverFocusedHeightMin
  endif
  augroup LCHover_textDocumentHover
    autocmd!
    autocmd CursorMoved * call <sid>moved()
    autocmd CursorHold  * call <sid>hold()
  augroup END
endfunction

function! s:disableHover()
  if s:state.status == 0
    return
  endif
  let s:state.status = 0
  if s:state.orig_preview_height
    exec 'set previewheight=' . s:state.orig_preview_height
  endif
  augroup! LCHover_textDocumentHover
endfunction

function! s:LCHover_init()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    call s:enableHover()
    " nnoremap <buffer> <silent> <M-d> :call LanguageClient#textDocument_hover()<cr>
    " nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
    " nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
  endif
endfunction

augroup LCHover
  autocmd!
  autocmd FileType * call <sid>LCHover_init()
augroup END
