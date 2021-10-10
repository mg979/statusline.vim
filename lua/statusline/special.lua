--------------------------------------------------------------------------------
-- Special buffers
--------------------------------------------------------------------------------

local git = require"statusline.git"

local Bg      = '%1* '
local Fill    = '%2* '

local v = vim.fn
local getreg = v.getreg
local substitute = v.substitute
local expand = v.expand

local special_bufnames = {  -- {{{1
  ['fugitive'] = {
    (function() return string.sub(getreg('%'), 1, 8) == 'fugitive' end),
    (function()
      local ret = substitute(getreg('%'), '.*\\.git\\W\\+', '', '')
      return ' fugitive: ' .. Bg .. ( string.find(ret, '/') and ret or string.sub(ret, 1, 8) )
    end) },
}

local special_filetypes = { -- {{{1
  ['gitcommit'] = function() return ' Commit ' .. Bg .. git.dir() end,
  ['fugitive'] =  function() return ' Git Status ' .. Bg .. git.dir() end,
  ['startify'] =  function() return ' Startify ' end,
  ['netrw'] =     function() return ' Netrw ' .. expand('%:t') end,
  ['dirvish'] =   function() return ' Dirvish ' .. Bg .. expand('%:~') end,
  ['help'] =      function() return vim.bo.readonly and ' HELP ' .. Bg .. expand('%:t') or '' end,
}

-- }}}

local function SpecialBufname() -- {{{1
  local sl
  for key, value in pairs(special_bufnames) do
    if value[1]() then
      sl = value[2]()
      if sl ~= '' then
        return sl .. Bg .. '%=' .. Fill .. ' %l:%c '
      end
      break
    end
  end
  return nil
end

local function SpecialFiletype()  -- {{{1
  local sl
  for ft, value in pairs(special_filetypes) do
    if vim.bo.filetype == ft then
      sl = value()
      if sl ~= '' then
        return sl .. Bg .. '%=' .. Fill .. ' %l:%c '
      end
      break
    end
  end
  return nil
end

-- }}}

return {
  bufname = SpecialBufname,
  filetype = SpecialFiletype
}
