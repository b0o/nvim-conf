""" language-client.vim
""" configuration for the plugin autozimu/LanguageClient-neovim

let s:cquery_cmd = ['cquery',
  \             '--log-file=~/.local/share/cquery/cquery.log',
  \             '--init={"cacheDirectory": "' . expand($HOME) . '/.cache/cquery"}' ]

" LanguageClient-neovim
let g:LanguageClient_serverCommands = {
  \     'c':   s:cquery_cmd,
  \     'cpp': s:cquery_cmd,
  \ }

" Fix for https://github.com/autozimu/LanguageClient-neovim/issues/379
let g:LanguageClient_hasSnippetSupport = 0
let g:LanguageClient_hoverPreview = "Never"

"" 'LCHover' mini plugin

let g:LanguageClientHoverEnabled = 1
let g:LanguageClientHoverPreview = 1
let g:LanguageClientPreviewHeight = 1
let g:LanguageClientHoverPreviewClose = 1
let g:LanguageClientPreviewBufName = "__LC_Symbol_Info__"

let s:orig_preview_height = v:null

func! LanguageClientHoverToggle()
  let g:LanguageClientHoverEnabled = !g:LanguageClientHoverEnabled
  if g:LanguageClientHoverEnabled == 0
    call s:disableHoverAugroup()
    echo "LanguageClientHover disabled"
  else
    call s:enableHoverAugroup()
    echo "LanguageClientHover enabled"
  endif
endfunc

let s:cleared = 0
let s:moved = 0
func! g:LanguageClientHoverCb(res)
  if   type(a:res) == v:t_dict        && has_key(a:res, "result")
  \ && type(a:res.result) == v:t_dict && has_key(a:res.result, "contents")
  \ && type(a:res.result.contents) == v:t_list
    let l:msg = []
    for l:item in a:res.result.contents
      if type(l:item) == v:t_dict && type(l:item.value) == v:t_string
        let l:msg += [l:item.value]
      endif
    endfor
    if len(l:msg) > 0
      if g:LanguageClientHoverPreview
        exec "silent! pedit! +setlocal\\ buftype=nofile\\ noswapfile\\ filetype=" . &ft . "\\ nonumber\\ norelativenumber\\ nomodeline " . g:LanguageClientPreviewBufName
        let l:previewBufnr = bufnr(g:LanguageClientPreviewBufName)
        call nvim_buf_set_lines(l:previewBufnr, 0, len(l:msg), 0, l:msg)
      else
        echohl Keyword | echo join(l:msg, "\n") | echohl None
      endif
      let s:cleared = 0
      let s:moved = 0
      return
    endif
  endif
  if s:cleared == 0
    if g:LanguageClientHoverPreview
      if g:LanguageClientHoverPreviewClose
        silent! pclose
      else
        let l:previewBufnr = bufnr(g:LanguageClientPreviewBufName)
        if l:previewBufnr != -1
          let l:lines = nvim_buf_get_lines(l:previewBufnr, 0, -1, 0)
          for l:i in range(0, len(l:lines) - 1)
            let l:lines[l:i] = ""
          endfor
          call nvim_buf_set_lines(l:previewBufnr, 0, len(l:lines), 0, l:lines)
        endif
      endif
    else
      echo ""
    endif
    let s:cleared = 1
    let s:moved = 0
  endif
endfunc

function! s:languageClientHover() abort
    let l:params = {
      \ 'filename':  LSP#filename(),
      \ 'text':      LSP#text(),
      \ 'line':      LSP#line(),
      \ 'character': LSP#character(),
      \ 'handle':    v:false,
      \ }
    return LanguageClient#Call('textDocument/hover', l:params, function("LanguageClientHoverCb"))
endfunction

func! LanguageClientAliveCb(res)
  let l:clientStatus = a:res.result
  if l:clientStatus == v:true
    call s:languageClientHover()
  endif
endfunc

let s:lastline = ""
let s:lastpos = ""
func! s:hold()
  let l:line = getline(line("."))
  let l:pos = join(getpos("."), ",")
  if s:moved == 1 && g:LanguageClientHoverEnabled == 1
    \ && (l:line != s:lastline || l:pos != s:lastpos)
    let s:lastline = l:line
    let s:lastpos = l:pos
    call LanguageClient#alive(function("LanguageClientAliveCb"))
  endif
endfunc

func! s:moved()
  let s:moved = 1
endfunc

func! s:enableHover()
  if g:LanguageClientPreviewHeight >= 0
    let s:orig_preview_height = &previewheight
    exec "set previewheight=" . g:LanguageClientPreviewHeight
  endif
  augroup LanguageClient_textDocumentHover
    au!
    au CursorMoved * call <sid>moved()
    au CursorHold  * call <sid>hold()
  augroup END
endfunc

func! s:disableHover()
  if s:orig_preview_height
    exec "set previewheight=" . s:orig_preview_height
  endif
  augroup! LanguageClient_textDocumentHover
endfunc

augroup LanguageClientListener
  au!
  au User LanguageClientStarted call <sid>enableHover()
  au User LanguageClientStopped call <sid>disableHover()
augroup END
