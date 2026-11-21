vim.pack.add({ 'https://github.com/lukas-reineke/indent-blankline.nvim' })

require('ibl').setup({
  debounce = 100,
  indent = {
    char = '▏'
  },
  scope = {
    show_start = false,
    show_end = false,
    include = {
      node_type = {
        ruby = { 'if', 'unless' },
        lua = { 'table_constructor' }
      }
    }
  }
})
