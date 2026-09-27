# Install and configure yt-dlp
# https://nix-community.github.io/home-manager/options/home-manager/programs/yt-dlp.html
# https://github.com/yt-dlp/yt-dlp#configuration
{ ... }:
{
  den.aspects.yt-dlp.homeManager = {
    programs.yt-dlp = {
      enable = true;
    };
  };
}
