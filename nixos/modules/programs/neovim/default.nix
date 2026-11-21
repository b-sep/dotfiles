{ config, lib, pkgs, ... }:

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
      elixir-ls
      lsof
      lua-language-server
      rust-analyzer
      typescript-language-server
      vscode-langservers-extracted
      tree-sitter
    ];
  };

  xdg.configFile."nvim" = {
    source = lib.fileset.toSource {
      root = ../../../../nvim;
      fileset = lib.fileset.fileFilter
        (file: file.name != "nvim-pack-lock.json")
        ../../../../nvim;
    };
    recursive = true;
  };

  xdg.configFile."nvim/nvim-pack-lock.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/projetos/dotfiles/nvim/nvim-pack-lock.json";
}
