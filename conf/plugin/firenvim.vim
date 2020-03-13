""" firenvim.vim
""" configuration for the plugin glacambre/firenvim
" OnLoad
if exists('g:started_by_firenvim')
  set guifont=InputMono\ Nerdg Font:h12
endif

" OnUIEnter
function! OnUIEnter(event) abort
  if !s:IsFirenvimActive(a:event)
    return
  endif
  set guifont=InputMono\ Nerdg Font:h12
endfunction

function! s:IsFirenvimActive(event) abort
  if !exists('*nvim_get_chan_info')
    return 0
  endif
  let l:ui = nvim_get_chan_info(a:event.chan)
  return has_key(l:ui, 'client') && has_key(l:ui.client, "name") &&
      \ l:ui.client.name is# "Firenvim"
endfunction

autocmd UIEnter * call OnUIEnter(deepcopy(v:event))
