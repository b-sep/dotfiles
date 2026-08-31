{ pkgs, ... }:

{
  imports = [
    ./bash
    ./git
    ./kitty
    ./neovim
  ];

  programs = {
    anki = {
      enable = true;
      theme = "followSystem";
    };

    bat = {
      enable = true;
    };

    btop = {
      enable = true;
    };

    dbeaver = {
      enable = true;
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    devenv = {
      enable = true;
      enableBashIntegration = false;
    };

    discord = {
      enable = true;
    };

    fastfetch = {
      enable = true;
      # TODO: settings
      # settings = {}
    };

    fd = {
      enable = true;
      ignores = [".git/"];
    };

    firefox = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    gcc = {
      enable = true;
    };

    gh = {
      enable = true;
    };

    jq = {
      enable = true;
    };

    lazygit = {
      enable = true;
    };

    obs-studio = {
      enable = true;
    };

    obsidian = {
      enable = true;
      cli = {
        enable = true;
      };
    };

    quickshell = {
      enable = true;
      systemd = {
        enable = true;
      };
    };

    ripgrep = {
      enable = true;
    };
  };
}
