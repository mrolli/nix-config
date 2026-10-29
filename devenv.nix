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
    python = {
      enable = true;
      venv.enable = true;
      venv.requirements = ''
        zensical
      '';
    };
  };

  delta.enable = true;

  git-hooks.hooks = {
    aspect-docs = {
      enable = true;
      name = "Check generated aspect documentation";
      entry = "python scripts/generate-aspect-docs.py";
      files = "\\.(nix|md)$";
      pass_filenames = false;
    };
    check-added-large-files.enable = true;
    check-executables-have-shebangs.enable = true;
    check-merge-conflicts.enable = true;
    check-yaml.enable = true;
    detect-private-keys.enable = true;
    nixfmt.enable = true;
    markdownlint.enable = true;
    mixed-line-endings = {
      enable = true;
      args = [
        "--fix=no"
      ];
    };
    shellcheck.enable = true;
    trim-trailing-whitespace = {
      enable = true;
      args = [ "--markdown-linebreak-ext=md" ];
    };
  };
}
