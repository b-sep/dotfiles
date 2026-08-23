require('lsp.diagnostics').setup()

local on_attach = require('lsp.diagnostics').on_attach

local servers = {
  'clangd',
  'cssls',
  'html',
  'lua_ls',
  'solargraph',
  'ts_ls'
}

for _, server in ipairs(servers) do
  local opts = {}
  local ok, settings = pcall(require, 'lsp.settings.' .. server)

  if ok then
    opts = vim.tbl_deep_extend('force', settings, opts)
  end

  opts.on_attach = on_attach

  vim.lsp.config(server, opts)
end

vim.lsp.enable(servers)
