---- monaqa/dial.nvim
local augend = require 'dial.augend'
require('dial.config').augends:register_group {
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.constant.new {
      elements = { 'false', 'true' },
      cyclic = false,
      preserve_case = true,
    },
    augend.constant.new {
      elements = { 'no', 'yes' },
      cyclic = false,
      preserve_case = true,
    },
    augend.constant.new {
      elements = { 'off', 'on' },
      cyclic = false,
      preserve_case = true,
    },
    augend.constant.alias.alpha,
    augend.constant.alias.Alpha,
    augend.semver.alias.semver,
    augend.date.alias['%Y/%m/%d'],
    augend.date.alias['%m/%d/%Y'],
    augend.date.alias['%d/%m/%Y'],
    augend.date.alias['%m/%d/%y'],
    augend.date.alias['%m/%d'],
    augend.date.alias['%Y-%m-%d'],
    augend.date.alias['%H:%M:%S'],
    augend.date.alias['%H:%M'],
    augend.constant.new {
      elements = { 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun' },
      word = true,
      cyclic = true,
    },
    augend.constant.new {
      elements = { 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' },
      word = true,
      cyclic = true,
    },
  },
}
