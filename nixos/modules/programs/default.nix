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
      settings = {
        logo = {
          source = "nixos_small";
          padding = {
            right = 2;
          };
        };
        display = {
          separator = "   ";
          key = {
            width = 6;
          };
        };
        modules = [
          {
            type = "os";
            key = "OS";
          }
          {
            type = "kernel";
            key = "KER";
          }
          {
            type = "packages";
            key = "PKG";
          }
          {
            type = "shell";
            key = "SH";
          }
          {
            type = "terminal";
            key = "TER";
          }
          {
            type = "wm";
            key = "WM";
          }
        ];
      };
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
