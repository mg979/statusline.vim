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

Features:
- branch indicator (needs fugitive)
- different color for branch indicator (generally red if cwd doesn't match repo wd)
- session indicator
- local/tab working directory indicator
- other indicators: read-only, spell, paste, modified (all textual, no icons)

Sample pics:
![1](https://user-images.githubusercontent.com/26169924/136709946-c18eb741-cff0-4ea9-bd0c-7c823dbe7d6f.png)
![2](https://user-images.githubusercontent.com/26169924/136709948-b1bbba24-a462-4041-acaa-c2981dedeaf3.png)
![3](https://user-images.githubusercontent.com/26169924/136709951-73d9dbdf-757d-4018-8487-a0fd1537b990.png)
![4](https://user-images.githubusercontent.com/26169924/136709952-013fd979-65bb-4438-9a2b-3cc285ac0f49.png)

