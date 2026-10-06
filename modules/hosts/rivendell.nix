{ den, ... }:
{
  den.aspects.rivendell = {
    includes = [
      den.aspects.base
      den.aspects.darwin-base
      den.aspects.devenv
      den.aspects.homebrew
    ];

    darwin =
      { ... }:
      {
        security.sudo.extraConfig = "%staff      ALL = (ALL) ALL";
      };
  };
}
