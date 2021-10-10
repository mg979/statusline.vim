## statusline

My humble statusline plugin. It's not as shiny as the load of other nvim
'blazing fast' statusline plugins, but it's quite a bit faster.

It needs either vim >= 8.2 (vim9script) or neovim.

```vim
fun! Test()
    let time = reltime()
    for i in range(10000)
        redrawstatus
    endfor
    echom matchstr(reltimestr(reltime(time)), '.*\..\{,3}') .. ' seconds to run'
endfun

command Test call Test()
```
This plugin takes 0.674s to run that command, in a single window with the file
`statusline.lua` of this repo. Tests for other plugins:

- lualine.nvim: 1.673s
- feline.nvim: 1.653s
- harline.nvim: 4.767s

Sample pics:

