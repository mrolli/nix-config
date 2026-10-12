{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  languages = {
    lua.enable = true;
    shell.enable = true;
    nix.enable = true;
  };

  delta.enable = true;

  git-hooks.hooks = {
    shellcheck.enable = true;
    nixfmt.enable = true;
  };
}
