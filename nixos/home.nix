{ config, pkgs, ... }:

# https://nix-community.github.io/home-manager/preface.html

{
  imports = [
    ./modules/programs
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
    dunst = {
      enable = true;
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
  };
}
