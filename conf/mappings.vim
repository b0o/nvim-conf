""" mappings.vim
""" mappings for various modes

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

" Indent visual selection without clearing selection
vmap > >gv
vmap < <gv

" quit active
nnoremap <silent> Q :confirm q \| pclose<cr>

" quit all
nnoremap ZQ :confirm qall<cr>

" save file
noremap <C-s> :w<cr>

" quickly enter command mode with substitution commands prefilled
nnoremap <leader>/ :%s/
nnoremap <leader>? :%S/
vnoremap <leader>/ :s/
vnoremap <leader>? :S/

" Toggle line wrapping
nnoremap <silent> <leader>W :setlocal wrap!<CR>:setlocal wrap?<CR>

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

" Duplicate line downwards/upwards
nnoremap <C-j> "dY"dp
nnoremap <C-k> "dY"dPj

" Duplicate selection downwards/upwards
vnoremap <C-j> "dy`>"dpgv
vnoremap <C-k> "dy`<"dPjgv

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
nnoremap <silent> <leader>s :new<return><esc>
nnoremap <silent> <leader>S :split<return><esc>
nnoremap <silent> <leader>v :vnew<return><esc>
nnoremap <silent> <leader>V :vsplit<return><esc>

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

"" Denite
nnoremap <leader>D   :Denite<space>
nnoremap <leader>db  :Denite buffer<cr>
nnoremap <leader>dch :Denite change<cr>
nnoremap <leader>dcs :Denite colorscheme<cr>
nnoremap <leader>dco :Denite command<cr>
nnoremap <leader>dch :Denite command_history<cr>
nnoremap <leader>dec :Denite decls<cr>
nnoremap <leader>di  :Denite dein<cr>
nnoremap <leader>dil :Denite dein_log<cr>
nnoremap <leader>dir :Denite directory_rec<cr>
nnoremap <leader>df  :Denite file<cr>
nnoremap <leader>dfo :Denite file/old<cr>
nnoremap <leader>dfp :Denite file/point<cr>
nnoremap <leader>dfr :Denite file/rec<cr>
nnoremap <leader>dft :Denite filetype<cr>
nnoremap <leader>dgr :Denite grep<cr>
nnoremap <leader>dh  :Denite help<cr>
nnoremap <leader>dj  :Denite jump<cr>
nnoremap <leader>dl  :Denite line<cr>
nnoremap <leader>dm  :Denite menu<cr>
nnoremap <leader>ds  :Denite neosnippet<cr>
nnoremap <leader>do  :Denite output<cr>
nnoremap <leader>dol :Denite outline<cr>
nnoremap <leader>dr  :Denite register<cr>
nnoremap <leader>dt  :Denite tag<cr>

"" Goyo
nnoremap <silent> <leader>go :Goyo<CR>
nnoremap <silent> <leader>g* :echo foo<CR>

"" VCoolor
nmap <silent> <leader>co :VCoolor<CR>

"" Tagbar
map <silent> <leader>b :TagbarToggle<Cr>
map <silent> <leader>B :TagbarOpen fj<Cr>

"" LeaderHelper
nmap <C-space> :call LeaderHelperPrompt('n')<cr>
imap <expr> <C-space> LeaderHelperPrompt('n')

"" GHC-Mod
" map <leader>t :GhcModType<return><esc>

"" vim-go
nnoremap <silent> <leader>gd :GoDef()<Cr>
nnoremap <silent> <leader>gf :GoFmt<Cr>
nnoremap <leader>gi :GoImport<space>
nnoremap <leader>gI :GoDrop<space>
nnoremap <silent> <leader>gt :GoInfo()<Cr>

"" ale.vim
map <leader>af :ALEFix<Cr>
map <leader>al :ALELint<Cr>

"" Autocompletion
imap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
imap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"" LanguageClient
nnoremap <silent> <leader>k :call LanguageClientHoverToggle()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> gD :call LanguageClient#textDocument_definition({"gotoCmd": "tabedit"})<CR>
nnoremap <silent> <leader>gr :call LanguageClient#textDocument_rename()<CR>

"" NeoSnippet
imap <C-e> <Plug>(neosnippet_expand_or_jump)
smap <C-e> <Plug>(neosnippet_expand_or_jump)
nmap <C-e> <Plug>(neosnippet_expand_target)
xmap <C-e> <Plug>(neosnippet_expand_target)

imap <expr><CR>
\ (pumvisible() && neosnippet#expandable()) ? "\<Plug>(neosnippet_expand_or_jump)" : "\<CR>"
