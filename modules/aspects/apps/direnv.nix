# direnv: per-directory environment loading, with the Nix-aware cache
# backend so `use nix`/`use flake` don't reevaluate on every prompt.
# https://nix-community.github.io/home-manager/options/home-manager/programs/direnv.html
{ ... }:
{
  den.aspects.direnv.homeManager = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
  };
}
