""" mappings.vim
""" mappings for various modes

" Disable C-z suspend
map  <C-z> <Nop>
map! <C-z> <Nop>

""" General

" Disable Ex mode
nnoremap Q <nop>

" make j and k treat wrapped lines as independent lines
" https://statico.github.io/vim.html
" https://stackoverflow.com/a/21000307
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" Quick movement
noremap J 5j
noremap K 5k

map <M-L> LJ
map <M-H> HK

" since the vim-wordmotion plugin overrides the normal `w` wordwise movement,
" make `W` behave as vanilla `w`
nnoremap W w

" Indent visual selection without clearing selection
vmap > >gv
vmap < <gv

" quit active
nnoremap <silent> Q :CloseWin<cr>

" quit all
nnoremap ZQ :confirm qall<cr>

" close window (except last one)
nnoremap <C-w> :close<cr>

" save file
noremap <C-s> :w<cr>

" quickly enter command mode with substitution commands prefilled
nnoremap <leader>/ :%s/
nnoremap <leader>? :%S/
vnoremap <leader>/ :s/
vnoremap <leader>? :S/

" Toggle line wrapping
nnoremap <silent> <leader>w :setlocal wrap!<CR>:setlocal wrap?<CR>

" Insert a space and then paste before/after cursor
nnoremap <M-o> maDo<esc>p`a
nnoremap <M-O> maDO<esc>p`a

" Copy to system clipboard
vnoremap <leader>y  "+y
nnoremap <leader>Y  "+yg_
nnoremap <leader>yy "+yy
vnoremap <C-y>  "+y
nnoremap <C-y>  "+y

" yank path of current file to system clipboard
nnoremap <silent> <leader>yp :let @+ = expand("%:p")<cr>:echom "Copied " . @+<cr>

" Paste from system clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P
vnoremap <C-p>  "+p
nnoremap <C-p>  "+p

" Insert a space and then paste before/after cursor
nnoremap <M-p> a <esc>p
nnoremap <M-P> i <esc>P

" Duplicate line downwards/upwards
nnoremap <C-M-j> "dY"dp
nnoremap <C-M-k> "dY"dPj

" Duplicate selection downwards/upwards
vnoremap <C-M-j> "dy`>"dpgv
vnoremap <C-M-k> "dy`<"dPjgv

" Clear search highlight and command-line on esc
nnoremap <silent> <esc> :noh \| echo ""<cr>

" Quickly edit a macro
" See: https://github.com/mhinz/vim-galore#quickly-edit-your-macros
function! g:EditMacro(...)
  let l:register = v:register
  if len(a:000) >= 1
    let l:register = a:0
  endif
  let l:str = 'let @' . l:register . ' = ' . string(getreg(l:register))
  execute "normal :" . l:str . "\<cr>"
  " execute "nnoremap <leader>MMMMM :" . l:str . "<cr>q:"
  " normal <leader>MMMMM
  " nunmap <leader>MMMMM
  " :<c-u><c-r><c-r>=<cr><c-f><left>
endfunction
nnoremap <expr> <leader>ma g:EditMacro("q")

" Force redraw
" See: https://github.com/mhinz/vim-galore#saner-ctrl-l
nnoremap <leader>l :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>

" Reload vim configuration
nnoremap <silent> <leader>rr :ReloadConfig<cr>

" goto file under cursor in new tab
noremap gF <C-w>gf

" open tab in new terminal instance
nnoremap <leader>W :call TabToNewWindow()<cr>

""" Insert Mode
" emacs-style movements
inoremap <C-a>  <Home>
inoremap <C-e>  <End>
inoremap <C-b>  <Left>
inoremap <C-f>  <Right>
inoremap <c-n>  <Down>
inoremap <c-p>  <Up>
inoremap <C-d>  <Delete>
inoremap <M-b>  <S-Left>
inoremap <M-f>  <S-Right>
inoremap <M-d>  <C-o>de

""" Command mode
" emacs-style movements
cnoremap <C-a>  <Home>
cnoremap <C-b>  <Left>
cnoremap <C-d>  <Delete>
cnoremap <C-f>  <Right>
cnoremap <M-b>  <S-Left>
cnoremap <M-f>  <S-Right>
cnoremap <C-g>  <C-c>

" Make c-n and c-p behave like up/down arrows, i.e. take into account the
" beginning of the text entered in the command line when jumping, but only if
" the pop-up menu (completion menu) is not visible
" See: https://github.com/mhinz/vim-galore#saner-command-line-history
cnoremap <expr> <c-p> pumvisible() ? "\<C-p>" : "\<up>"
cnoremap <expr> <c-n> pumvisible() ? "\<C-n>" : "\<down>"

""" Tabs

" Navigate left/right through tabs
noremap <silent> <M-'> :tabn<cr>
noremap <silent> <M-;> :tabp<cr>

" Rearrange tabs
noremap <silent> <M-"> :+tabm<cr>
noremap <silent> <M-:> :-tabm<cr>

" Open/close tabs
noremap <silent> <M-cr> :tabnew<cr>
noremap <silent> <M-backspace> :tabclose<cr>

" Navigation through tabs by index
noremap <silent> <M-1> :call Tabnm(1)<cr>
noremap <silent> <M-2> :call Tabnm(2)<cr>
noremap <silent> <M-3> :call Tabnm(3)<cr>
noremap <silent> <M-4> :call Tabnm(4)<cr>
noremap <silent> <M-5> :call Tabnm(5)<cr>
noremap <silent> <M-6> :call Tabnm(6)<cr>
noremap <silent> <M-7> :call Tabnm(7)<cr>
noremap <silent> <M-8> :call Tabnm(8)<cr>
noremap <silent> <M-9> :call Tabnm(9)<cr>
noremap <silent> <M-0> :call Tabnm(10)<cr>

""" Splits

" Navigate through splits in normal/visual/select/op-pending modes
noremap <M-h> <C-w>h
noremap <M-j> <C-w>j
noremap <M-k> <C-w>k
noremap <M-l> <C-w>l

" Alt+[hjkl] to navigate through splits in terminal mode
tnoremap <M-h> <C-\><C-n><C-w>h
tnoremap <M-j> <C-\><C-n><C-w>j
tnoremap <M-k> <C-\><C-n><C-w>k
tnoremap <M-l> <C-\><C-n><C-w>l

" resize splits left/right
noremap <M-[> <C-w>3<
noremap <M-]> <C-w>3>

" resize splits up/down
noremap <M-{> <C-w>3-
noremap <M-}> <C-w>3+

" create splits
nnoremap <silent> <leader>s  :new<cr>
nnoremap <silent> <leader>Ss :split<cr>
nnoremap <silent> <leader>v  :vnew<cr>
nnoremap <silent> <leader>Vv :vsplit<cr>

""" Plugins/functions
" vim-which-key
nnoremap <silent> <leader>         :WhichKey       mapleader<cr>
vnoremap <silent> <leader>         :WhichKeyVisual mapleader<cr>
nnoremap <silent> <localleader>    :WhichKey       maplocalleader<cr>
vnoremap <silent> <localleader>    :WhichKeyVisual maplocalleader<cr>
nnoremap <silent> g                :WhichKey       'g'<cr>
vnoremap <silent> g                :WhichKeyVisual 'g'<cr>
nnoremap <silent> <leader><leader> :WhichKey       nr2char(getchar())<cr>
vnoremap <silent> <leader><leader> :WhichKeyVisual nr2char(getchar())<cr>

"" Interleave
" interleave two same-sized contiguous blocks
" Select your two contiguous, same-sized blocks, and use it to Interleave ;)
vnoremap <silent> <leader>I <esc>:call Interleave()<CR>

"" PasteRestore
" paste register without overwriting with the original selection
" use P for original behavior
vnoremap <silent> <expr> p PasteRestore()

"" Term
" launch terminal size 10
nnoremap <leader>t :10Term<CR>

" switch to normal mode
tnoremap <C-S-n> <C-\><C-n>

" close terminal window
tnoremap <C-S-q> <C-\><C-n>:q<cr>

"" Conceal
" nnoremap <silent> <leader>cl :call ToggleConcealLevel()<cr>
" nnoremap <silent> <leader>cc :call ToggleConcealCursor()<cr>

"" Modeline
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

"" Between.vim
" map gb :call Betwixt()<cr>

"" GHC-Mod
" map <leader>t :GhcModType<return><esc>

"" vim-go
nnoremap <silent> <leader>gd :GoDef()<Cr>
nnoremap <silent> <leader>gf :GoFmt<Cr>
nnoremap          <leader>gi :GoImport<space>
nnoremap          <leader>gI :GoDrop<space>
nnoremap <silent> <leader>gt :GoInfo()<Cr>

"" ale.vim
nnoremap <leader>af :ALEFix<cr>
nnoremap <leader>al :ALELint<cr>

nmap ]a <Plug>(ale_next_wrap)
nmap [a <Plug>(ale_previous_wrap)
nmap ]e <Plug>(ale_next_wrap_error)
nmap [e <Plug>(ale_previous_wrap_error)
nmap ]w <Plug>(ale_next_wrap_warning)
nmap [w <Plug>(ale_previous_wrap_warning)

nnoremap <leader>ad :ALEDisable<cr>:let g:ale_enabled<cr>
nnoremap <leader>ae :ALEEnable<cr>:let g:ale_enabled<cr>
nnoremap <leader>aD :ALEToggle<cr>:let g:ale_enabled<cr>
nnoremap <leader>aE :ALEToggle<cr>:let g:ale_enabled<cr>
nnoremap <leader>as :let g:ale_fix_on_save=!g:ale_fix_on_save<cr>:let g:ale_fix_on_save<cr>
nnoremap <leader>aS :let g:ale_fix_on_save=0<cr>:let g:ale_fix_on_save<cr>

"" Autocompletion
imap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
imap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"" LanguageClient
nnoremap <silent> <leader>k :call LanguageClientHoverToggle()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> gD :call LanguageClient#textDocument_definition({"gotoCmd": "tabedit"})<CR>
nnoremap <silent> <leader>gr :call LanguageClient#textDocument_rename()<CR>

"" vim-fugitive
nnoremap <leader>gA  :Git add --all<cr>
nnoremap <leader>gaa :Git add --all<cr>
nnoremap <leader>gaf :Git add :%<cr>

nnoremap <leader>gC  :Gcommit --verbose<cr>
nnoremap <leader>gcc :Gcommit --verbose<cr>
nnoremap <leader>gca :Gcommit --verbose --all<cr>
nnoremap <leader>gcA :Gcommit --verbose --amend<cr>

nnoremap <leader>gL  :Gclog!<cr>
nnoremap <leader>gll :Gclog!<cr>
nnoremap <leader>glL :tabnew \| Gclog<cr>

nnoremap <leader>gpa :Gpush --all<cr>
nnoremap <leader>gpp :Gpush<cr>
nnoremap <leader>gpl :Gpull<cr>

nnoremap <leader>gR  :Git reset<cr>

nnoremap <leader>gS  :Gstatus<cr>
nnoremap <leader>gss :Gstatus<cr>
nnoremap <leader>gst :Gstatus<cr>

nnoremap <leader>gsp :Gsplit<cr>

nnoremap <leader>GG  :Git<space>
nnoremap <leader>GA  :Git add<space>
nnoremap <leader>GC  :Gcommit<space>
nnoremap <leader>GF  :Gfetch<space>
nnoremap <leader>GL  :Glog<space>
nnoremap <leader>GPP :Gpush<space>
nnoremap <leader>GPL :Gpull<space>
nnoremap <leader>GS  :Gstatus<space>
