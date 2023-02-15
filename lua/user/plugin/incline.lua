---- b0o/incline.nvim
local incline = require 'incline'
-- local colors = require 'user.colors'
-- local config = require 'incline.config'

-- if true then
--   return
-- end

if false then
  local function get_diagnostic_label(props)
    local icons = {
      Error = '',
      Warn = '',
      Info = '',
      Hint = '',
    }

    local label = {}
    for severity, icon in pairs(icons) do
      local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
      if n > 0 then
        local fg = '#'
          .. string.format('%06x', vim.api.nvim_get_hl_by_name('DiagnosticSign' .. severity, true)['foreground'])
        table.insert(label, { icon .. ' ' .. n .. ' ', guifg = fg })
      end
    end
    return label
  end

  require('incline').setup {
    debounce_threshold = { falling = 500, rising = 250 },
    render = function(props)
      local bufname = vim.api.nvim_buf_get_name(props.buf)
      local filename = vim.fn.fnamemodify(bufname, ':t')
      local diagnostics = get_diagnostic_label(props)
      local modified = vim.api.nvim_buf_get_option(props.buf, 'modified') and 'bold,italic' or 'None'
      local filetype_icon, color = require('nvim-web-devicons').get_icon_color(filename)

      local buffer = {
        { filetype_icon, guifg = color },
        { ' ' },
        { filename, gui = modified },
      }

      if #diagnostics > 0 then
        table.insert(diagnostics, { '| ', guifg = 'grey' })
      end
      for _, buffer_ in ipairs(buffer) do
        table.insert(diagnostics, buffer_)
      end
      return diagnostics
    end,
  }
elseif false then
  local a = vim.api
  local devicons = require 'nvim-web-devicons'
  local aerial = require 'aerial'
  require('incline').setup {
    render = function(props)
      local bufname = a.nvim_buf_get_name(props.buf)
      local modified = a.nvim_buf_get_option(props.buf, 'modified')
      local fname = bufname == '' and '[No name]' or vim.fn.fnamemodify(bufname, ':t')

      local unfoc_color = 'white'
      local color = function(foc, unfoc)
        if props.focused then
          return foc
        end
        return unfoc or unfoc_color
      end

      local icon, icon_fg
      -- Try to get the icon based on the filename
      if bufname ~= '' then
        icon, icon_fg = devicons.get_icon_color(fname)
      end
      -- Fall back to getting icon by filetype
      if not icon or icon == '' then
        local icon_name
        local filetype = a.nvim_buf_get_option(props.buf, 'filetype')
        if filetype ~= '' then
          icon_name = devicons.get_icon_name_by_filetype(filetype)
          if icon_name and icon_name ~= '' then
            icon, icon_fg = devicons.get_icon_color(icon_name)
          end
        end
      end
      icon = icon or ''

      local res = {}

      if icon_fg then
      else
      end

      local res = {
        {
          icon,
          guifg = icon_fg or nil,
          group = not icon_fg and 'Number' or nil,
        },
        ' ',
        {
          fname,
          modified and ' *' or '',
          group = 'Number',
        },
      }

      if props.focused then
        local aerial_data = aerial.get_location()
        for i = 1, #aerial_data do
          table.insert(res, {
            '  ',
            group = 'Conditional',
          })
          table.insert(res, {
            aerial_data[i].icon,
            ' ',
            aerial_data[i].name,
            group = i == #aerial_data and 'Character' or 'Label',
          })
        end
      end

      return res
    end,
    window = {
      margin = { horizontal = 0, vertical = 0 },
      zindex = 51,
      placement = { horizontal = 'right', vertical = 'top' },
    },
    hide = {
      cursorline = 'focused_win',
    },
  }
elseif false then
  local a = vim.api
  local devicons = require 'nvim-web-devicons'
  local gps = require 'nvim-gps'
  gps.setup()

  require('incline').setup {
    render = function(props)
      local bufname = a.nvim_buf_get_name(props.buf)
      local modified = a.nvim_buf_get_option(props.buf, 'modified')
      local fname = bufname == '' and '[No name]' or vim.fn.fnamemodify(bufname, ':t')

      local icon, icon_fg
      -- Try to get the icon based on the filename
      if bufname ~= '' then
        icon, icon_fg = devicons.get_icon_color(fname)
      end
      -- Fall back to getting icon by filetype
      if not icon or icon == '' then
        local icon_name
        local filetype = a.nvim_buf_get_option(props.buf, 'filetype')
        if filetype ~= '' then
          icon_name = devicons.get_icon_name_by_filetype(filetype)
          if icon_name and icon_name ~= '' then
            icon, icon_fg = devicons.get_icon_color(icon_name)
          end
        end
      end

      local res = {
        {
          icon or '',
          guifg = icon_fg or nil,
          group = not icon_fg and 'Number' or nil,
        },
        ' ',
        {
          fname,
          modified and ' *' or '',
          group = 'Number',
        },
      }

      if props.focused then
        local gps_data = gps.is_available() and gps.get_data() or {}
        for i = 1, #gps_data do
          table.insert(res, {
            '  ',
            group = 'Conditional',
          })
          table.insert(res, {
            gps_data[i].icon,
            gps_data[i].text,
            group = i == #gps_data and 'Character' or 'Label',
          })
        end
      end

      return res
    end,
    window = {
      zindex = 51,
      margin = { vertical = 0 },
      placement = { vertical = 'bottom' },
      winhighlight = {
        active = { Normal = 'Visual' },
        inactive = { Normal = 'Conceal' },
      },
    },
  }
elseif false then
  require('incline').setup {
    render = function(props)
      -- local winline_row = vim.api.nvim_win_get_config(props._win).row[false]
      -- if vim.api.nvim_win_get_cursor(props.win)[1] == vim.fn.line 'w0' then
      --   return
      -- end
      local bufname = vim.api.nvim_buf_get_name(props.buf)
      if bufname == '' then
        return '[No name]'
      end
      local directory_color = 'pink'
      local parts = vim.split(vim.fn.fnamemodify(bufname, ':.'), '/')
      local result = {}
      for idx, part in ipairs(parts) do
        if next(parts, idx) then
          table.insert(result, { part })
          table.insert(result, { string.format(' %s ', ''), guifg = directory_color })
        else
          table.insert(result, { part, gui = 'underline,bold' })
        end
      end
      local icon, color = require('nvim-web-devicons').get_icon_color(bufname, nil, {
        default = true,
      })
      if icon then
        table.insert(result, #result, { icon .. ' ', guifg = color })
      end
      return result
    end,
    -- render = 'basic',
    -- debounce_threshold = 1000,
    -- render = { 'devicons', color = false },
    hide = {
      --   focused_win = true,
      cursorline = 'focused_win',
    },
    window = {
      -- winhighlight = { Normal = 'Search' },
      width = 'fit',
      placement = {
        --vertical = 'bottom',
        horizontal = 'right',
      },
      zindex = 51,
      margin = { vertical = 0 },
      -- window = {
      --   options = {
      --     winhighlight = 'Normal:Search',
      --   },
    },
  }
elseif false then
  require('incline').setup {
    window = {
      margin = {
        horizontal = {
          left = 1,
          right = 0,
        },
        vertical = {
          bottom = 0,
          top = 1,
        },
      },
      options = {
        signcolumn = 'no',
        wrap = false,
      },
      padding = {
        left = 1,
        right = 1,
      },
      padding_char = ' ',
      placement = {
        horizontal = 'right',
        vertical = 'top',
      },
      width = 'fit',
      winhighlight = {
        active = {
          EndOfBuffer = 'None',
          Normal = 'InclineNormal',
          Search = 'None',
        },
        inactive = {
          EndOfBuffer = 'None',
          Normal = 'InclineNormalNC',
          Search = 'None',
        },
      },
      zindex = 50,
    },
  }
elseif false then
  require('incline').setup {
    render = function(props)
      local bufname = vim.api.nvim_buf_get_name(props.buf)
      if bufname == '' then
        return '[No name]'
      end
      local parts = vim.split(vim.fn.fnamemodify(bufname, ':.'), '/')
      local icon, _ = require('nvim-web-devicons').get_icon(bufname, nil, { default = true })
      parts[#parts] = string.format('%s %s', icon, parts[#parts])
      return table.concat(parts, '  ')
    end,
    window = {
      --options = { winhighlight = 'Normal:Search' },
      -- winhighlight = {
      --   active = { Normal = 'Search' },
      --   inactive = { Normal = 'Search' },
      -- },
      winhighlight = {
        Normal = 'Search',
      },
    },
    -- window = { winhighlight = 'Normal:Foo' },
    --window = { winhighlight = { active = 'Normal:Foo' } },
  }
elseif false then
  local a = vim.api

  require('incline').setup {
    -- render = function(props)
    render = function(props)
      local bufname = vim.api.nvim_buf_get_name(props.buf)
      local modified = a.nvim_buf_get_option(props.buf, 'modified')
      bufname = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No name]'
      return {
        {
          bufname,
          guifg = props.focused and '#B1CBFF' or '#8193B9',
        },
        {
          modified and ' *' or '',
          guifg = props.focused and '#98AFDE' or '#798AAE',
        },
        guibg = props.focused and '#2C2B56' or '#2C2C3B',
      }
    end,
    -- unfocused = function(props)
    --   return {
    --     { 'foo', guifg = 'blue' },
    --     { 'bar', guibg = 'red', gui = 'italic' },
    --     {
    --       'baz',
    --       'qux',
    --       {
    --         1,
    --         2,
    --         guibg = 'black',
    --         gui = 'undercurl',
    --       },
    --       guibg = 'green',
    --       guifg = 'yellow',
    --     },
    --     'hello',
    --     'world',
    --     {
    --       'and',
    --       'goodnight',
    --       blend = 10,
    --     },
    --   }
    -- end,
    -- sep = '',
    --     sep_hl = { focused = { guifg = 'red' }, unfocused = {} },
    highlight = {
      groups = {
        InclineNormal = { guibg = 'NONE' },
        InclineNormalNC = { guibg = 'NONE' },
      },
    },
    -- window = { padding = 'bar' },
  }

  -- require('incline').setup {
  --   render = {
  --     func = function(props)
  --       print(vim.fn.localtime())
  --       local bufname = vim.api.nvim_buf_get_name(props.buf)
  --       bufname = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No name]'
  --       return {
  --         '{',
  --         {
  --           bufname,
  --           guifg = 'white',
  --           gui = 'undercurl',
  --         },
  --         '}',
  --         ' ',
  --         {
  --           vim.tbl_map(function(n)
  --             return {
  --               n,
  --               guifg = n == ':' and (vim.fn.localtime() % 2 == 0 and colors.white or colors.grey2) or colors.powder,
  --             }
  --           end, vim.split(vim.fn.strftime '%H,:,%M,:,%S', ',')),
  --         },
  --         guifg = 'gray',
  --       }
  --     end,
  --     sep = '',
  --   },
  --   -- window = { padding = 'bar' },
  -- }

  -- require('incline').setup {
  --   render = {
  --     func = function(props)
  --       local bufname = vim.api.nvim_buf_get_name(props.buf)
  --       local modified = a.nvim_buf_get_option(props.buf, 'modified')
  --       if bufname == '' then
  --         return '[No name]'
  --       else
  --         bufname = vim.fn.fnamemodify(bufname, ':t')
  --       end
  --       return {
  --         {
  --           bufname,
  --           guifg = props.focused and '#B1CBFF' or '#8193B9',
  --         },
  --         {
  --           modified and '*' or '',
  --           guifg = props.focused and '#98AFDE' or '#798AAE',
  --         },
  --         guibg = props.focused and '#2C2B56' or '#2C2C3B',
  --       }
  --     end,
  --     sep = '_',
  --     sep_hl = { focused = { guifg = 'red' }, unfocused = {} },
  --   },
  -- }
else
  local a = vim.api

  local devicons = require 'nvim-web-devicons'

  local colors = {
    theme_bg = '#222032',
    fg = 'white',
    fg_nc = '#B4A7DE',
    bg = 'NONE',
    bg_nc = 'NONE',
    -- bg = '#6E6EA3',
    -- bg_nc = '#564D82',
    cursorline = '#3F3650',
    cursorline_nc = '#2F2A38',
  }

  incline.setup {
    render = function(props)
      local bufname = a.nvim_buf_get_name(props.buf)
      -- local cursor = a.nvim_win_get_cursor(props.win)

      local modified = a.nvim_buf_get_option(props.buf, 'modified')
      local focused = a.nvim_get_current_win() == props.win

      local fg = focused and colors.fg or colors.fg_nc
      local bg = focused and colors.bg or colors.bg_nc

      -- Match cursorline background if cursor is on the same line as the statusline
      -- local lower_bg = cursor[1] == 1 and (focused and colors.cursorline or colors.cursorline_nc) or colors.theme_bg

      local fname = bufname == '' and '[No name]' or vim.fn.fnamemodify(bufname, ':t')

      local icon, icon_fg
      if bufname ~= '' then
        icon, icon_fg = devicons.get_icon_color(fname)
      end
      if not icon or icon == '' then
        local icon_name
        local filetype = a.nvim_buf_get_option(props.buf, 'filetype')
        if filetype ~= '' then
          icon_name = devicons.get_icon_name_by_filetype(filetype)
        end
        if icon_name and icon_name ~= '' then
          icon, icon_fg = require('nvim-web-devicons').get_icon_color(icon_name)
        end
      end
      icon = icon or ''
      icon_fg = props.focused and (icon_fg or colors.fg) or colors.fg_nc

      return {
        guibg = bg,
        guifg = fg,

        -- { '', guifg = bg, guibg = lower_bg },
        ' ',
        { icon, guifg = icon_fg },
        ' ',
        { fname, gui = modified and 'bold,italic' or nil },
        { modified and ' * ' or ' ', guifg = colors.fg },
        -- { '', guifg = bg, guibg = lower_bg },
      }
    end,
    -- highlight = {
    --   groups = {
    --     InclineNormal = { guibg = 'NONE' },
    --     InclineNormalNC = { guibg = 'NONE' },
    --   },
    -- },
    window = {
      -- width = 'fill',
      -- winhighlight = { 'Normal:InclineNormal' },
      -- margin = { horizontal = 0, vertical = 3 },
      margin = { horizontal = 0, vertical = 0 },
      padding = 0,
      zindex = 51,
      placement = { horizontal = 'right', vertical = 'top' },
      -- options = { winhighlight = { 'Normal:InclineNormal' } },
    },
    hide = {
      cursorline = 'focused_win',
      -- focused_win = true,
      -- only_win = true,
      -- only_win = 'count_ignored',
    },
  }

  -- local config = require 'incline.config'
  --
  -- incline.setup {
  --   render = function(props)
  --     local bufname = vim.api.nvim_buf_get_name(props.buf)
  --     if bufname == '' then
  --       return '[No name]'
  --     else
  --       bufname = vim.fn.fnamemodify(bufname, ':t')
  --     end
  --     return bufname
  --   end,
  --   debounce_threshold = 30,
  --   window = {
  --     width = 'fit',
  --     placement = { horizontal = 'right', vertical = 'top' },
  --     margin = {
  --       horizontal = { left = 1, right = 1 },
  --       vertical = { bottom = 0, top = 1 },
  --     },
  --     padding = { left = 1, right = 1 },
  --     padding_char = ' ',
  --     zindex = 100,
  --     options = config.replace {
  --       winblend = 10,
  --     },
  --   },
  --   ignore = {
  --     floating_wins = true,
  --     unlisted_buffers = true,
  --     filetypes = {},
  --     buftypes = 'special',
  --     wintypes = 'special',
  --   },
  -- }
end
