# Install and configure ghostty using Home Manager
# https://nix-community.github.io/home-manager/options/home-manager/programs/ghostty.html
# https://ghostty.org/docs/config
{ ... }:
{
  den.aspects.ghostty.homeManager =
    { lib, pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;

        settings = {
          theme = "gruvbox-material-soft-dark";
          font-family = [
            "JetBrains Mono"
            "Nerd Font Symbols Only"
          ];
          font-size = "16";
          mouse-hide-while-typing = "true";
          scrollback-limit = "100000";
          window-save-state = "always";
          macos-titlebar-style = "transparent";
          macos-titlebar-proxy-icon = "hidden";
          # blueprint, chalkboard, microchip, glass, holographic, paper, retro, xray
          macos-icon = "paper";
          unfocused-split-opacity = "0.4";

          keybind = [
            "ctrl+h=goto_split:left"
            "ctrl+j=goto_split:bottom"
            "ctrl+k=goto_split:top"
            "ctrl+l=goto_split:right"

            "ctrl+a>h=new_split:left"
            "ctrl+a>j=new_split:down"
            "ctrl+a>k=new_split:up"
            "ctrl+a>l=new_split:right"
            "ctrl+a>f=toggle_split_zoom"
          ];
        };

        themes = {
          gruvbox-material-soft-dark = {
            background = "#32302f";
            cursor-color = "#d4be98";
            foreground = "#d4be98";
            palette = [
              "0=252423"
              "1=#ea6962"
              "2=#a9b665"
              "3=#d8a657"
              "4=#7daea3"
              "5=#d3869b"
              "6=#89b482"
              "7=#d4be98"
              "8=#32302f"
              "9=#ea6962"
              "10=#a9b665"
              "11=#d8a657"
              "12=#7daea3"
              "13=#d3869b"
              "14=#89b482"
              "15=#d4be98"
            ];
            selection-background = "#45403d";
            selection-foreground = "#d4be98";
          };
          gruvbox-material-medium-dark = {
            background = "#282828";
            cursor-color = "#d4be98";
            foreground = "#d4be98";
            palette = [
              "0=#1b1b1b"
              "1=#ea6962"
              "2=#a9b665"
              "3=#d8a657"
              "4=#7daea3"
              "5=#d3869b"
              "6=#89b482"
              "7=#d4be98"
              "8=#32302f"
              "9=#ea6962"
              "10=#a9b665"
              "11=#d8a657"
              "12=#7daea3"
              "13=#d3869b"
              "14=#89b482"
              "15=#d4be98"
            ];
            selection-background = "#3c3836";
            selection-foreground = "#d4be98";
          };
          gruvbox-material-hard-dark = {
            background = "#1d2021";
            cursor-color = "#d4be98";
            foreground = "#d4be98";
            palette = [
              "0=#141617"
              "1=#ea6962"
              "2=#a9b665"
              "3=#d8a657"
              "4=#7daea3"
              "5=#d3869b"
              "6=#89b482"
              "7=#d4be98"
              "8=#32302f"
              "9=#ea6962"
              "10=#a9b665"
              "11=#d8a657"
              "12=#7daea3"
              "13=#d3869b"
              "14=#89b482"
              "15=#d4be98"
            ];
            selection-background = "#32302f";
            selection-foreground = "#d4be98";
          };
        };
      };
    };
}
