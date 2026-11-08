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
        homebrew = {
          # Remove packages not managed here
          # onActivation.cleanup = "uninstall";
          casks = [
            "raycast"
          ];
        };

        # Let staff accounts do sudo
        security.sudo.extraConfig = "%staff      ALL = (ALL) ALL";
      };
  };
}
