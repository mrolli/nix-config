# Install and configure glow using Home Manager
# https://github.com/charmbracelet/glow
{ ... }:
{
  den.aspects.glow.homeManager =
    { pkgs, ... }:
    let
      yaml = pkgs.formats.yaml { };
    in
    {
      home.packages = [ pkgs.glow ];

      xdg.configFile."glow/glow.yml".source = yaml.generate "glow.yml" {
        style = "auto";
        mouse = false;
        pager = false;
        width = 80;
        all = false;
      };
    };
}
