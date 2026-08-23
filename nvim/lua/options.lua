local opt = vim.opt -- (set vimscript)

vim.keymap.set('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '

local options = {
  backup = false,
  clipboard = 'unnamedplus',
  cmdheight = 1,
  completeopt = { 'menuone', 'noselect' },
  conceallevel = 0,
  ignorecase = true,
  mouse = '',
  pumheight = 10,
  showmode = false,
  smartcase = true,
  smartindent = true,
  splitbelow = true,
  splitright = true,
  swapfile = false,
  timeoutlen = 1000,
  updatetime = 300,
  writebackup = false,
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  cursorline = true,
  cursorcolumn = false,
  number = true,
  relativenumber = true,
  numberwidth = 1,
  signcolumn = 'yes',
  wrap = false,
  scrolloff = 8,
  eol = true,
  termguicolors = true,
  background = 'dark',
}

for k, v in pairs(options) do
  opt[k] = v
end

opt.iskeyword:append({ '+', '=', '-' })
