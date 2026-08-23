local M = {}

M.setup = function()
  local config = {
    float = {
      border = 'rounded',
      scope = 'line'
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.INFO]  = ' ',
        [vim.diagnostic.severity.HINT]  = ' ',
        [vim.diagnostic.severity.WARN]  = ' '
      },
    },
    update_in_insert = true
  }

  vim.diagnostic.config(config)
end

local function lsp_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }
  local keymap = vim.keymap.set

  keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  keymap('n', 'gI', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  keymap('n', 'gl', '<Cmd>lua vim.diagnostic.open_float()<CR>', opts)
  keymap('n', '<leader>lf', '<Cmd>lua vim.lsp.buf.format{ async = true }<cr>', opts)
  keymap('n', '<leader>li', '<Cmd>checkhealth vim.lsp<cr>', opts)
  keymap('n', '<leader>la', '<Cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  keymap('n', '<leader>lj', '<Cmd>lua vim.diagnostic.jump({ count=1, float=true })<cr>', opts)
  keymap('n', '<leader>lk', '<Cmd>lua vim.diagnostic.jump({ count=-1, float=true })<cr>', opts)
  keymap('n', '<leader>lr', '<Cmd>lua vim.lsp.buf.rename()<cr>', opts)
  keymap('n', '<leader>ls', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  keymap('n', '<leader>lq', '<Cmd>lua vim.diagnostic.setloclist()<CR>', opts)
end

M.on_attach = function(_, bufnr)
  lsp_keymaps(bufnr)
end

return M
