return {
  'nvim-telescope/telescope.nvim', version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')

    telescope.setup({
      defaults = {
        file_ignore_patterns = { '%.git/.', 'node_modules' },
        prompt_prefix = ' ',
        selection_caret = ' ',
        path_display = { 'truncate' },
        layout_strategy = 'center',
        sorting_strategy = 'ascending',

        layout_config = {
          center = {
            prompt_position = 'top',
            height = 0.5
          }
        }
      },
      pickers = {
        find_files = {
          hidden = true,
          -- no_ignore = true,
          previewer = false
        },
        live_grep = {
          hidden = true,
          previewer = true,
          layout_strategy = 'horizontal'
        },
        buffers = {
          theme = 'dropdown',
          previewer = false,
          sort_mru = true,
          mappings = {
            i = {
              ['<C-d>'] = actions.delete_buffer
            }
          }
        },
      },
      extensions = { fzf = {} },
    })

    telescope.load_extension('fzf')
  end
}
