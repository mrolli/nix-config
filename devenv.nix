{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  languages.nix.enable = true;
  delta.enable = true;
  git-hooks.hooks = {
    shellcheck.enable = true;
    nixfmt.enable = true;
  };
}
