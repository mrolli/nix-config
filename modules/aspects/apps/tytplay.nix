# Deploy tytplay on Darwin with its Nix-managed command dependencies.
#
# Dependencies: fzf, mpv, yt-dlp, viu (optional)
{ lib, ... }:
{
  den.aspects.tytplay.homeManager =
    {
      config,
      pkgs,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      xdg.localBinInPath = true;

      home.packages = with pkgs; [
        curl
        yt-dlp
        viu
      ];

      home.file."${config.xdg.binHome}/tytplay" = {
        source = ../files/scripts/darwin/tytplay;
        executable = true;
      };
    };
}
