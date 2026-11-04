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
