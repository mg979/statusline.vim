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
local expand = v.expand
local winwidth = v.winwidth
local localdir = v.haslocaldir
local line = v.line
local winheight = v.winheight

local pathpat = vim.fn.has('win32') == 1 and '([/\\]?%.?[^/\\])[^/\\]-[/\\]'
                                         or '(/?%.?[^/])[^/]-/'

local slash = vim.fn.has('win32') == 1 and '[/\\]' or '/'
local slashchar = vim.fn.has('win32') == 1 and '\\' or '/'

local strfind = string.find
local gsub = string.gsub

local strwidth = vim.api.nvim_strwidth
local function width(s) s = gsub(s, '%%#?%w+#?%*?', '') return strwidth(s) end
--}}}

--------------------------------------------------------------------------------
-- Section: local functions
--------------------------------------------------------------------------------

local function ShortBufname(name, limit) -- {{{1
  if #name < limit or not strfind(name, slash) then
    return name
  end
  local path = gsub(name, pathpat, '%1' .. slashchar)
  if #path < limit then
    return path
  end
  return gsub(name, '.*' .. slashchar, '')
end

-- }}}


-------------------------------------------------------------------------------
-- Section: statuslines
-------------------------------------------------------------------------------

local function active()
  local Color, InsMode, Mode = unpack(modes[mode()])
  Mode = Color .. Mode

  Flags = o.readonly and Bg .. Color .. 'RO ' or ''
  Flags = o.paste and Flags .. Bg .. Color .. 'PASTE ' or Flags
  Flags = o.spell and Flags .. Bg .. Color .. o.spelllang .. ' ' or Flags

  if vim.g.caps_lock == true then
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
  Ff = (o.fileencoding == '' or o.fileencoding == 'utf-8') and Ff or Ff .. Bg .. Replace .. o.fileencoding .. ' '

  local Git = git.branch == '' and '' or (git.ok and Fill or Error) .. git.branch

  -- page current/max
  local Page  = Color .. string.format("%s/%s ",
                              math.floor(line('.') / winheight(0) + 1),
                              math.floor(line('$') / winheight(0) + 1))


  local n = #tostring(line('$'))
  local Ruler = Bg .. Color .. string.format('%%%s.%sl:%%-3c ', n, n)

  local left = Mode .. Git .. Flags .. Bg
  local right = Ldir .. session() .. Page .. Ff .. Ft .. Ruler .. warnings()
  local bname = ShortBufname(expand('%:~'), winwidth(0) - width(left) - width(right))
  return left .. bname .. '%=' .. right
end

local unlisted = function() return ' UNLISTED %1* %f%=%0* %4l:%-4c' end
local scratch  = function() return ' ' .. string.upper(v.getwinvar(0, '&buftype')) .. ' ' .. Bg .. '%f' end
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
