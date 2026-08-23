{ inputs, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in

{
  programs = {
    # https://gitlab.gnome.org/GNOME/dconf
    # used by evince
    dconf = { enable = true; };

    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${system}.hyprland;
      portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
      withUWSM = true;
      xwayland.enable = true;
    };
  };
}
