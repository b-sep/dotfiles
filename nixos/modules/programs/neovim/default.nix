{ pkgs, ... }:

{
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    viAlias = true;
    vimAlias = true;
    waylandSupport = true;

    extraPackages = with pkgs; [
      basedpyright
      clang-tools
      lua-language-server
      typescript-language-server
      vscode-langservers-extracted
      tree-sitter
    ];
  };

  xdg.configFile."nvim" = {
    source = ./settings;
    recursive = true;
  };
}
