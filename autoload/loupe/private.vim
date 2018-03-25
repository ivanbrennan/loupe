function! loupe#private#set_hlsearch(...)
  call s:delete_hlmatch()
  let &hlsearch = get(a:, 1, 1)
endfunction

function! s:delete_hlmatch()
  if exists('w:loupe_hlmatch')
    try
      call matchdelete(w:loupe_hlmatch)
    catch /\v<(E802|E803)>/
      " https://github.com/wincent/loupe/issues/1
    finally
      unlet w:loupe_hlmatch
    endtry
  endif
endfunction

function! loupe#private#add_hlmatch() abort
  call s:next_cursormove_clears_highlight()

  let highlight = get(g:, 'LoupeHighlightGroup', 'IncSearch')
  let pattern='\c\%#' . @/  " \c case insensitive
                            " \%# current cursor position
                            " @/ current search pattern
  let w:loupe_hlmatch = matchadd(highlight, pattern)
endfunction

function! s:next_cursormove_clears_highlight()
  augroup LoupeCursorMoved
    autocmd!
    autocmd CursorMoved * call loupe#clear_highlight()
  augroup END
endfunction

function! loupe#private#next_cursormove_adds_hlmatch()
  augroup LoupeCursorMoved
    autocmd!
    autocmd CursorMoved * call loupe#private#add_hlmatch()
  augroup END
endfunction

function! loupe#private#remove_cursormove_autocmd()
  augroup LoupeCursorMoved
    autocmd!
  augroup END
endfunction

" Dynamically returns "/" or "/\v" depending on the location of the just-typed
" "/" within the command-line. Only "/" that looks to be at the start of a
" command gets replaced. The "slash" is itself configurable via the `slash`
" argument, meaning that this function can be used in conjunction with other
" pattern delimiters like "?" and "@" etc (ie. "?" -> "?\v", "@" -> "@\v").
"
" Doesn't handle the full list of possible range types (specified in `:h
" cmdline-ranges`), but catches the most common ones.
function! loupe#private#very_magic_slash(slash) abort
  if !get(g:, 'loupe_very_magic', 1)
    return a:slash
  endif

  if getcmdtype() != ':'
    return a:slash
  endif

  " For simplicity, only consider "/" typed at the end of the command-line.
  let l:pos=getcmdpos()
  let l:cmd=getcmdline()
  if len(l:cmd) + 1 != l:pos
    return a:slash
  endif

  " Skip over ranges
  while 1
    let l:stripped=s:strip_ranges(l:cmd)
    if l:stripped ==# l:cmd
      break
    else
      let l:cmd=l:stripped
    endif
  endwhile

  if index(['g', 's', 'v'], l:cmd) != -1
    return a:slash . '\v'
  endif

  return a:slash
endfunction

function! s:strip_ranges(cmdline)
  let l:cmdline=a:cmdline

  " All the range tokens may be followed (several times) by '+' or '-' and an
  " optional number.
  let l:modifier='\([+-]\d*\)*'

  " Range tokens as specified in `:h cmdline-ranges`.
  let l:cmdline=substitute(l:cmdline, '^\d\+' . l:modifier, '', '') " line number
  let l:cmdline=substitute(l:cmdline, '^\.' . l:modifier, '', '') " current line
  let l:cmdline=substitute(l:cmdline, '^$' . l:modifier, '', '') " last line in file
  let l:cmdline=substitute(l:cmdline, '^%' . l:modifier, '', '') " entire file
  let l:cmdline=substitute(l:cmdline, "^'[a-z]\\c" . l:modifier, '', '') " mark t (or T)
  let l:cmdline=substitute(l:cmdline, "^'[<>]" . l:modifier, '', '') " visual selection marks
  let l:cmdline=substitute(l:cmdline, '^/[^/]\+/' . l:modifier, '', '') " /{pattern}/
  let l:cmdline=substitute(l:cmdline, '^?[^?]\+?' . l:modifier, '', '') " ?{pattern}?
  let l:cmdline=substitute(l:cmdline, '^\\/' . l:modifier, '', '') " \/ (next match of previous pattern)
  let l:cmdline=substitute(l:cmdline, '^\\?' . l:modifier, '', '') " \? (last match of previous pattern)
  let l:cmdline=substitute(l:cmdline, '^\\&' . l:modifier, '', '') " \& (last match of previous substitution)

  " Separators (see: `:h :,` and `:h :;`).
  let l:cmdline=substitute(l:cmdline, '^,', '', '') " , (separator)
  let l:cmdline=substitute(l:cmdline, '^;', '', '') " ; (separator)

  return l:cmdline
endfunction
