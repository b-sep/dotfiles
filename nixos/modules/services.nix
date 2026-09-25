{ lib, pkgs, ...}:

{
  services = {
    displayManager = {
      # gdm = {
      #   enable = true;
      # };

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
