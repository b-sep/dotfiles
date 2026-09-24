{ inputs, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in

{
  programs = {
    # https://gitlab.gnome.org/GNOME/dconf
    # used by evince (also force-enabled by i18n.inputMethod's ibus module,
    # but kept explicit here since evince's need is independent of ibus)
    dconf = { enable = true; };

    # gpu-screen-recorder needs a capability wrapper for KMS capture,
    # so it lives at system level; the capture scripts are in modules/screenshot.nix (home-manager)
    gpu-screen-recorder = { enable = true; };

    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${system}.hyprland;
      portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
      withUWSM = true;
      xwayland.enable = true;
    };
  };
}
