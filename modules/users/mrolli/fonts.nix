{ ... }:
{
  den.aspects.mrolli.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.symbols-only
      ];

      fonts.fontconfig.enable = true;
    };
}
