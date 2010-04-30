" Vim filetype plugin file
" Language:     Falcon
" Author:       Steven Oliver <oliver.steven@gmail.com>
" Copyright:    Copyright (c) 2009 Steven Oliver
" License:      You may redistribute this under the same terms as Vim itself

if &compatible || v:version < 700
    finish
endif

au BufNewFile,BufRead *.fal set filetype=falcon

"---------------------------------------------
" vim: set sw=4 sts=4 et tw=80 :
"

