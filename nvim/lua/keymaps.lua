local opts = { silent = true }
-- https://www.reddit.com/r/neovim/comments/xvp7c5/vimapinvim_set_keymap_vs_vimkeymapset_whats_the/
local keymap = vim.keymap.set

---@param picker string
local function custom_picker(picker)
  require('telescope.builtin')[picker](require('telescope.themes').get_dropdown({ previewer = false }))
end

-- Normal mode --
keymap('n', '<leader>e', '<Cmd>NvimTreeToggle<CR>', opts)
keymap('n', '<leader>f', '<Cmd>Telescope live_grep<CR>', opts)
keymap('n', '<leader>q', '<Cmd>q<CR>', opts)
keymap('n', '<leader>Q', '<Cmd>qa<CR>', opts)
keymap('n', '<leader>x', ':.lua<CR>')
keymap('n', '<leader><leader>x', '<Cmd>source %<CR>')
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-l>', '<C-w>l', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-\\>', '<cmd>vsp<cr>', opts)
keymap('n', '<A-,>', '<Cmd>sp<CR>', opts)
keymap('n', '<A-z>', '<Cmd>set wrap!<CR>', opts)
keymap('n', '<A-p>', '<Cmd>MarkdownPreviewToggle<CR>', opts)
keymap('n', '<C-w>', '<Cmd>Bdelete<CR>', opts)
keymap('n', '<A-f>', '<Cmd>Telescope buffers<CR>', opts)
keymap('n', '<C-b>', function() custom_picker('help_tags') end, opts)
-- Resize windows
keymap('n', '<A-h>', '<Cmd>vertical resize +2<CR>', opts)
keymap('n', '<A-l>', '<Cmd>vertical resize -2<CR>', opts)
keymap('n', '<A-j>', '<Cmd>resize -2<CR>', opts)
keymap('n', '<A-k>', '<Cmd>resize +2<CR>', opts)
keymap({ 'n', 'i' }, '<C-e>', function() custom_picker('find_files') end, opts)
keymap('n', '<Esc>', '<Cmd>noh<CR>', opts)

-- Insert mode --
keymap('i', '<S-Tab>', '<C-d>', opts)
keymap('i', '<A-z>', '<ESC><Cmd>set wrap!<CR>', opts)
keymap('i', '<C-\\>', function() require('Comment.api').toggle.linewise.current() end, opts)

-- Visual mode --
keymap('v', '<tab>', '>gv', opts)
keymap('v', '<S-Tab>', '<gv', opts)
keymap('v', 'p', '"_dP"', opts)
keymap('v', '<leader>x', ':.lua<CR>')
-- keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", opts)
-- keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", opts)
