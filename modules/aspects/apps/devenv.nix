# Install and configure devenv using Home Manager
# https://nix-community.github.io/home-manager/options/home-manager/programs/devenv.html
# https://devenv.sh
{ ... }:
let
  systemModule =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.devenv ];
    };

  homeModule =
    { pkgs, ... }:
    {
      # devenv's personal (non-project) settings, read from
      # $XDG_CONFIG_HOME/devenv/config.yaml. A project's own devenv.yaml /
      # devenv.local.yaml still takes precedence over prompt_prefix here.
      xdg.configFile."devenv/config.yaml".text = ''
        # yaml-language-server: $schema=https://devenv.sh/devenv.user.schema.json
        version: 1
        shell:
          # starship already shows a nix_shell indicator, so the extra
          # "(devenv) " prompt prefix devenv adds on top is redundant.
          prompt_prefix: false
        # tui:
        #   theme:
        #     preset: none
        #     palette:
        #       bg: "#282828"
        #       fg: "#928374"
        #       accent: "#d65d0e"
        #     styles:
        #       statusline:
        #         background: bg
        #         foreground: fg
        #       statusline.profiles:
        #         foreground: accent
        #         modifiers: [bold]
        #   statusline:
        #     layouts:
        #       main:
        #         left: [project]
        #         center: []
        #         right: []
      '';
    };
in
{
  den.aspects.devenv = {
    nixos = systemModule;
    darwin = systemModule;
    homeManager = homeModule;
  };
}
