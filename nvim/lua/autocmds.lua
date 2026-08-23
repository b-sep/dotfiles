-- https://github.com/neovim/neovim/issues/16572
local modified = false
vim.api.nvim_create_autocmd({'UIEnter', 'ColorScheme'}, {
  callback = function()
    local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
    if normal.bg then
      io.write(string.format('\027]11;#%06x\027\\', normal.bg))
      modified = true
    end
  end,
})

vim.api.nvim_create_autocmd('UILeave', {
  callback = function()
    if modified then
      io.write('\027]111\027\\')
    end
  end,
})

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking',
  group = vim.api.nvim_create_augroup('Kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
