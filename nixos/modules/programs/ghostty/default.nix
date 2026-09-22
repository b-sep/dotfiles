{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
  };

  xdg.configFile."ghostty" = {
    source = ../../../../ghostty;
    recursive = true;
  };
}
