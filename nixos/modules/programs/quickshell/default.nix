{ ... }:

let
  barConfig = ../../../../quickshell;
in

{
  programs.quickshell = {
    activeConfig = "bar";
    configs = {
      bar = barConfig;
    };
    enable = true;
    systemd = {
      enable = true;
    };
  };

  # The config lives in a new store path on every change, which quickshell's
  # file watcher never sees. Referencing it in the unit makes the unit change
  # too, so home-manager restarts the bar on switch.
  systemd.user.services.quickshell.Unit.X-Restart-Triggers = [ "${barConfig}" ];
}
