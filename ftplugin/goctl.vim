" Filetype plugin for goctl .api files

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" Comment settings
setlocal commentstring=//\ %s
setlocal comments=s1:/*,mb:*,ex:*/,://

" Indentation
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal expandtab

" Bracket matching
setlocal matchpairs+=<:>

" Folding
setlocal foldmethod=syntax

" Undo settings when switching filetype
let b:undo_ftplugin = "setlocal commentstring< comments< tabstop< shiftwidth< softtabstop< expandtab< matchpairs< foldmethod<"
