function! s:setReg(reg)
	if a:reg !~# '^[a-z0-9"+*-:#%\.]$'
		echohl ErrorMsg
		echon "\rInvalid register name: ".a:reg
		echohl NONE
		return
	endif
	let g:pasteReg = a:reg
	let g:yankReg = a:reg
endfunction

function! s:setPasteReg(reg)
	if a:reg !~# '^[a-z0-9"+*-:#%\.]$'
		echohl ErrorMsg
		echon "\rInvalid register name: ".a:reg
		echohl NONE
		return
	endif
	let g:pasteReg = a:reg
endfunction

function! g:GetPasteReg()
	let l:reg = get(g:, 'pasteReg', '"')
	if l:reg !~# '^[a-z0-9"+*-:#%\.]$'
		let l:reg = '"'
	endif
	return l:reg
endfunction

function! s:setYankReg(reg)
	if a:reg !~# '^[a-z0-9"+*-:#%\.]$'
		echohl ErrorMsg
		echon "\rInvalid register name: ".a:reg
		echohl NONE
		return
	endif
	let g:yankReg = a:reg
endfunction

function! g:GetYankReg()
	let l:reg = get(g:, 'yankReg', '"')
	if l:reg !~# '^[a-z0-9"+*-:#%\.]$'
		let l:reg = '"'
	endif
	return l:reg
endfunction

nnoremap <expr> <plug>(regPasteAfter)  '"'.GetPasteReg().'p'
nnoremap <expr> <plug>(regPasteBefore) '"'.GetPasteReg().'P'
xnoremap <expr> <plug>(regPasteAfter)  '"'.GetPasteReg().'p'
xnoremap <expr> <plug>(regPasteBefore) '"'.GetPasteReg().'P'
nnoremap <expr> <plug>(regYank) '"'.GetYankReg().'y'
xnoremap <expr> <plug>(regYank) '"'.GetYankReg().'y'
nnoremap <expr> <plug>(regYankL) '"'.GetYankReg().'Y'
xnoremap <expr> <plug>(regYankL) '"'.GetYankReg().'Y'

nmap p <plug>(regPasteAfter)
nmap P <plug>(regPasteBefore)
xmap p <plug>(regPasteAfter)
xmap P <plug>(regPasteBefore)
nmap y <plug>(regYank)
nmap Y <plug>(regYankL)
xmap y <plug>(regYank)
xmap Y <plug>(regYankL)

command! -bar -nargs=1 SetReg call <sid>setReg(<q-args>)
command! -bar -nargs=1 SetPasteReg call <sid>setPasteReg(<q-args>)
command! -bar -nargs=1 SetYankReg call <sid>setYankReg(<q-args>)
command! -bar -nargs=0 NoPasteReg unlet g:pasteReg
command! -bar -nargs=0 NoYankReg unlet g:yankReg

function! s:regPrompt()
  echon "SetReg: "
  let l:rawchar = getchar()
  let l:char = nr2char(l:rawchar)
  call s:setReg(l:char)
  redraw
  echon ""
endfunction

command! -bar -nargs=0 RegPrompt call <sid>regPrompt()

nnoremap <leader>" :RegPrompt<cr>

call s:setReg("+")
