" Vim indent file
" Language: Falcon
" Maintainer: Steven Oliver <oliver.steven@gmail.com>
" Website: https://steveno@github.com/steveno/falconpl-vim.git
" Credits: Thanks to the ruby.vim authors, I borrow a lot!
" ------------------------------------------------------------
" Previous Maintainer: Brent A. Fulgham <bfulgham@debian.org>

"======================================
"       SETUP
"======================================

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" We're indenting falconpl not C
setlocal nosmartindent

" Setup indent function and when to use it
setlocal indentexpr=FalconGetIndent()
setlocal indentkeys=0{,0},0),0],!^F,o,O,e
setlocal indentkeys+==~case,=~catch,=~default,=~elif,=~else,=~end,=~\" 

" Define the appropriate indent function but only once
setlocal indentexpr=FalconGetIndent()
if exists("*FalconGetIndent")
  finish
endif

" Regex of syntax group names that are strings or are comments.
let s:syng_strcom = '\<falcon\%(String\|StringEscape\|Comment\)\>'

" Regex of syntax group names that are strings.
let s:syng_string = '\<falcon\%(String\|StringEscape\)\>'

" Expression used to check whether we should skip a match with searchpair().
let s:skip_expr = "synIDattr(synID(line('.'),col('.'),1),'name') =~ '".s:syng_strcom."'"

" Keywords to indent on
let s:falcon_indent_keywords = '^\s*\(case\|catch\|class\|enum\|default\|elif\|else' .
    \ '\|function\|if.*"[^"]*:.*"\|if \(\(:\)\@!.\)*$\|loop\|object\|select\|switch' .
    \ '\|while\|for\)'

" Keywords to deindent on
let s:falcon_deindent_keywords = '^\s*\(case\|catch\|default\|elif\|else\|end\)'

"======================================
"       INDENT ROUTINE
"======================================

function FalconGetIndent()
  " Get the line to be indented
  let cline = getline(v:lnum)

  " Don't reindent comments on first column
  if cline =~ s:syng_strcom
    return 0
  endif

  "Find the previous non-blank line
  let lnum = prevnonblank(v:lnum - 1)
  "Use zero indent at the top of the file
  if lnum == 0
    return 0
  endif

  let prevline=getline(lnum)
  let ind = indent(lnum)
  let chg = 0

  " If previous line was a comment, use its indent
  if prevline =~ s:falcon_strcom
   return ind
  endif

  " If the start of the line = ", then indent to the previous lines 1st "
  if cline =~? '^\s*"'
    let chg = chg + &sw
  endif

  " If previous line started with a " and this one doesn't, unindent
  if prevline =~? '^\s*"' && cline =~? '^\s*'
    let chg = chg - &sw
  endif

  " If previous line was a 'define', indent
  if prevline =~? s:falcon_indent_keywords
    let chg = &sw
  " If previous line opened a parenthesis, and did not close it, indent
  elseif prevline =~ '^.*(\s*[^)]*\((.*)\)*[^)]*$'
    return = match( prevline, '(.*\((.*)\|[^)]\)*.*$') + 1
  "elseif prevline =~ '^.*(\s*[^)]*\((.*)\)*[^)]*$'
  elseif prevline =~ '^[^(]*)\s*$'
    " This line closes a parenthesis.  Find opening
    let curr_line = prevnonblank(lnum - 1)
    while curr_line >= 0
      let str = getline(curr_line)
      if str !~ '^.*(\s*[^)]*\((.*)\)*[^)]*$'
	let curr_line = prevnonblank(curr_line - 1)
      else
	break
      endif
    endwhile
    if curr_line < 0
      return -1
    endif
    let ind = indent(curr_line)
  endif

  " If previous line ended in a comma, indent again.
  if prevline =~? ',\s*$'
    let chg = chg + &sw
  endif


  " If a line starts with end, un-indent (even if we just indented!)
  if cline =~? s:falcon_deintent_keywords
    let chg = chg - &sw
  endif

  return ind + chg
endfunction

"---------------------------------------------
" vim: set sw=4 sts=4 et tw=80 :
"

