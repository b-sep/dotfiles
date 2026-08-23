{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      core = { editor = "nvim"; };
      init = { defaultBranch = "main"; };
      merge = { conflictStyle = "zdiff3"; };
      pull = { rebase = false; };
      user = { email = "b.sep@live.com"; name = "Júnior"; };
    };
  };
}
