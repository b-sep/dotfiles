return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  init = function()
    ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'ruby', 'typescript', 'python', 'elixir', 'javascript', 'html', 'css', 'erlang', 'sql', 'nix' }
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
          -- Enable treesitter-based indentation
          -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end

        -- local max_filesize = 100 * 1024
        -- local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
        -- if ok and stats and stats.size > max_filesize then
        --   return  -- skip treesitter for big files
        -- end

        -- Enable treesitter highlighting and disable regex syntax
        pcall(vim.treesitter.start)
      end,
    })
  end
}
