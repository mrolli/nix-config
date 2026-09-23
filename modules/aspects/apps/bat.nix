# Create bat/config
# https://nix-community.github.io/home-manager/options/home-manager/programs/bat.html
# https://github.com/sharkdp/bat
{ lib, ... }:
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
