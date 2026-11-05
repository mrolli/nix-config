# @doc id=cachix target=docs/apps/cachix.md
# Install Cachix and supply its authentication token through sops-nix.
#
# The `cachix/authToken` secret is inserted into a read-only Dhall config by a
# sops-nix template at activation. The Nix store contains only the placeholder,
# not the token. Since the generated file is managed by sops-nix, do not use
# `cachix authtoken` to update it; edit the encrypted source with `sops` and
# switch instead.
#
# See [Secrets management] for secret rules and the [Cachix documentation] for
# Cachix commands.
#
# [Secrets management]: <../secrets-management.md>
# [Cachix documentation]: <https://docs.cachix.org>
# @enddoc
# Install cachix and render its config with the personal auth token from sops.
# https://docs.cachix.org
# Secret: `cachix/authToken` in secrets/secrets.yaml (see docs/secrets-management.md).
{
  den.aspects.cachix.homeManager =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.cachix ];

      sops.secrets."cachix/authToken" = { };

      # Rendered at activation by sops-nix; the store only holds the template
      # with a placeholder. `cachix authtoken` cannot write to this file.
      sops.templates."cachix.dhall" = {
        path = "${config.xdg.configHome}/cachix/cachix.dhall";
        content = ''
          { authToken = "${config.sops.placeholder."cachix/authToken"}"
          , hostname = "https://cachix.org"
          , binaryCaches = [] : List { name : Text, secretKey : Text }
          }
        '';
      };
    };
}
