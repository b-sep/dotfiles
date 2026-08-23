{ inputs, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["Liberation Serif"];
        sansSerif = ["Liberation Sans"];
        serif = ["Liberation Mono"];
      };
      enable = true;
    };
    packages = with pkgs; [
      font-awesome
      nerd-fonts.adwaita-mono
      nerd-fonts.fira-mono
      nerd-fonts.hack
      nerd-fonts.inconsolata
      nerd-fonts.inconsolata-go
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
      nerd-fonts.overpass
      nerd-fonts.roboto-mono
      nerd-fonts.symbols-only
      nerd-fonts.ubuntu-sans
    ];
  };
}
