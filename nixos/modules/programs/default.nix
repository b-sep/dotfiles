{ inputs, pkgs, ... }:

{
  imports = [
    ./bash
    ./ghostty
    ./git
    ./kitty
    ./neovim
    ./quickshell
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

    claude-code = {
      enable = true;
      mcpServers = {
        github = {
          headers.Authorization = "Bearer \${GITHUB_PERSONAL_TOKEN}";
          type = "http";
          url = "https://api.githubcopilot.com/mcp/";
        };
      };
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
      skills = {
        teach = "${inputs.mattpocock-skills}/skills/productivity/teach";
      };
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

    herdr = {
      enable = true;
    };

    jq = {
      enable = true;
    };

    k9s = {
      enable = true;
    };

    lazygit = {
      enable = true;
    };

    mcp = {
      enable = true;
      servers = {
        github = {
          headers.Authorization = "Bearer {env:GITHUB_PERSONAL_TOKEN}";
          url = "https://api.githubcopilot.com/mcp/";
        };
      };
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

    opencode = {
      enable = true;
      enableMcpIntegration = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    };

    ripgrep = {
      enable = true;
    };

    tmux = {
      enable = true;
    };

    vscode = {
      enable = true;
      mutableExtensionsDir = true;
    };
  };
}
