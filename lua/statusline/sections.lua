local v = vim.fn
local getreg = v.getreg
local substitute = v.substitute
local fnamemodify = v.fnamemodify
local winwidth = v.winwidth
local buflisted = v.buflisted
local bufnr = v.bufnr
local exists = v.exists
local getcwd = v.getcwd
local search = v.search

local ok_tws = vim.g.ok_trailing_ws or {'markdown'}
local no_mix = vim.g.no_mixed_indent or {'vim', 'sh', 'python', 'go'}

local M = {}

function M.session() -- {{{1
  if vim.v.this_session == '' then
    return Bg
  end
  local ob = exists('g:loaded_obsession') and exists('g:this_obsession')
  local ss = fnamemodify(ob and vim.g.this_obsession or vim.g.this_session, ':t')
  local hl = ob and v.ObsessionStatus() ~= '[$]' and 'diffRemoved' or 'diffAdded' or 'Special'
  return string.format('%%#%s# %s ', hl, ss)
end

function M.warnings() -- {{{1
  if not vim.bo.modifiable or exists('SessionLoad') > 0 then
    return ''
  end

  local ft      = vim.o.filetype
  local size    = v.getfsize(getreg('%'))
  local large   = size == -2 or size > 20 * 1024 * 1024
  local trail   = ok_tws[ft] and false or search('\\s$', 'cnw')
  local mixed   = 0

  if no_mix[ft] then
    local tabs    = search('^\\s\\{-}\\t', 'cnw')
    local spaces  = search('^\\s\\{-} ', 'cnw')
    mixed         = tabs > 0 or spaces > 0 and vim.bo.expandtab and tabs or spaces or 0
  end

  if large or trail > 0 or mixed > 0 then
    if winwidth(0) < 150 then
      return '%5* ! '
    else
      local ret = {}
      if large then
        ret[#ret + 1] = ' Large file '
      end
      if trail > 0 then
        ret[#ret + 1] = ' Trailing space (' .. trail .. ') '
      end
      if mixed > 0 then
        ret[#ret + 1] = ' Mixed indent (' .. mixed .. ') '
      end
      return '%5* ' .. table.concat(ret, '|')
    end
  else
    return ''
  end
end

-- }}}

return M

-- vim: ft=lua et ts=2 sw=2 fdm=marker
