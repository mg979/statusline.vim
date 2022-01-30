--------------------------------------------------------------------------------
-- Git badge
--------------------------------------------------------------------------------

local v = vim.fn
local exists = v.exists
local substitute = v.substitute
local getcwd = v.getcwd

local Path = v.has('win32') > 0 and function(p) return v.tr(p, '\\', '/') end
             or function(p) return p end

vim.cmd([[
augroup git_statusline
  au!
  autocmd BufEnter            * lua require"statusline.git".info()
  autocmd CursorHold          * lua require"statusline.git".info()
  autocmd BufWritePost        * lua require"statusline.git".info()
  autocmd ShellCmdPost        * lua require"statusline.git".info()
  autocmd DirChanged          * lua require"statusline.git".info()
  autocmd User GitUpdate        lua require"statusline.git".info()
augroup END
]])

local git = {['branch'] = '', ['ok'] = false}

----
-- Update git badge
--
-- empty if no repo, or no fugitive plugin
-- normal color if repo is the same as cwd
-- error highlight if repo is different from cwd
----
function git.info()

    if exists('g:loaded_fugitive') == 0 or exists('g:SessionLoad') > 0 then
        return
    end

    local sha = v.FugitiveHead(8)

    if sha == '' then
        git.branch = ''
        return
    end

    git.branch = string.format(' %s ', sha)
    git.ok = Path(getcwd()) == Path(git.dir())
end

function git.dir()
  return exists('*FugitiveGitDir')
        and substitute(v.FugitiveGitDir(), '.\\.git$', '', '')
        or getcwd()
end

return git
