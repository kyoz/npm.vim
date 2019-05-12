if v:version < 800
    finish
endif

if !exists('g:npm_cli')
    call npm#get_cli()
endif
