{ den, ... }:
{
  den.aspects.galadriel = {
    includes = [
      den.aspects.base
      den.aspects.darwin-base
      den.aspects.homebrew
      den.aspects.starship
    ];
  };
}
