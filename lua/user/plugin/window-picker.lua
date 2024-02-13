---- s1n7ax/nvim-window-picker

local colors = require 'user.colors'

local font = {
  ['a'] = [[
,-.
,-|
`-^ ]],

  ['b'] = [[
.
|-.
| |
^-' ]],

  ['c'] = [[
,-.
|
`-' ]],

  ['d'] = [[
  .
,-|
| |
`-^ ]],

  ['e'] = [[
,-.
|-'
`-' ]],

  ['f'] = [[
,"'
|-
|
'  ]],

  ['g'] = [[
,-.
| |
`-|
. |
`'` ]],

  ['h'] = [[
|
|-.
| |
' ' ]],

  ['i'] = [[
'
|
| ]],

  ['j'] = [[
  '
  |
, |
`'` ]],

  ['k'] = [[
.
| ,
|<
' ` ]],

  ['l'] = [[
.
|
|
'-]],

  ['m'] = [[
,-,-.
| | |
' ' ' ]],

  ['n'] = [[
,-.
| |
' ' ]],

  ['o'] = [[
,-.
| |
`-' ]],

  ['p'] = [[
,-.
| |
|-'
|
'   ]],

  ['q'] = [[
,-.
| |
`-|
  |
  `-]],

  ['r'] = [[
,-.
|
'   ]],

  ['s'] = [[
,-.
`-.
`-' ]],

  ['t'] = [[
 .
-|-
 |
 `' ]],

  ['u'] = [[
. .
| |
`-^ ]],

  ['v'] = [[
.  ,
| /
`'   ]],

  ['w'] = [[
. , ,
|/|/
' '   ]],

  ['x'] = [[
\ /
 X
/ \ ]],

  ['y'] = [[
. .
| |
`-|
 /|
`-' ]],

  ['z'] = [[
,_,
 /
'"' ]],

  ['0'] = [[
,-.
|/|
`-' ]],

  ['1'] = [[
 ,
'|
 ` ]],

  ['2'] = [[
,-,
 /
'-` ]],

  ['3'] = [[
,-.
 -<
`-' ]],

  ['4'] = [[
 ,.
{_|
  ' ]],

  ['5'] = [[
.--
`-.
`-' ]],

  ['6'] = [[
,-.
|-.
`-' ]],

  ['7'] = [[
--,
 /
'   ]],

  ['8'] = [[
,-.
>-<
`-' ]],

  ['9'] = [[
,-.
`-|
`-' ]],

  [';'] = [[
:;
:;
,' ]],
}

require('window-picker').setup {
  hint = 'floating-big-letter',
  selection_chars = 'FJDKSLACMRUEIWOQPHTGYVBNZX',
  filter_rules = {
    autoselect_one = false,
    -- filter using buffer options
    bo = {
      -- if the file type is one of following, the window will be ignored
      filetype = { 'neo-tree', 'neo-tree-popup', 'notify', 'incline' },

      -- if the buffer type is one of following, the window will be ignored
      buftype = { 'quickfix' },
    },
  },
  picker_config = {
    floating_big_letter = {
      -- window picker plugin provides bunch of big letter fonts
      -- fonts will be lazy loaded as they are being requested
      -- additionally, user can pass in a table of fonts in to font
      -- property to use instead
      font = font,
    },
  },
  -- other_win_hl_color = colors.deep_anise,
  fg_color = colors.hydrangea,
  show_prompt = false,
}

return font
