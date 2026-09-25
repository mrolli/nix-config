# Install and configure bat using Home Manager
# https://nix-community.github.io/home-manager/options/home-manager/programs/bat.html
# https://github.com/sharkdp/bat
{ ... }:
{
  den.aspects.bat.homeManager = {
    programs.bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
      };
    };
  };
}
