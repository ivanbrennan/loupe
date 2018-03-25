function! loupe#prepare_highlights() abort
  call loupe#private#set_hlsearch()
  call loupe#private#next_cursormove_adds_hlmatch()
endfunction

function! loupe#add_highlights() abort
  call loupe#private#set_hlsearch()
  call loupe#private#add_hlmatch()
endf

function! loupe#clear_highlight() abort
  call loupe#private#remove_cursormove_autocmd()
  call loupe#private#set_hlsearch(0)
endfunction

function! loupe#toggle_highlight() abort
  if exists('w:loupe_hlmatch') || get(v:, 'hlsearch', 0)
    call loupe#clear_highlight()
    redraw
  else
    call loupe#add_highlights()
  endif
endf

" Called from WinEnter autocmd to clean up stray `matchadd()` vestiges.
" If we switch into a window and there is no 'hlsearch' in effect but we do have
" a `w:loupe_hlmatch` variable, it means that `:nohiglight` was probably run
" from another window and we should clean up the straggling match and the
" window-local variable.
function! loupe#cleanup() abort
  if !exists('v:hlsearch') || !v:hlsearch
    call loupe#clear_highlight()
  endif
endfunction
