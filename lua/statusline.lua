-------------------------------------------------------------------------------
-- Section: local variables
-------------------------------------------------------------------------------

-- Highlight groups {{{1

local Bg      = '%1* '
local Fill    = '%2* '
local Normal  = '%3* '
local Insert  = '%4* '
local Replace = '%5* '
local Visual  = '%6* '
local Command = '%7* '
local Warning = '%8* '
local Error   = '%9* '

-- Modes {{{1

local modes = {
    ['n'] =  { Normal,   false, 'N ' },
    ['i'] =  { Insert,   true,  'I ' },
    ['v'] =  { Visual,   false, 'V ' },
    ['V'] =  { Visual,   false, 'V-L ' },
    [''] = { Visual,   false, 'V-B ' },
    ['R'] =  { Replace,  true,  'R ' },
    ['s'] =  { Insert,   true,  'S ' },
    ['S'] =  { Insert,   true,  'S-L ' },
    [''] = { Insert,   true,  'S-B ' },
    ['c'] =  { Command,  true,  'C ' },
    ['t'] =  { Command,  false, 'T ' },
    }

-- Local variables {{{1

local session = require"statusline.sections".session
local warnings = require"statusline.sections".warnings
local git = require"statusline.git"
local special = require"statusline.special"

local v = vim.fn
local o = vim.o
local mode = v.mode
local getreg = v.getreg
local substitute = v.substitute
local fnamemodify = v.fnamemodify
local winwidth = v.winwidth
local localdir = v.haslocaldir
local line = v.line
local winheight = v.winheight

local strsub = string.sub
local strfind = string.find
--}}}

--------------------------------------------------------------------------------
-- Section: local functions
--------------------------------------------------------------------------------

local function ShortBufname(name) -- {{{1
  if #name < winwidth(0) / 2 or not strfind(name, '/') then
    return name
  end
  local path = substitute(name, '\\v%((\\.?[^/])[^/]*)?/(\\.?[^/])[^/]*', '\\1/\\2', 'g')
  path = strsub(path, 1, #path - 1) .. fnamemodify(name, ':t')
  if #path < winwidth(0) / 2 then
    return path
  end
  name = fnamemodify(name, ':p')
  return '...' .. strsub(name, #name - winwidth(0) / 3)
end

-- }}}


-------------------------------------------------------------------------------
-- Section: statuslines
-------------------------------------------------------------------------------

local function active()
  local Color, InsMode, Mode = unpack(modes[mode()])
  local Mode = Color .. Mode

  Flags = o.readonly and Bg .. Color .. 'RO ' or ''
  Flags = o.paste and Flags .. Bg .. Color .. 'PASTE ' or Flags
  Flags = o.spell and Flags .. Bg .. Color .. o.spelllang .. ' ' or Flags

  if vim.g.caps_lock then
    Flags = Flags .. Bg .. Color .. 'CAPS '
  end

  if InsMode then
      return Mode .. Flags .. Bg .. '%f%=' .. o.filetype .. ' ' .. Color .. ' %l:%c '
  end

  Flags = vim.bo.modified and Flags .. Bg .. Insert .. 'MODIFIED ' or Flags

  local Ldir = localdir() == 1      and Insert .. 'L ' or
               localdir(-1, 0) == 1 and Insert .. 'T ' or ''

  local Ft = o.filetype == '' and '' or Bg .. o.filetype

  local Ff = o.fileformat == 'unix' and '' or Bg .. Replace .. o.fileformat .. ' '
  local Ff = (o.fileencoding == '' or o.fileencoding == 'utf-8') and Ff or Ff .. Bg .. Replace .. o.fileencoding .. ' '

  local Git = git.branch == '' and '' or (git.ok and Fill or Error) .. git.branch

  -- page current/max
  local Page  = Color .. string.format("%s/%s ",
                              math.floor(line('.') / winheight(0) + 1),
                              math.floor(line('$') / winheight(0) + 1))


  local n = #tostring(line('$'))
  local Ruler = Bg .. Color .. string.format('%%%s.%sl:%%-3c ', n, n)

  return Mode .. Git .. Flags .. Bg .. ShortBufname(getreg('%')) .. '%=' ..
         Ldir .. session() .. Page .. Ft .. Ff .. Ruler .. warnings()
end

local unlisted = function() return ' UNLISTED %1* %f%=%0* %4l:%-4c' end
local scratch  = function() return ' ' .. string.upper(v.getwinvar(w, '&buftype')) .. ' ' .. Bg .. '%f%' end
local preview  = function() return ' PREVIEW %1* %f%=%0* %4l:%-4c' end
local inactive = function() return '%#StatuslineNC# %f %m%r%= %p%% ｜ %l:%c ' end


--------------------------------------------------------------------------------
-- Section: module function
--------------------------------------------------------------------------------

local M = {}

function M.SetStatusline()
  local custom = special.bufname() or special.filetype()
  if custom then
    return custom
  elseif not vim.bo.buflisted then
    return unlisted()
  elseif vim.bo.buftype ~= '' then
    return scratch()
  elseif vim.wo.previewwindow then
    return preview()
  elseif tonumber(vim.g.actual_curwin) == v.win_getid() then
    return active()
  else
    return inactive()
  end
end

return M

-- vim: ft=lua et ts=2 sw=2 fdm=marker
