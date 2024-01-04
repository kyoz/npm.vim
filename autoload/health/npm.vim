function! s:check_vim_version() abort
    if has('nvim')
        return 
    endif

    call v:lua.vim.health.start('Vim support')

    if v:version < 800
        call v:lua.vim.health.error(
            \ 'Your vim is too old: ' . v:version . ' and not supported by the plugin'
            \ 'Please install Vim 8.0 or later')
    else
        call v:lua.vim.health.ok('Your vim is supported')
    endif
endfunction

function! s:check_cli() abort
    call v:lua.vim.health.start('CLI check')

    let s:yarn = executable('yarn')
    let s:npm = executable('npm')

    if s:yarn || s:npm
        if s:yarn
            let l:ok_message = 'Found installed CLI: yarn'
        elseif s:npm
            let l:ok_message = 'Found installed CLI: npm'
        endif
        call v:lua.vim.health.ok(l:ok_message)
    else
        call v:lua.vim.health.error('Yarn or Npm is required but not installed or executable')
    endif
endfunction

function! health#npm#check() abort
    call s:check_vim_version()
    call s:check_cli()
endfunction
