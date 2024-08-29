local M = {}

local fn = require 'user.fn'

-- Extra keys
-- Configure your terminal emulator to send the unicode codepoint for each
-- given key sequence
M.xk = fn.utf8keys {
  [ [[<C-S-q>]] ] = 0xff01,
  [ [[<C-S-n>]] ] = 0xff02,
  [ [[<C-M-q>]] ] = 0xff03,
  [ [[<C-M-S-q>]] ] = 0xff04,
  [ [[<C-M-.>]] ] = 0xff05,
  [ [[<C-M-S-.>]] ] = 0xff06,
  [ [[<C-\>]] ] = 0x00f0,
  [ [[<C-S-\>]] ] = 0x00f1,
  [ [[<M-S-\>]] ] = 0x00f2,
  [ [[<C-M-S-\>]] ] = 0x00ff,
  [ [[<C-`>]] ] = 0x00f3,
  [ [[<C-S-w>]] ] = 0x00f4,
  [ [[<C-S-f>]] ] = 0x00f5,
  [ [[<C-S-t>]] ] = 0x00f6,
  [ [[<C-S-a>]] ] = 0x00f7,
  [ [[<C-'>]] ] = 0x00f8,
  [ [[<C-S-p>]] ] = 0x00f9,
  [ [[<C-S-.>]] ] = 0x00fa,
  [ [[<C-.>]] ] = 0x00fb,
  [ [[<C-S-o>]] ] = 0x00fc,
  [ [[<C-S-i>]] ] = 0x00fd,
  [ [[<M-c>]] ] = 0x00fe,
  [ [[<C-/>]] ] = 0x00d4,
  [ [[<C-M-/>]] ] = 0x00d5,
  [ [[<C-S-/>]] ] = 0x00d6,
  [ [[<M-S-/>]] ] = 0x00d7,
  [ [[<C-M-S-/>]] ] = 0x00d8,
  [ [[<M-Space>]] ] = 0x00d9,
  [ [[<C-M-S-s>]] ] = 0x00da,
  [ [[<C-S-u>]] ] = 0x00db,
  [ [[<C-S-r>]] ] = 0x00dc,
}

return M
