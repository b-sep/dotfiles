{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      parse_git_branch() {
        git branch --show-current 2>/dev/null
      }

      PS1="\[\033[1;32m\][\u@\h:\w]\$(if branch=\$(parse_git_branch); then [ -n \"\$branch\" ] && echo \"\[\033[0;36m\](\$branch)\"; fi)\[\033[1;32m\] \$ \[\033[0m\]"
    '';
    shellAliases = {
      grep = "grep --color='auto'";
      lg = "lazygit";
      ls = "ls --color=auto";
      ncg = "nix-collect-garbage -d";
      oc = "opencode";
    };
  };
}
