if exists('b:current_syntax')
    finish
endif

" Keyword
syntax match packageVersionKeyword 'Latest: '

highlight link packageVersionKeyword Function

let b:current_syntax = 'package-latest-version'
