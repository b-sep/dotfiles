{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    keybindings = {
      "ctrl+shift+k" = "resize_window taller";
      "ctrl+shift+j" = "resize_window shorter";
      "ctrl+shift+h" = "resize_window narrower";
      "ctrl+shift+l" = "resize_window wider";
      "ctrl+shift+z" = "toggle_layout stack";
      "ctrl+shift+enter" = "launch --location=hsplit --cwd=current";
      "ctrl+shift+5" = "launch --location=vsplit --cwd=current";
      "ctrl+c" = "copy_or_interrupt";
    };
    font = {
      name = "JetBrainsMonoNL Nerd Font";
      size = 13.5;
    };
    settings = {
      background_opacity = 0.7;
      enabled_layouts = "splits,stack";
    };
  };
}
