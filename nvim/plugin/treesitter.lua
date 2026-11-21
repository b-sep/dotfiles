vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
})

local ensure_installed = {
  'c',
  'lua',
  'vim',
  'vimdoc',
  'query',
  'ruby',
  'typescript',
  'python',
  'rust',
  'elixir',
  'javascript',
  'html',
  'css',
  'erlang',
  'sql',
  'nix'
}

local alreadyInstalled = require('nvim-treesitter.config').get_installed()
local parsersToInstall = vim.iter(ensure_installed)
  :filter(function(parser)
    return not vim.tbl_contains(alreadyInstalled, parser)
  end)
  :totable()

require('nvim-treesitter').install(parsersToInstall)

local indent_disabled = { ruby = true, css = true }

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if not indent_disabled[vim.bo[args.buf].filetype] then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    -- Enable treesitter highlighting and disable regex syntax
    pcall(vim.treesitter.start)
  end,
})
