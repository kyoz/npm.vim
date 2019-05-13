function! s:check_job() abort
    if exists('*jobstart') || exists('*job_start')
        call health#report_ok('Async check passed')
    else
        call health#report_error('+job feature is required to execute network request')
    endif
endfunction

function! s:check_vim_version() abort
    if has('nvim')
        return 
    endif

    if v:version < 800
        call health#report_error(
            \ 'Your vim is too old: ' . v:version . ' and not supported by the plugin'
            \ 'Please install Vim 8.0 or later')
    endif
endfunction

function! s:check_cli() abort
    let s:yarn = executable('yarn')
    let s:npm = executable('npm')

    if s:yarn || s:npm
        if s:yarn
            let l:ok_message = 'Found installed CLI: yarn'
        elseif s:npm
            let l:ok_message = 'Found installed CLI: npm'
        endif
        call health#report_ok(l:ok_message)
    else
        call health#report_error('Yarn or Npm is required but not installed or executable')
    endif
endfunction

function! health#npm#check() abort
    call s:check_job()
    call s:check_vim_version()
    call s:check_cli()
endfunction
