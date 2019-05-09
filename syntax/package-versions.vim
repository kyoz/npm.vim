if exists('b:current_syntax')
    finish
endif

" Keyword
syntax match packageVersionKeyword '\%<2l\s.*'

" Function
syntax match packageVersionFunction '\v\[|\]'

" String
syntax match packageVersionString '\v[0-9]+.+$'


highlight link packageVersionKeyword Keyword
highlight link packageVersionFunction Function
highlight link packageVersionString String

let b:current_syntax = 'package-versions'
