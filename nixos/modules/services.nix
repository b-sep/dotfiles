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
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # for sddm
    xserver.enable = true;
  };
}
