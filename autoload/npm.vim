function! npm#get_cli()
    let l:cli_version_regex = '\v[0-9]+\.[0-9]+\.?([0-9]+)?-?(.+)?'
    let l:npm_version       = split(system('nspm -v'), '\n')[0]
    let l:yarn_version      = split(system('yarn -v'), '\n')[0]

    if l:npm_version =~# l:cli_version_regex
        let g:npm_cli = 'npm'
        let g:npm_cli_version = l:npm_version
    elseif l:yarn_version =~# l:cli_version_regex
        let g:npm_cli = 'yarn'
        let g:npm_cli_version = l:yarn_version
    endif

	let g:npm_inited = 1
endfunction

function! npm#get_package_version(package_name)
    if !exists('g:npm_inited')
        return
	endif

    if len(a:package_name) > 0
        if g:npm_cli == 'npm'
            echo split(system('npm view ' .  a:package_name . ' version'), '\n')[0]
        else
            echo split(system('yarn info ' . a:package_name . ' version'), '\n')[1]
        endif
    else
        echohl ErrorMsg
        echo 'You must provide a package name !'
        echohl None
    endif
endfunction

function! npm#info()
    if !exists('g:npm_inited')
        return
	endif

    if exists('g:npm_cli') && exists('g:npm_cli_version')
        echo 'Package Manager: ' . g:npm_cli . ' (' . g:npm_cli_version . ')'
    else
        echohl ErrorMsg
        echo 'You must install Npm or Yarn to use this plugin !'
        echohl None
    endif
endfunction
