if exists('b:current_syntax')
    finish
endif

" Keyword
syntax match packageLatestVersionKeyword 'Latest: '

highlight link packageLatestVersionKeyword Function

let b:current_syntax = 'package-latest-version'
