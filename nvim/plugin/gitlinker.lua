vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/ruifm/gitlinker.nvim',
})

local gitlinker = require('gitlinker')

vim.api.nvim_set_keymap('n', '<leader>gY', '<cmd>lua require"gitlinker".get_repo_url()<cr>', { silent = true })

gitlinker.setup()
