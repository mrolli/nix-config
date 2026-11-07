{ den, ... }:
{
  den.aspects.rivendell = {
    includes = [
      den.aspects.base
      den.aspects.darwin-base
      den.aspects.azure-cli
      den.aspects.devenv
      den.aspects.homebrew
    ];

    darwin =
      { ... }:
      {
        # Let staff accounts do sudo
        security.sudo.extraConfig = "%staff      ALL = (ALL) ALL";

        homebrew = {
          # Remove packages not managed here
          #onActivation.cleanup = "uninstall";
          brews = [
            "id-unibe-ch/tap/bildschirmUniversum"
          ];
          casks = [
            "raycast"
            "windows-app"
          ];
        };
      };
  };
}
