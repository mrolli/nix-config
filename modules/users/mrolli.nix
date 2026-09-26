{ den, ... }:
{
  den.aspects.mrolli = {
    includes = [
      den.batteries.host-aspects
      den.batteries.primary-user
      # (den.batteries.user-shell "zsh")

      den.aspects.asciinema
      den.aspects.bat
      den.aspects.direnv
      den.aspects.editorconfig
      den.aspects.environment
      den.aspects.fzf
      den.aspects.glow
      den.aspects.starship
      den.aspects.zsh
    ];
  };
}
