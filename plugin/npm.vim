if v:version < 800
    finish
endif

if !exists('g:npm_loaded')
    call npm#init_mappings()
endif
