{ lib, pkgs, ...}:

{
  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "junior";
      };

      defaultSession = "hyprland-uwsm";

      sddm = {
        enable = true;
        wayland.enable = false;
      };
    };

    gvfs = {
      enable = true;
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # for sddm
    xserver.enable = true;
  };
}
