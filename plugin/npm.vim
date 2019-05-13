if v:version < 800
    finish
endif

if !exists('g:npm_inited')
    call npm#init_mappings()
endif
