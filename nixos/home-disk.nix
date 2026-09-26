{ ... }:

{
  boot.initrd.luks.devices.crypthome = {
    device = "/dev/disk/by-uuid/82a8cbc1-8901-4a4f-b156-f2d677ddd6b1";
  };

  fileSystems."/home" = {
    device = "/dev/mapper/crypthome";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" ];
  };
}
