return {
  'nvim-lualine/lualine.nvim',
  config = function ()
    local lualine = require('lualine')
    local lualine_nightfly = require('lualine.themes.nightfly')

    local colors = {
      blue = '#65D1FF',
      green = '#3EFFDC',
      violet = '#FF61EF',
      yellow = '#FFDA7B',
      black = '#000000',
      bg = '#2C3043',
    }

    lualine_nightfly.normal.a.bg = colors.blue
    lualine_nightfly.insert.a.bg = colors.green
    lualine_nightfly.visual.a.bg = colors.violet
    lualine_nightfly.command = {
      a = { gui = 'bold', bg = colors.yellow, fg = colors.black }
    }

    local statusbar_sections = {
      lualine_b = {
        {
          'branch',
          icon = { '󰘬', color = { fg = 'white' } },
          color = { fg = '#ffffff' },
          padding = 2,
        },
      },
      lualine_c = {},
      lualine_x = {
        {
          'filetype',
          colored = true,
          icon_only = true,
          icon = { align = 'right' },
        },
        {
          'filename',
          path = 1,
        },
        {
          'diagnostics',
          symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ', },
          colored = true,
        },
        {
          'diff',
          symbols = { added = '+', modified = '~', removed = '-', },
          padding = { left = 2, right = 1, },
        },
      },
    }

    lualine.setup({
      options = {
        icons_enabled = true,
        theme = lualine_nightfly,
        globalstatus = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = statusbar_sections,
    })
  end
}
