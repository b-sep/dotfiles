{ config, inputs, pkgs, ... }:

# https://nix-community.github.io/home-manager/preface.html

{
  imports = [
    ./modules/dictation.nix
    ./modules/programs
    ./modules/screenshot.nix
  ];

  home = {
    homeDirectory = "/home/junior";
    stateVersion = "26.05";
    username = "junior";

    packages = with pkgs; [
      cliamp
      ente-auth
      evince
      file
      fortune
      gdb
      gnumake
      hyprpaper
      hyprpicker
      insomnia
      logisim-evolution
      loupe
      man-pages
      mlocate
      tree
      valgrind
    ];

    pointerCursor = {
      enable = true;
      gtk.enable = true;
      hyprcursor.enable = true;
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
      x11.enable = true;
    };

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # gtk theming and config #
  gtk = {
    colorScheme = "dark";
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  # qt theme #
  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
    };
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # services #
  services = {
    # clipboard history (text and images), read by the quickshell bar
    cliphist = {
      enable = true;
    };

    dunst = {
      enable = true;

      settings = {
        global = {
          width = 350;
          height = "(0, 300)";
          origin = "top-right";
          offset = "(10, 10)";
          gap_size = 0;
          padding = 9;
          horizontal_padding = 12;
          frame_width = 2;
          separator_height = 0;
          corner_radius = 0;
          font = "Sans 11";
          alignment = "center";
          vertical_alignment = "center";
          markup = "full";
          format = "<b>%s</b>\\n%b";
          icon_position = "off";
          background = "#1d1918";
          mouse_left_click = "do_action, close_current";
        };

        urgency_low = {
          foreground = "#458588";
          frame_color = "#458588";
          timeout = 5;
        };

        urgency_normal = {
          foreground = "#689d6a";
          frame_color = "#689d6a";
          timeout = 10;
        };

        urgency_critical = {
          foreground = "#cc5b3e";
          frame_color = "#cc5b3e";
          timeout = 0;
        };

        # IBus always shows this on login on non-GNOME/KDE Wayland sessions,
        # even when correctly configured. Harmless, just noise; drop it.
        ignore_ibus_wayland_notice = {
          category = "wayland";
          appname = "ibus";
          skip_display = true;
        };
      };
    };

    elephant = {
      enable = true;
    };

    hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        wallpaper = [
          {
            monitor = "DP-1";
            path = "~/Wallpapers/";
            fit_mode = "cover";
            timeout = 14400; # 4 hours
          }
        ];
      };
    };

    hyprsunset = {
      enable = true;
      extraArgs = [ "--temperature" "4000" "--identity" ];
    };

    walker = {
      enable = true;
      # runs `walker --gapplication-service` as a user unit; since
      # elephant is enabled, it Requires/starts After elephant.service
      systemd.enable = true;
    };
  };
}
