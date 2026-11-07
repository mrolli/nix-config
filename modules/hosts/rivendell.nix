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
        #homebrew.onActivation.cleanup = "uninstall";
        security.sudo.extraConfig = "%staff      ALL = (ALL) ALL";
      };
  };
}
