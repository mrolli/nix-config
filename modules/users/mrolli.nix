{ den, ... }:
{
  den.aspects.mrolli = {
    includes = [
      den.batteries.host-aspects
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")

      den.aspects.asciinema
      den.aspects.bat
      den.aspects.direnv
      den.aspects.editorconfig
      den.aspects.environment
      den.aspects.fzf
      den.aspects.glow
      den.aspects.mpv
      den.aspects.personal-scripts
      den.aspects.starship
      den.aspects.yt-dlp
      den.aspects.zsh
    ];
  };
}
