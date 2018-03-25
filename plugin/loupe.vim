if exists('g:loaded_loupe') || &compatible || v:version < 700
  finish
endif
let g:loaded_loupe = 1

augroup LoupeHighlight
  autocmd!

  autocmd InsertEnter,WinLeave * call loupe#clear_highlight()
  autocmd CmdlineEnter   [:>=@-] call loupe#clear_highlight()

  autocmd CmdlineEnter [/\?] call loupe#prepare_highlights()

  autocmd WinEnter * call loupe#cleanup()
augroup END

let s:clear=get(g:, 'loupe_toggle_highlight_map', 1)
if s:clear
  if !hasmapto('<Plug>(loupe_toggle_highlight)') && maparg('<leader>n', 'n') ==# ''
    nmap <silent> <unique> <leader>n <Plug>(loupe_toggle_highlight)
  endif
endif

nnoremap <silent> <Plug>(loupe_toggle_highlight) :call loupe#toggle_highlight()<CR>

function s:magic_string()
  let s:magic=get(g:, 'loupe_very_magic', 1)
  return s:magic ? '\v' : ''
endfunction

function s:unmagic_string()
  let s:magic=get(g:, 'loupe_very_magic', 1)
  return s:magic ? '' : '\v'
endfunction

nnoremap <expr> / '/' . <SID>magic_string()
nnoremap <expr> ? '?' . <SID>magic_string()
xnoremap <expr> / '/' . <SID>magic_string()
xnoremap <expr> ? '?' . <SID>magic_string()

nnoremap <expr> <Plug>(loupe_unmagic_forward_search)  '/' . <SID>unmagic_string()
nnoremap <expr> <Plug>(loupe_unmagic_backward_search) '?' . <SID>unmagic_string()
xnoremap <expr> <Plug>(loupe_unmagic_forward_search)  '/' . <SID>unmagic_string()
xnoremap <expr> <Plug>(loupe_unmagic_backward_search) '?' . <SID>unmagic_string()

if !empty(s:magic_string())
  " Any single-byte character may be used as a delimiter except \, ", | and
  " alphanumerics. See `:h E146`.
  cnoremap <expr> ! loupe#private#very_magic_slash('!')
  cnoremap <expr> # loupe#private#very_magic_slash('#')
  cnoremap <expr> $ loupe#private#very_magic_slash('$')
  cnoremap <expr> % loupe#private#very_magic_slash('%')
  cnoremap <expr> & loupe#private#very_magic_slash('&')
  cnoremap <expr> ' loupe#private#very_magic_slash("'")
  cnoremap <expr> ( loupe#private#very_magic_slash('(')
  cnoremap <expr> ) loupe#private#very_magic_slash(')')
  cnoremap <expr> * loupe#private#very_magic_slash('*')
  cnoremap <expr> + loupe#private#very_magic_slash('+')
  cnoremap <expr> , loupe#private#very_magic_slash(',')
  cnoremap <expr> - loupe#private#very_magic_slash('-')
  cnoremap <expr> . loupe#private#very_magic_slash('.')
  cnoremap <expr> / loupe#private#very_magic_slash('/')
  cnoremap <expr> : loupe#private#very_magic_slash(':')
  cnoremap <expr> ; loupe#private#very_magic_slash(';')
  cnoremap <expr> < loupe#private#very_magic_slash('<')
  cnoremap <expr> = loupe#private#very_magic_slash('=')
  cnoremap <expr> > loupe#private#very_magic_slash('>')
  cnoremap <expr> ? loupe#private#very_magic_slash('?')
  cnoremap <expr> @ loupe#private#very_magic_slash('@')
  cnoremap <expr> [ loupe#private#very_magic_slash('[')
  cnoremap <expr> ] loupe#private#very_magic_slash(']')
  cnoremap <expr> ^ loupe#private#very_magic_slash('^')
  cnoremap <expr> _ loupe#private#very_magic_slash('_')
  cnoremap <expr> ` loupe#private#very_magic_slash('`')
  cnoremap <expr> { loupe#private#very_magic_slash('{')
  cnoremap <expr> } loupe#private#very_magic_slash('}')
  cnoremap <expr> ~ loupe#private#very_magic_slash('~')
endif

function! s:map(keys)
  let s:center=get(g:, 'loupe_center_results', 1)
  let s:center_string=s:center ? 'zz' : ''

  if !hasmapto('<Plug>(loupe-' . a:keys . ')')
    execute 'nmap <silent> ' . a:keys . ' <Plug>(loupe-' . a:keys . ')'
  endif
  execute 'nnoremap <silent> <Plug>(loupe-' . a:keys . ')' .
        \ ' ' .
        \ a:keys .
        \ 'zv' .
        \ s:center_string .
        \ ':call loupe#add_highlights()<CR>'
endfunction

call s:map('#')  " <Plug>(loupe-#)
call s:map('*')  " <Plug>(loupe-*)
call s:map('N')  " <Plug>(loupe-N)
call s:map('g#') " <Plug>(loupe-g#)
call s:map('g*') " <Plug>(loupe-g*)
call s:map('n')  " <Plug>(loupe-n)

" insanity ensues
nmap <silent> <Plug>(loupe_cword)
      \ Mmz<C-O><Plug>(loupe-*)<Plug>(loupe-N)`zzz<C-O><Plug>(loupe_toggle_highlight)
