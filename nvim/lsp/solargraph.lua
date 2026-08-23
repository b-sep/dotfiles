-- https://github.com/castwide/vscode-solargraph/blob/master/README.md#extension-settings
return {
  cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
  settings = {
    solargraph = {
      diagnostics = true
    },
  },
  init_options = { formatting = true },
  filetypes = { 'ruby' },
  root_markers = { 'Gemfile', '.git' },
}
