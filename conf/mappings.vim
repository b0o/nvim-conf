""" mappings.vim
""" mappings for various modes

""" Unmaps

" Disable C-z suspend
map  <C-z> <Nop>
map! <C-z> <Nop>

""" General

" Disable Ex mode
nnoremap Q <nop>

" delete while in insert mode
inoremap <C-d> <C-o>dd
inoremap <C-c> <C-o>D

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
nnoremap <silent> Q :lclose \| pclose \| confirm q<cr>

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
nnoremap <silent> <leader>W :setlocal wrap!<CR>:setlocal wrap?<CR>

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
nnoremap <leader>m :<c-u><c-r><c-r>='let @'. v:register .' = '. string(getreg(v:register))<cr><c-f><left>

" Force redraw
" See: https://github.com/mhinz/vim-galore#saner-ctrl-l
nnoremap <leader>l :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>

" Reload vim configuration
nnoremap <silent> <leader>R :so ~/.config/nvim/init.vim<return><esc>

" goto file under cursor in new tab
noremap gF <C-w>gf

" Reload vim configuration
nnoremap <leader>N :call TabToNewWindow()<cr>

""" Command mode

" emacs-style movements
cnoremap <C-a>  <Home>
cnoremap <C-b>  <Left>
cnoremap <C-f>  <Right>
cnoremap <C-d>  <Delete>
cnoremap <M-b>  <S-Left>
cnoremap <M-f>  <S-Right>
cnoremap <C-g>  <C-c>

" Make c-n and c-p behave like up/down arrows, i.e. take into account the
" beginning of the text entered in the command line when jumping
" See: https://github.com/mhinz/vim-galore#saner-command-line-history
cnoremap <c-n>  <down>
cnoremap <c-p>  <up>

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

"" Interleave
" interleave two same-sized contiguous blocks
" Select your two contiguous, same-sized blocks, and use it to Interleave ;)
vnoremap <silent> <leader>I <esc>:call Interleave()<CR>

"" PasteRestore
" paste register without overwriting with the original selection
vnoremap <silent> <expr> p PasteRestore()

"" TComment
" Toggle comments with <M-/>
noremap <silent> <M-/> :TComment<Cr>

"" Term
" launch terminal size 10
nnoremap <leader>t :10Term<CR>

" Allow hitting <C-S-n> to switch to normal mode in terminal mode
tnoremap <C-S-n> <C-\><C-n>

"" Conceal
nnoremap <silent> <leader>cl :call ToggleConcealLevel()<cr>
nnoremap <silent> <leader>cc :call ToggleConcealCursor()<cr>

"" Modeline
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

"" Goyo
nnoremap <silent> <leader>go :Goyo<CR>

"" VCoolor
nmap <silent> <leader>co :VCoolor<CR>

"" Tagbar
map <silent> <leader>b :TagbarToggle<Cr>
map <silent> <leader>B :TagbarOpen fj<Cr>

"" LeaderHelper.vim
nmap <C-space> :call LeaderHelperPrompt('n')<cr>
imap <expr> <C-space> LeaderHelperPrompt('n')

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
