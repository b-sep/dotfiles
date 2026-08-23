return {
  'lewis6991/gitsigns.nvim',
  config = function()
    local gitsigns = require('gitsigns')

    gitsigns.setup({
      signs = {
        add = { text = '▎' },
        change = { text = "▎" },
        delete = { text = '▎' },
        topdelete = { text = '▎' },
        changedelete = { text = '▎' }
      },
      current_line_blame = false,
      current_line_blame_opts = {
        delay = 1000
      },
      current_line_blame_formatter = '<author>, <author_time:%d-%m-%Y> - <summary>'
    })
  end
}
