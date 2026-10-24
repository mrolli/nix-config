# Manage Wezterm and its config; see
# https://nix-community.github.io/home-manager/options/home-manager/programs/wezterm.html
# https://wezfurlong.org/wezterm/config/files.html
{ ... }:
{
  den.aspects.wezterm.homeManager = {
    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
    };

    # Completion; the package already wires its own shell-integration
    # script via programs.wezterm.enableZshIntegration (default on).
    # programs.zsh.initContent = ''
    #   eval "$(wezterm shell-completion --shell zsh)"
    # '';
    #
    xdg.configFile = {
      "wezterm/wezterm.lua".source = ./wezterm/wezterm.lua;
      "wezterm/keybindings.lua".source = ./wezterm/keybindings.lua;
      "wezterm/plugins/statusbar.lua".source = ./wezterm/plugins/statusbar.lua;
      "wezterm/plugins/trackinfo.lua".source = ./wezterm/plugins/trackinfo.lua;
      "wezterm/plugins/weather.lua".source = ./wezterm/plugins/weather.lua;
      "wezterm/plugins/musicplaying" = {
        source = ./wezterm/plugins/musicplaying;
        executable = true;
      };
    };
  };
}
