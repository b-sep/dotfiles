vim.pack.add({ 'https://github.com/hiphish/rainbow-delimiters.nvim' })

local rainbow_delimiters = require('rainbow-delimiters')

vim.g.rainbow_delimiters = {
  strategy = {
    [''] = rainbow_delimiters.strategy['global'],
    vim = rainbow_delimiters.strategy['local'],
  },
  query = {
    [''] = 'rainbow-delimiters',
    lua = 'rainbow-blocks',
    tsx = 'rainbow-parens',
  },
  highlight = {
    'RainbowDelimiterYellow',
    'RainbowDelimiterBlue',
    'RainbowDelimiterGreen',
    'RainbowDelimiterViolet',
    'RainbowDelimiterCyan',
    'RainbowDelimiterOrange',
    'RainbowDelimiterRed',
  },
}
