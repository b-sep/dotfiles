vim.pack.add({ 'https://github.com/brianhuster/live-preview.nvim' })

require('livepreview.config').set({
  dynamic_root = true,
  picker = 'telescope',
})
