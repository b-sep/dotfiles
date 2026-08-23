return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  opts = {
    debounce = 100,
    indent = {
      char = "▏"
    },
    scope = {
      show_start = false,
      show_end = false,
      include = {
        node_type = {
          ruby = { "if", "unless" },
          lua = { "table_constructor" }
        }
      }
    }
  }
}
