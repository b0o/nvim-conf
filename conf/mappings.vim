""" mappings.vim

" Disable C-z suspend
map  <C-z> <Nop>
map! <C-z> <Nop>

" Disable C-c warning
map  <C-c> <Nop>
map! <C-c> <Nop>

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

" move to the end of the previous word
nnoremap <M-b> ge

" insert a single character
" https://vim.fandom.com/wiki/Insert_a_single_character
nnoremap <silent> <M-i> :exec "normal i".nr2char(getchar())."\e"<CR>

" Indent visual selection without clearing selection
vmap > >gv
vmap < <gv

" quit active
nnoremap <silent> Q :CloseWin<cr>

" quit all
nnoremap ZQ :confirm qall<cr>

" close tab (except last one)
nnoremap <C-w> :tabclose<cr>

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
nnoremap <expr> <C-y> pumvisible() ? "\<C-y>" : '"+yy'
vnoremap <expr> <C-y> pumvisible() ? "\<C-y>" : '"+y'

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
nnoremap <C-M-k> "dY"dP

" Duplicate selection downwards/upwards
vnoremap <C-M-j> "dy`<"dPjgv
vnoremap <C-M-k> "dy`>"dpgv

" Clear search highlight and command-line on esc
nnoremap <silent> <esc> :noh \| echo ""<cr>

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
" emacs-style motion & killing
inoremap <C-a>  <Home>
inoremap <C-e>  <End>
inoremap <C-b>  <Left>
inoremap <C-f>  <Right>
inoremap <C-n>  <Down>
inoremap <M-b>  <S-Left>
inoremap <M-f>  <S-Right>
inoremap <M-d>  <C-o>de
inoremap <C-k>  <C-o>D
inoremap <C-p>  <Up>
inoremap <C-d>  <Delete>

" restore support for digraphs to M-k
inoremap <M-k>  <C-k>

" overload tab key to also perform next/prev in popup menus
inoremap <silent> <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

""" Command mode
" emacs-style motion & killing
cnoremap         <C-a> <Home>
cnoremap         <C-b> <Left>
cnoremap         <C-d> <Delete>
cnoremap         <C-f> <Right>
cnoremap         <C-g> <C-c>
cnoremap         <C-k> <C-\>e(" ".getcmdline())[:getcmdpos()-1][1:]<Cr>
cnoremap         <M-f> <C-\>eCmdlineMoveWord( 1, 0)<Cr>
cnoremap         <M-b> <C-\>eCmdlineMoveWord(-1, 0)<Cr>
cnoremap         <M-d> <C-\>eCmdlineMoveWord( 1, 1)<Cr>
cnoremap <M-Backspace> <C-\>eCmdlineMoveWord(-1, 1)<Cr>

" restore support for digraphs to M-k
cnoremap <M-k>  <C-k>

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
tnoremap <silent> <M-'> <C-\><C-n>:tabn<cr>
tnoremap <silent> <M-;> <C-\><C-n>:tabp<cr>

" Rearrange tabs
noremap <silent> <M-"> :+tabm<cr>
noremap <silent> <M-:> :-tabm<cr>

" Open/close tabs
noremap <silent> <M-Cr> :tabnew<cr>
noremap <silent> <M-Backspace> :tabclose<cr>

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
"" vim-which-key
nnoremap <silent> <leader>         :WhichKey       mapleader<cr>
vnoremap <silent> <leader>         :WhichKeyVisual mapleader<cr>
nnoremap <silent> <localleader>    :WhichKey       maplocalleader<cr>
vnoremap <silent> <localleader>    :WhichKeyVisual maplocalleader<cr>
nnoremap <silent> g                :WhichKey       'g'<cr>
vnoremap <silent> g                :WhichKeyVisual 'g'<cr>
nnoremap <silent> <leader><leader> :WhichKey       nr2char(getchar())<cr>
vnoremap <silent> <leader><leader> :WhichKeyVisual nr2char(getchar())<cr>
nnoremap <silent> <F34>            :WhichKey       '<F34>'<cr>

" need to 'nore' map certain builtin 'g' bindings, otherwise WhichKey doesn't
" pass them through to vim
nnoremap gq gq
nnoremap gg gg

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

tnoremap <C-n> <C-n>
tnoremap <C-p> <C-p>
tnoremap <M-n> <M-n>
tnoremap <M-p> <M-p>

"" Modeline
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

"" Between.vim
" map gb :call Betwixt()<cr>

"" GHC-Mod
" map <leader>t :GhcModType<return><esc>

"" vim-go
" TODO: only apply these mappings in go files
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

"" LanguageClient
nnoremap <silent> <leader>k :call LanguageClientHoverToggle()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> gr :call LanguageClient#textDocument_references()<CR>
nnoremap <silent> gD :call LanguageClient#textDocument_definition({"gotoCmd": "tabedit"})<CR>
nnoremap <silent> <leader>gr :call LanguageClient#textDocument_rename()<CR>

"" vim-fugitive
nnoremap <leader>gA  :Git add --all<cr>
nnoremap <leader>gaa :Git add --all<cr>
nnoremap <leader>gaf :Git add :%<cr>

nnoremap <leader>gC  :Git commit --verbose<cr>
nnoremap <leader>gcc :Git commit --verbose<cr>
nnoremap <leader>gca :Git commit --verbose --all<cr>
nnoremap <leader>gcA :Git commit --verbose --amend<cr>

nnoremap <leader>gL  :Gclog!<cr>
nnoremap <leader>gll :Gclog!<cr>
nnoremap <leader>glL :tabnew \| Gclog<cr>

nnoremap <leader>gpa :Git push --all<cr>
nnoremap <leader>gpp :Git push<cr>
nnoremap <leader>gpl :Git pull<cr>

nnoremap <leader>gR  :Git reset<cr>

nnoremap <leader>gS  :Git status<cr>
nnoremap <leader>gss :Git status<cr>
nnoremap <leader>gst :Git status<cr>

nnoremap <leader>gsp :Gsplit<cr>

nnoremap <leader>GG  :Git<space>
nnoremap <leader>GA  :Git add<space>
nnoremap <leader>GC  :Git commit<space>
nnoremap <leader>GF  :Git fetch<space>
nnoremap <leader>GL  :Git log<space>
nnoremap <leader>GPP :Git push<space>
nnoremap <leader>GPL :Git pull<space>
nnoremap <leader>GS  :Git status<space>
" TODO: <leader> gX / gxx -> close all fugitive windows

"" vim-clap
" map <C-,> to \x1b[21;5~ (F34) in your terminal emulator
nnoremap <silent> <F34>C     :Clap<cr>
nnoremap <silent> <F34><F34> :Clap<cr>

nnoremap <silent> <F34>X     :call clap#floating_win#close()<cr>
nnoremap <silent> <F34>xx    :call clap#floating_win#close()<cr>

nnoremap <silent> <F34>B     :Clap buffers<cr>
nnoremap <silent> <F34>bb    :Clap buffers<cr>
nnoremap <silent> <F34>bgc   :Clap bcommits<cr>
nnoremap <silent> <F34>bu    :Clap buffers<cr>
nnoremap <silent> <F34>bl    :Clap blines<cr>

nnoremap <silent> <F34>cc    :Clap command<cr>
nnoremap <silent> <F34>cmd   :Clap command<cr>
nnoremap <silent> <F34>col   :Clap colors<cr>
nnoremap <silent> <F34>ch    :Clap command_history<cr>
nnoremap <silent> <F34>h     :Clap command_history<cr>

nnoremap <silent> <F34>F     :Clap files<cr>
nnoremap <silent> <F34>ff    :Clap files<cr>
nnoremap <silent> <F34>fi    :Clap files<cr>
nnoremap <silent> <F34><c-f> :Clap files<cr>
nnoremap <silent> <F34>ft    :Clap filetypes<cr>

nnoremap <silent> <F34>G     :Clap grep<cr>
nnoremap <silent> <F34>gg    :Clap grep<cr>
nnoremap <silent> <F34>gr    :Clap grep<cr>
nnoremap <silent> <F34>gc    :Clap commits<cr>
nnoremap <silent> <F34>gf    :Clap git_files<cr>
nnoremap <silent> <F34>gd    :Clap git_diff_files<cr>

nnoremap <silent> <F34>H     :Clap help_tags<cr>
nnoremap <silent> <F34>hh    :Clap help_tags<cr>
nnoremap <silent> <F34>hi    :Clap history<cr>
nnoremap <silent> <F34>hs    :Clap search_history<cr>
nnoremap <silent> <F34>h/    :Clap search_history<cr>
nnoremap <silent> <F34>/     :Clap search_history<cr>

nnoremap <silent> <F34>J     :Clap jumps<cr>
nnoremap <silent> <F34>jj    :Clap jumps<cr>
nnoremap <silent> <F34>ju    :Clap jumps<cr>

nnoremap <silent> <F34>L     :Clap lines<cr>
nnoremap <silent> <F34>li    :Clap lines<cr>
nnoremap <silent> <F34>lo    :Clap loclist<cr>
nnoremap <silent> <F34>ll    :Clap loclist<cr>

nnoremap <silent> <F34>Q     :Clap quickfix<cr>
nnoremap <silent> <F34>qq    :Clap quickfix<cr>
nnoremap <silent> <F34>qi    :Clap quickfix<cr>
nnoremap <silent> <F34>qf    :Clap quickfix<cr>

nnoremap <silent> <F34>M     :Clap maps<cr>
nnoremap <silent> <F34>mm    :Clap maps<cr>
nnoremap <silent> <F34>mr    :Clap marks<cr>
nnoremap <silent> <F34>mk    :Clap marks<cr>

nnoremap <silent> <F34>P     :Clap providers<cr>
nnoremap <silent> <F34>pp    :Clap providers<cr>
nnoremap <silent> <F34>pr    :Clap providers<cr>

nnoremap <silent> <F34>R     :Clap registers<cr>
nnoremap <silent> <F34>rr    :Clap registers<cr>
nnoremap <silent> <F34>re    :Clap registers<cr>

nnoremap <silent> <F34>T     :Clap tags<cr>
nnoremap <silent> <F34>tt    :Clap tags<cr>
nnoremap <silent> <F34>ta    :Clap tags<cr>

nnoremap <silent> <F34>W     :Clap windows<cr>
nnoremap <silent> <F34>ww    :Clap windows<cr>
nnoremap <silent> <F34>wi    :Clap windows<cr>

"" fzf
nnoremap <silent> <C-f><C-f> :Files<cr>
nnoremap <silent> <C-f>f     :Files<cr>
nnoremap <silent> <C-f><C-g> :GFiles<cr>
nnoremap <silent> <C-f>gg    :GFiles<cr>
nnoremap <silent> <C-f>gf    :GFiles<cr>
nnoremap <silent> <C-f><C-b> :Buffers<cr>
nnoremap <silent> <C-f>b     :Buffers<cr>
nnoremap <silent> <C-f><C-a> :Ag<cr>
nnoremap <silent> <C-f>a     :Ag<cr>
nnoremap <silent> <C-f>gc    :Commits<cr>
nnoremap <silent> <C-f><C-c> :Commands<cr>
nnoremap <silent> <C-f>c     :Commands<cr>
nnoremap <silent> <C-f><C-m> :Maps<cr>
nnoremap <silent> <C-f>m     :Maps<cr>

"" emmet.vim
let g:user_emmet_leader_key='<C-z>'

nmap <C-z><C-z> <C-z>,
imap <C-z><C-z> <C-z>,
vmap <C-z><C-z> <C-z>,
