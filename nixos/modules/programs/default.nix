{ config, inputs, lib, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  agentsMd = ../../../shared/AGENTS.md;
  mcpRemote = inputs.llm-agents.packages.${system}.mcp-remote;

  auvpMcp = pkgs.writeShellScript "mcp-auvp" ''
    token=''${AUVP_API_KEY//[$'\r\n']/}
    exec ${lib.getExe mcpRemote} \
      https://financas-api.auvp.com.br/mcp \
      --transport http-only \
      --header "x-api-key: $token"
  '';
in

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
    antigravity = {
      enable = true;
      package = pkgs.antigravity-ide;
    };

    antigravity-cli = {
      context = { AGENTS = agentsMd; };
      enable = true;
      enableMcpIntegration = true;
      package = inputs.llm-agents.packages.${system}.antigravity-cli;
    };

    bat = {
      enable = true;
    };

    btop = {
      enable = true;
    };

    claude-code = {
      context = agentsMd;
      enable = true;
      enableMcpIntegration = true;
      package = inputs.llm-agents.packages.${system}.claude-code;
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
        auvp = {
          command = "${auvpMcp}";
          env.AUVP_API_KEY.file = "${config.home.homeDirectory}/.config/auvp-mcp.txt";
        };
        github = {
          args = ["stdio"];
          command = lib.getExe pkgs.github-mcp-server;
          env.GITHUB_PERSONAL_ACCESS_TOKEN.file = "${config.home.homeDirectory}/.config/ghmcp.txt";
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
      context = agentsMd;
      enable = true;
      enableMcpIntegration = true;
      mutableSettings = true; # avoids collisions with files OpenCode rewrites
      package = inputs.llm-agents.packages.${system}.opencode2;

      # cli = {
      #   theme = {};
      # };
    };

    ripgrep = {
      enable = true;
    };
  };
}
