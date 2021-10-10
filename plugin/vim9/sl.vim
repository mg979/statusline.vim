"    _____   __            __                     __     _
"   / ___/  / /_  ____ _  / /_  __  __   _____   / /    (_)  ____   ___
"   \__ \  / __/ / __ `/ / __/ / / / /  / ___/  / /    / /  / __ \ / _ \
"  ___/ / / /_  / /_/ / / /_  / /_/ /  (__  )  / /___ / /  / / / //  __/
" /____/  \__/  \__,_/  \__/  \__,_/  /____/  /_____//_/  /_/ /_/ \___/

" GUARD {{{1
if v:version < 802 || exists('g:loaded_statusline')
    finish
endif
vim9script
g:loaded_statusline = true

# Lambdas and variables {{{1
g:git_infos = {'dir': '', 'branch': '', 'prev_dir': '', 'ok': false}
var git = g:git_infos

var Path = (p) => has('win32') ? substitute(p, '\\\ze[^ ]', '/', 'g') : p
var GitDir = () => exists('*FugitiveGitDir') ? substitute(g:FugitiveGitDir(), '.\.git$', '', '') : getcwd()
#}}}


#==============================================================================
# Section: highlight groups
#==============================================================================

# Highlight groups {{{1

var Bg      = '%1* '
var Fill    = '%2* '
var Normal  = '%3* '
var Insert  = '%4* '
var Replace = '%5* '
var Visual  = '%6* '
var Command = '%7* '
var Warning = '%8* '
var Error   = '%9* '

# Modes {{{1

var colors = {
    'n':      Normal,
    'i':      Insert,
    'v':      Visual,
    'V':      Visual,
    "\<C-V>": Visual,
    'R':      Replace,
    's':      Insert,
    'S':      Insert,
    "\<C-s>": Insert,
    'c':      Command,
    't':      Command,
    }

var modes = {
    'n':      'N ',
    'i':      'I ',
    'v':      'V ',
    'V':      'V-L ',
    "\<C-V>": 'V-B ',
    'R':      'R ',
    's':      'S ',
    'S':      'S-L ',
    "\<C-s>": 'S-B ',
    'c':      'C ',
    't':      'T ',
    }

var insmode = {
    'n':      false,
    'i':      true,
    'v':      false,
    'V':      false,
    "\<C-V>": false,
    'R':      true,
    's':      true,
    'S':      true,
    "\<C-s>": true,
    'c':      true,
    't':      false,
    }
#}}}



var Unlisted = () => ' UNLISTED %1* %f%=%0* %4l:%-4c'
var Scratch  = (s) => ' ' .. toupper(s) .. ' ' .. Bg .. '%f%'
var Preview  = () => ' PREVIEW %1* %f%=%0* %4l:%-4c'
var Inactive = () => '%#StatuslineNC# %f %m%r%= %p%% ｜ %l:%c '

def Active(): string
    # Statusline for handled windows {{{1
    var Color = colors[mode()]
    var Mode = Color .. modes[mode()]
    var Flags = ''

    Flags ..= &ro         ? Bg .. Color .. 'RO ' : ''
    Flags ..= &paste      ? Bg .. Color .. 'PASTE ' : ''
    Flags ..= &spell      ? Bg .. Color .. &spelllang .. ' ' : ''

    if get(g:, 'caps_lock', false)
        Flags ..= Bg .. Color .. 'CAPS '
    endif

    if insmode[mode()]
        return Mode .. Flags .. Bg .. '%f%=' .. &ft .. ' ' .. Color .. ' %l:%c '
    endif

    Flags ..= &buftype != '' ? Bg .. Insert .. toupper(&buftype) .. ' '
                             : &mod ? Bg .. Insert .. 'MODIFIED ' : ''

    var Ldir = haslocaldir() == 1 ? Insert .. 'L ' :
               haslocaldir() == 2 ? Insert .. 'T ' : ''

    var Ft = empty(&ft) ? '' : Bg .. &ft
    var Ff = &fileformat == 'unix' ? '' : Bg .. Replace .. &fileformat .. ' '
    Ff = &fileencoding == 'utf-8' ? Ff : Ff .. Bg .. Replace .. &fileencoding .. ' '

    var Git = insmode[mode()] || git.branch == '' ? '' : (git.ok ? Fill : Error) .. git.branch

    # page current/max
    var Page  = Color .. printf("%s/%s ",
                                line('.') / winheight(0) + 1,
                                line('$') / winheight(0) + 1)

    # ruler, with padding left and right
    var n = strlen(line('$'))
    var Ruler = Bg .. Color .. printf('%%%s.%sl:%%-3c ', n, n)

    #=================================================================

    return Mode .. Git .. Flags .. Bg .. ShortBufname() .. '%=' ..
           Ldir .. Session() .. Page .. Ft .. Ff .. Ruler .. Warn()
enddef #}}}


def g:Statusline(): string
    # Selector for the statusline function, based on buffer type {{{1
    var w = g:statusline_winid
    var custom = SpecialBufname(w) ?? SpecialFiletype(w)
    if custom != ''
        return custom
    elseif !getwinvar(w, '&buflisted')
        return Unlisted()
    elseif getwinvar(w, '&buftype') != ''
        return Scratch(getwinvar(w, '&buftype'))
    elseif getwinvar(w, '&previewwindow')
        return Preview()
    elseif w != win_getid()
        return Inactive()
    else
        return Active()
    endif
enddef #}}}



#==============================================================================
# Section: special buffers
#==============================================================================

var special_bufnames = {
    '^fugitive:': () => {
        var ret = substitute(@%, '.*\.git\W\+', '', '')
        return ' fugitive: ' .. Bg .. ( ret =~ '/' ? ret : ret[ : 8] )
        },
    ' --graph$':  () => ' Git graph ' .. Bg .. GitDir()
    }

var special_filetypes = {
    'gitcommit': () => ' Commit ' .. Bg .. GitDir(),
    'fugitive':  () => ' Git Status ' .. Bg .. GitDir(),
    'startify':  () => ' Startify ',
    'netrw':     () => ' Netrw ' .. expand('%:t'),
    'dirvish':   () => ' Dirvish ' .. Bg .. expand('%:~'),
    'help':      () => &ro ? ' HELP ' .. Bg .. expand('%:t') : '',
    }


def SpecialBufname(w: number): string #{{{1
    for b in keys(special_bufnames)
        if bufname(winbufnr(w)) =~ b
            var sl = special_bufnames[b]()
            if sl != ''
                return sl .. Bg .. '%=' .. Fill .. ' %l:%c '
            endif
            break
        endif
    endfor
    return ''
enddef


def SpecialFiletype(w: number): string #{{{1
    for ft in keys(special_filetypes)
        if getwinvar(w, '&ft') == ft
            var sl = special_filetypes[ft]()
            if sl != ''
                return sl .. Bg .. '%=' .. Fill .. ' %l:%c '
            endif
            break
        endif
    endfor
    return ''
enddef


def ShortBufname(): string #{{{1
    if strlen(@%) < winwidth(0) / 2
        return @%
    endif
    var path = substitute(@%, '/\([^/]\)[^/]*', '/\1', 'g')
    path = path[ : -2] .. fnamemodify(@%, ':t')
    if strlen(path) < winwidth(0) / 2
        return path
    endif
    return '...' .. fnamemodify(@%, ':t')[ -(winwidth(0) / 2) : ]
enddef #}}}


#==============================================================================
# Section: autocommands
#==============================================================================

set statusline=%!Statusline()

augroup statusline
    autocmd!
    autocmd VimResized    *      redrawstatus
    autocmd CmdWinEnter   *      setlocal statusline=\ Command\ Line\ %1*
    autocmd TextChanged,TextChangedI * silent! unlet b:sl_warnings
augroup END



#==============================================================================
# Section: badges
#==============================================================================

##
# Session badge, possible highlight:
#   no session:          nothing
#   normal session:      Special
#   Obsession not ready: diffRemoved
#   Obsession ready:     diffAdded
##
def Session(): string
    #{{{1
    if empty(v:this_session)
        return Bg
    endif
    var ob = exists('g:loaded_obsession') && exists('g:this_obsession')
    var ss = fnamemodify(ob ? g:this_obsession : v:this_session, ':t')
    var hl = ob ? g:ObsessionStatus() != '[$]' ? 'diffRemoved' : 'diffAdded' : 'Special'
    return printf('%%#%s# %s ', hl, ss)
enddef #}}}

##
# Warnings badge for large file/mixed indent/trailing whitespace.
##
def Warn(): string
    #{{{1
    if exists('b:sl_warnings')
        return b:sl_warnings
    elseif !&ma || exists('SessionLoad')
        return ''
    endif

    var size    = getfsize(@%)
    var large   = size == -2 || size > 20 * 1024 * 1024
    var trail   = index(['markdown'], &ft) >= 0 ? 0 : search('\s$', 'cnw')
    var mixed   = 0

    var noMix = get(g:, 'no_mixed_indent', ['vim', 'sh', 'python', 'go'])

    if index(noMix, &ft) >= 0
        var tabs    = search('^\s\{-}\t', 'cnw')
        var spaces  = search('^\s\{-} ', 'cnw')
        mixed       = tabs > 0 || spaces > 0 ? &expandtab ? tabs : spaces : 0
    endif

    if large || trail > 0 || mixed > 0
        if winwidth(0) < 150
            b:sl_warnings = Replace .. '! '
        else
            b:sl_warnings = Replace .. join(
                ( large     ? [' Large file '] : [] ) +
                ( trail > 0 ? [' Trailing space (' .. trail .. ') '] : [] ) +
                ( mixed > 0 ? [' Mixed indent (' .. mixed .. ') '] : [] ), '|'
            )
        endif
    else
        b:sl_warnings = ''
    endif
    return b:sl_warnings
enddef #}}}



#==============================================================================
# Section: Git badge
#==============================================================================

augroup git_statusline
    au!
    autocmd VimEnter            * GitInfo()
    autocmd BufEnter            * GitInfo()
    autocmd CursorHold          * GitInfo()
    autocmd BufWritePost        * GitInfo()
    autocmd ShellCmdPost        * GitInfo()
    autocmd DirChanged          * GitInfo()
    autocmd User GitUpdate        GitInfo()
augroup END


def GitInfo(): void
    # Update git badge {{{1
    # empty if no repo, or no fugitive plugin
    # normal color if repo is the same as cwd
    # error highlight if repo is different from cwd

    if !exists('g:loaded_fugitive') || exists('g:SessionLoad')
        return
    endif

    var sha = g:FugitiveHead(8)

    if empty(sha)
        git.branch = ''
        return
    endif

    git.branch = printf(' %s ', sha)
    git.dir = Path(GitDir())
    git.ok = Path(getcwd()) == git.dir
enddef #}}}


# vim: ft=vim et ts=4 sw=4 fdm=marker
