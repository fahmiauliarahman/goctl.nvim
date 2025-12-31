" Vim syntax file
" Language: goctl (.api files)
" Maintainer: goctl.nvim

if exists("b:current_syntax")
  finish
endif

" Comments
syn keyword goctlTodo contained TODO FIXME XXX NOTE
syn match goctlComment "//.*$" contains=goctlTodo
syn region goctlComment start="/\*" end="\*/" contains=goctlTodo

" Strings
syn region goctlString start='"' end='"' skip='\\"'
syn region goctlString start='`' end='`'
syn region goctlString start="'" end="'" skip="\\'"

" Keywords
syn keyword goctlKeyword type struct interface map func const var import package
syn keyword goctlControl if else for range return break continue switch case default defer go select fallthrough goto

" HTTP Methods
syn keyword goctlHttpMethod GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH
syn keyword goctlHttpMethod get head post put delete connect options trace patch

" Service keywords
syn keyword goctlService service
syn keyword goctlReturns returns

" Annotations
syn match goctlAnnotation "@doc"
syn match goctlAnnotation "@server"
syn match goctlAnnotation "@handler"

" Info block
syn keyword goctlInfo info
syn keyword goctlInfoKey title desc author email version

" Types
syn keyword goctlType bool byte string error
syn keyword goctlType int int8 int16 int32 int64
syn keyword goctlType uint uint8 uint16 uint32 uint64
syn keyword goctlType float32 float64 complex64 complex128
syn keyword goctlType uintptr rune any

" Constants
syn keyword goctlConstant true false nil iota

" Numbers
syn match goctlNumber "\<\d\+\>"
syn match goctlNumber "\<0x[0-9a-fA-F]\+\>"
syn match goctlNumber "\<0o[0-7]\+\>"
syn match goctlNumber "\<0b[01]\+\>"
syn match goctlFloat "\<\d\+\.\d*\>"
syn match goctlFloat "\<\.\d\+\>"

" URL paths in service definitions
syn match goctlPath "/[A-Za-z0-9_/:-]*" contained

" Struct tags
syn match goctlTag '`[^`]*`'
syn match goctlTagKey contained "json\|form\|path\|validate\|optional"

" Operators
syn match goctlOperator "[-+*/%&|^~<>=!]"
syn match goctlOperator ":="
syn match goctlOperator "&&\|||"
syn match goctlOperator "==\|!=\|<=\|>="

" Delimiters
syn match goctlDelimiter "[,;:]"
syn match goctlBracket "[(){}[\]]"

" Type declarations (highlight the type name)
syn match goctlTypeDecl "\<type\s\+\zs\w\+" contained

" Service name
syn match goctlServiceName "\<service\s\+\zs[A-Za-z][A-Za-z0-9_.-]*"

" Define highlighting
hi def link goctlTodo Todo
hi def link goctlComment Comment
hi def link goctlString String
hi def link goctlKeyword Keyword
hi def link goctlControl Conditional
hi def link goctlHttpMethod Function
hi def link goctlService Keyword
hi def link goctlReturns Keyword
hi def link goctlAnnotation PreProc
hi def link goctlInfo Keyword
hi def link goctlInfoKey Identifier
hi def link goctlType Type
hi def link goctlConstant Constant
hi def link goctlNumber Number
hi def link goctlFloat Float
hi def link goctlPath String
hi def link goctlTag Special
hi def link goctlTagKey Identifier
hi def link goctlOperator Operator
hi def link goctlDelimiter Delimiter
hi def link goctlBracket Delimiter
hi def link goctlTypeDecl Type
hi def link goctlServiceName Type

let b:current_syntax = "goctl"
