" Autoload Functions {{{
function! npm#get_cli() abort
    let l:cli_version_regex = '\v[0-9]+\.[0-9]+\.?([0-9]+)?-?(.+)?'
    let l:npm_version       = split(system('nsspm -v'), '\n')[0]
    let l:yarn_version      = split(system('yarn -v'), '\n')[0]

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

    if len(l:result) == 0
        return
    endif

    " TODO: try to show float-preview if using nvim

    redraw | echo l:result
endfunction

function! npm#get_all_versions(package_name) abort
    let l:result = s:get_version(a:package_name, 'all')

    if len(l:result) == 0
        return
    endif

    let l:buffer_index = bufwinnr('__packages_versions__')

    if l:buffer_index > 0
        execute l:buffer_index . 'wincmd w'
        setlocal modifiable
    else
        rightbelow 50vsplit __packages_versions__
    endif

    normal! ggdG
    setlocal filetype=package-versions
    setlocal buftype=nofile

    call append(0, 'Package: ' . a:package_name)
    call append(2, '[')
    call append(3, map(l:result, '"    " . v:val . ""'))
    call append(len(l:result) + 3, ']')

    setlocal nomodifiable
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
            if g:npm_cli ==# 'npm'
                let l:param = 'versions --json'
            else
                let l:param = 'versions'
            endif
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
            return []
        else
            if a:option ==# 'latest'
                if g:npm_cli ==# 'npm'
                    return split(l:result, '\n')[0]
                else
                    return split(l:result, '\n')[1]
                endif
            else
                if g:npm_cli ==# 'npm'
                    " Remove all null character ^@
                    let l:result = substitute(l:result, '[[:cntrl:]]', '', 'g')
                    " Remove all trailing white space
                    let l:result = substitute(l:result, '[ \t]+', '', 'g')
                    " Parse result as list and reverse it
                    return reverse(eval(l:result))
                else
                    return reverse(eval(join(split(l:result, '\n')[1:-2], '')))
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
