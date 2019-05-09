" Autoload Functions {{{
function! npm#get_cli() abort
    let l:cli_version_regex = '\v[0-9]+\.[0-9]+\.?([0-9]+)?-?(.+)?'
    let l:npm_version       = trim(system('npm -v'))
    let l:yarn_version      = trim(system('yarn -v'))

    if l:npm_version =~# l:cli_version_regex
        let g:npm_cli = 'npm'
        let g:npm_cli_version = l:npm_version
    elseif l:yarn_version =~# l:cli_version_regex
        let g:npm_cli = 'yarn'
        let g:npm_cli_version = l:yarn_version
    endif

	let s:loaded = 1
endfunction

if !exists('s:loaded')
    finish
endif

function! npm#get_latest_version(package_name) abort
    let l:result = s:get_version(a:package_name, 'latest')

    " TODO: try to show float-preview if using nvim
    
    redraw | echo l:result
endfunction

function! npm#get_all_versions(package_name) abort
    let l:result = s:get_version(a:package_name, 'all')

    let l:buffer_index = bufwinnr('__packages_versions__')
    
    if l:buffer_index > 0
        execute l:buffer_index . 'wincmd w'
    else
        rightbelow vsplit __packages_versions__
    endif

    normal! ggdG
    setlocal filetype=packagesversions
    setlocal buftype=nofile

    call append(0, l:result)
    normal! gg
endfunction

function! npm#info() abort
    if exists('g:npm_cli') && exists('g:npm_cli_version')
        echo 'Package Manager: ' . g:npm_cli . ' (' . g:npm_cli_version . ')'
    else
        echohl ErrorMsg
        echo 'You must install Npm or Yarn to use this plugin !'
        echohl None
    endif
endfunction
" }}}

" Local Functions {{{
" option: 'latest' | 'all'
"   - 'latest': Return only the latest version of package
"   - 'all': Return all versions of package
function! s:get_version(package_name, option) abort
    if len(a:package_name) > 0

        echo 'Getting ' . a:package_name . ' infomation... (with ' . g:npm_cli . ')'

        if a:option ==# 'latest'
            let l:param = 'version'
        else
            let l:param = 'versions'
        endif

        if g:npm_cli ==# 'npm'
            let l:result = system('npm view ' . a:package_name . ' ' . l:param)
        else
            let l:result = system('yarn info ' . a:package_name . ' ' . l:param)
        endif

        if l:result =~? '\verr|error|invalid'
            echohl ErrorMsg
            redraw | echo "Can't get infomation of '" . a:package_name . "'"
            echohl None
        else
            if a:option ==# 'latest'
                if g:npm_cli ==# 'npm'
                    return split(l:result, '\n')[0]
                else
                    return split(l:result, '\n')[1]
                endif
            else
                if g:npm_cli ==# 'npm'
                    return eval(trim(l:result))
                else
                    return eval(join(split(trim(l:result), '\n')[1:-2], ''))
                endif
            endif
        endif
    else
        echohl ErrorMsg
        echo 'You must provide a package name !'
        echohl None
    endif

    return 0
endfunction
" }}}
