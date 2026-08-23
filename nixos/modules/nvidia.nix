# https://wiki.nixos.org/wiki/NVIDIA
#
#
{ config, ... }:

{
  # When the hardware.nvidia.powerManagement.enable option is enabled, the driver saves video memory to /tmp by default.
  # If /tmp is backed by tmpfs (RAM) and the GPU VRAM usage exceeds the available space, the system will not resume and you will see a blank screen instead.
  # To resolve this, redirect the temporary file to a storage location with sufficient capacity (e.g., /var/tmp) using kernel parameters: 
  boot = {
    kernelParams = [ "nvidia.NVreg_TemporaryFilePath=/var/tmp" ];
  };

  hardware = {
    graphics = { enable = true; };

    nvidia = {
      modesetting = { enable = true; }; # wayland requirement
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      powerManagement = { enable = true; };
    };
  };

  services = {
    xserver.videoDrivers = ["nvidia"];
  };
}
