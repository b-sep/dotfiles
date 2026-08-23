return {
  'brenoprata10/nvim-highlight-colors',
  ft = { 'css', 'javascript', 'html' },
  config = function()
    local nhc = require('nvim-highlight-colors')
    local opts = {
      render = 'background',
      enable_named_colors = true,
      enable_tailwind = false
    }

    nhc.setup(opts)
  end
}
