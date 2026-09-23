{ ... }:

{
  programs.quickshell = {
    activeConfig = "bar";
    configs = {
      bar = ../../../../quickshell;
    };
    enable = true;
    systemd = {
      enable = true;
    };
  };
}
