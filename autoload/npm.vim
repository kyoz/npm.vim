function! npm#get_cli()
    let l:cli_version_regex = '\v[0-9]+\.[0-9]+\.?([0-9]+)?'
    let l:npm_version       = split(system('npm -v'), '\n')[0]
    let l:yarn_version      = split(system('yarn -v'), '\n')[0]

    if l:npm_version =~# l:cli_version_regex
        let g:npm_cli = 'Npm'
        let g:npm_cli_version = l:npm_version
    elseif l:yarn_version =~# l:cli_version_regex
        let g:npm_cli = 'Yarn'
        let g:npm_cli_version = l:yarn_version
    endif
endfunction

function! npm#info()
    echomsg 'Package Manager: ' . g:npm_cli . ' (' . g:npm_cli_version . ')'
endfunction
