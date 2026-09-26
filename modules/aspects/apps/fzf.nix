# Fuzzy-finder integration (keybindings + completion), replacing the old
# `source <(fzf --zsh)` call; zsh integration is wired automatically when
# programs.zsh.enable is also true.
# https://nix-community.github.io/home-manager/options/home-manager/programs/fzf.html
{ ... }:
{
  den.aspects.fzf.homeManager = {
    programs.fzf.enable = true;
  };
}
