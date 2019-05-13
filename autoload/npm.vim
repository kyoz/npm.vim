" npm#init_mappings() {{{
function! npm#init_mappings() abort
    if !get(g:, 'npm_default_mappings', 1)
        return
    endif

    nnoremap <Plug>(npm-get-latest-version) :call npm#get_latest_version('')<CR>
    nnoremap <Plug>(npm-get-all-versions)   :call npm#get_all_versions('')<CR>

    if !hasmapto('<Plug>(npm-get-latest-version)')
        nmap <leader>n <Plug>(npm-get-latest-version)
    endif

    if !hasmapto('<Plug>(npm-get-all-versions)')
        nmap <leader>N <Plug>(npm-get-all-versions)
    endif

    command! -nargs=1 Npm       call npm#get_latest_version(<f-args>)
    command! -nargs=1 NpmLatest call npm#get_latest_version(<f-args>)
    command! -nargs=1 NpmL      call npm#get_latest_version(<f-args>)
    command! -nargs=1 NpmAll    call npm#get_all_versions(<f-args>)
    command! -nargs=1 NpmA      call npm#get_all_versions(<f-args>)

	let g:npm_inited = 1
endfunction
" }}}

if !exists('g:npm_inited')
    finish
endif

" npm#get_cli() {{{
function! npm#get_cli() abort
    redraw | echo 'Getting CLI...'

    " Preper yarn cause it's seem faster
    if executable('yarn')
        let g:npm_cli = 'yarn'
    elseif executable('npm')
        let g:npm_cli = 'npm'
    endif
endfunction
" }}}

" npm#get_package_name() {{{
function! npm#get_package_name(package_name) abort
    if !exists('g:npm_cli')
        execute "normal! :call npm#get_cli()\<cr>"
    endif

    " set iskeyword to match @,-,/,A-Z, a-z, 0-9
    let l:current_iskeyword = substitute(execute('echo &iskeyword'), '[[:cntrl:]]', '', 'g')
    set iskeyword=@-@,-,/,47,65-90,97-122,48-57

    if len(a:package_name) > 0
        let l:package_name = a:package_name
    else
        let l:package_name = substitute(expand('<cword>'), '[ \t]+', '', 'g')
    endif

    " Reset user iskeyword setting
    silent execute "normal! :set iskeyword=" . l:current_iskeyword . "\<cr>"

    " Regex for valid npm name:
    " ^@?([[:<:]](?!-)[0-9a-zA-Z-]+[[:>:]](?!-))\/?([[:<:]](?!-)[0-9a-zA-Z-]+[[:>:]](?!-))?
    " But it not work with vim regex so i have to validate my self
    let l:is_valid_package = 1

    if len(l:package_name) > 214 || !(l:package_name =~# '\v^[@0-9A-Za-z/-]+$')
        let l:is_valid_package = 0
    endif

    if l:is_valid_package ==# 0
        echohl ErrorMsg
        redraw | echomsg l:package_name . " isn't a valid package name !"
        echohl None
        return ''
    endif

    return l:package_name
endfunction
" }}}

" npm#get_version() {{{
" option: 'latest' | 'all'
"   - 'latest': Return only the latest version of package
"   - 'all': Return all versions of package
function! npm#get_version(package_name, option) abort
    if !exists('g:npm_cli')
        echohl ErrorMsg
        redraw | echomsg "You must install npm or yarn for this plugin to work"
        echohl None
        return ''
    endif

    if len(a:package_name) > 0

        redraw! | echo 'Getting ' . a:package_name . ' infomation... (with ' . g:npm_cli . ')'

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

" npm#get_latest_version() {{{
function! npm#get_latest_version(package_name) abort
    let l:package_name = npm#get_package_name(a:package_name)

    if len(l:package_name) ==# 0 | return | endif

    let l:result = npm#get_version(l:package_name, 'latest')

    if len(l:result) ==# 0
        return
    endif

    " Try to show float-preview if using nvim
    if has('nvim-0.4.0') && get(g:, 'npm_allow_floating_window', 1)
        call npm#open_floating_window(' Latest: ' . l:result . ' ')
    else
        redraw | echom "Latest version of '" . l:package_name . "': " . l:result
    endif
endfunction
" }}}

" npm#get_all_versions() {{{
function! npm#get_all_versions(package_name) abort
    let l:package_name = npm#get_package_name(a:package_name)

    if len(l:package_name) ==# 0 | return | endif

    let l:result = npm#get_version(l:package_name, 'all')

    if len(l:result) ==# 0
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

    call append(0, 'Package: ' . l:package_name)
    call append(2, '[')
    call append(3, map(l:result, '"    " . v:val . ""'))
    call append(len(l:result) + 3, ']')

    setlocal nomodifiable
    normal! gg
endfunction
" }}}

" npm#open_floating_window() {{{
function! npm#open_floating_window(content) abort
    redraw | echo ''
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:true, [a:content])
    let opts = {
        \ 'relative': 'cursor',
        \ 'width': len(a:content) + 2,
        \ 'height': 1,
        \ 'col': 0,
        \ 'row': 1,
        \ 'anchor': 'NW'}

    let g:npm_disable_autocmd = 1
    let s:popup_win_id = nvim_open_win(buf, v:true, opts)

    " New buffer settings
    setlocal buftype=nofile | setlocal bufhidden=wipe | setlocal signcolumn=no
    setlocal filetype=package-latest-version | setlocal nowrap
    setlocal nomodifiable | setlocal nobuflisted | setlocal noswapfile
    setlocal nonumber | setlocal norelativenumber | setlocal nocursorline

    wincmd p | unlet g:npm_disable_autocmd

    augroup NpmClosePopup
        autocmd!
        autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call <SID>ClosePopup()
    augroup END
endfunction

function! s:ClosePopup() abort
    if exists('s:popup_win_id') && !exists('g:npm_disable_autocmd')
        call nvim_win_close(s:popup_win_id, 1)
        unlet s:popup_win_id
    endif
endfunction
" }}}

