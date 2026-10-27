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

    #homebrew.onActivation.cleanup = "uninstall";

    darwin =
      { ... }:
      {
        security.sudo.extraConfig = "%staff      ALL = (ALL) ALL";
      };
  };
}
