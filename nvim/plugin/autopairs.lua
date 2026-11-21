vim.pack.add({ 'https://github.com/windwp/nvim-autopairs' })

vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  callback = function()
    require('nvim-autopairs').setup({
      check_ts = true,
    })
  end,
})
