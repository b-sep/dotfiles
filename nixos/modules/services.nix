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
      # ALSA clients (voxtype records from ALSA "default") go through PipeWire
      alsa.enable = true;
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # for sddm
    xserver.enable = true;
  };
}
