{ den, ... }:
{
  den.aspects.mrolli = {
    includes = [
      den.batteries.host-aspects
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
    ];
  };
}
