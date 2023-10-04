local colors_gui = vim.g.colors_gui or {}

local colors = {
  black = colors_gui['1'] or 'black',
  white = colors_gui['5'] or 'white',

  skyblue = colors_gui['7'] or 'skyblue',
  cyan = colors_gui['8'] or 'cyan',
  fg = colors_gui['4'] or 'fg',
  green = colors_gui['14'] or 'green',
  oceanblue = colors_gui['9'] or 'oceanblue',
  magenta = colors_gui['15'] or 'magenta',
  orange = colors_gui['17'] or 'orange',
  red = colors_gui['12'] or 'red',
  violet = colors_gui['10'] or 'violet',
  yellow = colors_gui['13'] or 'yellow',

  butter = '#fffacf',

  milk = '#fdf6e3',
  cream = '#e6dac3',
  cashew = '#CEB999',
  almond = '#a6875a',
  cocoa = '#3b290e',

  licorice = '#483270',
  lavender = '#A872FB',
  velvet = '#B29EED',
  anise = '#7F7DEE',
  hydrangea = '#fb72fa',
  blush = '#EBBBF9',
  powder = '#EAC6F5',
  dust = '#EAD2F1',
  mistyrose = '#ffe4e1',
  rebeccapurple = '#3C2C74',

  evergreen = '#9fdfb4',

  snow = '#e4fffe',
  ice = '#a4e2e0',
  mint = '#a2e0ca',

  nectar = '#f0f070',
  cayenne = '#FF7D90',
  yam = '#e86f54',
  pumpkin = '#ff9969',
  rose = '#b32e29',

  grey2 = '#222222',
  grey5 = '#777777',
  grey6 = '#aaaaaa',
  grey7 = '#cccccc',
  grey8 = '#dddddd',

  mid_velvet = '#6E6EA3',

  deep_lavender = '#38265A',
  deep_licorice = '#252137',
  deep_anise = '#564D82',
  deep_velvet = '#8F8FB3',

  light_lavender = '#EAD6FF',
}

colors.inactive_bg = colors_gui['0'] or 'NONE'
colors.active_bg = colors_gui['3'] or 'NONE'
colors.bg = colors.active_bg

return colors
