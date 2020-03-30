""" deoplete.vim
" configuration for the plugin Shougo/deoplete.vim

set completeopt+=noinsert
set completeopt+=noselect
set completeopt+=preview

let g:deoplete#enable_at_startup = 1

call g:deoplete#custom#option('refresh_always', v:true)
call g:deoplete#custom#option('auto_refresh_delay', 50)
call g:deoplete#custom#option('smart_case', v:true)

call g:deoplete#custom#source('_', 'converters', ['converter_remove_overlap', 'converter_truncate_abbr'])

let g:deoplete#lock_buffer_name_pattern = '\*ku\*'

let g:deoplete#sources#syntax#min_keyword_length = 1

" let g:deoplete#sources#go#use_cache = 1
" let g:deoplete#sources#go#json_directory = '~/.cache/deoplete/golang'

" let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'
" let g:deoplete#sources#clang#clang_header = '/usr/lib/clang/6.0.1/include/'
