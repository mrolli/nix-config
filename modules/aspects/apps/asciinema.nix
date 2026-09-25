# Install and configure asciinema using Home Manager
# https://nix-community.github.io/home-manager/options/home-manager/programs/asciinema.html
# https://docs.asciinema.org/manual/cli/configuration/v3/
{ lib, ... }:
{
  den.aspects.asciinema.homeManager = {
    programs.asciinema = {
      enable = true;
      settings = {
        session = {
          idle_time_limit = 2;
        };
      };
    };
  };
}
