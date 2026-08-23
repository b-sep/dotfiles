# https://nixos.org/manual/nixos/stable/#sec-configuration-file
#
#
{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/nvidia.nix
    ./modules/fonts.nix
    ./modules/programs.nix
    ./modules/services.nix
    ./modules/screenshot.nix
  ];

  # TODO: install livebook https://nixos.org/manual/nixos/stable/#module-services-livebook
  # TODO: certificate https://nixos.org/manual/nixos/stable/#module-security-acme

  boot = {
    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages_latest;

    # Use the systemd-boot EFI boot loader.
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  # set google public dns
  environment.etc."resolv.conf".text = ''
    nameserver 8.8.8.8
    nameserver 8.8.4.4
    options edns0
  '';

  networking = {
    # Set hostname
    hostName = "nix";

    # Configure network connections interactively with nmcli or nmtui.
    networkmanager = {
      dns = "none";
      enable = true;
    };

    resolvconf = {
      enable = false;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.junior = {
    description = "Roberto Júnior";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    isNormalUser = true;
  };

  virtualisation.docker = {
    enable = true;
  };
 
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    optimise = {
      automatic = true;
    };

    settings = {
      # cache hyprland dependencies
      substituters = ["https://hyprland.cachix.org"];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      # Required so non-root users are allowed to use the above substituter/keys.
      # Use @wheel for all sudo users, or list your username explicitly.
      trusted-users = ["root" "@wheel" "junior"];

      # cache llm-agents
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];

      # enable flake support
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # allow unfree packages to be installed
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    nautilus
    nodejs_24
    nwg-look # gtk theme configuration
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    ruby_4_0
    spotify
    steam-run
    stremio-linux-shell
    walker
    wget
    wl-clipboard
    unzip
    xxd
    vlc
    zeal
  ];

  # hint electron apps to use Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # enable bashcompletions
  environment.pathsToLink = [ "/share/bash-completion" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
