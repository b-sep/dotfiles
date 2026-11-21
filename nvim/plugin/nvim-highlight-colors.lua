vim.pack.add({ 'https://github.com/brenoprata10/nvim-highlight-colors' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'css', 'javascript', 'html' },
  once = true,
  callback = function()
    require('nvim-highlight-colors').setup({
      render = 'background',
      enable_named_colors = true,
      enable_tailwind = false,
    })
  end,
})
