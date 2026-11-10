# Install and configure zoxide
# https://nix-community.github.io/home-manager/options/home-manager/programs/zoxide.html
# https://github.com/ajeetdsouza/zoxide
{ ... }:
{
  den.aspects.zoxide.homeManager = {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
