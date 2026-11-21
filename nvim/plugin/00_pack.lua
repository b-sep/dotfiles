-- Build / update hooks must be registered before the first vim.pack.add() call
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind

    if name == 'telescope-fzf-native.nvim' and (kind == 'install' or kind == 'update') then
      local res = vim.system({ 'make' }, { cwd = ev.data.path }):wait()
      if res.code ~= 0 then
        vim.notify('telescope-fzf-native build failed:\n' .. (res.stderr or ''), vim.log.levels.ERROR)
      end
    end

    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

-- Convenience commands for vim.pack management
vim.api.nvim_create_user_command('PackUpdate', function()
  vim.pack.update()
end, { desc = 'Update plugins managed by vim.pack' })

vim.api.nvim_create_user_command('PackClean', function()
  local inactive = vim.iter(vim.pack.get())
    :filter(function(p)
      return not p.active
    end)
    :map(function(p)
      return p.spec.name
    end)
    :totable()

  if #inactive == 0 then
    vim.notify('vim.pack: no inactive plugins to remove', vim.log.levels.INFO)
    return
  end

  vim.pack.del(inactive)
end, { desc = 'Remove inactive plugins managed by vim.pack' })
