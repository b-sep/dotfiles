-- https://github.com/clangd/coc-clangd/issues/40
return {
  init_options = {
    fallbackFlags = { '-xc', '-std=c23' }
  }
}
